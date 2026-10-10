const C='planora-v31-onboarding-motion-20261010';
const ASSETS=['./','./index.html','./manifest.json','./icon.svg','./icon-192.png','./icon-512.png','./icon-512-maskable.png'];
self.addEventListener('install',e=>{self.skipWaiting();e.waitUntil(caches.open(C).then(c=>c.addAll(ASSETS)))});
self.addEventListener('activate',e=>{e.waitUntil(caches.keys().then(k=>Promise.all(k.filter(x=>x!==C).map(x=>caches.delete(x)))).then(()=>self.clients.claim()))});
self.addEventListener('fetch',e=>{if(e.request.method!=='GET'||new URL(e.request.url).origin!==self.location.origin)return; e.respondWith(fetch(e.request,{cache:'no-store'}).then(r=>{if(r.ok){const x=r.clone();caches.open(C).then(c=>c.put(e.request,x)).catch(()=>{});}return r}).catch(()=>caches.match(e.request)))})
