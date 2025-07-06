import { Controller } from "@hotwired/stimulus"
import { loadYouTubeAPI } from "lib/youtube_loader"

const LAST_PLAYED_VIDEO_ID_KEY = 'playlist_last_played_video_id';

export default class extends Controller {
  static targets = [ "player", "videoItem", "publishedAt" ]

  connect() {
    console.log("Playlist Controller CONNECTED. Initializing...");
    this.playerReady = false;
    this.player = null;
    this.playbackInterval = null;

    loadYouTubeAPI().then(YT => {
      console.log("YouTube IFrame API is ready.");
      this.YT = YT; // Сохраняем YT для доступа в других методах
      this.initializePlayer();
    });
  }

  disconnect() {
    this.stopTrackingPlayback();
    if (this.player && typeof this.player.destroy === 'function') {
      this.player.destroy();
    }
  }

  initializePlayer() {
    const lastPlayedVideoId = localStorage.getItem(LAST_PLAYED_VIDEO_ID_KEY);
    let initialVideoElement;

    if (lastPlayedVideoId) {
      initialVideoElement = this.videoItemTargets.find(
        item => item.dataset.videoId === lastPlayedVideoId
      );
    }
    
    if (!initialVideoElement) {
      initialVideoElement = this.videoItemTargets[0];
    }

    if (!initialVideoElement) {
      console.log("No video items found, aborting initialization.");
      return;
    }

    // Прокручиваем список к найденному элементу
    initialVideoElement.scrollIntoView({
      block: 'center',
      behavior: 'auto' // 'auto' для мгновенной прокрутки при загрузке
    });

    const initialVideoId = initialVideoElement.dataset.videoId;
    const initialVideoPublishedAt = initialVideoElement.dataset.publishedAt;
    
    if (!initialVideoId) {
      console.error("The chosen initial video element is missing data-video-id attribute.");
      return;
    }

    this.setActiveVideo(initialVideoId);
    const savedTime = localStorage.getItem(initialVideoId) || 0;

    this.player = new this.YT.Player(this.playerTarget, {
      // height и width УБРАНЫ, теперь они управляются через CSS
      videoId: initialVideoId,
      playerVars: { 'playsinline': 1 },
      events: {
        'onReady': (event) => this.onPlayerReady(event, savedTime, initialVideoPublishedAt),
        'onStateChange': (event) => this.onPlayerStateChange(event)
      }
    });
  }

  onPlayerReady(event, startTime, publishedAt) {
    this.playerReady = true;
    event.target.seekTo(startTime);
    if (publishedAt && this.hasPublishedAtTarget) {
      this.publishedAtTarget.innerText = publishedAt;
    }
  }

  selectVideo(event) {
    event.preventDefault();
    if (!this.playerReady) {
      console.warn("Player not ready, cannot select video.");
      return;
    }

    const videoElement = event.currentTarget;
    const videoId = videoElement.dataset.videoId;
    const publishedAt = videoElement.dataset.publishedAt;
    const savedTime = localStorage.getItem(videoId) || 0;
    
    this.setActiveVideo(videoId);

    this.player.loadVideoById({
      videoId: videoId,
      startSeconds: parseFloat(savedTime)
    });

    if (publishedAt && this.hasPublishedAtTarget) {
      this.publishedAtTarget.innerText = publishedAt;
    }
  }

  onPlayerStateChange(event) {
    if (event.data === this.YT.PlayerState.PLAYING) {
      this.startTrackingPlayback();
    } else {
      this.stopTrackingPlayback();
    }
  }

  startTrackingPlayback() {
    this.stopTrackingPlayback();

    this.playbackInterval = setInterval(() => {
      if (this.player && typeof this.player.getPlayerState === 'function' && this.player.getPlayerState() === this.YT.PlayerState.PLAYING) {
        const videoId = this.player.getVideoData()['video_id'];
        const currentTime = this.player.getCurrentTime();
        if (videoId && currentTime > 0) {
          localStorage.setItem(videoId, currentTime);
          localStorage.setItem(LAST_PLAYED_VIDEO_ID_KEY, videoId);
        }
      }
    }, 5000);
  }

  stopTrackingPlayback() {
    if (this.playbackInterval) {
      clearInterval(this.playbackInterval);
      this.playbackInterval = null;
    }
  }

  setActiveVideo(videoId) {
    this.videoItemTargets.forEach(item => {
      item.classList.toggle('is-active', item.dataset.videoId === videoId);
    });
  }

  // --- ДОБАВЬ ЭТОТ МЕТОД ---
  disableButton(event) {
    // Находим кнопку внутри формы, которая вызвала событие
    const button = event.target.querySelector('button');
    
    // Меняем ее состояние
    button.disabled = true;
    button.innerText = 'Обновление...';
  }
}