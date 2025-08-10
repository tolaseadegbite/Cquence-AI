class Song < ApplicationRecord
  attr_accessor :mode, :lyrics_mode

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
      partial: "songs/track_status"
    )
  end

  after_update_commit do
    broadcast_replace_to(
      self.user,
      partial: "songs/track_status"
    )
  end

  def valid_for_generation
    is_simple_mode = full_described_song.present?

    # "Write" mode requires `lyrics` and `prompt`.
    is_custom_write_mode = lyrics.present? && prompt.present?

    # "Auto" mode requires `described_lyrics` and `prompt`.
    is_custom_auto_mode = described_lyrics.present? && prompt.present?

    unless is_simple_mode || is_custom_write_mode || is_custom_auto_mode
      errors.add(:base, "You must provide either a full description, or both lyrics and styles, or a lyric description and styles.")
    end
  end
end
