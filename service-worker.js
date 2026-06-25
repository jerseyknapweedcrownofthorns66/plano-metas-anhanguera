// Service Worker do Plano de Metas — Polo Anhanguera Campo Grande/RJ
// Função: permitir instalação como app (PWA) e abrir rápido (cache do "casco" visual).
// Os DADOS (colaboradores, apurações, login) sempre vêm do Supabase pela rede —
// este cache nunca guarda informação sensível, só os arquivos estáticos do app.

const CACHE_NAME = 'plano-metas-v1';
const ASSETS_TO_CACHE = [
  './index.html',
  './manifest.json',
  './supabase.js',
  './icon-192.png',
  './icon-512.png'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(ASSETS_TO_CACHE))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE_NAME).map((k) => caches.delete(k)))
    )
  );
  self.clients.claim();
});

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);

  // Nunca cacheia chamadas ao Supabase (sempre precisam ser pedidos de rede frescos)
  if (url.hostname.includes('supabase.co')) {
    return;
  }

  // Para os arquivos do próprio app: tenta rede primeiro, cai pro cache se offline
  event.respondWith(
    fetch(event.request)
      .then((response) => {
        const copy = response.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copy));
        return response;
      })
      .catch(() => caches.match(event.request))
  );
});
