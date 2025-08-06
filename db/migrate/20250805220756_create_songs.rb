class CreateSongs < ActiveRecord::Migration[8.0]
  def change
    create_table :songs do |t|
      t.string :title
      t.string :s3_key
      t.string :thumbnail_s3_key
      t.integer :status, default: 0
      t.boolean :instrumental, default: false
      t.text :prompt
      t.text :lyrics
      t.text :full_described_song
      t.text :described_lyrics
      t.float :guidance_scale
      t.float :infer_step
      t.float :audio_duration
      t.float :seed
      t.boolean :published, default: false
      t.integer :listen_count, default: 0
      t.integer :likes_count, default: 0

      t.timestamps
    end
  end
end
