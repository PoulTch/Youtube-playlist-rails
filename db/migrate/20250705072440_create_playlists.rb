class CreatePlaylists < ActiveRecord::Migration[8.0]
  def change
    create_table :playlists do |t|
      t.string :title
      t.string :youtube_id

      t.timestamps
    end
    add_index :playlists, :youtube_id, unique: true
  end
end
