class Category < ApplicationRecord
  validates :name, presence: true
  validates :name, uniqueness: { case_sensitive: false }

  has_many :song_categories, dependent: :destroy
  has_many :songs, through: :song_categories
end
