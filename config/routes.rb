Rails.application.routes.draw do

  # Эта строка подключает веб-интерфейс (дашборд) GoodJob по адресу /goodjob
  mount GoodJob::Engine => 'goodjob'

  # Создает все стандартные маршруты: /playlists, /playlists/new, /playlists/:id и т.д.
  resources :playlists do
    # Создает вложенный маршрут для кнопки "Refresh"
    # -> POST /playlists/:id/refresh
    member do
      post :refresh
    end
  end

  # Делаем главной страницей список всех плейлистов
  root "playlists#index"
end