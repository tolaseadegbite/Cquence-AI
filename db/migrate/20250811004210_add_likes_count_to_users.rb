class AddLikesCountToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :likes_count, :integer, default: 0
  end
end
