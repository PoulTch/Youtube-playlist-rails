class AddPlaylistToVideos < ActiveRecord::Migration[8.0]
  def change
    add_reference :videos, :playlist, null: false, foreign_key: true
  end
end
