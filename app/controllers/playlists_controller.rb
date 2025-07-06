class PlaylistsController < ApplicationController
  before_action :set_playlist, only: [:show, :destroy, :refresh]

  # GET /playlists (Главная страница)
  def index
    @playlists = Playlist.all
  end

  # GET /playlists/:id
  def show
    # @playlist уже найден благодаря before_action
    @videos = @playlist.videos.order(:position_in_playlist)
  end

  # GET /playlists/new
  def new
    @playlist = Playlist.new
  end

  # POST /playlists
  def create
    # Получаем параметры как обычно
    processed_params = playlist_params
    url_or_id = processed_params[:youtube_id]

    # Проверяем, есть ли что-то в поле и является ли это строкой
    if url_or_id.is_a?(String)
      # Пытаемся извлечь ID из URL с помощью регулярного выражения
      # Ищем в строке "list=" и забираем все, что идет после этого до символа "&" или до конца строки
      match = url_or_id.match(/list=([a-zA-Z0-9_-]+)/)

      # Если мы нашли совпадение, заменяем полную ссылку на чистый ID
      if match
        processed_params[:youtube_id] = match[1]
      end
    end
    
    # Создаем плейлист уже с обработанными параметрами
    @playlist = Playlist.new(processed_params)

    if @playlist.save
      PlaylistImportJob.perform_later(@playlist.id)
      redirect_to @playlist, notice: "Плейлист успешно добавлен и поставлен в очередь на импорт."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # DELETE /playlists/:id
  def destroy
    # @playlist уже найден
    @playlist.destroy
    redirect_to playlists_url, notice: "Плейлист был успешно удален."
  end

  # POST /playlists/:id/refresh
  def refresh
    # @playlist уже найден
    PlaylistImportJob.perform_later(@playlist.id)
    redirect_to @playlist, notice: "Обновление плейлиста запущено в фоновом режиме!"
  end

  private

  def set_playlist
    @playlist = Playlist.find(params[:id])
  end

  def playlist_params
    params.require(:playlist).permit(:title, :youtube_id)
  end
end