class Song < ApplicationRecord
  belongs_to :user, dependent: :destroy, counter_cache: :songs_count

  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user
  has_many :song_categories, dependent: :destroy
  has_many :categories, through: :song_categories

  enum status: {
    pending: 0,
    processing: 1,
    processed: 2,
    failed: 3,
    no_credits: 4
  }
end
