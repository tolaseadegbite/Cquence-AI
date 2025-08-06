class CreateSongCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :song_categories do |t|
      t.references :song, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
