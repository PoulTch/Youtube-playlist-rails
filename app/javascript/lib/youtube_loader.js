let apiPromise = null;

// Эта функция будет вызвана глобально самим скриптом YouTube, когда он загрузится.
// Важно, чтобы она была в глобальной области видимости, поэтому 'window.'
window.onYouTubeIframeAPIReady = () => {
  // Напрямую присваиваем результат (объект YT) нашему промису для всех, кто его ждет.
  // Это самый надежный способ, но требует, чтобы промис уже был создан.
  // В нашем коде ниже это так.
};

export function loadYouTubeAPI() {
  // Если уже пытались загрузить, просто возвращаем тот же промис.
  // Это предотвращает повторную загрузку скрипта.
  if (apiPromise) {
    return apiPromise;
  }

  apiPromise = new Promise((resolve) => {
    // Проверяем, может API уже загружено (например, другим скриптом или из кэша)
    if (window.YT && window.YT.Player) {
      console.log("YouTube API was already loaded.");
      resolve(window.YT);
      return;
    }
    
    // Переопределяем колбэк, чтобы он вызывал resolve нашего текущего промиса.
    // Это гарантирует, что даже если скрипт загрузится мгновенно, мы поймаем событие.
    window.onYouTubeIframeAPIReady = () => {
      console.log("onYouTubeIframeAPIReady fired, resolving promise.");
      resolve(window.YT);
    };

    // Если скрипта еще нет на странице, добавляем его.
    if (!document.querySelector('script[src="https://www.youtube.com/iframe_api"]')) {
      console.log("YouTube API script not found, creating and appending it.");
      const script = document.createElement('script');
      script.src = "https://www.youtube.com/iframe_api";
      // Вставляем наш скрипт перед первым найденным тегом <script> на странице.
      document.head.appendChild(script);
    } else {
      // Если скрипт уже есть, но YT объект еще не готов,
      // мы просто ждем, пока onYouTubeIframeAPIReady будет вызван.
      console.log("YouTube API script tag found, waiting for it to load.");
    }
  });

  return apiPromise;
}