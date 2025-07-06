namespace :import_videos do
  desc "Import videos from a YouTube playlist"
  task from_playlist: :environment do
    playlist_id = 'PLcQngyvNgfmK0mOFKfVdi2RNiaJTfuL5e'
    
    # Было:
    # YoutubePlaylistImporter.import(playlist_id)

    # Стало:
    puts "Запускаем импорт через фоновую задачу..."
    PlaylistImportJob.perform_now(playlist_id)
    puts "Импорт завершен."
  end
end