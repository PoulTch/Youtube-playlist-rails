class CreateVideos < ActiveRecord::Migration[8.0]
  def change
    create_table :videos do |t|
      t.string :title
      t.string :youtube_id
      t.string :thumbnail_url
      t.integer :position_in_playlist

      t.timestamps
    end
  end
end
