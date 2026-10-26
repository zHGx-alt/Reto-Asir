# Tarea 27: Wireframes y diseño conceptual de la web

- **Bloque:** 6 Web
- **Responsable:** Peio
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** hecha
- **Fecha:** 23/10/2026

## 1. Alcance

Wireframes de baja fidelidad de la web del restaurante (tarea 28) en escritorio y en móvil, con la estructura de cada sección y su comportamiento adaptable (*responsive*).

La web se implementó antes que los wireframes. Por eso los wireframes se han sacado de la web ya hecha (`web/index.html` y `web/style.css`): reflejan la estructura real y sirven de referencia para las tareas que siguen (validación, tarea 29, y hosting, tareas 30 y 31).

> [!NOTE]
> **Orden de las tareas.** El enunciado pone el «diseño conceptual» antes de la implementación, y aquí se hizo al revés: los wireframes son posteriores a la web. Se reconoce así en la defensa. Lo que sí se decidió antes de programar está en el apartado 1.1.

### 1.1 Diseño conceptual (lo decidido antes de programar)

| Decisión | Qué se eligió | Por qué |
|---|---|---|
| Objetivo | Web unidireccional que da a conocer el restaurante: quiénes son, platos estrella, dónde están y cómo contactar | Es lo que pide el enunciado («solo exponga información») |
| Estructura | Una sola página con anclas: inicio, filosofía, platos estrella (slideshow), ubicación (mapa y geolocalización), contacto (formulario de ejemplo) | Pocas secciones, un solo documento: carga rápida y fácil de mantener sin CMS |
| Paleta | Fondo crema `#f3efe6`, texto verde muy oscuro `#18231d` y acento teja `#c84b31` (`#ad3f28` para texto, por contraste) | Colores cálidos de cocina tradicional; el acento oscuro cumple el contraste AA de accesibilidad |
| Tipografía | Títulos con serifa (Georgia) y texto sin serifa (Inter/Arial), sin fuentes externas | Contraste entre lo tradicional y lo actual, y ninguna descarga de fuentes (rendimiento y privacidad) |
| Adaptable | Móvil primero: a menos de 800 px, una columna y menú desplegable | Muchos clientes miran la web desde el móvil, en la calle |
| Accesibilidad | Enlace «saltar al contenido», textos alternativos, botones del slideshow con nombre, foco visible | Lo pide el enunciado («accesible») y lo mide Lighthouse (tarea 29) |


## 2. Archivos

| Archivo | Contenido |
|---|---|
| [`27-wireframes-web.drawio`](../diagramas/27-wireframes-web.drawio) | Fuente editable en draw.io, con dos páginas: escritorio y móvil |
| [`27-wireframe-escritorio.svg`](../diagramas/27-wireframe-escritorio.svg) | Escritorio, 1440 px de ancho |
| [`27-wireframe-movil.svg`](../diagramas/27-wireframe-movil.svg) | Móvil, 390 px de ancho, y el menú desplegado |

## 3. Escritorio

![Wireframe de escritorio](../diagramas/27-wireframe-escritorio.svg)

## 4. Móvil

![Wireframe de móvil](../diagramas/27-wireframe-movil.svg)

## 5. La web implementada

Capturas de la web (tarea 28) a 1440 px de ancho, para comparar con el wireframe de escritorio. Se han generado abriendo `web/index.html` con Chrome.

**Portada** (secciones 1 y 2 del wireframe):

![Portada de la web](../evidencias/27-wireframes/web-01-portada.png)

**Ubicación con el mapa de OpenStreetMap** (sección 5):

![Sección de ubicación con el mapa](../evidencias/27-wireframes/web-02-ubicacion-mapa.png)

**Formulario de contacto** (sección 6):

![Formulario de contacto](../evidencias/27-wireframes/web-03-formulario-contacto.png)

## 6. Estructura de la página

Es una sola página: el menú lleva a cada sección mediante anclas (`#historia`, `#platos`, `#ubicacion` y `#contacto`).

| # | Sección | Escritorio | Móvil (800 px o menos) |
|---|---|---|---|
| 1 | Cabecera | Logo a la izquierda y menú a la derecha; «Contacto» destacado | El menú se esconde tras el botón «Menú» y se despliega debajo de la cabecera |
| 2 | Portada | Titular grande, texto y enlace a «Platos» a la derecha, imagen grande con pie vertical y un «01» decorativo | Una columna, sin pie vertical ni «01» |
| 3 | Historia | Titular y texto en dos columnas | Apilados |
| 4 | Platos estrella | Fondo oscuro; carrusel de 3 platos con flechas y contador | Título y controles encima de la imagen |
| 5 | Ubicación | Datos de contacto, «Cómo llegar», «Usar mi ubicación» y mapa de OpenStreetMap con insignia | Mapa debajo de los datos, con 420 px de alto como mínimo |
| 6 | Contacto | Formulario a dos columnas: nombre, correo y mensaje | Formulario a una columna |
| 7 | Pie | Logo, ciudad y créditos en una fila | Apilados |

## 7. Decisiones de diseño

- **Una sola página.** La web es de presentación, con poco contenido; las anclas evitan tener que navegar entre páginas.
- **Un único punto de corte, en 800 px.** Por encima, las secciones van a dos columnas; por debajo, a una.
- **Mapa de OpenStreetMap en lugar de Google Maps.** No necesita clave de API ni cuenta.
- **El mapa se carga al pulsar «Ver el mapa»** (26/10/2026). Trae más de 1 MB de JavaScript y bajaba Lighthouse en móvil a 70 contra la URL pública (ahora 94); mientras tanto se ve un fondo de cuadrícula con la insignia. Sin JavaScript, el botón es un enlace a OpenStreetMap.
- **El formulario es de demostración.** No envía datos, así que la web es estática y se puede alojar sin servidor (tarea 30).
- **Geolocalización.** El botón «Usar mi ubicación» solo funciona con HTTPS, porque los navegadores la bloquean en HTTP. Es otro motivo para que la tarea 30 incluya un certificado.

## 8. Cómo editarlos

Los SVG se ven directamente en GitHub. Para cambiar los wireframes, se abre el `.drawio` en [app.diagrams.net](https://app.diagrams.net) o en draw.io Desktop y, al terminar, se exporta cada página a SVG con el mismo nombre (**Archivo → Exportar como → SVG**).
