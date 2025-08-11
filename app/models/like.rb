class Like < ApplicationRecord
  belongs_to :user, counter_cache: true
  belongs_to :song, counter_cache: true

  validates :user_id, uniqueness: { scope: :song_id }
end
