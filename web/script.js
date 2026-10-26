const menuButton=document.querySelector('.menu-toggle');const menu=document.querySelector('#menu');
menuButton.addEventListener('click',()=>{const open=menu.classList.toggle('open');menuButton.setAttribute('aria-expanded',String(open));});
menu.querySelectorAll('a').forEach(link=>link.addEventListener('click',()=>{menu.classList.remove('open');menuButton.setAttribute('aria-expanded','false');}));

const slides=[...document.querySelectorAll('.slide')];const current=document.querySelector('#current');let active=0;
function showSlide(index){slides[active].hidden=true;slides[active].classList.remove('active');active=(index+slides.length)%slides.length;slides[active].hidden=false;slides[active].classList.add('active');current.textContent=String(active+1).padStart(2,'0');}
document.querySelector('#next').addEventListener('click',()=>showSlide(active+1));document.querySelector('#prev').addEventListener('click',()=>showSlide(active-1));

// Ubicación del local (la misma que el marcador del mapa) y distancia en línea recta (fórmula del haversine)
const LOCAL={lat:43.263,lon:-2.935};
function distanciaKm(lat1,lon1,lat2,lon2){const rad=g=>g*Math.PI/180;const dLat=rad(lat2-lat1);const dLon=rad(lon2-lon1);const a=Math.sin(dLat/2)**2+Math.cos(rad(lat1))*Math.cos(rad(lat2))*Math.sin(dLon/2)**2;return 6371*2*Math.atan2(Math.sqrt(a),Math.sqrt(1-a));}
const geoButton=document.querySelector('#geo-button');const geoStatus=document.querySelector('#geo-status');
geoButton.addEventListener('click',()=>{if(!('geolocation' in navigator)){geoStatus.textContent='Tu navegador no permite usar la geolocalización.';return;}geoStatus.textContent='Obteniendo tu ubicación…';geoButton.disabled=true;navigator.geolocation.getCurrentPosition(({coords})=>{const lat=coords.latitude.toFixed(5);const lon=coords.longitude.toFixed(5);const km=distanciaKm(coords.latitude,coords.longitude,LOCAL.lat,LOCAL.lon);const distancia=km<1?`${Math.round(km*1000)} m`:`${km.toFixed(1).replace('.',',')} km`;geoStatus.innerHTML=`Estás a unos <strong>${distancia}</strong> del restaurante (en línea recta). <a href="https://www.openstreetmap.org/directions?engine=fossgis_osrm_foot&amp;route=${lat}%2C${lon}%3B${LOCAL.lat}%2C${LOCAL.lon}" target="_blank" rel="noopener">Ver la ruta a pie en OpenStreetMap</a>.`;geoButton.disabled=false;},()=>{geoStatus.textContent='No se pudo acceder a tu ubicación. Revisa los permisos del navegador.';geoButton.disabled=false;},{enableHighAccuracy:false,timeout:8000,maximumAge:300000});});

// El mapa de OpenStreetMap pesa más de 1 MB: se carga solo cuando se pide (sin JavaScript, el enlace abre OpenStreetMap)
const mapLoad=document.querySelector('#map-load');
mapLoad.addEventListener('click',event=>{event.preventDefault();const map=document.createElement('iframe');map.title='Mapa de la zona de Bilbao donde se encuentra Almi Chain';map.src=mapLoad.dataset.src;map.referrerPolicy='no-referrer-when-downgrade';mapLoad.replaceWith(map);map.focus();});

document.querySelector('#contact-form').addEventListener('submit',event=>{event.preventDefault();document.querySelector('#form-status').textContent='Demostración: el formulario está preparado, pero no envía datos.';});
