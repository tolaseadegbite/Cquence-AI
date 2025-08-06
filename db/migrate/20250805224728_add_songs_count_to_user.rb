class AddSongsCountToUser < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :songs_count, :integer, default: 0
  end
end
