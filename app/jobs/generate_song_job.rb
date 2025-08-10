class GenerateSongJob < ApplicationJob
  queue_as :song_generation

  limits_concurrency to: 1, key: ->(song) { song.user_id }, duration: 10.minutes

  rescue_from(StandardError) do |exception|
    song = arguments.first
    song&.failed!
    Rails.logger.error "GenerateSongJob failed for song #{song&.id}: #{exception.message}"
  end

  def perform(song)
    user = song.user

    song.processing!

    # === Step 1: Check Credits ===
    unless user.credits > 0
      song.no_credits!
      return # Stop execution if no credits.
    end

    # === Step 2: Build the request for the external service ===
    endpoint, body = build_request_payload(song)

    # === Step 3: Call external API ===
    response = ModalApiClient.generate(endpoint, body)

    # === Step 4: Update song based on response ===
    if response.is_a?(Net::HTTPSuccess)
      response_data = JSON.parse(response.body).deep_symbolize_keys
      process_successful_response(song, response_data)
      deduct_credit(user)
    else
      # If the API call fails, raise an exception to trigger the `rescue_from` block.
      raise "Modal API failed with status #{response.code}: #{response.body}"
    end
  end

  private

  def build_request_payload(song)
    common_params = {
      guidance_scale: song.guidance_scale,
      infer_step: song.infer_step,
      audio_duration: song.audio_duration,
      seed: song.seed,
      instrumental: song.instrumental
    }.compact

    body = {}
    endpoint = ""
    creds = Rails.application.credentials.modal

    if song.full_described_song.present?
      endpoint = creds.generate_from_description_endpoint
      body = { full_described_song: song.full_described_song, **common_params }
    elsif song.lyrics.present? && song.prompt.present?
      endpoint = creds.generate_with_lyrics_endpoint
      body = { lyrics: song.lyrics, prompt: song.prompt, **common_params }
    elsif song.described_lyrics.present? && song.prompt.present?
      endpoint = creds.generate_from_described_lyrics_endpoint
      body = { described_lyrics: song.described_lyrics, prompt: song.prompt, **common_params }
    else
      raise "Invalid song parameters for generation. Song ID: #{song.id}"
    end

    [ endpoint, body ]
  end

  def process_successful_response(song, data)
    song.transaction do
      song.update!(
        s3_key: data[:s3_key],
        thumbnail_s3_key: data[:cover_image_s3_key],
        status: :processed
      )

      if data[:categories].present?
        normalized_names = data[:categories].map { |name| name.to_s.strip.downcase }
        valid_category_names = normalized_names.select(&:present?).uniq

        # THIS IS THE FIX: A robust, case-insensitive find_or_create_by
        categories = valid_category_names.map do |name|
          Category.where("LOWER(name) = ?", name).first_or_create!(name: name)
        end

        song.categories = categories
      end
    end
  end

  def deduct_credit(user)
    user.decrement!(:credits)
  end
end
