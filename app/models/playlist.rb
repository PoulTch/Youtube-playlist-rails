class Playlist < ApplicationRecord
  has_many :videos, dependent: :destroy # Если мы удалим плейлист, все его видео тоже удалятся

  validates :title, presence: true
  validates :youtube_id, presence: true, uniqueness: true
end
