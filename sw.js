const CACHE = 'gachafood-v1';
const BASE = '/eat-what-gacha';
const ASSETS = [
  BASE + '/',
  BASE + '/index.html',
  BASE + '/map.svg',
  BASE + '/manifest.json',
  BASE + '/compressed-assets/MACHINE.png',
  BASE + '/compressed-assets/HOTPOT.png',
  BASE + '/compressed-assets/BBQ.png',
  BASE + '/compressed-assets/SKEWER.png',
  BASE + '/compressed-assets/SUSHI.png',
  BASE + '/compressed-assets/PIZZA.png',
  BASE + '/compressed-assets/KOREAN.png',
  BASE + '/compressed-assets/WESTERN.png',
  BASE + '/compressed-assets/CHINESE.png',
  BASE + '/compressed-assets/BUFFET.png',
  BASE + '/compressed-assets/23ZUO.png',
  BASE + '/compressed-assets/HUDA_FANGUAN.png',
  BASE + '/compressed-assets/TIEBAN_CHUFANG.png',
  BASE + '/compressed-assets/FUSAN_XIAOHONGMAO.png',
  BASE + '/compressed-assets/KAOJIANG.png',
  BASE + '/compressed-assets/JINGUYUAN.png',
  BASE + '/compressed-assets/LIUZHOU_LUOSIFEN.png',
  BASE + '/compressed-assets/NANQUAN_SHISANYI.png',
  BASE + '/compressed-assets/MOXIAOLU_GUILIN_MIFEN.png',
  BASE + '/compressed-assets/YEGUANGUAN_MIXIAN.png',
  BASE + '/compressed-assets/MCDONALDS.png',
  BASE + '/compressed-assets/KFC.png'
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
