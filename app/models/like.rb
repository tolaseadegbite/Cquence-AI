class Like < ApplicationRecord
  belongs_to :user, counter_cache: :likes_count
  belongs_to :song, counter_cache: :likes_count

  validates :user_id, uniqueness: { scope: :song_id }
end
