# Tarea 47 · Tabla de pruebas por bloque

**Responsable:** Eneko.S · **Fechas:** 10–11/11/2026 · **Depende de:** tareas 21, 26 y 29
**Estado:** ✅ Repasada fila a fila el 10/11/2026 contra el documento de cada tarea (antes: 27/10, 29/10 y 04/11). Añadidas las pruebas del cifrado y los servicios reducidos del gerente (tareas 12 y 64) y la restauración en una máquina nueva (RTO). Las filas ⏳ y 🟡 que quedan son pruebas que dependen de otras tareas abiertas; cada una dice qué falta y de quién es.

Resume, por bloque del reto, **qué se ha probado, qué resultado dio y dónde está la evidencia**. No sustituye a la documentación de cada tarea: cada fila enlaza a ella. Los resultados se han copiado de los documentos de cada tarea, de [verificacion.md](verificacion.md) y del [backlog](backlog-kanban.csv) (repaso del 10/11/2026); no se han inventado ni redondeado. Si una prueba se hizo en una máquina virtual y no en el equipo real, lleva 🖥️.

| Símbolo | Significa |
|---|---|
| ✅ | Prueba hecha con el resultado esperado |
| ❌ | Prueba hecha con un resultado distinto del esperado (sin corregir) |
| 🟡 | Prueba hecha en parte: la fila dice qué falta |
| ⏳ | Prueba prevista y todavía sin hacer |
| 🖥️ | Hecha en máquina virtual: falta repetirla en el equipo real |

## Resumen

| Bloque | Pruebas | ✅ | 🟡 | ⏳ | Lo que falta, en una línea |
|---|---|---|---|---|---|
| 0 Gestión | 5 | 4 | 0 | 1 | Commits de Eneko.P (tarea 5) |
| 1 Hardware | 3 | 3 | 0 | 0 | — |
| 2 SO | 11 | 10 | 0 | 1 | Scripts del TPV en los dos equipos (tarea 15, S-20) |
| 3 Arcade | 10 | 10 | 0 | 0 | — |
| 4 Arduino | 7 | 6 | 0 | 1 | Probar el antirrebote en la placa (tarea 59) |
| 5 Redes | 10 | 7 | 1 | 2 | WDS: Wi-Fi de clientes por el router 2, aislamiento probado desde él y cobertura antes y después (tarea 25) |
| 6 Web | 6 | 6 | 0 | 0 | Repetir Lighthouse con la web del 04/11 (necesita la EC2 encendida) |
| 7 ERP | 8 | 7 | 0 | 1 | Importar y exportar datos contra Odoo (tarea 36) |
| 8 BD | 4 | 4 | 0 | 0 | — |
| 9 Backup | 6 | 6 | 0 | 0 | — (sin probar: un TPV contra el servidor recuperado) |
| 10 Seguridad | 3 | 2 | 1 | 0 | Comprobaciones 2, 3, 6 y 7 en el servidor del equipo (tarea 46, sección 5) |
| **Total** | **73** | **65** | **2** | **6** | |

## 0 · Gestión

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| G-01 | 5 | CI de gitleaks en los merges a `main` | En verde | ✅ Los 3 últimos merges, en verde (23/10); repetido el 10/11: los merges de las PR #111 a #113 (09/11), en verde | 23/10 y 10/11 | [verificacion.md §3](verificacion.md) · [Actions](https://github.com/zHGx-alt/Reto-Asir/actions) |
| G-02 | 5 | gitleaks local sobre todo el historial | Sin fugas | ✅ 81 commits, sin fugas (23/10); 420 commits, sin fugas (10/11) | 23/10 y 10/11 | [verificacion.md §2](verificacion.md) |
| G-03 | 5 | Las 6 personas tienen commits propios (Anexo IX) | 6 de 6 | ⏳ 5 de 6: falta Eneko.P | 23/10 | [verificacion.md §3](verificacion.md) |
| G-04 | 4 | `python3 scripts/gantt.py`: backlog coherente | Sin errores | ✅ Sin errores | 27/10 | [gantt.md](gantt.md) |
| G-05 | 5 | `bash scripts/verificar-repo.sh` | «Todo correcto» | ✅ «Todo correcto» con Docker: enlaces, Gantt, sintaxis, antirrebote, SQL (49/49 y 9/9), shellcheck, W3C y gitleaks | 10/11 | [verificar-repo.sh](../../scripts/verificar-repo.sh) |

## 1 · Hardware

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| H-01 | 8 | Sumas de la tabla de hardware | Cuadran | ✅ 2.361,36 € | 23/10 | [08-tabla-hardware.md](../hardware/08-tabla-hardware.md) |
| H-02 | 10 | Sumas del presupuesto | Cuadran | ✅ 2.447,34 € de inversión (23/10); con lo añadido el 24/10, 3.814,74 € y 4.174,74 € el primer año; con las licencias de los TPV (30/10), 2.522,16 €, 3.889,56 € y 4.249,56 € | 23-30/10 | [10-presupuesto-hardware.md](../hardware/10-presupuesto-hardware.md) |
| H-03 | 11 | SVG del diagrama de arquitectura | XML válido y legible | ✅ | 24/10 | [DIAGRAMA.md](../diagramas/11-arquitectura-equipos/DIAGRAMA.md) |

## 2 · Sistemas operativos

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| S-01 | 12 | Arranque dual: GRUB ofrece los dos sistemas y ambos arrancan | Los dos arrancan | ✅ 🖥️ VMware (23/10); la VM se migró a VirtualBox el 29/10 y sigue arrancando los dos | 23/10 | [12-dual-boot.md](../so/12-dual-boot.md) |
| S-02 | 12 | El usuario `gerente` no es administrador | Sin `sudo` en Ubuntu; UAC pide credenciales en Windows | ✅ 🖥️ | 22-23/10 | [Ubuntu](../evidencias/12-dual-boot/ubu-05-gerente-sin-sudo.webp) · [Windows](../evidencias/12-dual-boot/win-04-uac-gerente.png) |
| S-03 | 12, 55 | Integridad de la VM entregada y contraseñas robustas | SHA-256 coinciden; contraseñas en KeePassXC | ✅ | 23/10 | [cuentas y contraseñas](../evidencias/12-dual-boot/ubu-07-cuentas-y-contrasenas.txt) |
| S-04 | 13 | TPV: usuario estándar, quiosco con Edge, USB bloqueado, cortafuegos y Defender | Todo aplicado | ✅ 🖥️ A mano en dos VM con Windows 11 Pro. El quiosco apunta todavía a `http://localhost:8069` (provisional). Sin el bloqueo de salida del firewall ni la lista blanca de Edge que da `configurar-tpv.ps1` (hallazgo S-20 de la tarea 46) | 26/10 | [Bastionado del TPV](../so/13-tpv/Tarea13_Markdown_GitHub/13-bastionado-tpv-windows.md) |
| S-05 | 15 | Analizador de PowerShell sobre `configurar-tpv.ps1` y `comprobar-tpv.ps1` | 0 errores | ✅ | 24/10 | [comprobar-tpv.ps1](../so/13-tpv/comprobar-tpv.ps1) |
| S-06 | 15 | `comprobar-tpv.ps1` en los dos TPV | Todo OK | ⏳ Iker: pasar `configurar-tpv.ps1` y `comprobar-tpv.ps1` en las VM de Markel (hallazgo S-20 de la 46) | — | [comprobar-tpv.ps1](../so/13-tpv/comprobar-tpv.ps1) |
| S-07 | 14 | Impresión de prueba desde el TPV | Imprime | ✅ 🖥️ Con la Samsung ML-1660 (impresora de pruebas acordada el 27/10): por IPP a la cola CUPS del PC, el ticket de Odoo sale en papel desde la VM del TPV. Por USB pasado a la VM, Windows no crea el puerto | 27/10 | [Tarea 52](../erp/52-https-odoo/DOCUMENTACION.md) |
| S-08 | 12 | Cifrado del PC del gerente: BitLocker en `C:` y `/home/gerente` con fscrypt | Cifrado; Windows pide la contraseña al arrancar en frío | ✅ 🖥️ XTS-AES 256 al 100 % con contraseña de arranque; `fscrypt status` «is encrypted» y la carpeta se abre al entrar como `gerente` | 29/10 | [BitLocker](../evidencias/12-dual-boot/win-10-bitlocker-final.txt) · [arranque](../evidencias/12-dual-boot/win-11-bitlocker-pide-contrasena-al-arrancar.png) · [fscrypt](../evidencias/12-dual-boot/ubu-09-fscrypt-home-gerente.txt) |
| S-09 | 12 | Actualizaciones del gerente: Windows Update y `20auto-upgrades` en Ubuntu | Al día; automáticas | ✅ 🖥️ Acumulativa KB5066791 (19045.6456) y las dos opciones de Ubuntu a `"1"` | 29/10 | [Windows Update](../evidencias/12-dual-boot/win-13-historial-windows-update-kb5066791.png) · [Ubuntu](../evidencias/12-dual-boot/ubu-03-ufw-y-auto-upgrades.png) |
| S-10 | 64 | Servicios reducidos en Windows: `12-servicios-reducidos.ps1` y `Get-Service` de los 12 de la lista | Los 12 deshabilitados; la impresión sigue | ✅ 🖥️ Los 12 en *Disabled / Stopped*, `Spooler` en marcha; 248 → 237 servicios no deshabilitados | 09/11 | [antes y después](../evidencias/12-dual-boot/win-14-servicios-reducidos.txt) · [captura](../evidencias/12-dual-boot/win-15-servicios-deshabilitados.png) |
| S-11 | 64 | Servicios reducidos en Ubuntu: `12-servicios-reducidos.sh` y `ss -tulpn` en un arranque normal | 5 unidades fuera; nada escucha hacia la red | ✅ 🖥️ Las 5 *disabled / inactive*, `cups` activo; 73 → 68 habilitadas; solo escucha en `127.0.0.x` y `::1` | 09/11 | [antes y después](../evidencias/12-dual-boot/ubu-11-servicios-reducidos.txt) · [arranque normal](../evidencias/12-dual-boot/ubu-12-servicios-tras-arranque-normal.txt) |

## 3 · Recreativa

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| A-01 | 16 | Arranque directo a MAME | Sin contraseña ni escritorio | ✅ 🖥️ 4,7 s | 22/10 | [Tarea 16](../arcade/16-recreativa-mame/DOCUMENTACION.md) |
| A-02 | 16 | ROMs legales | 5 de 5 correctas | ✅ `5 romsets found, 5 were OK` | 22/10 | [verificacion-roms.txt](../arcade/16-recreativa-mame/evidencias/verificacion-roms.txt) |
| A-03 | 16 | `arcade` sin `sudo`, contraseña bloqueada y carpetas privadas | Denegado | ✅ 🖥️ | 22/10 | [Tarea 16, §7](../arcade/16-recreativa-mame/DOCUMENTACION.md) |
| A-04 | 51 | Batocera frente a Debian en VM de 1 núcleo y 1 GB | Elegir el más ligero | ✅ 🖥️ Debian: 7,1 s frente a 12,9 s hasta jugar; 400 MB frente a 554 MB | 26/10 | [NOTAS.md](../arcade/16-batocera/NOTAS.md) |
| A-05 | 17 | Rendimiento antes y después de optimizar (VM de 2 núcleos y 1,5 GB) | Mejora o igual | ✅ 🖥️ Timers 8 → 3, disco −277 MB, Robby Roto +27 % y más estable; arranque no concluyente | 22/10 | [rendimiento.csv](../arcade/17-rendimiento-mame/evidencias/rendimiento.csv) |
| A-06 | 17, 18 | Lo mismo en la VM de 1 núcleo y 1 GB, también jugando | Antes y después | ✅ 🖥️ Hecho dentro de la tarea 54 en `Recreativa-53` (ver A-09) | 29/10 | [Tarea 54](../arcade/54-medidas-equipo-real/DOCUMENTACION.md) |
| A-07 | 18 | Scripts de monitorización en Linux | CSV correcto, parada limpia | ✅ | 23/10 | [Tarea 18](../arcade/18-monitorizacion-recreativa.md) |
| A-08 | 53 | Recreativa en VM de 1 núcleo y 1 GB con el stick: comprobaciones P1-P10 | Todo OK | ✅ 🖥️ `Recreativa-53`: arranque directo a MAME, 5 juegos, partida con el stick, MAME se reabre, `arcade` sin privilegios, SSH solo con clave; 524 MB libres con MAME | 29/10 | [Tarea 53](../arcade/53-recreativa-fisica/DOCUMENTACION.md) |
| A-09 | 54 | Medidas antes y después en `Recreativa-53` (1 núcleo y 1 GB): 3 + 3 arranques, reposo y 10 min de juego | Datos de antes y después | ✅ 🖥️ Timers 8 → 5, disco −12 %; arranque (14,4 s), RAM y velocidad sin cambios significativos (*Robby Roto* 773 % → 777 %). Jugando: CPU media 52-58 %, más de 460 MB libres y sin swap | 29/10 | [Tarea 54](../arcade/54-medidas-equipo-real/DOCUMENTACION.md) |
| A-10 | 16, 62 | Front-end: arranque al menú de juegos a pantalla completa, filtro de juegos instalados y selección con el stick | Elegir juego sin teclado | ✅ 🖥️ Menú de MAME con los 5 juegos (filtro *Available*), Botón 1 y Start eligen, Esc vuelve a abrir MAME | 22/10 y 29/10 | [Tarea 16, §4.7](../arcade/16-recreativa-mame/DOCUMENTACION.md#47-el-front-end-gráfico-la-interfaz-de-mame) |

## 4 · Arcade stick (Arduino)

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| R-01 | 20 | Compilar el firmware (`pio run` hasta el 04/11; ahora Arduino IDE o `subir.sh`) | Compila | ✅ Flash 37,4 %, RAM 17,4 % (26/10); 38,6 % y 20,0 % con el antirrebote (04/11) | 26/10 | [README del stick](../../arduino/mando-joystick/README.md) |
| R-02 | 16 | MAME detecta un mando con la identidad USB del Leonardo | Detectado | ✅ 🖥️ Mando virtual | 22/10 | [prueba-stick-virtual.txt](../arcade/16-recreativa-mame/evidencias/prueba-stick-virtual.txt) |
| R-03 | 19 | Montaje y cableado | Montado | ✅ Cableado y probado en la placa; montado en la caja con la palanca y los botones (la caja tiene 6 botones; el firmware lee 4) | 27/10 | [Foto](../../arduino/mando-joystick/evidencias/stick-montado-2026-10-27.webp) · [prueba en la placa](../../arduino/mando-joystick/evidencias/prueba-placa-2026-10-27.txt) |
| R-04 | 50 | Firmware en la placa: HID, comandos y EEPROM | Funciona | ✅ Los 4 botones y las 4 direcciones llegan al PC y a Batocera | 27/10 | [Entrada registrada](../../arduino/mando-joystick/evidencias/entrada-stick-2026-10-27-1124.txt) · [EEPROM](../../arduino/mando-joystick/evidencias/eeprom-2026-10-27.txt) |
| R-05 | 21 | Stick con MAME y con otro emulador | Funciona en los dos | ✅ MAME: partida en `Recreativa-53` (tarea 53, 29/10). Batocera (RetroArch): evtest con los 4 botones y los ejes y una partida el 27/10, sin captura | 27-29/10 | [evtest en Batocera](../../arduino/mando-joystick/evidencias/batocera-evtest-2026-10-27.txt) · [partida en MAME](../arcade/53-recreativa-fisica/evidencias/07-partida-stick.png) |
| R-06 | 59 | Antirrebote del firmware con rebotes simulados (`prueba-antirrebote/probar.sh`) | Una pulsación con rebotes cuenta 1; el ruido no pasa | ✅ 9 de 9: pulsación con rebotes de 3 ms = 1, picos de 1-2 ms ignorados, retardo 6 ms, remapeo sin botones colgados | 04/11 | [README del stick, Antirrebote](../../arduino/mando-joystick/README.md#antirrebote-tarea-59) |
| R-07 | 59 | Antirrebote en la placa: `ver-mando.py` pulsando cada control | Ninguna pulsación de menos de 30 ms | ⏳ Markel: subirlo a la placa con `subir.sh` y pulsar cada control | — | [README del stick, Antirrebote](../../arduino/mando-joystick/README.md#antirrebote-tarea-59) |

## 5 · Redes

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| N-01 | 23 | Simulación en Packet Tracer: direcciones, acceso a Odoo, aislamiento de invitados, NAT | 16 pruebas correctas | ✅ 16 de 16 | 25/10 | [Packet Tracer](../redes/23-packet-tracer-red-local.md) |
| N-02 | 24 | Red segura en un TL-WR841N: administración remota cerrada, WPA2-AES, SPI, contraseñas cambiadas | Aplicado | ✅ | 26/10 | [Tarea 24](../redes/24-red-segura/DOCUMENTACION.md) |
| N-03 | 24 | Red de invitados aislada y WPA3 en el Archer C6 | Aislada | ✅ Aislada en el TL-WR841N de pruebas: Internet sí, gerente y otro invitado no (30/10). WPA3 no existe en ese router: queda para el Archer C6 | 30/10 | [Tarea 24](../redes/24-red-segura/DOCUMENTACION.md) |
| N-04 | 25 | Práctica de WDS con dos TL-WR841N en `192.168.1.0/24`: enlace, DHCP del router 2 apagado, ping y cobertura | Enlazados, sin pérdidas | ✅ El PC conectado al router 2 recibe IP del router 1 y le hace ping: 4/4, 0 % de pérdidas; DHCP del router 2 apagado; cobertura comprobada con el móvil (sin medidas numéricas) | 27/10 | [Tarea 25](../redes/25-wds/DOCUMENTACION.md) (la práctica del 27/10, en el historial de Git del fichero) |
| N-05 | 25 | WDS en la red del proyecto: router 2 en Range Extender enlazado al router 1, en `192.168.10.2` y con su DHCP apagado | Enlazado; un solo DHCP | ✅ Estado «Range Extender» conectado a `Restaurante_Almichain`; LAN `192.168.10.2/24`; DHCP del router 2 desactivado | 04/11 | [estado](../redes/25-wds/evidencias/11-router2-estado-range-extender.png) · [LAN](../redes/25-wds/evidencias/13-router2-lan.png) · [DHCP](../redes/25-wds/evidencias/19-router2-dhcp-desactivado.jpg) |
| N-06 | 26 | nmap desde la LAN y desde invitados; capturas de Wireshark | Lo del plan de la tarea 23 | ✅ Invitados no ven la LAN; router con UPnP y SSH (H-01, H-02); L2-L8 y W5 pendientes de que el servidor esté en la red | 30/10 Eneko.S | [Tarea 26](../redes/26-analisis-conectividad/DOCUMENTACION.md) |
| N-07 | 25 | Ping al router 1 a través del montaje | 0 % de pérdidas | ✅ 4/4, 0 % de pérdidas | 04/11 | [ping](../redes/25-wds/evidencias/10-ping-router-principal.png) |
| N-08 | 25 | Desde la Wi-Fi de invitados: Internet sí; `192.168.10.1`, `.2` y `.10` no | Aislados de la LAN | 🟡 Internet sí y los tres destinos inalcanzables, pero conectado al **router 1**: falta repetirlo en el BSSID del router 2 (tarea 25, prueba W6) | 04/11 | [router 2](../redes/25-wds/evidencias/16-invitados-sin-acceso-router2.jpg) · [LAN](../redes/25-wds/evidencias/17-invitados-sin-acceso-lan.jpg) |
| N-09 | 25 | La Wi-Fi de **clientes** llega a través del router 2 | El router 2 enlazado a `Restaurante-Almichain-Invitados` | ⏳ Peio: hoy está enlazado a la del personal. En Range Extender el TL-WR841N repite una sola red; se cambia en *Connect to Network* (5 min) | — | [Tarea 25, sección 6](../redes/25-wds/DOCUMENTACION.md#6-por-qué-el-router-2-no-repite-la-wi-fi-de-clientes-y-cómo-se-arregla) |
| N-10 | 25 | Cobertura antes y después: dBm en la barra y en la entrada con el router 2 apagado y encendido | Más señal con el router 2 | ⏳ Peio: solo hay una medida del router 1 a 0 m (-26 dBm personal, -31 dBm invitados); tabla en blanco en la [tarea 25, sección 7](../redes/25-wds/DOCUMENTACION.md#7-lo-que-falta-hoja-de-trabajo) | — | [WiFi Analyzer](../redes/25-wds/evidencias/15-wifi-analyzer-p1-antes.jpg) |

## 6 · Web

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| W-01 | 29 | Validador W3C contra la URL pública | 0 errores | ✅ 0 en HTML y en CSS (26/10); repetido el 10/11 con la web actual (validador Nu en Docker, desde `verificar-repo.sh`): 0 errores en `index.html` y `style.css` | 26/10 | [lighthouse-w3c.txt](../evidencias/web/lighthouse-w3c.txt) |
| W-02 | 29 | Lighthouse contra la URL pública (mediana de 5) | ≥ 90 | ✅ Móvil 94/100/100/100; escritorio 99/100/100/100. Hay que repetirlo por los cambios del 27/10 y el 04/11 (con la EC2 encendida) | 26/10 | [lighthouse-w3c.txt](../evidencias/web/lighthouse-w3c.txt) |
| W-03 | 30 | Web en AWS con dominio y HTTPS; `nginx -t` | Responde por HTTPS | ✅ Con el laboratorio encendido; fuera de sesión no responde (el Learner Lab apaga la EC2) | 23/10 | [Tarea 30](../web/30-hosting-aws.md) |
| W-04 | 28 | Geolocalización con una posición simulada | Distancia y ruta | ✅ «1,1 km» y enlace a la ruta | 24/10 | [verificacion.md §8](verificacion.md) |
| W-05 | 31 | `terraform fmt`/`validate` y `apply` en el Learner Lab | Infraestructura creada | ✅ `validate` y `fmt` (24/10); `apply`, pruebas con curl, despliegue por Actions y `plan` sin cambios (29/10) | 29/10 | [iac/evidencias/](../../iac/evidencias/02-apply.txt) |
| W-06 | 27, 62 | Web en tableta: 820 × 1180 y 1024 × 1366 con Chrome | Sin desplazamiento horizontal; todo visible | ✅ Con el nuevo punto de corte (801-1100 px): sin desplazamiento horizontal, imagen de portada a todo el ancho y campos del formulario de 354 px (antes, 150) | 10/11 | [capturas](../web/27-wireframes.md#41-tableta-801-1100-px) |

## 7 · ERP (Odoo)

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| E-01 | 33 | Despliegue en un Docker limpio | Login 200; gestor de BD desactivado; 5432 sin publicar; `admin/admin` rechazado | ✅ | 23/10 | [Tarea 33](../erp/33-odoo-docker/DOCUMENTACION.md) |
| E-02 | 34 | `configurar-odoo.py` en una base nueva, dos veces | Configura e idempotente | ✅ Tras corregir 2 fallos | 23/10 | [prueba-instalacion-limpia.txt](../erp/34-configurar-odoo/evidencias/prueba-instalacion-limpia.txt) |
| E-03 | 34 | `cajero1` intenta cambiar un precio y crear un usuario | Denegado | ✅ | 23/10 | [prueba-instalacion-limpia.txt](../erp/34-configurar-odoo/evidencias/prueba-instalacion-limpia.txt) |
| E-04 | 35 | Caso de uso automatizado: pedido, factura, cobro y PDF | Factura validada y cobrada | ✅ `INV/2026/00001` y `00002` | 23/10 | [Tarea 35](../erp/35-factura-automatica/DOCUMENTACION.md) |
| E-05 | 35 | Repetirlo con el caso de uso real: menú de grupo con IVA del 10 % | Factura correcta | ✅ `INV/2026/00004` = 660,00 €; la `00003` (654,55 €, IVA mal calculado) anulada con la rectificativa `RINV/2026/00001` | 27/10 | [INV_2026_00004.pdf](../erp/35-factura-automatica/evidencias/INV_2026_00004.pdf) |
| E-06 | 52 | Proxy HTTPS: certificado, redirección, TLS 1.2/1.3, cabeceras, venta por HTTPS | 15 pruebas | ✅ 🖥️ 15 de 15 | 26/10 | [Tarea 52](../erp/52-https-odoo/DOCUMENTACION.md) |
| E-07 | 36 | Importar y exportar datos (carta, clientes, ventas) | CSV correctos | ⏳ Script y CSV hechos (24/10); Eneko.P: ejecutarlo contra Odoo y guardar las salidas | — | [Tarea 36](../erp/36-importar-exportar/DOCUMENTACION.md) |
| E-08 | 37 | Ticket desde el TPV de Odoo | Imprime | ✅ 🖥️ Desde la VM win-11 por IPP a la Samsung ML-1660 (impresora de pruebas acordada: no hay térmicas para todos) | 27/10 | [Tarea 52](../erp/52-https-odoo/DOCUMENTACION.md) |

## 8 · Base de datos

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| D-01 | 40 | Scripts DDL en PostgreSQL 16 | 01-03 sin errores; 05 33/33; 04 recrea | ✅ 33/33 dos veces (49/49 desde la tarea 56) | 23/10 | [40-scripts-ddl.md](../bd/40-scripts-ddl.md) |
| D-02 | 41 | Datos de prueba y consultas | 8 facturas; 12 consultas sin errores | ✅ | 24/10 | [41-datos-y-consultas.txt](../bd/evidencias/41-datos-y-consultas.txt) |
| D-03 | 42 | Usuarios con mínimos privilegios (`tpv_app` e `informes`) | 9/9 por cuenta | ✅ | 24/10 | [42-usuarios-y-permisos.txt](../bd/evidencias/42-usuarios-y-permisos.txt) |
| D-04 | 56 | Ternaria, historial (R-07) y multivaluado en PostgreSQL 16 | 05 49/49; 06 carga 17 tablas; C-13 a C-15 correctas; la aplicación no toca el historial | ✅ 49/49 dos veces; C-15: café vendido a 1,45 € con el precio de hoy en 1,55 € | 04/11 | [56-ampliacion-er.txt](../bd/evidencias/56-ampliacion-er.txt) |

## 9 · Copias de seguridad

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| B-01 | 43 | RAID 1 y simulación de fallo de un disco | El sistema sigue y el RAID se reconstruye | ✅ 🖥️ | 22-23/10 | [Tarea 43](../backup/43-raid1/DOCUMENTACION.md) |
| B-02 | 43 | Lo mismo con la base de datos de Odoo dentro del RAID | Odoo sigue funcionando | ✅ 🖥️ Venta guardada con el RAID degradado `[U_]`; reconstruido en 30 s; reinicio correcto | 27/10 | [Tarea 43](../backup/43-raid1/DOCUMENTACION.md) |
| B-03 | 44 | Copia 3-2-1 cifrada y diaria (RAID y USB) y aviso si falla | Copia de las dos bases; aviso | ✅ 🖥️ Odoo y `almi_chain`; aviso (`OnFailure=`) probado con un fallo provocado. El tercer destino en S3 está preparado sin probar | 22/10 y 27/10 | [Tarea 44](../backup/44-backup-3-2-1/DOCUMENTACION.md) |
| B-04 | 45 | Restaurar la copia del USB en un entorno aislado | Odoo restaurado | ✅ 🖥️ 46 s (con el servidor ya instalado) | 22/10 | [Tarea 45](../backup/45-restauracion/DOCUMENTACION.md) |
| B-06 | 60 | Copia en S3 y restauración desde S3, con `almi_chain` comparada (tablas, filas, importes y permisos) | Todo igual que en producción | ✅ 🖥️ 23 OK en 166 s desde S3; desde el RAID, 23 OK en 68 s (laboratorio) | 04/11 | [restauracion-s3-2026-11-04.log](../backup/45-restauracion/evidencias/restauracion-s3-2026-11-04.log) |
| B-05 | 45, 48 | Recuperar el servidor en una VM **vacía** desde el USB (RTO real): preseed + `recuperar-servidor-nuevo.sh` | Odoo por HTTPS con los datos de la copia; tiempo medido | ✅ 🖥️ **832 s ≈ 14 min**; `/web/login` 200 por HTTP y HTTPS, `admin` entra, última venta `TPV Barra 1 - 000007` y `almi_chain` (13 tablas) recuperadas. Sin probar desde un TPV | 10/11 | [rto-maquina-nueva-2026-11-10.log](../backup/45-restauracion/evidencias/rto-maquina-nueva-2026-11-10.log) |

## 10 · Seguridad

| Id | Tarea | Prueba | Esperado | Resultado | Fecha | Evidencia |
|---|---|---|---|---|---|---|
| X-01 | 46 | Revisión de seguridad del repositorio, repasada el 27/10, el 29/10 y el 03/11 | Hallazgos con responsable | ✅ 26 hallazgos (S-01 a S-26): corregidos S-01, S-04, S-05, S-06, S-13, S-15, S-18, S-21, S-22 y S-24, y S-08 y S-09 en el preseed (04/11); S-03 ya no aplica (se descarta Batocera) | 26/10-04/11 | [Tarea 46](../seguridad/46-revision-seguridad/DOCUMENTACION.md) |
| X-02 | 46, 52 | S-01: certificado de Odoo limitado con `nameConstraints` | No vale para otras webs | ✅ 🖥️ Probado también en Edge | 26/10 | [Tarea 46, §4.1](../seguridad/46-revision-seguridad/DOCUMENTACION.md) |
| X-03 | 46 | Comprobaciones en los equipos (nmap, router, SSH, cifrado) | 9 comprobaciones | 🟡 La 1 hecha con la tarea 26 (30/10); la 6 y la 7 (SSH y actualizaciones) en el laboratorio y en una instalación nueva con el preseed (03-04/11); la 2, la 3 y la 6 y 7 en el servidor del equipo esperan a que esté en la red | — | [Tarea 46, §5](../seguridad/46-revision-seguridad/DOCUMENTACION.md) |

## Cómo actualizar esta tabla

1. Al cerrar una prueba ⏳, cambiar el símbolo, el resultado, la fecha y el enlace a la evidencia.
2. Recalcular el resumen (contar ✅ y ⏳ por bloque).
3. Antes de la entrega, comprobar que cada enlace abre: `bash scripts/verificar-repo.sh` revisa los enlaces rotos.

**Nota sobre G-05:** el 27/10 se ejecutó en un Linux sin Docker y se saltaron shellcheck, W3C y gitleaks; el 10/11, en el PC de Adrian con Docker, pasó todo.
