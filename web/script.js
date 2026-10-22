const menuButton=document.querySelector('.menu-toggle');const menu=document.querySelector('#menu');
menuButton.addEventListener('click',()=>{const open=menu.classList.toggle('open');menuButton.setAttribute('aria-expanded',String(open));});
menu.querySelectorAll('a').forEach(link=>link.addEventListener('click',()=>{menu.classList.remove('open');menuButton.setAttribute('aria-expanded','false');}));

const slides=[...document.querySelectorAll('.slide')];const current=document.querySelector('#current');let active=0;
function showSlide(index){slides[active].hidden=true;slides[active].classList.remove('active');active=(index+slides.length)%slides.length;slides[active].hidden=false;slides[active].classList.add('active');current.textContent=String(active+1).padStart(2,'0');}
document.querySelector('#next').addEventListener('click',()=>showSlide(active+1));document.querySelector('#prev').addEventListener('click',()=>showSlide(active-1));

const geoButton=document.querySelector('#geo-button');const geoStatus=document.querySelector('#geo-status');
geoButton.addEventListener('click',()=>{if(!('geolocation' in navigator)){geoStatus.textContent='Tu navegador no permite usar la geolocalización.';return;}geoStatus.textContent='Obteniendo tu ubicación…';geoButton.disabled=true;navigator.geolocation.getCurrentPosition(({coords})=>{const lat=coords.latitude.toFixed(5);const lon=coords.longitude.toFixed(5);geoStatus.innerHTML=`Ubicación obtenida. <a href="https://www.openstreetmap.org/?mlat=${lat}&mlon=${lon}#map=15/${lat}/${lon}" target="_blank" rel="noopener">Abrir en OpenStreetMap</a>.`;geoButton.disabled=false;},()=>{geoStatus.textContent='No se pudo acceder a tu ubicación. Revisa los permisos del navegador.';geoButton.disabled=false;},{enableHighAccuracy:false,timeout:8000,maximumAge:300000});});

document.querySelector('#contact-form').addEventListener('submit',event=>{event.preventDefault();document.querySelector('#form-status').textContent='Demostración: el formulario está preparado, pero no envía datos.';});
