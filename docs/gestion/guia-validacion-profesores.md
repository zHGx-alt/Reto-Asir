# Guía para validar con los profesores

10 actividades por validar (la 5, la 6, la 7, la 12, la 13 y la 14 ya están validadas). Van agrupadas por profesor y, dentro de cada uno, **de la que más tiempo lleva enseñar a la que menos**. Los tiempos son una estimación de lo que dura la demostración, sin contar la preparación.

Cada actividad del profesor agrupa varias tareas del backlog (`docs/gestion/backlog-kanban.csv`); el número entre corchetes es la tarea.

| Profesor | Actividades | Tiempo aprox. |
|---|---|---|
| Ales | 4, 16, 3, 15, 2, 1 | ~65 min |
| Jose Mari | 11, 10 (la 5 y la 12, validadas el 12/11) | ~18 min |
| Virginia | 9, 8 (la 7, validada el 12/11) | ~15 min |

---

## Ales

### 4 · ERP + TPV (difícil, ~20 min)
Tareas [32] [33] [34] [35] [36] [37] [52] [63]

**Preparar:** arrancar la VM `ServidorERP` y la win-11 del TPV; tener la impresora Samsung ML-1660 encendida y el CUPS del PC activo.

**Enseñar, en este orden:**
1. Por qué Odoo: `docs/erp/32-comparativa-erp.md`.
2. Docker: `docker compose ps` en el servidor; gestor de BD desactivado y el 5432 sin publicar ([33]).
3. Entrar por HTTPS (proxy nginx con certificado propio, [52]) y enseñar los módulos configurados ([34]).
4. Una venta en el TPV, de principio a fin, y el **ticket impreso** desde la VM ([37]).
5. El caso de uso automatizado: pedido → factura → cobro → PDF ([35], menú de grupo con IVA 10 %).
6. Importar la carta con `importar-exportar.py` ([36]).

**Ojo, falta:** [36] pasos 2-6 y [63] (CRM, empleados, marketing, inventario) son de Eneko.P y están sin hacer. Si Ales pregunta por los módulos que no son facturación ni TPV, de momento solo están instalados. Los ajustes del TPV solo se aplican con una sesión de caja nueva.

### 16 · Implementación de la base de datos (media-difícil, ~15 min)
Tareas [40] [41] [42] [43] [57]

**Enseñar:**
1. Los scripts DDL 01-03 ejecutándose sin errores y `05-pruebas` con 33/33 ([40]).
2. Datos de prueba y algunas de las 12 consultas de `07-consultas.sql` ([41]).
3. Usuarios con mínimos privilegios: `tpv_app` e `informes`, y `09-pruebas-usuarios.sql` con 9/9 ([42]).
4. Que la BD vive en el RAID 1 ([43]).
5. La integración con Odoo: `sincronizar-carta.py` lleva la carta de `almi_chain` al TPV por XML-RPC ([57]).

**Ojo, falta:** la [57] solo está probada contra un Odoo simulado; falta ejecutarla en la ServidorERP (Iker, evidencias 01-04).

### 3 · Web en AWS (media, ~12 min)
Tareas [27] [28] [29] [30] [31]

**Preparar:** el Learner Lab apaga la EC2 fuera de sesión. **Encenderlo antes** y comprobar que `https://almichain1.duckdns.org` responde. Si las credenciales del Lab han caducado, renovarlas.

**Enseñar:**
1. Wireframes de escritorio, tableta y móvil ([27]).
2. La web en marcha: mapa de OpenStreetMap, geolocalización, formulario y slideshow ([28]).
3. Lighthouse y W3C contra la URL pública: móvil 94/100/100/100 ([29]).
4. S3 + EC2 + DuckDNS + certificado de Let's Encrypt, con el candado en el navegador ([30]).
5. Terraform y GitHub Actions: un push despliega solo ([31], `iac/README.md`).

### 15 · Modelo E/R y tablas (media, ~10 min)
Tareas [38] [39] [56]

**Enseñar:**
1. El E/R en notación Chen: `docs/bd/38-modelo-er-chen.svg`.
2. La ampliación: relación ternaria, historiales y atributos especiales ([56]).
3. El paso a tablas en 3FN y por qué cumple cada forma normal (`docs/bd/39-modelo-logico-3fn.md`).

### 2 · Software necesario (fácil, ~5 min)
Tarea [9]

Tabla de software y licencias con versión y justificación de cada programa (servidor, puestos, recreativa y web): `docs/hardware/09-tabla-software-licencias.md`. Si pregunta por la instalación, remitir a las actividades 4, 7 y 12, donde se ve instalado.

### 1 · Hardware necesario (fácil, ~5 min)
Tareas [7] [8] [10] [11]

1. Necesidades de cada equipo (`07-necesidades-equipos.md`).
2. Tabla de hardware justificada y presupuesto con enlaces: 2.361,36 € comprobados ([8] [10]).
3. Diagrama de arquitectura ([11]).

---

## Jose Mari

### 5 · Arcade stick con Arduino (difícil, ~15 min) · ✅ validada el 12/11
Tareas [19] [20] [21] [50] [59]

**Preparar:** el stick montado, un cable USB y la VM de la recreativa con MAME.

**Enseñar:**
1. El montaje y el esquema de conexiones: 4 botones en los pines 2-5 y la palanca digital en A2-A5 ([19]).
2. Conectarlo: lo reconoce como mando HID sin instalar drivers ([20] [50]).
3. Remapear sin reprogramar: `MAP` + `GUARDAR` en la EEPROM, desenchufar, volver a enchufar y ver que se conserva.
4. Una partida en MAME (Gridlee) con el stick ([21]).
5. El antirrebote por software, 5 ms por entrada: prueba simulada con 9 de 9 OK y, en la placa, 116 pulsaciones sin ninguna de menos de 30 ms (12/11) ([59]).

**Ojo:** en Batocera, el segundo emulador, la partida se jugó el 27/10 pero no hay captura ([README del stick](../../arduino/mando-joystick/README.md)). La caja tiene 6 botones pero el firmware lee 4 (decisión del profesor).

### 12 · Optimizar y monitorizar la recreativa (media-difícil, ~12 min) · ✅ validada el 12/11
Tareas [16] [51] [17] [18] [53] [54]

**Enseñar:**
1. Por qué Debian + MAME y no Batocera: la comparativa en una VM de 1 núcleo y 1 GB ([51]).
2. El arranque directo a MAME en 4,7 s y las 5 ROMs legales ([16] [53]).
3. Las medidas antes y después de `optimizar-arcade.sh` (9 optimizaciones) con `medir-rendimiento.sh` ([17] [54]).
4. `monitor-recreativa.sh` en marcha mientras se juega, y el resumen ([18]).

### 11 · Restricción de cuentas de usuarios y equipos (media, ~10 min)
Tareas [13] [15] [55]

**Enseñar:**
1. El TPV en Windows 11 Pro: el usuario es estándar, está en modo quiosco y tiene los USB bloqueados ([13]).
2. Los scripts que lo dejan igual en cualquier TPV: `configurar-tpv.ps1` y `comprobar-tpv.ps1` ([15]).
3. Las contraseñas robustas del gerente, guardadas en KeePassXC ([55]).
4. Si da tiempo: los usuarios de la BD con mínimos privilegios ([42]) y los servicios reducidos del gerente ([64]).

**Ojo, falta ([15], de Iker):** ejecutar los scripts en los dos TPV. Ahora mismo el bastionado está hecho a mano.

### 10 · Ampliación de cobertura Wi-Fi (media, ~8 min)
Tarea [25], cerrada el 12/11

**Enseñar:**
1. El router 2 en modo Range Extender, enlazado por radio al router 1: `192.168.10.2` y DHCP apagado ([25]).
2. Las pruebas de conectividad: ping al router 1, salida a Internet y los invitados sin acceso a la LAN.

**Ojo, queda como mejora (Peio, sección 7 de la tarea):** el router 2 repite la Wi-Fi del personal y no la de clientes, y no hay medidas de cobertura en dBm antes y después (pruebas W6 y W8 en ⏳). Si pregunta si mejora la cobertura, la respuesta honesta es que el enlace funciona pero la mejora no está medida; se cerró así por falta de tiempo (decisión en el Anexo II).

---

## Virginia

### 7 · Instalación de S.O. y arranque dual (difícil, ~15 min) · ✅ validada el 12/11
Tareas [12] [55] [62] [64]

**Preparar:** la VM `VM-dualboot-W10-ubuntu` en VirtualBox, con la instantánea `guest-additions-2026-11-10`.

**Enseñar:**
1. La VM: RAM, disco y Guest Additions ([62]).
2. El menú de arranque con los dos sistemas.
3. Windows con BitLocker y contraseña de arranque. **Truco:** pulsar Esc nada más arrancar → Boot Manager → Windows Boot Manager. Si se entra desde GRUB, BitLocker no recibe el teclado.
4. Ubuntu 26.04.1 LTS con `/home/gerente` cifrado con fscrypt.
5. Los servicios reducidos: de 248 a 237 en Windows y de 73 a 68 en Ubuntu ([64]).

**Si Windows sale primero:** Windows Update pone su gestor de arranque el primero en EFI; se arregla con `efibootmgr -o` desde Ubuntu.

### 9 · Diseño y esquema de conectividad (media, ~10 min)
Tareas [23] [24] [26] [11]

**Enseñar:**
1. El plano del local y el plan de IP, con la red de invitados aislada en 192.168.50.0/24 ([23], `23-plano-local.svg`).
2. La red en Packet Tracer: `23-red-local.pkt` abierto, con un ping que funciona y otro que se bloquea.
3. La red segura en el TL-WR841N: administración remota cerrada, WPA2-AES, SPI y anti-DoS ([24]).
4. El análisis con Wireshark y nmap ([26]).

### 8 · Conectividad WAN (fácil, ~5 min)
Tarea [22]

`docs/redes/22-comparativa-wan.md`: el análisis de necesidades, la comparativa de operadores y por qué se elige DIGI 1 Gb a 30 €/mes.

---

## Antes de empezar

- Tener el repo abierto en `main` y `LOGICA_RETO.md` a mano: la sección 15, «Montarlo desde cero, en orden», sirve para cualquier pregunta de «¿cómo lo repetirías?».
- Dejar arrancadas de antemano las VMs: ServidorERP, el TPV, la del gerente y la de la recreativa.
- Encender el Learner Lab de AWS al menos 10 minutos antes de ver a Ales.
- Si se puede, empezar por Ales. Es lo más largo y depende de que todo esté encendido.
