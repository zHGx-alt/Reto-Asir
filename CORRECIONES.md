# Correcciones del reto Almi-Chain · Lista para el lunes 26/10/2026

Revisión del repositorio contra el **enunciado** ([Reto_1_ASIR1_2026-2027.docx](Reto_1_ASIR1_2026-2027.docx)), la única fuente fiable. El plan ([almi-chain-plan.pdf](almi-chain-plan.pdf)) lo hizo el equipo y no cuenta como requisito.

- **Revisión:** 24/10/2026. El mismo día se corrigió todo lo que se podía arreglar desde el repositorio (commit `215eac7`, rama `gestion/correcciones`; sección 1).
- **Este documento es la lista de lo que queda.** Cada punto dice qué hacer, dónde, quién lo lleva (según el [backlog](docs/gestion/backlog-kanban.csv)) y cuándo se da por terminado. Al terminar uno, se marca `[x]` con la fecha y se actualizan la observación del CSV y el Gantt (`python3 scripts/gantt.py`).
- La revisión completa original, con la explicación de cada fallo, está en la versión del fichero del commit `215eac7`: `git show 215eac7:CORRECIONES.md`.
- **Gravedad:** 🔴 grave (incumple el enunciado o es un fallo de seguridad) · 🟠 media (error que un evaluador puede ver) · 🟢 leve.
- **Actualizado el 24/10/2026** con las decisiones del equipo (sección 6): Drive revisado, equipo de 6, DuckDNS, fechas, base central, TicketBAI, una VM y la impresora que da el centro. Lo que dependa de la rúbrica se revisará cuando se publique.

---

## 0. Orden recomendado para el lunes

El PR #41 (`gestion/correcciones`) ya está unido a `main`. El reto va del **lunes 26/10 al jueves 12/11/2026**.

| Orden | Qué | Por qué primero | Quién | Sección |
|---|---|---|---|---|
| 1 | **Cambiar la contraseña Wi-Fi expuesta** y la de administración del router | Está en el historial de Git y se puede leer | Peio | [2.1](#21-urgente-contraseñas) |
| 2 | Pasar la contraseña de restic a KeePassXC y borrar su copia en texto | Contraseña en texto plano | Iker | [2.1](#21-urgente-contraseñas) |
| 3 | Pasar `verificar-repo.sh` en un equipo con Docker | Comprueba los SQL nuevos (tarea 41) y el resto, sin coste | Iker | [3.1](#31-base-de-datos-tareas-41-y-42) |
| 4 | Decidir red plana o VLAN | Cambia Packet Tracer, diagramas y presupuesto | Equipo | [4.1](#41-decisión-red-plana-o-vlan) |
| 5 | Mover la BD al RAID y repetir la prueba | Tal como está, incumple el enunciado | Iker | [3.2](#32-raid-y-copias-tareas-43-45) |
| 6 | TPV, impresora (cuando la dé el centro) y stick | Tareas literales del enunciado sin empezar | Iker · Adrian · Markel · Peio | [5](#5-tareas-del-enunciado-sin-empezar) |

---

## 1. Ya corregido el 24/10/2026 (no hay que repetirlo)

| Bloque | Qué se hizo |
|---|---|
| Seguridad | Contraseña Wi-Fi y RADIUS tapadas en las capturas 07 y 08 de la tarea 24; preseed de la recreativa sin la clave SSH fija (`preseed-local.cfg`, en `.gitignore`); SSH de la recreativa sin contraseña ni root; actualizaciones de seguridad de la recreativa a las 04:30 y 05:00 |
| Redes | Tarea 22 en Markdown con análisis de necesidades, esquema de conectividad y fuentes; tarea 23 con la cita literal del enunciado, invitados en `192.168.50.0/24`, switch en el armario, lista de lo que falta en Packet Tracer (apartado 5.4) y opciones red plana / VLAN (5.5); tarea 24 con cabecera, aviso de contraseñas y fallos de configuración |
| Hardware | Presupuesto con servidor, discos del RAID, disco USB, SAI, switch, cable, adaptador Wi-Fi y palanca ([tarea 10, sección 12](docs/hardware/10-presupuesto-hardware.md#12-elementos-que-faltaban-en-el-presupuesto)); Windows 10 IoT Enterprise LTSC 2021 para los TPV; tarea 9 con versiones; impresoras en `.41` y `.42` |
| SO | Tarea 12: RG-05 de Windows como parcial y justificación del cifrado |
| Arcade | Tarea 17 marcada en curso con la advertencia de los 2 núcleos; tarea 18 reescrita para Debian; tarea 16 con la conexión a la Wi-Fi de invitados; administración desde la consola local |
| Arduino | Firmware con palanca digital de 4 microinterruptores (modo por defecto) y botones 7-8; compila (`pio run`: Flash 39,9 %, RAM 19,3 %) |
| ERP | Tarea 35 con menú de grupo al 10 % (`--iva`); TicketBAI decidido; tareas 32 y 33 al día; menús del cajero documentados |
| BD | [`06-datos.sql`](docs/bd/scripts/06-datos.sql) y [`07-consultas.sql`](docs/bd/scripts/07-consultas.sql); base central de la cadena; `almi_chain` en el mismo PostgreSQL y en las copias |
| Copias | Procedimiento para mover la BD al RAID; USB fuera del local cada lunes con aviso a los 7 días; RTO real marcado como sin medir |
| Web | CSP y Permissions-Policy en nginx; distancia y ruta a pie al local; créditos de las imágenes; diseño conceptual en la tarea 27 |
| Gestión | Fechas reales en las tareas hechas; responsables y revisores coherentes; Anexo II con requisitos separados; registro de IA ordenado |

---

## 2. Seguridad

### 2.1 Urgente: contraseñas

- [ ] 🔴 **Cambiar la contraseña Wi-Fi del TL-WR841N.** Tenía 8 cifras y se leía en las capturas antiguas, que siguen en el historial de Git. La nueva, una frase de KeePassXC de 20 caracteres o más. Si el router ya no se usa, apuntarlo.
  - **Quién:** Peio · **Dónde:** [tarea 24, sección 12](docs/redes/24-red-segura/DOCUMENTACION.md#12-pendiente) · **Hecho cuando:** contraseña cambiada y marcada en la tarea 24 (sin captura de la contraseña).
- [ ] 🟠 **Contraseña de administración del router** (parece la de fábrica): cambiarla, limitar la administración a la MAC del PC del gerente y hacer captura (sin la contraseña).
  - **Quién:** Peio · **Dónde:** tarea 24, secciones 8 y 12.
- [x] **Drive revisado (24/10/2026):** la carpeta solo tiene `VM-dualboot-W10-ubuntu-disk1.vmdk`, `Contraseñas.kdbx` (del 23/10) y la librería del joystick; **no hay ningún `.txt`**. El `.kdbx` es una base cifrada de KeePassXC: sin su contraseña maestra, que solo está en local, no sirve de nada. Cerrado.
- [ ] 🟠 **Contraseña de restic:** pasarla a KeePassXC y borrar `tarea-44/.credenciales-backup` del PC del técnico.
  - **Quién:** Iker · **Dónde:** [tarea 44, sección 5](docs/backup/44-backup-3-2-1/DOCUMENTACION.md).
- [ ] 🟢 En las recreativas instaladas con el preseed antiguo, borrar la línea `recreativa-claude` de `~tecnico/.ssh/authorized_keys`.
  - **Quién:** Iker.

### 2.2 Resto de seguridad

- [ ] 🔴 **HTTPS en Odoo (tarea 52):** proxy HTTPS delante de Odoo y, entonces, publicar el puerto como `"127.0.0.1:8069:8069"` en [`docker-compose.yml`](docs/erp/33-odoo-docker/odoo/docker-compose.yml) (ya hay un comentario). **Hecho cuando:** `https://192.168.10.10` abre el TPV y `http://192.168.10.10:8069` no responde desde otro equipo.
  - **Quién:** Adrian · Revisa Iker.
- [ ] 🟠 **Menús del cajero en Odoo:** ocultar Contactos, Empleados, Conversaciones, Calendario y Tableros al grupo del cajero (opciones en la [tarea 34, sección 9](docs/erp/34-configurar-odoo/DOCUMENTACION.md)). Probarlo en una base de pruebas, pasarlo a `configurar-odoo.py` y repetir la prueba 1 de la sección 8.2 con captura nueva.
  - **Quién:** Iker · Revisa Adrian.
- [ ] 🟢 Batocera: cambiar la contraseña de root y desactivar SSH si se elige (tarea 51).
- [ ] 🟢 Revisión de seguridad transversal (tarea 46) con todo lo anterior hecho.
  - **Quién:** Adrian · Revisa Markel.

---

## 3. Datos: BD, RAID y copias

### 3.1 Base de datos (tareas 41 y 42)

- [ ] 🔴 **Ejecutar los scripts nuevos** en un equipo con Docker: `bash scripts/verificar-repo.sh`. Tiene que dar OK en `06-datos.sql`, `8 facturas cargadas` y `07-consultas.sql: 12 consultas sin errores`. Si algo falla, corregir el script.
  - **Quién:** Iker · Revisa Eneko.S.
- [ ] 🔴 **Guardar la evidencia:** `psql -d almi_chain -f 07-consultas.sql > docs/bd/evidencias/41-consultas.txt` y revisar que los resultados tienen sentido (por ejemplo, C-08 devuelve la chuleta de Abando por debajo del mínimo; C-05, los platos sin ventas). Cambiar la evidencia de la tarea 41 en el CSV y pasarla a **Hecho**.
- [ ] 🔴 **Crear `almi_chain` en el servidor** (en el mismo PostgreSQL que Odoo) con los comandos de la [tarea 40, sección 2](docs/bd/40-scripts-ddl.md), y comprobar que la siguiente copia nocturna incluye `almi_chain.dump`.
- [ ] 🟠 **Usuarios con `LOGIN` (tarea 42):** crear un usuario de aplicación y uno de lectura con contraseñas de KeePassXC, documentarlos (sin contraseña) y guardar la evidencia de que no pueden hacer DDL ni borrar facturas.
  - **Quién:** Adrian · Revisa Iker.

### 3.2 RAID y copias (tareas 43-45)

- [ ] 🔴 **Mover la BD al RAID:** seguir la [tarea 43, sección 7](docs/backup/43-raid1/DOCUMENTACION.md#7-pendiente-la-base-de-datos-tiene-que-estar-en-el-raid) (`data-root` de Docker en `/srv/datos/docker`, y Docker arrancando después de montar el RAID). **Hecho cuando:** `docker info` dice `/srv/datos/docker` y Odoo funciona igual.
  - **Quién:** Iker · Revisa Adrian.
- [ ] 🔴 **Repetir la simulación de fallo con Odoo funcionando:** quitar un disco del RAID, hacer una venta y comprobar que se guarda. Evidencia nueva en `docs/backup/43-raid1/evidencias/`. Después, la tarea 43 pasa a **Hecho**.
- [ ] 🟠 **Probar el `backup-odoo.sh` nuevo** en la VM: la copia incluye las dos bases y, si el USB lleva más de 7 días sin conectarse, el servicio sale con error (`systemctl --failed`).
- [ ] 🟠 **RTO real:** restaurar en una VM nueva desde cero (preseed + `desplegar-odoo.sh` + restic) y cronometrar, como dice la [tarea 45, sección 6](docs/backup/45-restauracion/DOCUMENTACION.md). Poner ese tiempo en la tarea 45, en LOGICA_RETO y en el Anexo II.
- [ ] 🟢 Aviso por correo si la copia falla (`OnFailure=`). Mejora: tercer repositorio en S3.

---

## 4. Redes

### 4.1 Decisión: red plana o VLAN

- [ ] 🔴 **Decidir entre la opción (a) y la (b)** de la [tarea 23, apartado 5.5](docs/redes/23-plano-direccionamiento.md#55-decisión-pendiente-red-real-plana-o-con-vlan). Antes de elegir la (a), comprobar en la tabla de hardware de OpenWrt que el Archer C6 v3 está soportado. Apuntar la decisión en el Anexo II (sección 5) y en la tarea 23.
  - **Quién:** el equipo (Adrian lo apunta).

### 4.2 Packet Tracer (tarea 23)

- [ ] 🔴 **Añadir al `.pkt` la parte pública:** router ISP, servidor INTERNET (`198.51.100.10`), WAN `203.0.113.0/30`, NAT con sobrecarga en R1 y `dns-server` en los pools. La configuración está en la tarea 23, apartado 5.4. Si se elige la opción (b), simular la red plana y dejar el `.pkt` de VLAN como anexo.
  - **Quién:** Adrian · Revisa Iker.
- [ ] 🔴 **Wi-Fi en el `.pkt`:** punto de acceso de invitados (y otro del personal) y el portátil CLIENTE con tarjeta inalámbrica; un segundo punto de acceso hace de «WDS», explicando que la prueba real es la tarea 25.
- [ ] 🟠 **Seguridad de R1 y SW1:** `enable secret`, usuario local, SSH v2 en las `vty`, `service password-encryption`, y Fa0/7-24 apagados y en una VLAN sin uso.
- [ ] 🟠 **Pruebas nuevas y captura:** ping y HTTP a INTERNET desde cada VLAN, `show ip nat translations`, comprobar que desde INTERNET no se llega a ninguna IP interna y SSH a R1 y SW1. Rehacer `23-segmentacion-vlan.png` y la tabla de pruebas.

### 4.3 Routers reales (tareas 24-26)

- [ ] 🟠 **Repetir la tarea 24 en el Archer C6:** LAN `192.168.10.0/24`, reservas DHCP, WPA3 (o WPA2/WPA3), WPS desactivado, clave de grupo con renovación y modo sin 802.11b. Lista en la [tarea 24, sección 12](docs/redes/24-red-segura/DOCUMENTACION.md#12-pendiente).
  - **Quién:** Peio · Revisa Adrian.
- [ ] 🟠 **Red de invitados aislada** y pruebas 3 a 5 de la [tarea 23, sección 6](docs/redes/23-plano-direccionamiento.md#6-cómo-se-comprueba). Apuntar qué subred da el router de verdad.
- [ ] 🔴 **WDS (tarea 25):** segundo router, medidas de cobertura y velocidad, y comprobar si la red de invitados pasa por el enlace WDS. Si no pasa, documentarlo y corregir los diagramas (tarea 11 y LOGICA_RETO).
  - **Quién:** Peio · Revisa Iker.
- [ ] 🟢 Análisis con Wireshark y nmap (tarea 26). **Quién:** Eneko.S · Revisa Markel.
- [ ] 🟢 Apuntar las MAC de los equipos en la tabla 4.3 de la tarea 23 al montarlos.

---

## 5. Tareas del enunciado sin empezar

- [ ] 🔴 **Bastionado de los TPV en VM (tarea 13):** usuario estándar, modo quiosco con el navegador en el TPV de Odoo, USB de almacenamiento bloqueado y firewall con salida solo a Odoo, DNS y actualizaciones. Decidir la edición: Windows 10 IoT Enterprise LTSC 2021 o Windows 10 Pro + ESU (tarea 10, apartado 4.1). Pruebas RT-01, RT-04, RT-05 y RT-06 de la tarea 7.
  - **Quién:** Iker · Revisa Markel.
- [ ] 🔴 **Scripts de Windows (tarea 15):** PowerShell que repita la tarea 13 en los dos TPV (y la configuración del gerente).
  - **Quién:** Iker · Revisa Markel.
- [ ] 🔴 **Impresora en el TPV (tarea 14)**, cuando el centro dé la impresora: driver de Epson (apuntar la versión en la tarea 9), cola de impresión y página de prueba en la VM.
  - **Quién:** Adrian · Revisa Eneko.S.
- [ ] 🔴 **Ticket en la impresora real (tarea 37)**, con la impresora del centro.
  - **Quién:** Peio · Revisa Iker.
- [ ] 🔴 **Montar el arcade stick (tarea 19)** con la palanca Sanwa (sus 4 microinterruptores a A2-A5 y el común a GND) y los botones. Actualizar el esquema SVG con la palanca digital.
  - **Quién:** Markel · Revisa Peio.
- [ ] 🔴 **Probar el firmware en la placa (tarea 50):** lista del [README del stick](arduino/mando-joystick/README.md#pendiente-prueba-en-físico-tarea-50), con las pruebas nuevas de la palanca digital.
  - **Quién:** Adrian · Revisa Markel.
- [ ] 🔴 **Stick con MAME y otro emulador (tarea 21).**
  - **Quién:** Markel · Revisa Iker.
- [ ] 🟠 **Importar y exportar datos en Odoo (tarea 36):** importar la carta por CSV y exportar clientes o ventas (RA.7 de LMSGI).
  - **Quién:** Iker · Revisa Peio.
- [ ] 🟠 **IaC (tarea 31):** Terraform para el bucket S3, la EC2, la IP elástica y el grupo de seguridad (recursos en la tarea 30, sección 9) y publicación con GitHub Actions.
  - **Quién:** Iker · Revisa Adrian.

---

## 6. Dudas y decisiones (tarea 6)

Decidido por el equipo el 24/10/2026. Cuando salga la **rúbrica** se revisa todo con un criterio más objetivo; hasta entonces, esto queda cerrado.

| Duda | Decisión | Estado |
|---|---|---|
| Equipo de 6 personas (el enunciado dice 4-5) | El grupo es de **6 personas**. Eneko.P sigue sin tareas asignadas | [x] Cerrado |
| Dominio propio | **`almichain1.duckdns.org` vale**: no se compra dominio | [x] Cerrado |
| Fechas del reto | Del **lunes 26/10 al jueves 12/11/2026**. La planificación actual vale; no se replanifica hasta tener la rúbrica | [x] Cerrado |
| Base central o una por local | **Base central** (tarea 38, apartado 1.1) | [x] Cerrado |
| TicketBAI | **No hace falta configurarlo.** Se deja documentado como obligación legal (tarea 34, sección 6) | [x] Cerrado |
| Arranque dual en VM | **Una VM** vale | [x] Cerrado |
| Impresoras | **La impresora la da el centro.** Las tareas 14 y 37 esperan a tenerla | [x] Cerrado |
| Notación del E/R (pata de gallo o Chen) | Se mantiene pata de gallo | [ ] Revisar con la rúbrica |

**Pendiente:** Peio apunta estas decisiones en el Anexo II (sección 5) y en la observación de la tarea 6 del CSV, y la pasa a **Hecho**.

---

## 7. Repetir pruebas en las VM y en AWS

### 7.1 Recreativa (tareas 17, 18, 51, 53 y 54)

- [ ] 🔴 **Rendimiento en la VM `Recreativa-1GB` (1 núcleo, 1 GB):** 3 medidas antes y 3 después con la versión nueva de `optimizar-arcade.sh` (`medir-rendimiento.sh --bench`). Sustituir las tablas de la [tarea 17](docs/arcade/17-rendimiento-mame/DOCUMENTACION.md) y pasarla a **Hecho**.
  - **Quién:** Iker · Revisa Adrian.
- [ ] 🟠 **Medir jugando:** `monitor-recreativa.sh` durante una partida de 10 minutos (protocolo de la [tarea 18, sección 5](docs/arcade/18-monitorizacion-recreativa.md)) y guardar los CSV en `docs/evidencias/18-monitorizacion/`.
  - **Quién:** Adrian · Revisa Markel.
- [ ] 🟠 **Decidir entre Debian y Batocera (tarea 51)** con esas medidas y apuntarlo en el Anexo II.
  - **Quién:** Iker · Revisa Markel.
- [ ] 🟠 **Recreativa real (tarea 53):** mismo preseed (con `preseed-local.cfg`) y conexión a la Wi-Fi de invitados ([tarea 16, sección 6](docs/arcade/16-recreativa-mame/DOCUMENTACION.md#6-conexión-a-la-wi-fi-de-invitados)); después, las medidas reales (tarea 54).
  - **Quién:** Eneko.S · Revisa Iker.

### 7.2 ERP

- [ ] 🟠 **Repetir la factura automática** con el caso de uso nuevo (menú de grupo: 20 × 30 € + 10 % = 660,00 €) y sustituir los PDF y las salidas de `evidencias/` en la [tarea 35](docs/erp/35-factura-automatica/DOCUMENTACION.md).
  - **Quién:** Iker · Revisa Adrian.

### 7.3 Gerente (tarea 12)

**Quién (los tres puntos):** Adrian · Revisa Eneko.S.

- [ ] 🟠 **Versión exacta de Ubuntu** (`lsb_release -d`) y nombre de la ISO, en la tarea 12 y en la tarea 9.
- [ ] 🟠 **Windows Update:** conectar la VM, instalar las actualizaciones acumulativas y repetir la evidencia de RG-05.
- [ ] 🟢 **Cifrado:** BitLocker en `C:` (clave de recuperación en KeePassXC) y LUKS para los datos de Ubuntu; después, probar el arranque desde GRUB.

### 7.4 Web (tareas 29 y 30)

**Quién (los dos primeros puntos):** Adrian · Revisa Iker.

- [ ] 🟠 **Publicar la versión actual:** con el Learner Lab arrancado, `aws s3 sync web/ s3://almi-chain-web-2026/ --delete --exclude "README.txt" --exclude ".gitkeep"`, y volver a ejecutar `instalar-servidor-web.sh` para que nginx tenga las cabeceras CSP y Permissions-Policy.
- [ ] 🟠 **Repetir las pruebas contra la URL pública:** `curl -I https://almichain1.duckdns.org` (que `Content-Length` coincida con el tamaño de `web/index.html` y que salgan las cabeceras nuevas), Lighthouse y W3C. Sustituir `08-pruebas-curl.txt` y `lighthouse-w3c.txt`.
- [ ] 🟢 Copiar las imágenes de Unsplash a `web/` (con su autor) y cambiar la foto del primer plato del carrusel, que es la misma que la de la portada.

---

## 8. Gestión y documentación

- [x] **Planificación:** el reto va del 26/10 al 12/11/2026 y la planificación actual del CSV vale (decisión del 24/10; se revisa con la rúbrica). Las tareas hechas conservan sus fechas reales.
- [ ] 🟠 **Revisar las filas del [registro de IA](docs/gestion/registro-ia.md)** que dicen «pendiente de revisar por el equipo»: quien revise pone lo que comprobó y su nombre.
  - **Quién:** cada persona, sus filas.
- [ ] 🟠 **Regenerar `arquitectura-equipos.svg`** desde el Mermaid de la tarea 11 y, cuando existan, enlazar las guías de los TPV y de las impresoras en su sección 5. Si cambia la red (4.1), dibujar las redes reales y la WAN.
  - **Quién:** Iker · Revisa Adrian.
- [ ] 🟢 Revisar los documentos que siguen «pendiente de revisión» (tareas 7, 8, 11, 12, 23, 27, 30…): el revisor del CSV aprueba el PR y la tarea pasa a **Hecho** si tiene evidencias.
- [ ] 🟢 Documentación final y presentación (tareas 48 y 49), cuando esté lo anterior.

---

## 9. Cumplimiento del enunciado (estado tras el 24/10)

| Tarea del enunciado | Estado | Qué falta | Sección |
|---|---|---|---|
| Necesidades, configuración y presupuesto de equipos e impresoras | Hecho | Precio de la licencia de Windows de los TPV (la impresora la da el centro) | 5 |
| Identificar y documentar el hardware necesario | Hecho | — | — |
| Identificar y documentar el software necesario | Hecho, con huecos | Versión de Ubuntu y del driver de Epson | 7.3, 5 |
| Instalación, optimización y monitorización de la recreativa | Parcial | Medidas en 1 núcleo y 1 GB; monitorización jugando | 7.1 |
| Montaje y programación del arcade stick | Parcial | Montaje y prueba en placa | 5 |
| Identificar necesidades de comunicación | Hecho | — | — |
| Implementación y configuración de sistemas operativos | Parcial | TPV | 5 |
| Restricción de cuentas y equipos (mínimos privilegios) | Parcial | TPV; menús del cajero | 5, 2.2 |
| Diseño conceptual de la web | Hecho, a posteriori | — | — |
| Web accesible y por HTTPS | Hecho | Publicar la versión actual | 7.4 |
| Hosting en AWS con dominio propio y despliegue reproducible | Parcial | IaC (DuckDNS vale como dominio) | 5 |
| ERP + TPV con un caso de uso automatizado | Hecho | Repetirlo con el caso de uso nuevo | 7.2 |
| Instalación y configuración de una impresora | **Sin empezar** | Tareas 14 y 37 | 5 |
| Modelo E/R y tablas | Hecho | Notación, a revisar con la rúbrica | 6 |
| Implementación de la BD y consulta de sus datos | Parcial | Ejecutar los scripts y guardar la evidencia | 3.1 |
| Configurar disco redundante | Parcial | **La BD no está en el RAID** | 3.2 |
| Plan de copias y prueba de restauración | Hecho, con huecos | RTO en una máquina nueva | 3.2 |
| Seguridad por defecto en toda la solución | Parcial | Contraseñas; HTTPS en Odoo; red | 2 |
| Verificar con pruebas (funcionamiento, restauración, failover) | Parcial | WDS; invitados; TPV; stick; fallo con Odoo en marcha | 3.2, 4.3, 5 |
| Documentación reproducible con diagramas | Parcial | Guías de los TPV; SVG de la tarea 11 | 5, 8 |
| Seguimiento (Gantt o Kanban) y Git | Hecho, con huecos | Commits de Eneko.P | 8 |
| Documentación y presentación | Pendiente | Tareas 48 y 49 | 8 |

**Redes, en concreto:**

| Pide el enunciado | Estado |
|---|---|
| Contratar una línea WAN | Hecho (DIGI 1 Gb, con análisis de necesidades) |
| Esquema de conectividad | Hecho ([tarea 22, sección 4](docs/redes/22-comparativa-wan.md#4-esquema-de-conectividad)) |
| Diagrama de la red (plano), cableado y Wi-Fi | Plano hecho; Packet Tracer sin WAN ni Wi-Fi (4.2) |
| Red configurada de forma segura | Parcial: decisión de red (4.1), invitados sin configurar y contraseñas (2.1) |
| Segundo router por WDS, comprobando que funciona | Sin empezar (4.3) |
| RA.7 de PAR: conectar redes privadas a públicas | Sin demostrar hasta añadir NAT y WAN a Packet Tracer (4.2) |
