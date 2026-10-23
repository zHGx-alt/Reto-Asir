# Correcciones del reto Almi-Chain

Revisión de todo el repositorio contra el **enunciado** ([Reto_1_ASIR1_2026-2027.docx](Reto_1_ASIR1_2026-2027.docx)), que es la única fuente fiable. El plan ([almi-chain-plan.pdf](almi-chain-plan.pdf)) lo hizo el equipo y no cuenta como requisito.

- **Fecha:** 24/10/2026
- **Qué se ha revisado:** todos los documentos, scripts, evidencias e imágenes de `docs/`, `web/`, `arduino/`, `scripts/`, `iac/` y la raíz. El fichero de Packet Tracer (`23-segmentacion-vlan.pkt`) se ha descifrado para leer la configuración real de R1 y SW1, y no solo la captura.
- **Gravedad:**
  - **Grave:** incumple el enunciado o es un fallo de seguridad.
  - **Media:** error o incoherencia que un evaluador puede ver.
  - **Leve:** mejora o detalle.

---

## 0. Resumen: lo primero que hay que arreglar

| # | Gravedad | Problema | Sección |
|---|---|---|---|
| 1 | Grave | **La contraseña Wi-Fi (`22123256`) se ve en dos capturas subidas al repo**, aunque el documento dice que están ocultas. También se ve la contraseña RADIUS `admin` | [1.1](#11-contraseñas-a-la-vista) |
| 2 | Grave | **Packet Tracer: solo hay una red interna, sin WAN ni Internet.** No hay router del operador, NAT, red pública, Wi-Fi ni segundo router WDS. El enunciado pide conectar la red privada a una pública (RA.7 de PAR) | [2.1](#21-packet-tracer-solo-hay-una-red-interna) |
| 3 | Grave | **La red que se va a montar de verdad es una sola LAN plana** (`192.168.10.0/24`): servidor, gerente y TPV en la misma red. Las VLAN solo están en la simulación, como «diseño ideal» | [2.2](#22-el-diseño-real-y-el-simulado-no-coinciden) |
| 4 | Grave | **La base de datos de Odoo no está en el RAID.** El RAID (`/srv/datos`) solo guarda las copias; PostgreSQL está en `/var/lib/docker`, en el disco del sistema. El enunciado dice que la BD «se almacenará en un dispositivo redundante» | [8.1](#81-la-bd-no-está-en-el-dispositivo-redundante) |
| 5 | Grave | **La BD diseñada (`almi_chain`) no tiene datos ni consultas**, no está instalada en el servidor y no entra en las copias. El enunciado pide «implementación de la base de datos y consulta de sus datos» | [7](#7-bases-de-datos) |
| 6 | Grave | **TPV sin restringir, impresora sin instalar y arcade stick sin montar** (tareas 13, 14, 15, 19, 21, 37, 50). Son tareas literales del enunciado | [12](#12-cumplimiento-del-enunciado-tarea-por-tarea) |
| 7 | Grave | **Rendimiento de MAME medido en una VM de 2 núcleos y 1,5 GB**, no en la de 1 núcleo y 1 GB del enunciado | [5.1](#51-recreativa) |
| 8 | Media | **Planificación de 3 semanas y equipo de 6 personas.** El enunciado dice 10 semanas (Anexo VIII) y equipos de 4-5 personas. Además, el Gantt marca como hechas tareas con fechas futuras | [9](#9-gestión-del-proyecto) |
| 9 | Media | **La web publicada no es la del repositorio.** Las pruebas de HTTPS sirven un `index.html` de 7.143 bytes (versión del 22/10); el actual tiene 9.167. Lighthouse se pasó en local | [10](#10-web-y-aws) |
| 10 | Media | **El servidor (Odoo, BD y RAID) no está en el presupuesto**, ni sus discos, ni el disco USB de copias, ni el cable, ni las piezas del stick | [3](#3-hardware-software-y-presupuesto) |

---

## 1. Seguridad (urgente)

### 1.1 Contraseñas a la vista

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Grave | [`07-wifi-seguridad-primera.png`](docs/redes/24-red-segura/imagenes/07-wifi-seguridad-primera.png) y [`08-wifi-seguridad-final.png`](docs/redes/24-red-segura/imagenes/08-wifi-seguridad-final.png) | Se lee la contraseña Wi-Fi `22123256`. El recuadro negro tapa otra zona. En la 08 se ve también la contraseña RADIUS `admin`. El documento dice: «Las contraseñas visibles en las capturas originales se han ocultado» | 1) **Cambiar ya esa contraseña Wi-Fi** si el router sigue en uso: está en el historial de Git y borrar la imagen no la quita de ahí. 2) Volver a tapar las imágenes encima del campo correcto. 3) gitleaks no lo detecta porque no analiza imágenes: revisar cada captura a ojo antes de subirla |
| Grave | Mismas capturas | La contraseña tiene 8 cifras. Va contra «contraseñas robustas» y contra la norma del propio proyecto (KeePassXC) | Frase de contraseña generada con KeePassXC, de 20 caracteres o más |
| Media | [`11-acceso-administracion.png`](docs/redes/24-red-segura/imagenes/11-acceso-administracion.png) | El panel se entra como `Admin` con una contraseña de 5 caracteres: parece la de fábrica (`admin`). El panel va por HTTP («No es seguro») y la administración local está abierta a todos los equipos de la LAN (captura 04) | Documentar el cambio de la contraseña de administración y limitarla a la MAC del PC del gerente |
| Media | [README](README.md) y backlog (tarea 55) | El backlog dice «falta subir a Drive el .vmdk y el .kdbx nuevos y **borrar el .txt antiguo**». Ese `.txt` tenía las contraseñas débiles y está en una carpeta de Drive enlazada desde el README | Borrar el `.txt` de Drive y comprobar quién tiene acceso a la carpeta |
| Media | [`44-backup-3-2-1/DOCUMENTACION.md`](docs/backup/44-backup-3-2-1/DOCUMENTACION.md), sección 5 | La contraseña de cifrado de restic está «en el PC del técnico» en un fichero de texto (`.credenciales-backup`). Contradice la norma de usar KeePassXC | Guardarla en KeePassXC y borrar el fichero |
| Media | [`preseed-recreativa.cfg`](docs/arcade/16-recreativa-mame/preseed-recreativa.cfg) | El preseed mete en `authorized_keys` una clave llamada `recreativa-claude`, la del equipo donde se ejecutó el agente de IA. Quien tenga esa clave privada entra en todas las recreativas instaladas con este fichero | Pasar la clave pública como parámetro (o usar la del equipo de administración) y no dejar una fija en el repositorio |

### 1.2 Otros puntos de seguridad

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Grave | Odoo (tareas 33 y 52) | Odoo va por **HTTP**: las contraseñas de cajeros y gerente viajan sin cifrar por la LAN y por la Wi-Fi del personal. El enunciado pide «comunicaciones cifradas» | Tarea 52: proxy HTTPS. Al hacerlo, publicar 8069 solo en `127.0.0.1` (ahora `docker-compose.yml` lo publica en todas las interfaces) |
| Media | [`optimizar-arcade.sh`](docs/arcade/17-rendimiento-mame/optimizar-arcade.sh) | Desactiva `apt-daily-upgrade`: la recreativa se queda **sin actualizaciones de seguridad automáticas**. Va contra «seguridad por defecto» | Dejar `unattended-upgrades` programado fuera del horario del local (por ejemplo, a las 5:00) en vez de quitarlo |
| Media | Recreativa (tareas 16 y 23) | Tiene SSH abierto con contraseña (el preseed no desactiva `PasswordAuthentication`) y está en la **Wi-Fi de clientes** | `PasswordAuthentication no` y, si es posible, SSH solo desde la red de administración |
| Media | [`23-plano-direccionamiento.md`](docs/redes/23-plano-direccionamiento.md), 5.2, y [tarea 24](docs/redes/24-red-segura/DOCUMENTACION.md), 9 | Contradicción: la tarea 24 pide aislar a los clientes entre sí en la red de invitados, y la 23 dice que la recreativa se administra conectando un portátil **a esa misma red**. Con el aislamiento activado, no se llega | Elegir uno: o recreativa en su propia red (VLAN 40, como en Packet Tracer) o administrarla desde la consola local |
| Leve | [Batocera](docs/arcade/16-batocera/NOTAS.md) | Root con contraseña `linux` y SSH activo de fábrica | Ya anotado; no conectarla a la red hasta endurecerla |

---

## 2. Redes

### 2.1 Packet Tracer: solo hay una red interna

**Qué hay de verdad en el `.pkt`** (configuración leída del fichero, no de la captura):

| Equipo | Configuración |
|---|---|
| R1 (2911) | `Gi0/0` con 6 subinterfaces (VLAN 10, 20, 30, 40, 50 y 99), DHCP y 3 ACL. **`Gi0/1` y `Gi0/2` apagadas y sin IP.** Sin ruta por defecto, sin `ip nat`, sin `enable secret`, sin SSH, `no service password-encryption` |
| SW1 (2960) | Fa0/1-Fa0/6 en sus VLAN; trunk en Gi0/1. **Fa0/7-Fa0/24 encendidos y en la VLAN 1.** Sin contraseñas |
| Hosts | 5 PC/servidor y un portátil, **todos por cable** |
| Enlaces | 7 cables. No hay ningún enlace inalámbrico |

Las 6 VLAN son 6 subredes, pero las 6 cuelgan del mismo router y **ninguna sale de él**. No hay red pública, así que la simulación no representa lo que pide el enunciado:

| El enunciado pide | En el `.pkt` |
|---|---|
| «Contratar una línea WAN» y un «esquema de conectividad» | No hay router del operador ni red WAN |
| RA.7 de PAR: «Conecta redes privadas a redes públicas» | No hay red pública ni NAT. Las ACL terminan en `permit ip any any` («internet sí»), pero no hay Internet que probar |
| Plano «cableado y Wi-Fi» | No hay ningún punto de acceso. El «CLIENTE» (Wi-Fi de invitados) es un portátil con cable |
| «Otro router Wi-Fi conectado mediante WDS al router principal» | No hay segundo router |
| «Red configurada de forma segura» | R1 y SW1 sin contraseñas ni SSH; la «VLAN de gestión» no sirve para administrar nada (la prueba 3 solo hace ping). Puertos libres del switch activos en la VLAN 1. Los pools DHCP no reparten DNS |

**Cómo corregirlo** (mínimo para que haya, como mínimo, una red privada y una pública):

1. Añadir un router **ISP** (el de DIGI) y, detrás, un servidor «Internet» con HTTP y DNS (por ejemplo `198.51.100.10`).
2. WAN entre R1 y el ISP en `Gi0/1`, con una red propia (por ejemplo `203.0.113.0/30`), y NAT con sobrecarga en R1:
   ```
   interface GigabitEthernet0/1
    ip address 203.0.113.2 255.255.255.252
    ip nat outside
    no shutdown
   ! en cada subinterfaz Gi0/0.10 ... Gi0/0.99:
    ip nat inside
   ip route 0.0.0.0 0.0.0.0 203.0.113.1
   access-list 1 permit 192.168.0.0 0.0.255.255
   ip nat inside source list 1 interface GigabitEthernet0/1 overload
   ```
   En cada pool DHCP: `dns-server 198.51.100.10`.
3. Wi-Fi: un punto de acceso en un puerto de la VLAN 50 (SSID de invitados, WPA2/WPA3) y otro para el personal; el portátil CLIENTE, con tarjeta inalámbrica. El segundo router (WDS) se puede representar como otro punto de acceso con el mismo SSID. Hasta donde sé, Packet Tracer no simula WDS tal cual, así que hay que dejar escrito que la prueba de verdad es la tarea 25 con los Archer C6.
4. Seguridad: `enable secret`, usuario local, `ip ssh version 2` y `transport input ssh` en las `vty` de R1 y SW1; `service password-encryption`; apagar Fa0/7-24 y pasarlos a una VLAN sin uso.
5. Pruebas nuevas: de cada VLAN a Internet (`ping 198.51.100.10` y abrir la web), `show ip nat translations` en R1, y que desde Internet no se llega a ninguna IP interna.
6. Rehacer la captura `23-segmentacion-vlan.png` y la tabla de pruebas de la sección 5.4.

### 2.2 El diseño real y el simulado no coinciden

| Gravedad | Problema | Cómo corregirlo |
|---|---|---|
| Grave | Con el hardware presupuestado (2 Archer C6 de fábrica) **todo el personal está en una sola red**. El documento lo reconoce: separar TPV y gerente «por rangos» (.20 / .30) **no aísla nada**, porque cualquiera puede ponerse una IP fija. El diseño con VLAN solo existe en Packet Tracer | Una de dos: **(a)** montar de verdad las VLAN: un switch gestionable de 8 puertos (que además hace falta, ver 2.3) y un router que las enrute; el Archer C6 v3 parece estar soportado por OpenWrt, pero hay que comprobarlo en su tabla de hardware antes de decidirlo. **(b)** Mantener la red plana, pero entonces Packet Tracer tiene que simular **esa** red (router con NAT, LAN del personal, red de invitados y WDS) y la de VLAN queda como anexo de mejora |
| Media | La subred `192.168.20.0/24` es la **Wi-Fi de invitados** en el diseño real (tabla 4.1) y la **VLAN de los TPV** en el ideal (tabla 5.3) | Cambiar una de las dos para que la misma red no signifique cosas distintas |
| Media | La red de invitados no está configurada ni probada en ningún router (tarea 24, sección 9). Es la única separación que tiene el diseño real | Configurarla en el Archer C6 y probar el aislamiento (prueba 4 de la sección 6 de la tarea 23) |
| Media | No se sabe si la red de invitados del Archer C6 pasa por el enlace WDS al router 2. El diagrama (tarea 11) y LOGICA_RETO lo dan por hecho («amplía las dos Wi-Fi») | Comprobarlo en la tarea 25; si no funciona, documentarlo y corregir los diagramas |

### 2.3 Otros errores de redes

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Media | [`23-plano-direccionamiento.md`](docs/redes/23-plano-direccionamiento.md), sección 1 | Dice «El enunciado pide un *plano del local con cableado y Wi-Fi* y un *plan de direccionamiento IP y segmentación (TPV, gerente, clientes, arcade)*». **Esas frases no están en el enunciado**: son del plan del equipo. El enunciado dice «esquema de conectividad y un diagrama de la arquitectura de red (plano), cableado y Wi-Fi, con la red configurada de forma segura» | Citar el enunciado literal y decir que la segmentación por grupos es una decisión del equipo |
| Media | Tarea 24 | Hecha en un **TL-WR841N**, que no es el router presupuestado, con la LAN en `192.168.1.0/24` (el plan de IP usa `192.168.10.0/24`). Modo `11bgn mixed` (admite 802.11b), periodo de renovación de la clave de grupo a 0 y sin evidencia de WPS desactivado. El documento no tiene cabecera (responsable, fecha, revisor) | Repetirla con el Archer C6 (WPA3, invitados, WPS desactivado) o explicar por qué vale el TL-WR841N |
| Media | [`22-comparativa-wan.md`](docs/redes/22-comparativa-wan.md) | Solo compara precios. El enunciado pide «identificar necesidades de comunicación en función de los requerimientos» y un «esquema de conectividad», y no están. Faltan: cuántos equipos y qué ancho de banda necesitan, subida simétrica, IP fija o CG-NAT, servicio técnico para empresa. Las fuentes no tienen enlace. La tabla HTML está mal: todas las filas van en `<thead>` y el `<tbody>` está vacío | Añadir el análisis de necesidades, el esquema WAN → router → LAN/invitados y los enlaces a las ofertas; pasar la tabla a Markdown |
| Media | Tareas 7 (diagrama) y 23 (supuesto S-05) | La tarea 7 dibuja un **switch**; la 23 dice que no hay. Con los 4 puertos LAN ocupados, la recreativa tiene que ir por Wi-Fi y no queda ningún puerto libre | Presupuestar un switch (lo pide también la opción (a) de 2.2) |
| Leve | [`10-presupuesto-hardware.md`](docs/hardware/10-presupuesto-hardware.md), 4.3 y 7 | Impresoras en `.21` y `.22`, dentro del rango de **gerencia** (`.20-.29`) de la tarea 23. La propia tarea 23 pide cambiarlo y sigue igual | Pasarlas a `.40-.49` o quitar las IP, porque van por USB |
| Leve | Tarea 7 (RT-08) | Habla de «la red de TPV», que en el diseño real no existe | Ajustar el texto al diseño que se elija en 2.2 |

---

## 3. Hardware, software y presupuesto

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Media | [Tarea 10](docs/hardware/10-presupuesto-hardware.md) | Falta lo que sostiene la mitad del proyecto: **servidor** (Odoo, BD, RAID), **2 discos del RAID**, **disco USB de copias**, **SAI** del servidor, **cable Cat6** (~50 m según el plano), canaletas, **switch**, adaptador Wi-Fi de la recreativa, **placa, botones y palanca del stick** | Añadirlos con precio y enlace. Si el centro los presta, ponerlo como supuesto, con su coste de referencia |
| Media | Tareas 7, 8, 9 y 10 | Windows 10 no tiene soporte desde el 14/10/2025, y el ESU para particulares terminó el 13/10/2026. Los equipos traen Windows 11 Pro y el derecho de *downgrade* sigue sin confirmar (H-01) | Para los TPV, valorar **Windows 10 IoT Enterprise LTSC 2021**, con soporte hasta 2032 y pensado para equipos de función fija. Otra opción es el ESU de pago para empresas. Tiene que verse en el presupuesto |
| Media | [Tarea 9](docs/hardware/09-tabla-software-licencias.md) | Sin versiones (lo dice el propio backlog). Falta el software del servidor (Debian 13, Docker, Odoo 19, PostgreSQL 17, mdadm, restic) y de la recreativa (Debian, MAME 0.276). El enunciado pide «detalles tanto del hardware como del software que se les va a instalar». El precio de Windows pone «De pago» | Completar la tabla con versión, equipo y licencia de cada programa |
| Leve | Tarea 7, RG-07 | Pide acceso a Odoo «por HTTPS», que aún no existe (tarea 52) | Mantener el requisito y cerrarlo con la 52 |
| Leve | [`registro-ia.md`](docs/gestion/registro-ia.md) | Para la tarea 8 da una suma de 2.444,04 €; la cifra correcta es 2.361,36 € | Actualizar |

---

## 4. Sistemas operativos

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Grave | Tareas 13, 14 y 15 | **No hay nada de los TPV**: ni VM, ni usuario restringido, ni quiosco, ni bloqueo de USB, ni impresora, ni scripts de Windows. Es la parte del enunciado que más insiste en los «mínimos privilegios» | Prioridad alta |
| Media | [`12-dual-boot.md`](docs/so/12-dual-boot.md) | La versión de Ubuntu está sin rellenar («versión exacta: `lsb_release -d`»). Sin ella, la guía no se puede repetir igual | Apuntar la versión exacta y la ISO |
| Media | Tarea 12, prueba RG-05 Windows | Se da por buena, pero el historial ([`win-07`](docs/evidencias/12-dual-boot/win-07-historial-windows-update.txt)) solo tiene una actualización de 2022 (KB5020683, del instalador) y un driver; el 23/10 todo falla. **Ninguna actualización acumulativa de seguridad instalada** | Instalar las actualizaciones disponibles y repetir la evidencia, o poner el resultado como «parcial» |
| Leve | Tarea 12 | El equipo del gerente queda sin cifrar (BitLocker desactivado para el arranque dual) | Justificarlo o cifrar después de instalar (BitLocker en Windows, LUKS en la partición de datos de Linux) |

---

## 5. Recreativa y arcade stick

### 5.1 Recreativa

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Grave | [Tarea 17](docs/arcade/17-rendimiento-mame/DOCUMENTACION.md) | El antes y el después se midieron en una VM de **2 núcleos y 1,5 GB**. En la de 1 núcleo y 1 GB solo hay 3 medidas de «antes». El enunciado: «un procesador de un núcleo y 1 GB de RAM» y «dejando constancia de las pruebas de rendimiento». Ahora mismo la tarea 17 no demuestra nada sobre el equipo del cliente | Repetir antes y después en `Recreativa-1GB` y sustituir las tablas |
| Media | Tareas 17 y 18 | No se ha medido el rendimiento **jugando** (FPS, CPU y RAM durante la partida): solo `-bench`, que emula sin pantalla ni límite de velocidad. La monitorización (tarea 18) no se ha ejecutado nunca en la recreativa | Ejecutar `monitor-recreativa.sh` durante una partida en la VM de 1 GB y guardar los CSV |
| Media | [Tarea 18](docs/arcade/18-monitorizacion-recreativa.md) | Está escrita para **Batocera** (`ssh root@...`, `/userdata`), pero el sistema elegido (provisional) es Debian. Dice «Batocera pide 1 GB como mínimo» y las notas de Batocera dicen **2 GB** | Escribirla para el sistema que se elija y corregir el dato |
| Media | Tarea 16 | La recreativa va por **Wi-Fi** (tarea 23), pero la instalación solo configura cable. No se explica cómo conectarla a la Wi-Fi (firmware, `wpa_supplicant` o NetworkManager) ni qué adaptador lleva | Añadir el paso y el adaptador al presupuesto |
| Leve | Tarea 51 | No se ha decidido entre Debian y Batocera, y las tareas 16, 17 y 18 dependen de esa decisión | Decidir con datos y reflejarlo en el Anexo II |

### 5.2 Arcade stick

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Grave | Tareas 19, 21 y 50 | El stick **no está montado ni probado** en placa, ni con MAME ni con otro emulador. El enunciado pide «montar el arcade stick» | Prioridad alta (tareas físicas) |
| Media | [`mando_joystick.ino`](arduino/mando-joystick/mando_joystick/mando_joystick.ino) | El firmware solo lee una **palanca analógica** (`analogRead` en A0/A1). Una palanca de arcade normal (Sanwa, Zippy…) son **4 microinterruptores digitales**, no un potenciómetro. Si se compra una palanca arcade, el firmware no la lee | Añadir el modo digital: 4 pines con `INPUT_PULLUP` (arriba, abajo, izquierda, derecha) que muevan los ejes a 0 / centro / 1023. Que la palanca que se compre case con el firmware |
| Leve | [Esquema](arduino/mando-joystick/esquema-conexiones.svg) y README | Con 6 botones, Moneda y Start ocupan 2 y quedan 4 para jugar | Valorar 2 botones más (los pines 8 y 9 están libres) |

---

## 6. ERP (Odoo)

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Media | [Tarea 35](docs/erp/35-factura-automatica/DOCUMENTACION.md) | El caso de uso factura «Partida recreativa» y «Alquiler recreativa (día)» a «Bar Pepe» con IVA del 21 %. No es una operación de un restaurante, y el enunciado pide «un caso de uso **real**» | Automatizar algo del negocio: factura completa a un cliente desde un pedido del TPV, o factura de un evento o menú de grupo con IVA del 10 % |
| Media | [Tarea 34](docs/erp/34-configurar-odoo/DOCUMENTACION.md), 8.2 | El cajero ve **Contactos, Empleados, Conversaciones, Calendario y Tableros**, y puede leer facturas, diarios y usuarios. Ver los datos de los clientes y del personal no le hace falta para cobrar | Quitar esas apps al grupo del cajero y comprobarlo con la captura |
| Media | Tarea 34, sección 6 | Se deja «a decidir» entre TicketBAI y Veri*Factu, pero la web pone el restaurante en **Bilbao**, y en Bizkaia rige **TicketBAI (Batuz)**, no Veri*Factu. Sin eso el restaurante no podría facturar legalmente | Decidir TicketBAI, coherente con la ubicación, y documentar por qué no se configura (certificado) |
| Media | Tarea 36 | Importar y exportar datos está sin hacer. El RA.7 de LMSGI lo pide expresamente («importación, integración, aseguramiento y extracción») | Prioridad alta |
| Leve | Tarea 32 | Dice que la contabilidad completa es solo de Enterprise, pero en la tarea 34 se usa el plan PYMES y se generan asientos en Community | Precisar qué falta en Community (informes contables completos, conciliación avanzada…) |
| Leve | [Tarea 33](docs/erp/33-odoo-docker/DOCUMENTACION.md) | Dice aún que «la tarea 32 todavía no está cerrada» y la sección 8 manda tareas a Markel y Peio, que ya no las llevan | Actualizar |

---

## 7. Bases de datos

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Grave | Tarea 41 | **No hay datos ni consultas**: los scripts cargan 0 filas. El enunciado: «Implementación de la base de datos y consulta de sus datos» | INSERT de prueba y consultas con JOIN, agregados y subconsultas, con su salida como evidencia |
| Grave | Tareas 40 y 44 | `almi_chain` solo se ha probado en un PostgreSQL 16 aparte. **No está en el servidor, ni en el RAID, ni en las copias** | Crearla en el servidor (en el mismo PostgreSQL, sobre el RAID, ver 8.1) y añadirla a `backup-odoo.sh` |
| Media | [`38-modelo-er.md`](docs/bd/38-modelo-er.md) y [`40-scripts-ddl.md`](docs/bd/40-scripts-ddl.md) | Se dice «una base de datos **por establecimiento**», pero el modelo tiene la tabla `ESTABLECIMIENTO`, `STOCK` por local y catálogos comunes (clientes, platos, campañas). Eso es una base **central** de toda la cadena. Con una base por local, `establecimiento` tendría una sola fila y los clientes y platos se repetirían en cada local | Elegir y justificar: o una BD por local sin la dimensión «establecimiento», o una central, explicando que el enunciado habla de «las bases de datos que habrá en cada establecimiento» |
| Media | Tarea 42 | Faltan los usuarios con `LOGIN` y su evidencia | Ya anotado en el backlog |
| Leve | Tarea 38 | El E/R está en notación «pata de gallo» (Mermaid). En la asignatura suele pedirse Chen | Confirmar con el profesor qué notación quiere |

---

## 8. RAID y copias de seguridad

### 8.1 La BD no está en el dispositivo redundante

[`crear-raid1.sh`](docs/backup/43-raid1/crear-raid1.sh) monta el RAID en `/srv/datos`, y la tarea 43 dice: «Ahí irán las copias de seguridad». PostgreSQL y los adjuntos de Odoo siguen en los volúmenes de Docker (`/var/lib/docker/volumes/...`, lo usa `backup-odoo.sh`), que están en `sda`, el disco del sistema, **fuera del RAID**.

El enunciado dice: «Esta BD **se almacenará en un dispositivo redundante**». Si falla `sda`, la base de datos viva se pierde y hay que restaurar la última copia (hasta 24 h de datos perdidos). La prueba de fallo del RAID no lo detecta porque el disco que se «rompió» era del RAID, no el del sistema.

**Cómo corregirlo:** mover el `data-root` de Docker (`/etc/docker/daemon.json`) o los volúmenes `odoo-db-data` y `odoo-web-data` a `/srv/datos`, o instalar el sistema entero sobre el RAID 1. Después, repetir la simulación de fallo con Odoo funcionando durante el fallo, y llevar las copias a otro sitio que no sea el mismo RAID (ver 8.2).

### 8.2 Otros puntos

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Media | [Tarea 44](docs/backup/44-backup-3-2-1/DOCUMENTACION.md) | La copia «fuera del local» depende de que el gerente traiga el USB. Mientras está en su casa, la copia diaria al USB no se hace, y no está escrito cada cuánto se renueva la copia externa | Fijar la frecuencia (por ejemplo, cada lunes) y que el servicio avise si el USB no está. Mejor aún: el tercer repositorio en S3 que ya se propone |
| Media | [Tarea 45](docs/backup/45-restauracion/DOCUMENTACION.md) | La restauración se hizo **en el mismo servidor**. El «RTO de 46 s» no incluye reinstalar el servidor, que es lo que pasaría si se pierde | Repetirla en una VM nueva (preseed + `desplegar-odoo.sh` + restic) y dar ese tiempo como RTO real |
| Leve | Tarea 44 | Sin aviso si la copia falla (`OnFailure=`) | Ya anotado como pendiente |

---

## 9. Gestión del proyecto

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Media | [Anexo I](docs/gestion/anexo-I-contrato-equipo.md) y [roles](docs/gestion/roles.md) | El equipo es de **6 personas**; el enunciado dice «Equipos de 4-5 personas». Eneko.P no tiene tareas ni commits | Confirmarlo con el profesor y, si Eneko.P sale, actualizar el Anexo I |
| Media | [Anexo II](docs/gestion/anexo-II-11-pasos.md), [Gantt](docs/gestion/gantt.md) | Periodo del 21/10 al 10/11 (**15 días laborables**). El enunciado: 285 h y «semanas 1-10» (Anexo VIII) | Replanificar sobre las 10 semanas |
| Media | [`backlog-kanban.csv`](docs/gestion/backlog-kanban.csv) | Hay tareas en **Hecho** con fechas que aún no han llegado (4, 29, 30, 34, 35, 43, 45, por ejemplo la 45: 05/11-06/11). Varias las hizo otra persona y se cambió el responsable después. El enunciado pide saber «quién hace cada tarea y **cuándo**» | Poner en el CSV las fechas reales de inicio y fin de lo hecho (y, si se quiere, la planificada aparte) |
| Media | Anexo II, sección 2 | Mezcla requisitos del enunciado con ideas del plan (envío por correo y descuento de stock en el caso de uso, «al menos dos emuladores»), y luego otros documentos dicen que no son obligatorios | Separar lo que pide el enunciado de lo que añade el equipo |
| Leve | Anexo II, sección 3 | La fuente del E/R y del firmware es «Claude» | Citar documentación técnica (apuntes, manuales); la IA va en el registro de IA |
| Leve | [`registro-ia.md`](docs/gestion/registro-ia.md) | La primera fila no tiene persona; casi todo está «pendiente de revisar por el equipo»; las filas no están en orden de fecha | Completar y ordenar |

### Responsables y revisores que no coinciden con el CSV

| Documento | Dice | CSV |
|---|---|---|
| [Tarea 17](docs/arcade/17-rendimiento-mame/DOCUMENTACION.md) | Revisa Eneko.P | Revisa Adrian |
| [Tarea 30](docs/web/30-hosting-aws.md) | Revisa Eneko.P | Revisa Iker |
| [Tarea 34](docs/erp/34-configurar-odoo/DOCUMENTACION.md) | Responsable Markel; sección 7: Adrian (35), Peio (36), Eneko.P (37) | Iker; 35 Iker, 36 Iker, 37 Peio |
| [Tarea 35](docs/erp/35-factura-automatica/DOCUMENTACION.md) | Responsable Adrian; revisa «Iker → cambiar» | Iker; revisa Adrian |
| [Tarea 43](docs/backup/43-raid1/DOCUMENTACION.md) | Responsable Eneko.P; revisa «Iker → cambiar» | Iker; revisa Adrian |
| [Tarea 44](docs/backup/44-backup-3-2-1/DOCUMENTACION.md) | Responsable Markel | Iker |
| [Tarea 33](docs/erp/33-odoo-docker/DOCUMENTACION.md), sección 8 | 34 Markel, 36 Peio, 44 Markel | 34 Iker, 36 Iker, 44 Iker |
| [README del stick](arduino/mando-joystick/README.md) | Tarea 50: revisa Eneko.P | Revisa Markel |
| [Tarea 18](docs/arcade/18-monitorizacion-recreativa.md) | «Depende de: tarea 16 (Batocera y MAME)» | Batocera es la 51 |

---

## 10. Web y AWS

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Media | [Tarea 30](docs/web/30-hosting-aws.md) | El enunciado pide «**dominio propio**» y se usa `almichain1.duckdns.org`, un subdominio de un servicio gratuito | Confirmarlo con el profesor. Si no vale: un dominio de pago (unos 10 €/año, al presupuesto) o uno gratuito del GitHub Student Pack, con un registro A a la IP elástica |
| Media | [`08-pruebas-curl.txt`](docs/evidencias/30-hosting-aws/08-pruebas-curl.txt) y [`lighthouse-w3c.txt`](docs/evidencias/web/lighthouse-w3c.txt) | El servidor devuelve `Content-Length: 7143`, que es el `index.html` del 22/10. El del repositorio (commit `87a8b65`, posterior a la prueba) tiene 9.167. Lighthouse se pasó «en local» y dice que es lo mismo que está publicado, y no lo es | Subir la versión actual al bucket y repetir curl y Lighthouse **contra la URL pública** |
| Media | Tarea 31 | Sin IaC: `iac/` está vacía. El enunciado lo pide «a poder ser» | Ya planificada |
| Leve | [Tarea 27](docs/web/27-wireframes.md) | Los wireframes se sacaron de la web ya hecha. El enunciado pone el «diseño conceptual» antes de la implementación | Decirlo en la defensa o añadir la paleta y la estructura que se pensaron al principio |
| Leve | [`web/index.html`](web/index.html) | Imágenes enlazadas directamente de Unsplash, sin atribución; la portada y el primer plato del carrusel usan la misma foto. La geolocalización solo muestra dónde está el usuario, sin la distancia ni la ruta al restaurante | Copiar las imágenes a `web/` con su atribución; con la ubicación, calcular la distancia al local o abrir la ruta |
| Leve | [`instalar-servidor-web.sh`](scripts/web/instalar-servidor-web.sh) | Faltan `Content-Security-Policy` y `Permissions-Policy` (esta, para limitar la geolocalización a la propia web) | Añadir las dos cabeceras |
| Leve | Tarea 30, sección 7 | Habla de mínimos privilegios en AWS, pero `LabInstanceProfile` del Learner Lab tiene permisos amplios | Escribirlo como limitación del laboratorio |

---

## 11. Diagramas

| Gravedad | Dónde | Qué pasa | Cómo corregirlo |
|---|---|---|---|
| Media | [Tarea 11](docs/diagramas/11-arquitectura-equipos/DIAGRAMA.md) | El enunciado pide para los TPV e impresoras «un diagrama de la arquitectura que permita **repetir la instalación**». El diagrama enseña qué hay, pero no cómo se instala (no hay guía de los TPV: tareas 13-15) | Cuando estén las tareas 13-15, enlazar desde el diagrama los pasos de instalación de cada equipo |
| Leve | Tareas 11 y 23 | Cuando se decida 2.2, los diagramas tienen que enseñar la WAN, las redes que haya de verdad y la Wi-Fi de invitados | Regenerar SVG y Mermaid |

---

## 12. Cumplimiento del enunciado, tarea por tarea

Cada fila es una de las tareas de la lista del enunciado.

| Tarea del enunciado | Estado real | Qué falta |
|---|---|---|
| Necesidades, configuración y presupuesto de equipos e impresoras | Hecho, con huecos | Servidor y periféricos en el presupuesto (3) |
| Identificar y documentar el hardware necesario | Hecho | — |
| Identificar y documentar el software necesario | Parcial | Versiones, servidor y recreativa (3) |
| Instalación, optimización y monitorización de la recreativa | Parcial | Medidas en 1 núcleo y 1 GB; monitorización ejecutada (5.1) |
| Montaje y programación del arcade stick con Arduino | Parcial | Montaje, prueba en placa, palanca digital (5.2) |
| Identificar necesidades de comunicación | Parcial | Análisis de necesidades y esquema de conectividad (2.3) |
| Implementación y configuración de sistemas operativos | Parcial | TPV (4) |
| Restricción de cuentas y equipos (mínimos privilegios) | Parcial | TPV, cajero de Odoo (4 y 6) |
| Diseño conceptual de la web | Hecho, a posteriori | (10) |
| Web accesible y por HTTPS | Hecho | Publicar la versión actual (10) |
| Hosting en AWS con dominio propio y despliegue reproducible | Parcial | Dominio propio, IaC (10) |
| ERP + TPV con un caso de uso automatizado | Hecho | Caso de uso más realista (6) |
| Instalación y configuración de una impresora | **Sin empezar** | Tareas 14 y 37 |
| Modelo E/R y tablas | Hecho | Aclarar «una BD por local» (7) |
| Implementación de la BD y consulta de sus datos | **Sin empezar** (las consultas) | Tarea 41 (7) |
| Configurar disco redundante | Parcial | **La BD no está en el RAID** (8.1) |
| Plan de copias y prueba de restauración | Hecho, con huecos | Restauración en máquina nueva, copia externa (8.2) |
| Seguridad por defecto en toda la solución | Parcial | Contraseñas expuestas, HTTP en Odoo, red plana (1 y 2) |
| Verificar con pruebas (funcionamiento, restauración, failover) | Parcial | WDS, red de invitados, TPV, stick |
| Documentación reproducible con diagramas de arquitectura | Parcial | Ubuntu sin versión, recreativa por Wi-Fi, TPV (4, 5, 11) |
| Seguimiento (Gantt o Kanban) y Git | Hecho, con huecos | Fechas reales, 10 semanas, commits de todos (9) |
| Documentación y presentación | Pendiente | Tareas 48 y 49 |

**Redes, en concreto** (lo que pide el enunciado):

| Pide | Estado |
|---|---|
| Contratar una línea WAN | Comparativa hecha (DIGI), sin análisis de necesidades |
| Esquema de conectividad | Falta como documento (solo hay un esquema en ASCII en LOGICA_RETO) |
| Diagrama de la arquitectura de red (plano), cableado y Wi-Fi | Plano hecho; Packet Tracer sin WAN ni Wi-Fi (2.1) |
| Red configurada de forma segura | Parcial: red plana, invitados sin configurar, contraseña Wi-Fi expuesta y débil (1.1 y 2.2) |
| Segundo router por WDS, comprobando que funciona | Sin empezar (tarea 25) |
| RA.7: conectar redes privadas a redes públicas | Sin demostrar: no hay NAT ni WAN en la simulación (2.1) |

---

## 13. Estado tras aplicar las correcciones (24/10/2026)

Lo que se ha podido corregir en el repositorio y lo que queda, porque necesita hardware, ejecutar algo en las VM o en AWS, o una decisión del equipo o del profesor.

### Corregido

| Sección | Qué se ha hecho |
|---|---|
| 1.1 | Contraseña Wi-Fi y RADIUS tapadas en las capturas 07 y 08. La tarea 24 avisa de que siguen en el historial y de que hay que cambiarlas; documentados los problemas de la contraseña de administración |
| 1.1 | Preseed de la recreativa sin la clave `recreativa-claude`: la clave se pasa al instalar (`preseed-local.cfg`, en `.gitignore`) |
| 1.1 | Contraseña de restic: la tarea 44 manda guardarla en KeePassXC y borrar `.credenciales-backup` |
| 1.2 | `optimizar-arcade.sh` mantiene las actualizaciones de seguridad, a las 04:30 y 05:00; SSH de la recreativa sin contraseña ni root; recreativa administrada desde la consola local (contradicción 23/24 resuelta) |
| 2.1 | Tarea 23: lista de lo que falta en el `.pkt` (WAN, NAT, Wi-Fi, seguridad, pruebas) con la configuración |
| 2.2 | Red de invitados real a `192.168.50.0/24`; opciones (a)/(b) planteadas en la tarea 23, apartado 5.5 |
| 2.3 | Cita literal del enunciado; cabecera y problemas de la tarea 24; tarea 22 en Markdown con análisis de necesidades, esquema de conectividad y enlaces; switch presupuestado; impresoras en `.41`/`.42`; RT-08 |
| 3 | Presupuesto con servidor, discos, USB, SAI, switch, cable, adaptador Wi-Fi y palanca (tarea 10, sección 12); Windows 10 IoT Enterprise LTSC 2021; tarea 9 con versiones, servidor y recreativa; suma del registro de IA |
| 4 | Tarea 12: RG-05 de Windows como parcial y justificación del cifrado |
| 5.1 | Tarea 17 marcada en curso con la advertencia; tarea 18 reescrita para Debian; tarea 16 con la conexión a la Wi-Fi de invitados |
| 5.2 | Firmware con palanca digital de 4 microinterruptores (modo por defecto) y botones 7-8 en los pines 8 y 9. Compila (`pio run`, 24/10) |
| 6 | Caso de uso de la tarea 35: menú de grupo con IVA del 10 % (`--iva`); TicketBAI decidido; Community vs Enterprise precisado; tarea 33 al día; menús del cajero documentados |
| 7 | `06-datos.sql` y `07-consultas.sql` (12 consultas); decisión de base central; `almi_chain` en el mismo PostgreSQL y en las copias; añadidos a `verificar-repo.sh` |
| 8 | Procedimiento para mover la BD al RAID (tarea 43, sección 7); USB fuera del local cada lunes con aviso a los 7 días; ruta del volumen robusta; RTO real marcado como sin medir |
| 9 | Fechas reales en las tareas hechas; nota de las 10 semanas; Anexo II con requisitos separados y fuentes técnicas; responsables y revisores coherentes con el CSV; registro de IA ordenado |
| 10 | CSP y Permissions-Policy en nginx; distancia y ruta a pie en la geolocalización; créditos de las imágenes; aviso de la web publicada antigua; limitación de `LabInstanceProfile`; dominio a confirmar; diseño conceptual en la tarea 27 |
| 11 | Tarea 11: switch, servidor y red de invitados en el Mermaid; tabla de guías de instalación por equipo |

### Pendiente (no se puede hacer desde el repositorio)

- **Cambiar la contraseña Wi-Fi expuesta** y la de administración del router; borrar de Drive el `.txt` antiguo.
- Packet Tracer: aplicar los cambios del apartado 5.4 de la tarea 23 y rehacer la captura.
- Decidir red plana o VLAN (tarea 23, 5.5), número de personas del equipo, dominio propio y notación del E/R (profesor).
- Ejecutar `06-datos.sql` y `07-consultas.sql` en PostgreSQL y guardar la salida (no había PostgreSQL ni Docker en el equipo donde se hicieron); crear `almi_chain` en el servidor.
- Mover los datos de Docker al RAID y repetir el fallo con Odoo funcionando; restaurar en una VM nueva para medir el RTO real.
- Repetir la tarea 17 en la VM de 1 núcleo y 1 GB y ejecutar la monitorización jugando.
- TPV, impresora y arcade stick (tareas 13-15, 19, 21, 37, 50); importar y exportar en Odoo (36); usuarios con `LOGIN` (42); proxy HTTPS (52); IaC (31).
- Repetir la factura automática con el caso de uso nuevo; ocultar menús al cajero y comprobarlo.
- Subir la web actual a AWS, reinstalar nginx con las cabeceras nuevas y pasar curl y Lighthouse contra la URL pública.
- Versión exacta de Ubuntu, actualizaciones de Windows y cifrado en la VM del gerente.
- Regenerar `arquitectura-equipos.svg`; replanificar sobre las 10 semanas con el Anexo VIII.
