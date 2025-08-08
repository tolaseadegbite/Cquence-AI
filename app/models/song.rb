class Song < ApplicationRecord
  validates :title, presence: true, length: { maximum: 100 }
  validate :valid_for_generation, on: :create

  belongs_to :user, counter_cache: :songs_count

  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :song_categories, dependent: :destroy
  has_many :categories, through: :song_categories

  enum :status, {
    pending: 0,
    processing: 1,
    processed: 2,
    failed: 3,
    no_credits: 4
  }

  after_create_commit do
    broadcast_prepend_to(
      self.user,
      target: "track_list",
      partial: "songs/track_status" # <-- FIX: Use new partial name
    )
  end

  after_update_commit do
    broadcast_replace_to(
      self.user,
      partial: "songs/track_status" # <-- FIX: Use new partial name
    )
  end

  def valid_for_generation
    # The song is valid if it matches any of the three conditions checked by the job.
    is_simple_mode = full_described_song.present?
    is_custom_write_mode = lyrics.present? && prompt.present?
    is_custom_auto_mode = described_lyrics.present? && prompt.present?

    # If none of the conditions are met, add an error to the model.
    unless is_simple_mode || is_custom_write_mode || is_custom_auto_mode
      errors.add(:base, "Song must have a description, style tags with description or lyrics with style tags.")
    end
  end

  def self.new_from_params_and_user(params, user)
    mode = params.fetch(:mode)
    lyrics_mode = params.fetch(:lyrics_mode)

    # We can use 'params' directly here, no need for another 'slice'.
    attributes = build_song_attributes(params, mode, lyrics_mode)
    title = generate_title_from_params(params, mode, lyrics_mode)

    user.songs.new(attributes.merge(title: title, status: :pending))
  end

  private_class_method

  def self.build_song_attributes(params, mode, lyrics_mode)
    if mode == "simple"
      params.slice(:full_described_song, :instrumental)
    else # Custom mode
      if lyrics_mode == "write"
        params.slice(:prompt, :lyrics, :instrumental)
      else # Auto-lyrics mode
        params.slice(:prompt, :instrumental).merge(described_lyrics: params[:lyrics])
      end
    end
  end

  def self.generate_title_from_params(params, mode, lyrics_mode)
    source_text = "Untitled Song"

    if mode == "simple" && params[:full_described_song].present?
      source_text = params[:full_described_song]
    elsif mode == "custom" && lyrics_mode == "auto" && params[:lyrics].present?
      source_text = params[:lyrics]
    elsif mode == "custom" && params[:prompt].present?
      source_text = params[:prompt]
    end

    source_text.truncate(100).capitalize
  end
end
