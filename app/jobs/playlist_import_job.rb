class PlaylistImportJob < ApplicationJob
  queue_as :default

  def perform(playlist_record_id)
    playlist = Playlist.find_by(id: playlist_record_id)
    unless playlist
      puts "Ошибка: Плейлист с ID ##{playlist_record_id} не найден в базе."
      return
    end

    youtube_playlist_id = playlist.youtube_id
    require 'httparty'
    api_key = Rails.application.credentials.youtube_api_key

    if api_key.blank?
      puts "Ошибка: YOUTUBE_API_KEY не найден в credentials."
      return
    end

    puts "Шаг 1: Получение актуальных ID видео с YouTube для плейлиста '#{playlist.title}'..."
    youtube_video_ids = []
    page_token = nil
    base_url = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&maxResults=50&playlistId=#{youtube_playlist_id}&key=#{api_key}"

    loop do
      url = page_token.present? ? "#{base_url}&pageToken=#{page_token}" : base_url
      response = HTTParty.get(url)

      unless response.code == 200
        puts "Ошибка при запросе к YouTube API: #{response.body}"
        return
      end

      data = JSON.parse(response.body)
      
      data['items'].each do |item|
        snippet = item['snippet']
        video_id = snippet.dig('resourceId', 'videoId')
        next unless video_id

        youtube_video_ids << video_id

        video = playlist.videos.find_or_initialize_by(youtube_id: video_id)
        video.update(
          title: snippet['title'],
          thumbnail_url: snippet['thumbnails']['high']['url'],
          published_at: snippet['publishedAt'],
          position_in_playlist: snippet['position']
        )
      end

      page_token = data['nextPageToken']
      break if page_token.blank?
    end
    puts "Загружено #{youtube_video_ids.count} актуальных видео. Начинаем синхронизацию..."

    local_video_ids = playlist.videos.pluck(:youtube_id)
    ids_to_delete = local_video_ids - youtube_video_ids

    if ids_to_delete.any?
      puts "Шаг 2: Найдено #{ids_to_delete.count} удаленных видео. Очистка..."
      playlist.videos.where(youtube_id: ids_to_delete).destroy_all
    else
      puts "Шаг 2: Удаленных видео не найдено. База данных актуальна."
    end

    puts "Импорт и синхронизация для плейлиста '#{playlist.title}' завершены."
  end
end