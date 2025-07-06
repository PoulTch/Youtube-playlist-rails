let apiLoaded = null;

export function loadYouTubeAPI() {
  if (apiLoaded) {
    return apiLoaded;
  }

  apiLoaded = new Promise((resolve) => {
    // Если API уже загружено кем-то другим (например, другим скриптом)
    if (window.YT && window.YT.Player) {
      resolve(window.YT);
      return;
    }

    // Определяем глобальный колбэк, который разрешит наш Promise
    window.onYouTubeIframeAPIReady = () => {
      resolve(window.YT);
    };

    // Загружаем скрипт
    const tag = document.createElement('script');
    tag.src = "https://www.youtube.com/iframe_api";
    const firstScriptTag = document.getElementsByTagName('script')[0];
    firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);
  });

  return apiLoaded;
}
