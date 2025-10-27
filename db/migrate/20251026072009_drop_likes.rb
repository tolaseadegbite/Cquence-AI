class DropLikes < ActiveRecord::Migration[8.0]
  def change
    drop_table :likes
  end
end
