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

  def valid_for_generation
    # The song is valid if it matches any of the three conditions checked by the job.
    is_simple_mode = full_described_song.present?
    is_custom_write_mode = lyrics.present? && prompt.present?
    is_custom_auto_mode = described_lyrics.present? && prompt.present?

    # If none of the conditions are met, add an error to the model.
    unless is_simple_mode || is_custom_write_mode || is_custom_auto_mode
      errors.add(:base, "Song must have a description, or a prompt with lyrics/described lyrics.")
    end
  end
end
