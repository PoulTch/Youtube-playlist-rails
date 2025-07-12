class PlaylistsController < ApplicationController
  before_action :set_playlist, only: [:show, :destroy, :refresh]

  # GET /playlists (Главная страница)
  def index
    @playlists = Playlist.all
    
    # --- ИЗМЕНЕНИЕ ---
    # Явно указываем, что делать с разными типами запросов
    respond_to do |format|
      format.html # Для обычных браузеров
      # Для браузеров со странными заголовками Accept (как Opera)
      # все равно отдаем HTML. Это и есть решение проблемы 406.
      format.any { render 'index', content_type: 'text/html' } 
    end
    # --- КОНЕЦ ИЗМЕНЕНИЯ ---
  end

  # GET /playlists/:id
  def show
    # @playlist уже найден благодаря before_action
    @videos = @playlist.videos.order(:position_in_playlist)

    # --- ИЗМЕНЕНИЕ ---
    # Добавляем такой же блок и сюда, так как эта страница тоже может 
    # открываться напрямую и столкнуться с той же проблемой.
    respond_to do |format|
      format.html
      format.any { render 'show', content_type: 'text/html' }
    end
    # --- КОНЕЦ ИЗМЕНЕНИЯ ---
  end

  # GET /playlists/new
  def new
    @playlist = Playlist.new

    # --- ИЗМЕНЕНИЕ ---
    # И сюда тоже для полноты картины
    respond_to do |format|
      format.html
      format.any { render 'new', content_type: 'text/html' }
    end
    # --- КОНЕЦ ИЗМЕНЕНИЯ ---
  end

  # POST /playlists
  def create
    processed_params = playlist_params
    url_or_id = processed_params[:youtube_id]

    if url_or_id.is_a?(String)
      match = url_or_id.match(/list=([a-zA-Z0-9_-]+)/)
      if match
        processed_params[:youtube_id] = match[1]
      end
    end
    
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
    @playlist.destroy
    redirect_to playlists_url, notice: "Плейлист был успешно удален."
  end

  # POST /playlists/:id/refresh
  def refresh
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