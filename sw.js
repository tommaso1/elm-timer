var CACHE_NAME = 'cache-v1';
var urlsToCache = [
  '/',
  '/main.css',
  '/main.js',
  '/when.mp3'
];

self.addEventListener('install', function(event) {
    console.log('Service worker -> Install');
  // Perform install steps
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(function(cache) {
        console.log('Service worker -> Opened cache');
        return cache.addAll(urlsToCache);
      })
  );
});

self.addEventListener('fetch', function(event) {
  event.respondWith(
    caches.match(event.request)
      .then(function(response) {
        console.log('Service worker -> Cache hit');
        // Cache hit - return response
        if (response) {
            return response;
        }

        return fetch(event.request).then(
          function(response) {
          // Check if we received a valid response
          if(!response || response.status !== 200 || response.type !== 'basic') {
              return response;
          }

          var responseToCache = response.clone();

          caches.open(CACHE_NAME)
              .then(function(cache) {
              cache.put(event.request, responseToCache);
              });

          console.log('Service worker -> Cache storing value');

          return response;
          }
        );
      })
    );
  });
  