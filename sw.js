const CACHE = 'gachafood-v1';
const ASSETS = [
  '/',
  '/index.html',
  '/map.svg',
  '/manifest.json',
  '/compressed-assets/MACHINE.png',
  '/compressed-assets/HOTPOT.png',
  '/compressed-assets/BBQ.png',
  '/compressed-assets/SKEWER.png',
  '/compressed-assets/SUSHI.png',
  '/compressed-assets/PIZZA.png',
  '/compressed-assets/KOREAN.png',
  '/compressed-assets/WESTERN.png',
  '/compressed-assets/CHINESE.png',
  '/compressed-assets/BUFFET.png',
  '/compressed-assets/23ZUO.png',
  '/compressed-assets/HUDA_FANGUAN.png',
  '/compressed-assets/TIEBAN_CHUFANG.png',
  '/compressed-assets/FUSAN_XIAOHONGMAO.png',
  '/compressed-assets/KAOJIANG.png',
  '/compressed-assets/JINGUYUAN.png',
  '/compressed-assets/LIUZHOU_LUOSIFEN.png',
  '/compressed-assets/NANQUAN_SHISANYI.png',
  '/compressed-assets/MOXIAOLU_GUILIN_MIFEN.png',
  '/compressed-assets/YEGUANGUAN_MIXIAN.png',
  '/compressed-assets/MCDONALDS.png',
  '/compressed-assets/KFC.png'
];

self.addEventListener('install', e => {
  e.waitUntil(caches.open(CACHE).then(c => c.addAll(ASSETS)));
  self.skipWaiting();
});

self.addEventListener('activate', e => {
  e.waitUntil(caches.keys().then(keys =>
    Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k)))
  ));
  self.clients.claim();
});

self.addEventListener('fetch', e => {
  e.respondWith(
    caches.match(e.request).then(cached => cached || fetch(e.request))
  );
});
