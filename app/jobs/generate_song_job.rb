# app/jobs/generate_song_job.rb
class GenerateSongJob < ApplicationJob
  # This correctly assigns the job to the dedicated queue.
  queue_as :song_generation

  # === CORRECT CONCURRENCY CONTROL (From the Official Docs) ===
  # This uses Solid Queue's built-in concurrency controls to ensure that
  # only one job with the same key (the user's ID) is running at a time.
  limits_concurrency to: 1, key: ->(song) { song.user_id }, duration: 10.minutes

  # This block will handle any unexpected error during the job's execution,
  # marking the song as 'failed' so the user gets feedback.
  rescue_from(StandardError) do |exception|
    song = arguments.first
    song&.failed!
    Rails.logger.error "GenerateSongJob failed for song #{song&.id}: #{exception.message}"
  end

  def perform(song)
    user = song.user

    # The concurrency check is now handled automatically by Solid Queue before `perform` is called.
    # We can immediately set the status to processing.
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
        categories = data[:categories].map do |category_name|
          Category.find_or_create_by!(name: category_name)
        end
        song.categories = categories
      end
    end
  end

  def deduct_credit(user)
    user.decrement!(:credits)
  end
end
