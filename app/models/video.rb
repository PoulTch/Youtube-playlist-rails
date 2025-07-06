class Video < ApplicationRecord
    belongs_to :playlist # Каждое видео принадлежит плейлисту
end
