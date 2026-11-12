# Anexo II · Documento 11 pasos

| | |
|---|---|
| **Reto** | 1 · Almi-Chain |
| **Grupo** | ASIR1 2026-2027 |
| **Equipo** | Adrian, Iker, Eneko.S, Eneko.P, Markel, Peio |
| **Periodo** | 21/10/2026 – 12/11/2026 (técnico hasta el 4/11; huecos de la rúbrica, documentación y presentación del 5 al 11/11, con el ensayo el 11/11) |
| **Responsable del documento** | Adrian |

---

## 1. Análisis del reto

Una cadena de restaurantes contrata el diseño e implantación de su infraestructura informática. El alcance es el siguiente:

- **Puestos de trabajo:** equipo de gerencia con arranque dual Windows 10 / GNU-Linux; dos TPV Windows de barra con impresoras de tickets, configurados con mínimos privilegios.
- **Ocio:** máquina recreativa MAME sobre hardware limitado (1 núcleo, 1 GB de RAM) y arcade stick propio basado en Arduino con HID nativo.
- **Red:** contratación de línea WAN, esquema de conectividad, plano de red con cableado y Wi-Fi, red configurada de forma segura y ampliación de la cobertura Wi-Fi mediante WDS. (La segmentación por grupos es una decisión del equipo, no del enunciado.)
- **Presencia web:** sitio informativo responsivo y accesible, alojado en AWS con dominio propio, HTTPS y despliegue reproducible, «a poder ser» automatizado con scripts o infraestructura como código.
- **Gestión:** ERP con TPV integrado y al menos un proceso de negocio automatizado de extremo a extremo.
- **Datos:** base de datos de los establecimientos (una base central con los datos de cada local, [tarea 38](../bd/38-modelo-er.md#11-una-base-central-para-toda-la-cadena)) sobre almacenamiento redundante, con plan de copias verificado mediante restauración real.

Condiciones transversales: seguridad por defecto, reproducibilidad, documentación ejecutable por un técnico ajeno al proyecto y capacidad de cada miembro para defender el conjunto.

## 2. Requisitos

La columna *Enunciado* recoge solo lo que dice el enunciado. Lo que añade el equipo (o venía en el plan de trabajo) va aparte: es opcional y, si no se hace, no se incumple el reto.

| Bloque | Lo pide el enunciado | Lo añade el equipo (criterios propios) |
|---|---|---|
| Hardware y presupuesto | Necesidades, configuración y presupuesto de equipos e impresoras; detalles del hardware y del software que se instala | Precios con fuente enlazada; justificación de cada componente; presupuesto con WAN, router adicional, servidor y copias |
| Sistemas operativos | Arranque dual Windows 10 - GNU/Linux para el gerente; 2 TPV Windows; restringidos al máximo, mínimos privilegios y seguridad por defecto; instalación y configuración de una impresora; documentación reproducible y diagrama que permita repetir la instalación | Cuentas separadas usuario/administrador, bloqueo de USB, firewall y actualizaciones activos; configuración con scripts |
| Arcade | MAME en un equipo de 1 núcleo y 1 GB, optimizado, con constancia de las pruebas de rendimiento; monitorización; arcade stick con Arduino compatible con cualquier emulador e input personalizable | Medidas de FPS, CPU y RAM antes y después; probar el stick con dos emuladores como muestra de «cualquier emulador» |
| Redes | Identificar necesidades de comunicación; contratar una línea WAN; esquema de conectividad; plano de red con cableado y Wi-Fi; red configurada de forma segura; segundo router por WDS comprobando que funciona | Segmentación por función (TPV, gerencia, clientes, arcade); WPA3; red de invitados aislada; medidas de cobertura y velocidad |
| Web | Unidireccional, atractiva, responsiva, accesible y con buen rendimiento; geolocalización, formulario de contacto (placeholder) y slideshow de platos; HTTPS, dominio propio, nube (AWS) y despliegue reproducible, a poder ser automatizado | HTML/CSS válidos en el W3C y Lighthouse ≥ 90 como forma de medir «accesible» y «buen rendimiento»; Terraform |
| ERP + TPV | ERP para facturas, clientes, personal, marketing, inventario…; al menos un caso de uso real de extremo a extremo automatizado (p. ej. emisión de una factura); importación, integración, aseguramiento y extracción de información (RA.7 de LMSGI) | Envío de la factura por correo y descuento de stock en el caso de uso (ideas del plan, no obligatorias) |
| Base de datos | Diseño del modelo E/R y tablas; implementación y consulta de sus datos | Normalización a 3FN, reglas con disparadores y usuarios con privilegios mínimos |
| Disponibilidad y copias | La BD en un dispositivo redundante; plan de copias de seguridad con prueba de restauración; verificar con pruebas (restauración, failover) | Regla 3-2-1, copias cifradas y automatizadas |
| Transversal | Seguridad por defecto (mínimos privilegios, gestión de credenciales y secretos, comunicaciones cifradas); documentación que un técnico nuevo pueda seguir, con diagramas; seguimiento con Gantt o Kanban y Git; documentación y presentación | KeePassXC para todas las contraseñas; gitleaks; revisión por Pull Request |

## 3. Investigación

Fuentes y documentación técnica de referencia por bloque. Cada responsable añade lo que consulte.

| Bloque | Fuente |
|---|---|
| BD · Modelo E/R | Apuntes de clase de Gestión de Bases de Datos (modelo E/R, paso a tablas y normalización); [documentación de PostgreSQL](https://www.postgresql.org/docs/) (restricciones, disparadores y roles). El uso de IA está en el [registro de IA](registro-ia.md) |
| Arduino · Firmware HID y EEPROM | [Documentación de Arduino Leonardo](https://docs.arduino.cc/hardware/leonardo/) (HID nativo del ATmega32U4), [referencia de EEPROM de Arduino](https://docs.arduino.cc/learn/built-in-libraries/eeprom/) y la librería [mheironimus/ArduinoJoystickLibrary](https://github.com/MHeironimus/ArduinoJoystickLibrary). El uso de IA está en el registro de IA |
| Web · Hosting | [Documentación de Certbot](https://eff-certbot.readthedocs.io), [DuckDNS](https://www.duckdns.org/spec.jsp), documentación de Amazon S3 y EC2 |
| Web · Validación | [Lighthouse](https://developer.chrome.com/docs/lighthouse), [validador Nu del W3C](https://validator.w3.org/nu/) |
| ERP · Comparativa | Fuentes de Odoo, Dolibarr y ERPNext consultadas el 22/10 ([tarea 32](../erp/32-comparativa-erp.md)) |
| ERP · Odoo | Documentación de Odoo 19 y su API XML-RPC ([tareas 33-35](../erp/)) |
| Copias · restic y mdadm | Documentación de restic y de mdadm ([tareas 43-45](../backup/)) |
| Arcade · MAME y Batocera | Documentación de MAME, Debian (preseed) y Batocera ([tareas 16-18](../arcade/)) |
| SO · Cifrado del gerente | Documentación de Microsoft sobre BitLocker (`manage-bde`, directiva «Requerir autenticación adicional al iniciar») y de [fscrypt](https://github.com/google/fscrypt) (protectores de inicio de sesión y `pam_fscrypt`) ([tarea 12](../so/12-dual-boot.md)) |
| ERP · HTTPS | Documentación de nginx (`proxy_pass`, TLS) y de OpenSSL (`nameConstraints`) ([tarea 52](../erp/52-https-odoo/DOCUMENTACION.md)) |

## 4. Alternativas evaluadas

| Decisión | Opciones | Criterios |
|---|---|---|
| ERP | Odoo Community, Dolibarr, ERPNext | Módulos requeridos, TPV de restauración, coste de licencia, API |
| Hosting web | S3 + CloudFront + ACM, S3 + EC2 con nginx | Coste, mantenimiento, HTTPS gestionado, dominio gratuito |
| IaC | Terraform, CloudFormation | Portabilidad, curva de aprendizaje |
| SO de la recreativa | Debian mínimo, Batocera (medidas en la [tarea 51](../arcade/16-batocera/NOTAS.md)); Alpine y Lakka solo en papel | Consumo de RAM, soporte de MAME, mantenimiento |
| Firmware de router | OpenWrt, DD-WRT | Soporte WDS, compatibilidad del hardware |
| SGBD | MariaDB, PostgreSQL | Herramientas de la asignatura, integración con Odoo |
| Backup | restic, borg, rsync + cron | Cifrado, deduplicación, destino S3 |
| Placa del arcade stick | Arduino Leonardo, Pro Micro | HID nativo, precio, tamaño |

## 5. Decisiones

| Decisión | Elección | Justificación | Fecha |
|---|---|---|---|
| Gestión de tareas | Gantt en el repo, generado desde el CSV | El enunciado pide Gantt o Kanban. El Gantt vive en el repositorio y se regenera con un script; el tablero de GitHub Projects se creó pero no se usa | 21/10/2026 (revisado el 23/10) |
| Firmware del arcade stick | Joystick HID estándar (no teclado) | Cualquier emulador lo reconoce como mando sin drivers, no interfiere con el teclado y el mapeo se personaliza en la EEPROM; todo el firmware está hecho así. Moneda y Start se asignan una vez en MAME ([STICK-ARDUINO.md](../arcade/16-recreativa-mame/STICK-ARDUINO.md)) | 23/10/2026 |
| Línea WAN | Fibra DIGI 1 Gb, 30 €/mes | Es la que elige la comparativa ([tarea 22](../redes/22-comparativa-wan.md)) y la que ya usaba el plano (tarea 23); el presupuesto se corrige para que coincida (360 €/año en vez de 588,12 €) | 23/10/2026 |
| Contraseñas | Robustas, generadas y guardadas en KeePassXC; nunca en texto plano ni en Git | Lo exigen el enunciado (gestión de credenciales y secretos) y el plan | 23/10/2026 |
| Reparto tras la revisión del estado | Software pendiente para Adrian e Iker; tareas físicas para cualquiera salvo Eneko.P; las tareas con parte en VM y parte física se separan | Eneko.P está pendiente de confirmar si sigue; Adrian e Iker son quienes han hecho casi todo el software ([roles.md](roles.md), [verificacion.md](verificacion.md)) | 23/10/2026 |
| ERP | Odoo Community | Cubre las funciones del enunciado con un TPV táctil integrado, usa PostgreSQL, tiene más documentación en español y es gratuito ([tarea 32](../erp/32-comparativa-erp.md), sección 6) | 22/10/2026 |
| Hosting web | Bucket S3 privado + EC2 con nginx, IP elástica, dominio `almichain1.duckdns.org` y certificado de Let's Encrypt | Dominio y certificado gratuitos. DuckDNS solo admite registros A, y CloudFront y ACM necesitan CNAME; con una IP elástica basta un registro A ([tarea 30](../web/30-hosting-aws.md)) | 23/10/2026 |
| IaC | Terraform (proveedor AWS) + GitHub Actions para publicar. El 29/10 se aplicó importando el montaje a mano (misma IP); el bucket se crea con la CLI porque el Learner Lab no deja leer su *object lock* | Lo nombra el plan y es portable; `terraform validate` lo comprueba sin credenciales. CloudFormation ataría el código a AWS ([iac/](../../iac/README.md)) | 24/10/2026 |
| SO de la recreativa | Debian 13 mínimo con arranque directo a MAME (descartada Batocera) | Medido en VM de 1 núcleo y 1 GB: llega a la partida en 7,1 s con 400 MB usados y MAME a 934 %/685 %; Batocera usa 554 MB solo con el menú (ya con swap), tarda 12,9 s al menú optimizado, pide 2 GB según su guía y guarda la contraseña de root en claro ([tarea 51](../arcade/16-batocera/NOTAS.md)) | 26/10/2026 |
| Impresora de tickets de las pruebas | Samsung ML-1660 (láser) por IPP | Las térmicas del centro no llegan para todos los grupos. El ticket de Odoo sale igual; en la tienda real sigue siendo la Epson TM-T20IV por USB (tarea 8) | 27/10/2026 |
| Corte técnico | Todo lo técnico acaba el miércoles 4/11; tabla de pruebas, documentación final y presentación del 5 al 10/11 | El 4/11 dan la rúbrica: lo que no se ajuste a ella tiene una semana de margen, y lo que más depende de la rúbrica (documentación y presentación) se hace después | 27/10/2026 |
| Firmware de router | El de fábrica de TP-Link (sin OpenWrt) | Con la red plana (decisión del 24/10) no hacen falta VLAN; el firmware de fábrica tiene WDS y red de invitados, y OpenWrt arriesga los routers ([tarea 23, apartado 5.3](../redes/23-plano-direccionamiento.md#53-por-qué-la-red-plana-y-no-las-vlan)) | 24/10/2026 |
| SGBD | PostgreSQL | Lo exige Odoo, así que todo el proyecto usa un único gestor. Scripts DDL probados en PostgreSQL 16 y 18 y, desde el 29/10, en el 17 que usa Odoo, con todas las pruebas correctas ([tarea 40](../bd/40-scripts-ddl.md)); Odoo corre sobre PostgreSQL 17 ([tarea 33](../erp/33-odoo-docker/DOCUMENTACION.md)) | 22/10/2026 |
| Backup | restic sobre RAID 1 (`mdadm`) y disco USB externo | Copias cifradas con AES-256, deduplicadas y automatizadas; cumple la regla 3-2-1 ([tarea 44](../backup/44-backup-3-2-1/DOCUMENTACION.md)) | 22/10/2026 |
| Placa del arcade stick | Arduino Leonardo (ATmega32U4) | HID nativo por USB sin drivers; compatible con la librería Joystick; EEPROM para guardar el mapeo | 22/10/2026 |
| Tamaño del equipo | 6 personas | El grupo es de 6 aunque el enunciado diga 4-5. Eneko.P volvió el 26/10 y tiene tareas ([roles.md](roles.md)) | 24/10/2026 |
| Dominio de la web | `almichain1.duckdns.org` | Vale como dominio propio; no se compra ninguno | 24/10/2026 |
| Fechas del reto | Del 26/10 al 12/11/2026 | Se mantiene la planificación actual hasta que salga la rúbrica | 24/10/2026 |
| Base de datos de los establecimientos | Base central con los datos de cada local | Evita repetir carta y clientes en cada local ([tarea 38](../bd/38-modelo-er.md#11-una-base-central-para-toda-la-cadena)) | 24/10/2026 |
| TicketBAI | No se configura | Queda documentado como obligación legal (tarea 34, sección 6) | 24/10/2026 |
| Arranque dual | Una VM | Suficiente para demostrar el arranque dual (tarea 12). Desde el 29/10 en VirtualBox ([tarea 12, sección 7](../so/12-dual-boot.md#7-decisiones-y-problemas-encontrados)) | 24/10/2026 |
| Cifrado del PC del gerente | BitLocker con contraseña de arranque en Windows; fscrypt en `/home/gerente` | La VM no tiene TPM (en el equipo real, TPM + PIN). fscrypt no obliga a reparticionar y se abre con la contraseña de inicio de sesión ([tarea 12](../so/12-dual-boot.md#44-actualizar-y-cifrar-después-de-instalar-los-dos-sistemas)) | 29/10/2026 |
| Máquinas virtuales | No se suben a Drive: cada VM se queda en el PC de quien la tiene, con su lista ([maquinas-virtuales.md](maquinas-virtuales.md)) | Ocupan decenas de GB, en Drive solo cabe una y cada exportación se queda vieja en cuanto se toca la VM; lo que demuestra cada tarea son sus evidencias. En Drive sigue la exportación del gerente del 23/10, desfasada | 30/10/2026 (amplía la del 29/10 de no volver a exportar la del gerente) |
| Impresora de tickets | La da el centro | Las tareas 14 y 37 esperan a tenerla ([guía](../so/14-impresora/DOCUMENTACION.md)). **Sustituida el 27/10**: las pruebas se hacen con la Samsung ML-1660 | 24/10/2026 |
| Notación del E/R | Chen (rectángulos, rombos y elipses, con (mín,máx)) | Es la que se ha visto en clase; la de pata de gallo se queda como vista de tablas ([tarea 38, sección 2](../bd/38-modelo-er.md#2-diagrama)) | 30/10/2026 (sustituye a «pata de gallo» del 24/10) |
| Windows de los TPV | Windows 10 IoT Enterprise LTSC 2021 (licencia Entry, 37,41 € cada una) | Es Windows 10, como pide el enunciado, y tiene actualizaciones de seguridad hasta enero de 2032; el ESU es de pago cada año y solo llega a 2028. Las VM de pruebas usan Windows 11 Pro porque la LTSC no se descarga sin contrato OEM ([tarea 10, apartado 4.1](../hardware/10-presupuesto-hardware.md)) | 30/10/2026 |
| Red del local | Plana (LAN del personal) con la Wi-Fi de invitados aislada; separación entre TPV, gerente y servidor por el cortafuegos de cada equipo | Las VLAN reales exigían OpenWrt en los routers, complicaban el WDS, no se podían probar con el router de prácticas y obligaban a rehacer el plan de IP, los scripts de los TPV, el HTTPS, el presupuesto y los diagramas. ([tarea 23, apartados 5.2 y 5.3](../redes/23-plano-direccionamiento.md#52-decisión-red-plana-con-red-de-invitados-aislada-24102026)) | 24/10/2026 |
| Simulación de Packet Tracer | Simular la red real (ISP, NAT, LAN, dos Wi-Fi, router 2 como puente). El primer `.pkt`, con una VLAN por grupo, se quitó el 25/10/2026 para que solo quede el diseño que se monta | La simulación tiene que coincidir con lo que se monta; el router 2 en WDS es un puente, y en Packet Tracer el aparato equivalente es un punto de acceso ([guía](../redes/23-packet-tracer-red-local.md)) | 24/10/2026 |
| Plan tras la rúbrica | Gantt final del 04/11 al 11/11 y reparto por los huecos de la rúbrica: una tarea por cada criterio que no llega al 5 (56-63), 5-6 días de trabajo por persona | La rúbrica ([rubrica-anexo-VI.md](rubrica-anexo-VI.md)) es acumulativa: un nivel no cuenta sin el anterior, así que primero se cierra lo que falta para el 4 en cada criterio ([gantt.md](gantt.md)) | 04/11/2026 |
| Copia remota en el Learner Lab | Bucket privado `almi-chain-backup-2026` con las credenciales temporales del lab en `s3.env` | El Learner Lab no deja crear usuarios IAM (`iam:CreateUser` denegado). Con la cuenta real se crea el usuario con la política de la [tarea 44, sección 8.2](../backup/44-backup-3-2-1/DOCUMENTACION.md#82-tercer-repositorio-en-aws-s3-copia-3b) | 04/11/2026 |
| Clave SSH del servidor | El preseed lleva la marca `CLAVE_PUBLICA_SSH`, que se sustituye por la clave del PC del gerente antes de instalar | Antes tenía fija la clave del laboratorio (`recreativa-claude`). Así cada instalación autoriza solo la clave de quien administra (tarea 46, S-08) | 04/11/2026 |
| Antirrebote del stick | Por software: cada entrada solo cambia cuando la lectura lleva 5 ms estable, sin `delay(10)`; el informe USB se envía al cambiar algo o cada 100 ms | No necesita componentes extra ni recablear el stick, y la pulsación llega en unos 6 ms. Se prueba en el PC con rebotes simulados antes de subirlo a la placa ([README del stick, «Antirrebote»](../../arduino/mando-joystick/README.md#antirrebote-tarea-59)) | 04/11/2026 |
| Forma de subir el firmware del stick | Solo `subir.sh` (arduino-cli y avrdude, librería en versión fija); fuera PlatformIO | Había dos formas de compilar y solo una estaba probada en la placa (27/10); con una sola, la documentación y la prueba no se desajustan | 04/11/2026 |
| Ampliación del E/R | Relación ternaria SUMINISTRO (proveedor, artículo y local, con el precio de compra), historial HISTORIAL_PRECIO_PLATO, alérgenos como atributo multivaluado y total como derivado | Son los elementos que pide la rúbrica (GBD RA1-RA2) y que el modelo no tenía; se llevan también al modelo lógico y a los scripts ([tarea 38, sección 6](../bd/38-modelo-er.md)) | 04/11/2026 |
| Servicios reducidos en el PC del gerente | Un script por sistema con una lista fija de servicios y el motivo de cada uno, que guarda la salida antes y después; la cola de impresión se queda en los dos | La rúbrica (ISO RA1, nivel 5) pide «servicios reducidos» y solo había evidencia de mínimos privilegios (auditoría del 06/11). Con lista fija se puede repetir en el equipo real y explicar servicio a servicio ([tarea 12, sección 4.4](../so/12-dual-boot.md)) | 06/11/2026 |
| Recuperación del servidor desde cero | Un script, `recuperar-servidor-nuevo.sh`, que hace el plan de desastre de la tarea 48 en una máquina instalada con el preseed: el USB se monta en solo lectura y la contraseña de restic llega de KeePassXC en un fichero temporal | El plan de la 48 eran 11 pasos a mano; con el script se pueden cronometrar (RTO de 14 min el 10/11) y un técnico nuevo no se salta ninguno. En solo lectura la copia no se puede estropear al restaurar | 10/11/2026 |
| Tareas de otros que vencen sin empezar | Adrian hace la 47, la 48 y la 61 el 10/11; sus responsables (Eneko.S, Markel y Peio) las revisan para poder defenderlas | La entrega es el 13/11 y las tres son de documentación sobre trabajo ya hecho; cada uno presenta lo que no ha hecho (sección 9.2) | 10/11/2026 |
| Red que repite el router 2 (TL-WR841N) | La Wi-Fi de **invitados** (`Restaurante-Almichain-Invitados`), no la del personal | En modo Range Extender el TL-WR841N repite una sola red y no tiene menú de invitados. El enunciado pide ampliar la Wi-Fi de los clientes, el diseño de Packet Tracer ya lo dibuja así y el personal no lo necesita porque TPV, servidor y gerente van por cable ([tarea 25, sección 6](../redes/25-wds/DOCUMENTACION.md#6-por-qué-el-router-2-no-repite-la-wi-fi-de-clientes-y-cómo-se-arregla)) | 10/11/2026 |
| Firmware del TL-WR841N | No se actualiza | Es el router de prácticas y se sustituye por el Archer C6, que se pone en marcha con el último firmware; mientras, la administración está limitada al PC del gerente (hallazgo H-02 de la tarea 26) | 10/11/2026 |
| Tecnologías habilitadoras que se analizan | Siete: nube, IaC y automatización, ERP-TPV, sistemas embebidos, virtualización y contenedores, ciberseguridad e IA; y por qué no big data, blockchain ni robótica | Son las que de verdad están montadas en el repositorio, cada una con su evidencia; las que no se usan se justifican por el tamaño del restaurante ([tarea 58](../digitalizacion/58-tecnologias-habilitadoras.md)) | 10/11/2026 |
| Front-end de la recreativa | La interfaz propia de MAME (menú con filtro de juegos instalados, pantalla completa, manejo con el stick), sin EmulationStation ni Attract-Mode | Batocera (EmulationStation) ocupa 554 MB solo con el menú en 1 GB de RAM y tarda 12,9 s; Debian con MAME, 400 MB con el juego abierto y 7,1 s ([tarea 16, sección 4.7](../arcade/16-recreativa-mame/DOCUMENTACION.md#47-el-front-end-gráfico-la-interfaz-de-mame)) | 10/11/2026 |
| Web en tableta | Segundo punto de corte (801-1100 px) | La rúbrica pide móvil, tableta y escritorio; a 820 px la portada se salía de la pantalla y el formulario quedaba con campos de 150 px ([tarea 27, sección 4.1](../web/27-wireframes.md#41-tableta-801-1100-px)) | 10/11/2026 |
| Controlador del stick frente a un encoder USB | Arduino Leonardo (54,60 € con palanca y botones) y no un kit con encoder «zero delay» (unos 20 €) | El encoder tiene el mapeo fijo y no se puede programar; el Leonardo permite remapear sin reprogramar, ajustar el antirrebote y ampliarlo ([README del stick](../../arduino/mando-joystick/README.md#por-qué-un-microcontrolador-y-no-un-encoder-usb-comercial)) | 10/11/2026 |
| Documentación para entregar al profesor | Un único PDF (`entrega/Almi-Chain-documentacion.pdf`, unas 336 páginas) que se genera desde el repositorio con `python3 scripts/documentacion-entrega.py`: portada, índice con enlaces, 14 partes por bloque y los 59 documentos tal cual; los scripts y evidencias en texto quedan enlazados a GitHub. El PDF no se sube a Git (27 MB) | Cada tarea ya tiene su guía y no hay que redactarlo dos veces: si alguien corrige su documento antes del 13/11, se vuelve a generar en medio minuto. El script falla si aparece un `.md` nuevo sin meter en el índice, así que no se queda nada fuera | 10/11/2026 |
| Guest Additions del PC del gerente (VM) | Windows: las de la ISO de VirtualBox (7.2.16), instaladas en silencio con `/S`. Ubuntu: los paquetes del sistema `virtualbox-guest-utils` y `-x11` (7.2.6), no la ISO | Las pide la rúbrica (ISO RA1, nivel 4: «configuraciones adecuadas en VirtualBox (RAM, disco, Guest Additions...)»). En Ubuntu el paquete se actualiza con `apt` como el resto y no hay que recompilar módulos en cada núcleo. Añade un servicio a los de la tarea 64; en el Lenovo real no se instalan | 10/11/2026 |
| Cierre de la tarea 25 (WDS) | Se da por terminada el 12/11 con el router 2 enlazado por radio, sin DHCP y con ping e Internet; quedan como mejora la Wi-Fi de clientes por el router 2 y la cobertura medida en dBm | La entrega es el 12/11 y no hay tiempo de volver a montar los routers; lo que falta está descrito paso a paso en la sección 7 de la tarea y las pruebas W6 y W8 siguen como ⏳ en la tabla de pruebas | 12/11/2026 |
| Cierre de las tareas 5 y 46 | Se dan por terminadas el 12/11. La 5 con el repositorio, gitleaks y commits de 5 de las 6 personas (Eneko.P sin commits propios); la 46 con 26 hallazgos repartidos y las comprobaciones 1, 4, 5, 6, 7 y 9 hechas, sin las 2 y 3 en el servidor y los TPV del equipo | Es el día de la entrega; lo que falta no depende ya de Adrian (commits de Eneko.P) o necesita los equipos del equipo en la red. Queda apuntado en la tabla de pruebas (G-03) y en la sección 5 de la tarea 46 | 12/11/2026 |

## 6. Planificación

- Diagrama de Gantt y carga por persona: [gantt.md](gantt.md).
- Fuente de datos de la planificación: [backlog-kanban.csv](backlog-kanban.csv).
- Criterios de reparto y revisión: [roles.md](roles.md).

| Semana | Fechas | Objetivo |
|---|---|---|
| 1 | 21/10 – 27/10 | Organización, requisitos, comparativas, diseño (red, web, E/R) y presupuesto; buena parte de la implantación en VM |
| 2 | 28/10 – 04/11 | Terminar lo técnico (corte el miércoles 4/11, día de la rúbrica): equipos físicos, red y WDS, comprobaciones de seguridad |
| 3 | 05/11 – 11/11 | Huecos de la rúbrica (tareas 56-63), tabla de pruebas, documentación final, presentación y ensayo el 11/11 |

> **Fechas del reto:** del lunes 26/10 al jueves 12/11/2026. El 27/10 se fijó el corte técnico el 4/11 (sección 5). Las tareas ya hechas conservan sus fechas reales.

## 7. Ejecución

| Bloque | Ubicación en el repositorio |
|---|---|
| Documentación y diagramas | `docs/`, `docs/diagramas/` |
| Scripts de configuración y backup | `scripts/` |
| Infraestructura AWS | `iac/` |
| Web | `web/` |
| Arcade stick | `arduino/` |
| Evidencias | `docs/evidencias/` |

Incidencias relevantes durante la ejecución:

| Fecha | Bloque | Incidencia | Resolución |
|---|---|---|---|
| 22/10/2026 | Arcade | Debian 13 reserva el nombre de usuario `admin` y el instalador desatendido se paraba | El administrador se llama `tecnico` ([tarea 16](../arcade/16-recreativa-mame/DOCUMENTACION.md)) |
| 22/10/2026 | Arcade | Las medidas de rendimiento se hicieron en una VM de 2 núcleos y 1,5 GB, no de 1 núcleo y 1 GB como pide el enunciado | Repetidas el 29/10 en `Recreativa-53` (1 núcleo y 1 GB, 967 MB útiles): [tarea 54](../arcade/54-medidas-equipo-real/DOCUMENTACION.md) |
| 22/10/2026 | ERP | Odoo se instaló antes de cerrar la comparativa de ERP (tarea 32) | La tarea 32 eligió Odoo Community, así que no hay que rehacer nada |
| 22/10/2026 | ERP | Crear la factura por XML-RPC devolvía `cannot marshal None` | La acción sí se ejecuta; el script lo controla ([tarea 35](../erp/35-factura-automatica/DOCUMENTACION.md)) |
| 22/10/2026 | Redes | El router TP-Link TL-WR841N v14 no admite WPA3 | Se usa WPA2-PSK con AES; para WPA3 hace falta otro equipo ([red segura](../redes/24-red-segura/DOCUMENTACION.md)) |
| 23/10/2026 | Web | Sin presupuesto para un dominio de pago; DuckDNS (gratuito) no admite CNAME, así que no puede apuntar a CloudFront ni validar un certificado de ACM | Se cambia a EC2 con IP elástica y Let's Encrypt; S3 sigue guardando la web ([tarea 30](../web/30-hosting-aws.md), sección 2) |
| 23/10/2026 | Web | La consola de AWS no admite nombres de grupo de seguridad que empiecen por `sg-` | Se llama `web-almichain-sg` |
| 23/10/2026 | Web | La redirección de HTTP que crea certbot mostraba la versión de nginx | `server_tokens off` en el bloque `http` del script |
| 23/10/2026 | Web | Lighthouse: contraste insuficiente en tres textos, imágenes de 1600 px en móvil y un error del W3C | Corregido en `web/` (PR #25); Lighthouse 98-100 |
| 23/10/2026 | ERP | En una instalación limpia de Odoo, `configurar-odoo.py` y `cargar-carta-y-mesas.py` fallaban (almacén buscado antes de instalar Inventario; `copy` devuelve una lista en Odoo 19) | Corregidos y repetida toda la instalación hasta la factura ([verificación](verificacion.md), sección 4) |
| 23/10/2026 | Gestión | 14 enlaces rotos y documentos fuera de la carpeta de su bloque | Movidos a `docs/redes/` y `docs/bd/` y enlaces corregidos; `scripts/verificar-repo.sh` lo comprueba |
| 23/10/2026 | Seguridad | Contraseñas débiles de la VM del gerente en un fichero de texto sin seguimiento | No se sube (añadido al `.gitignore`); se cambian y se guardan en KeePassXC (tarea 55) |
| 26/10/2026 | Seguridad | El certificado propio de Odoo (tarea 52) era una CA sin límites: con su clave se podían firmar certificados de cualquier web, y los TPV se los creerían | `nameConstraints` limitado a la IP del servidor y a `odoo.almichain.local`; probado con un certificado falso, que ahora se rechaza ([tarea 46, S-01](../seguridad/46-revision-seguridad/DOCUMENTACION.md#41-s-01-el-certificado-de-odoo-podía-firmar-cualquier-web-corregido)) |
| 27/10/2026 | ERP | La impresora USB pasada a la VM del TPV no creaba el puerto `USB001` y el ticket no salía desde la VM | El TPV imprime por IPP en la cola CUPS del equipo que tiene la impresora; probado con el ticket en papel y ya sin QR ([tarea 52, sección 4.2](../erp/52-https-odoo/DOCUMENTACION.md#42-pruebas-5-y-6-con-un-tpv-provisional-26102026)) |
| 29/10/2026 | SO | En VMware, sobre un Ubuntu con Wayland, no funcionaban copiar y pegar ni algunas teclas, y Windows Update fallaba porque el adaptador de red estaba deshabilitado | VM del gerente pasada a VirtualBox (disco SATA, teclado USB); Windows al día (KB5066791) ([tarea 12, sección 7](../so/12-dual-boot.md#7-decisiones-y-problemas-encontrados)) |
| 29/10/2026 | Seguridad | Al activar BitLocker, la clave de recuperación salió en pantalla (`Add-BitLockerKeyProtector` la escribe como advertencia) | Clave sustituida por otra que no se mostró y script corregido (`-WarningAction SilentlyContinue`) |
| 29/10/2026 | Redes | En tres capturas de la segunda parte de la red segura se leían la contraseña Wi-Fi (la misma en personal e invitados) y el PIN de WPS: el recuadro negro tapaba el campo de al lado | Capturas tapadas bien; hay que cambiar la contraseña y poner otra distinta en invitados (tarea 46, S-24) |
| 29/10/2026 | Gestión | La 17, la 18 y la 54 pedían la misma medida en la VM de 1 GB, y la 48 estaba en Hecho sin haber empezado | La medida queda solo en la 54; la 17 y la 18 se cierran con lo hecho; la 48 vuelve a En curso ([roles.md](roles.md)) |
| 27/10/2026 | Seguridad | Los TPV se bastionaron a mano y no tienen el bloqueo de salida del firewall ni la lista blanca de Edge que da `configurar-tpv.ps1`; `subir.sh` instalaba la librería del stick sin versión fija | Hallazgos S-20 (Markel) y S-21 (corregido: versión 2.1.1 fijada) ([tarea 46, sección 1.1](../seguridad/46-revision-seguridad/DOCUMENTACION.md#11-repaso-del-27102026)) |
| 30/10/2026 | ERP | `restringir-menus-cajero.py` no ocultaba nada a los cajeros: Odoo enseña un menú si el usuario está en cualquiera de sus grupos, y el grupo de gerencia se sumaba a «Usuario interno» | El grupo de gerencia queda como único grupo de esos menús (los originales se guardan para deshacerlo); se comprueba con `ver-menus-usuarios.py` ([tarea 34](../erp/34-configurar-odoo/DOCUMENTACION.md)) |
| 30/10/2026 | ERP | `cortafuegos-servidor.sh` lanzado con `ssh host 'sudo …'` no encontraba la IP de quien lo ejecutaba (`who -m` no tiene entrada sin shell de login) y podía dejarle sin SSH | Busca `SSH_CLIENT` en los procesos padre; probado en el laboratorio ([tarea 33](../erp/33-odoo-docker/DOCUMENTACION.md)) |
| 30/10/2026 | Redes | El nmap de la tarea 26 encontró en el router UPnP activo y SSH con software de hace más de diez años | Hallazgo S-25 de la tarea 46 (Peio): desactivar UPnP y actualizar el firmware |
| 03/11/2026 | Seguridad | En la `ServidorERP` del laboratorio el SSH sigue aceptando contraseña y no hay actualizaciones automáticas (comprobaciones 6 y 7 de la tarea 46) | Aplicada la sección 4.2 en el laboratorio y repetidas: las dos pasan. Falta en el servidor del equipo (S-08 y S-09, Iker); los comandos están en la sección 4.2 de la [tarea 46](../seguridad/46-revision-seguridad/DOCUMENTACION.md#42-s-08-y-s-09-endurecer-el-servidor-erp) |
| 04/11/2026 | Backup | La prueba de restauración solo comparaba la base de Odoo: la de `almi_chain` iba en la copia pero nadie comprobaba que se recuperara | `probar-restauracion.sh` restaura también los roles y `almi_chain` y compara tablas, filas, importes y permisos; 23 comprobaciones OK desde S3 y desde el RAID ([tarea 45](../backup/45-restauracion/DOCUMENTACION.md)) |
| 04/11/2026 | Backup | Al montar el laboratorio desde cero, `mover-docker-al-raid.sh` no se podía ejecutar: estaba en Git sin permiso de ejecución | Permiso corregido en Git; esa vez se lanzó con `bash` |
| 04/11/2026 | Backup | El Learner Lab no deja crear el usuario IAM que preveía la tarea 44 para S3 | Credenciales temporales del lab (sección 5); la copia a S3 solo funciona con el lab arrancado |
| 04/11/2026 | Gestión | La auditoría del repositorio con la rúbrica encontró textos desfasados: README, CORRECIONES, LOGICA_RETO, tareas 9, 10, 11-18, 23, 25, 30, 33, 40 y 43, listas de pendientes ya hechas y la validez del presupuesto (15 días desde el 22-24/10, que vence el 06-08/11) | Corregidos en el PR #108; `CORRECIONES.md` tiene ahora una tabla de cumplimiento del enunciado (sección 5). Lo que queda va en la tarea 61 (Peio) y LOGICA_RETO en la 48 (Markel) |
| 04/11/2026 | Redes | En la tarea 25 los nombres de las capturas no coincidían con lo que mostraban, faltaba la del DHCP apagado del router 2 y las medidas de cobertura (-31 dBm) y las de aislamiento se tomaron conectado al **router 1**, no al 2 | Capturas renombradas por su contenido, foto del DHCP apagado recuperada y la [tarea 25](../redes/25-wds/DOCUMENTACION.md#7-lo-que-falta-hoja-de-trabajo) dice qué repetir conectado al router 2 (Peio) |
| 04/11/2026 | Arduino | Para la tarea 59 se subió a `arduino/` un documento que describe otro montaje (Arduino Uno R3 con un joystick KY-023 que envía por serie) y no el stick del proyecto (Leonardo con HID, 4 botones y palanca) | Pendiente: pasar lo que sirva (componentes, por qué el ATmega32U4) al [README del stick](../../arduino/mando-joystick/README.md) con los datos reales y quitar el documento suelto (Markel, tarea 59) |
| 05-06/11/2026 | Gestión | Las tareas 15, 25, 36, 46, 59 y 63 tenían fin el 05 o el 06/11 y no han entrado cambios en `main` desde el 04/11 a las 13:44 | Siguen abiertas en el [Gantt](gantt.md). Casi todo lo que falta necesita el aula (TPV, router, servidor del equipo), así que conviene hacerlo en una misma sesión |
| 09/11/2026 | SO | Tarea 64 (servicios reducidos en la VM del gerente): Windows Update volvió a poner Windows Boot Manager el primero en el arranque EFI y GRUB no salía; además, un disco FAT32 sin tabla de particiones no se ve en Windows | Orden EFI corregido desde Ubuntu con `efibootmgr -o` ([tarea 12, sección 7](../so/12-dual-boot.md#7-decisiones-y-problemas-encontrados)); el disco de intercambio se rehízo con una partición MBR. Servicios reducidos: 11 en Windows y 5 en Ubuntu; en un arranque normal Ubuntu solo escucha en localhost ([tarea 12, sección 6](../so/12-dual-boot.md#6-verificación)) |
| 09/11/2026 | Gestión | Un commit subido directo a `main`, sin PR, renombró `25-wds/DOCUMENTACION.md` a `WDS.md`: 7 enlaces rotos, la evidencia de la tarea 25 del backlog sin fichero y `gantt.py` y `verificar-repo.sh` en rojo. Ya pasó el 27/10 | Nombre recuperado en la PR #112, con la verificación otra vez en verde. Cualquier cambio de nombre va en una PR que arregle los enlaces a la vez |
| 09/11/2026 | Gestión | Las tareas 15, 25, 36, 46, 59 y 63 (fin el 05-06/11) siguen abiertas y la 61 y la 62 vencen hoy sin cambios en `main`. Desde el 06/11 solo han entrado la 64 y el renombrado anterior | Siguen en el [Gantt](gantt.md); quedan dos días hasta el ensayo del 11/11. Lo que necesita el aula (TPV, router, servidor del equipo) conviene hacerlo en una sola sesión |
| 10/11/2026 | Backup | Al recuperar el servidor en una máquina nueva, restic se quedaba reintentando con `read-only file system` | El USB se monta en solo lectura para no tocar la copia, y restic intenta dejar un bloqueo en el repositorio. `--no-lock` en `recuperar-servidor-nuevo.sh` (leer no necesita bloqueo); el tiempo perdido no cuenta en el RTO |
| 10/11/2026 | Gestión | La 47, la 48 y la 61 (Eneko.S, Markel y Peio) llegaban a su fecha de fin sin cambios | Las hizo Adrian el 10/11 (decisión de la sección 5); los responsables las revisan. Siguen abiertas la 2, 5, 15, 25, 36, 46, 49, 57-59, 62 y 63 |
| 10/11/2026 | Redes | La tarea 25 llevaba desde el 04/11 «en curso». Al revisarla, el router 2 está enlazado a la Wi-Fi del personal (el enunciado pide ampliar la de clientes), la medida de -31 dBm es del router 1 a 0 m, las pruebas de aislamiento se hicieron conectado al router 1 y el documento decía que no había captura del canal 6 (está en la tarea 24) | Documento reordenado: qué demuestra cada captura, por qué el router 2 repite una sola red y una hoja de trabajo de 30-45 min para Peio (enlazar a invitados, pruebas en el router 2, dBm antes y después, UPnP). Nombre de la Wi-Fi del personal unificado en 23 y 24 |
| 10/11/2026 | Arduino | El documento de la tarea 59 subido el 04/11 (`arduino/Stick - antirrebote….md`) describía un Arduino Uno con un joystick analógico KY-023 y tenía datos «[confirmar]» sin rellenar: no es el stick del reto (Leonardo, palanca digital y 4 botones) | Quitado (queda en el historial de Git). Lo que pedía la tarea va en el [README del stick](../../arduino/mando-joystick/README.md): antirrebote explicado, pruebas por control, componentes con precio y comparación con un encoder comercial |
| 10/11/2026 | Backup | La copia nocturna del servidor del laboratorio falló a las 10:08 en el paso de S3 (`client.BucketExists: 400 Bad Request`): las credenciales temporales del Learner Lab de `s3.env` habían caducado. RAID y USB sí se copiaron y saltó el aviso de fallo | Credenciales nuevas en `s3.env` (sin mostrarlas) y copia relanzada a las 13:19: RAID, USB y S3 correctos y `check` sin errores. Procedimiento de renovación en la tarea 44, sección 8.2 |
| 10/11/2026 | SO | Al entrar en Windows desde el menú de GRUB, la pantalla de BitLocker no recibía el teclado | Se apagó desde esa pantalla (nada descifrado) y se entró desde el Boot Manager del firmware, donde el teclado funciona. Anotado en la tarea 12, sección 7 |
| 10/11/2026 | Gestión | La segunda auditoría (bóveda local, `auditoria-v2`) encontró «N de 64 tareas hechas» distinto en README (52), LOGICA_RETO (49) y Gantt (54) | Los tres dicen 54 de 64, como el CSV |
| 12/11/2026 | Arduino | La tarea 59 (Markel) llegaba a la entrega sin la prueba del antirrebote en la placa, y en el PC de Adrian `subir.sh` paraba: no había `arduino-cli` ni el AppImage del Arduino IDE | Se instaló solo `arduino-cli` 1.6.0 con el instalador oficial en `~/.local/bin` (donde lo busca `subir.sh`), sin el IDE; Adrian subió el firmware y lo probó con `ver-mando.py` (sección 8). Markel lo revisa |

## 8. Pruebas

| Bloque | Prueba | Resultado esperado | Resultado obtenido | Evidencia |
|---|---|---|---|---|
| SO | Arranque de ambos sistemas desde GRUB | Ambos arrancan y GRUB muestra las dos entradas | GRUB 2.14 muestra Ubuntu y Windows Boot Manager; particiones, EFI compartida, cuentas y firewall comprobados; contraseñas robustas en KeePassXC (23/10). 29/10: Windows al día (KB5066791), BitLocker pide la contraseña al arrancar y `/home/gerente` cifrado con fscrypt. 09/11 (tarea 64): servicios reducidos, 11 en Windows y 5 en Ubuntu; en un arranque normal Ubuntu solo escucha en localhost | [tarea 12](../so/12-dual-boot.md#6-verificación) |
| SO | Cajero intenta instalar software / usar USB | Operación denegada | Memoria USB sin acceso (directiva *denegar todo acceso*) y usuario de caja sin administrador, en las dos VM (26/10). Falta pasar `comprobar-tpv.ps1` (16 OK) | [tarea 13](../so/13-tpv/Tarea13_Markdown_GitHub/13-bastionado-tpv-windows.md) |
| Arcade | Rendimiento MAME antes y después de optimizar | Aumento de FPS y menor consumo de RAM | En la VM de 1 núcleo y 1 GB (29/10, `Recreativa-53`): MAME va de sobra (*Robby Roto* al 777 %, *Gridlee* al 1021 %); jugando, CPU media 52-58 % y más de 460 MB libres, sin swap. La optimización baja los timers de 8 a 5 y el disco un 12 %; velocidad, arranque y RAM no cambian de forma concluyente | [tarea 54](../arcade/54-medidas-equipo-real/DOCUMENTACION.md) |
| Arduino | Stick en MAME y en un segundo emulador | Todas las entradas reconocidas y remapeables | En la placa (27/10): 4 botones y palanca llegan al PC sin pulsaciones fantasma; `MAP` y `GUARDAR` sobreviven al reinicio; Batocera lo reconoce (`evtest`) y se jugó una partida; en MAME, partida de *Gridlee* en la recreativa de 1 GB (tarea 53, 29/10). 04/11: antirrebote por software probado en el PC con rebotes simulados (9 de 9 OK). 12/11: subido a la placa; `ver-mando.py` 45 s, 116 pulsaciones y ninguna de menos de 30 ms (la más corta, 39 ms), las 4 direcciones ([registro](../../arduino/mando-joystick/evidencias/entrada-stick-2026-11-12-0918.txt)) | [tarea 50](../../arduino/mando-joystick/README.md#prueba-en-físico-tarea-50) |
| Redes | Cliente de la red de invitados accede a la red interna | Acceso bloqueado | Red de invitados configurada el 29/10 (sin acceso a la LAN y con aislamiento entre clientes); 30/10: desde un móvil de invitados, el ping al PC del gerente y a otro móvil de invitados no responde, y el de Internet sí. ✅ | [tarea 24](../redes/24-red-segura/configurar-red-segura.md#9-pruebas-de-la-red-de-invitados) |
| Redes | Roaming y throughput con WDS | Cobertura ampliada; velocidad medida con iperf3 | Prueba de laboratorio del 27/10 con dos TL-WR841N: el enlace WDS funciona. 04/11, con la red del proyecto: router 2 en Range Extender en `192.168.10.2`, DHCP apagado, ping al router 1 sin pérdidas e invitados aislados. La medida de -31 dBm y las de aislamiento se tomaron conectado al router 1. Falta (hoja de trabajo de la tarea 25, sección 7): enlazar el router 2 a la Wi-Fi de clientes, repetir las pruebas en su BSSID y medir los dBm en la barra y la entrada con el router 2 apagado y encendido | [tarea 25](../redes/25-wds/DOCUMENTACION.md) |
| Web | Lighthouse y validador W3C | Sin errores; puntuación ≥ 90 | W3C sin errores; Lighthouse contra la URL pública con la web actual (29/10, tras el `terraform apply`): móvil 97/100/100/100 y escritorio 100/100/100/100 | [lighthouse-w3c.txt](../evidencias/web/lighthouse-w3c.txt) |
| Web | Acceso por HTTP | Redirección a HTTPS con certificado válido | `301` a HTTPS; certificado de Let's Encrypt válido hasta el 21/01/2027 | [tarea 30, sección 5](../web/30-hosting-aws.md#5-pruebas) |
| ERP | Venta en el TPV de barra | Ticket, cobro, cierre de caja y asiento contable | Mesa 3, 35,50 € en efectivo: factura simplificada, caja cuadrada (diferencia 0,00 €) y asiento `POSS/2026/10/0001` validado | [tarea 34, sección 8](../erp/34-configurar-odoo/DOCUMENTACION.md) |
| ERP | Venta por HTTPS y venta sin red (tarea 52) | Candado sin avisos; la venta sin red se guarda y se sincroniza | Edge sin avisos con el certificado propio; venta de 7,30 € y, con el cable quitado, venta de 5,00 € que aparece en el servidor como `paid` al reconectar. Hecho con un TPV provisional (VM win-11) en la red 192.168.10.0/24. El 27/10 el ticket se imprime desde esa VM por IPP, sin QR | [tarea 52, sección 4.2](../erp/52-https-odoo/DOCUMENTACION.md#42-pruebas-5-y-6-con-un-tpv-provisional-26102026) |
| ERP | Factura automática de extremo a extremo | Pedido, factura validada, cobro y PDF sin intervención | Repetido el 23/10 en una instalación limpia: `INV/2026/00001` y `00002` cobradas y con PDF. No incluye envío por correo ni descuento de stock (ideas del plan, no exigidas por el enunciado). Repetido el 27/10 con el caso de uso real (menú de grupo, IVA 10 %): `INV/2026/00004` = 660,00 € | [tarea 35](../erp/35-factura-automatica/DOCUMENTACION.md) |
| BD | Usuario de aplicación ejecuta DDL | Permiso denegado | `CREATE TABLE`: *permission denied for schema public*; `DROP` y `ALTER`: *must be owner*; `DELETE`/`UPDATE` de facturas denegados; 33 pruebas de reglas correctas (repetido el 23/10). 04/11, con la ampliación del E/R (tarea 56): 17 tablas y 49 pruebas correctas en PostgreSQL 16 ([evidencia](../bd/evidencias/56-ampliacion-er.txt)) | [verificación](verificacion.md), [05-pruebas.sql](../bd/scripts/05-pruebas.sql) |
| RAID | Retirada de un disco del RAID 1 | Servicio continúa; reconstrucción correcta | Los datos siguen accesibles y se puede escribir; arranca degradado; reconstrucción en 27 s con las sumas SHA-256 intactas. El 27/10 la BD y los adjuntos de Odoo pasan al RAID y se repite con una venta en el RAID degradado ([tarea 43](../backup/43-raid1/DOCUMENTACION.md)) | [tarea 43](../backup/43-raid1/DOCUMENTACION.md) |
| Backup | Restauración completa en entorno limpio | Datos íntegros; tiempo de recuperación registrado | Restaurada la copia del USB en un entorno aislado: 16 comprobaciones coinciden con producción; 46 s de restauración en el mismo servidor; repetida el 27/10 con la BD en el RAID: todo correcto en 63 s. 04/11 (tarea 60): copia en AWS S3 y restauración desde S3 con `almi_chain` incluida, 23 comprobaciones OK en 166 s. **10/11: RTO real de 832 s (≈ 14 min)** en una VM vacía con el preseed y `recuperar-servidor-nuevo.sh`: Odoo por HTTPS con la última venta de la copia ([log](../backup/45-restauracion/evidencias/rto-maquina-nueva-2026-11-10.log)) | [tarea 45](../backup/45-restauracion/DOCUMENTACION.md) |
| Seguridad | Revisión transversal de scripts y configuraciones | Hallazgos con gravedad, responsable y arreglo | 26 hallazgos (6 altos), repasado hasta el PR #99 (03/11); 10 corregidos (S-01, S-04, S-05, S-06, S-13, S-15, S-18, S-21, S-22 y S-24), S-11 hecho en el PC del gerente, S-12 resuelto en el diseño de los TPV y S-03 sin aplicar (se descarta Batocera). Comprobaciones: invitados sin acceso a la LAN y router (1, 4, 5) y cifrado del gerente (9) ✅; en el laboratorio, solo 22, 80 y 443 hacia fuera, y SSH solo con clave y `unattended-upgrades` activo tras aplicar la sección 4.2 (6 y 7; falta en el servidor del equipo, S-08 y S-09). 04/11: S-08 y S-09 en el preseed del servidor; 6 y 7 pasan en una instalación desde cero sin tocar nada a mano. Faltan las de los equipos del equipo en la red (2, 3) y el HTTPS en el servidor del equipo (S-02), hoy probado solo en VM | [tarea 46](../seguridad/46-revision-seguridad/DOCUMENTACION.md) |
| SO | Guest Additions en los dos sistemas de la VM del gerente | El anfitrión lee la versión con `VBoxManage guestproperty` | 10/11: 7.2.16 con Windows arrancado y 7.2.6 con Ubuntu | [win-17](../evidencias/12-dual-boot/win-17-guest-additions-desde-anfitrion.txt), [ubu-16](../evidencias/12-dual-boot/ubu-16-guest-additions-desde-anfitrion.txt) |
| Backup | Copia a S3 con las credenciales caducadas y renovadas | Falla solo S3, avisa, y vuelve a funcionar al renovarlas | 10/11: RAID y USB guardados y aviso de fallo; tras renovar, `6959de7f` en S3 y `check` sin errores | [log](../backup/44-backup-3-2-1/evidencias/s3-caducado-y-renovado-2026-11-10.log) |

## 9. Documentación y presentación

> **Borrador del 26/10/2026, revisado el 04/11 con la rúbrica y puesto al día el 10/11** (Adrian). Lo que existe hoy y lo que falta para la entrega. Cada responsable actualiza su fila.

### 9.1 Entregables

| Entregable | Tarea | Responsable | Qué hay ya | Qué falta | Estado |
|---|---|---|---|---|---|
| Documentación técnica paso a paso | 48 | Markel | [LOGICA_RETO.md](../../LOGICA_RETO.md) con el montaje desde cero en orden (sección 15: red → servidor → copias → puestos → recreativa → web → comprobar), un `DOCUMENTACION.md` por tarea y el capítulo de restauración ([48-documentacion-final-restauracion.md](../backup/48-documentacion-final-restauracion.md)) con el RTO real (10/11) | Que Markel lo repase para defenderlo | Hecho (10/11) |
| Documentación completa en un solo PDF | 48 | Adrian | `python3 scripts/documentacion-entrega.py` genera `entrega/Almi-Chain-documentacion.pdf` con todo el repositorio en orden (10/11) | Regenerarlo el día de la entrega, después de la última PR | Hecho (10/11) |
| Diagramas | Cada bloque | Responsable de cada bloque | Arquitectura de equipos ([tarea 11](../diagramas/11-arquitectura-equipos/DIAGRAMA.md)), plano y red ([tarea 23](../redes/23-plano-direccionamiento.md)), E/R y 3FN ([tareas 38](../bd/38-modelo-er.md) y [39](../bd/39-modelo-logico-3fn.md)), wireframes ([tarea 27](../web/27-wireframes.md)), Gantt ([gantt.md](gantt.md)) | **AWS:** hecho el 29/10 ([tarea 30, sección 2](../web/30-hosting-aws.md#2-arquitectura)). **Copias:** un esquema de la regla 3-2-1 (datos → RAID → USB fuera del local) | Parcial |
| Tabla de pruebas por bloque | 47 | Eneko.S | [47-tabla-pruebas.md](47-tabla-pruebas.md): 73 pruebas de los 11 bloques (66 ✅, 3 🟡, 4 ⏳ tras el antirrebote en la placa del 12/11), repasada fila a fila el 10/11; sección 8 de este anexo y [verificacion.md](verificacion.md) | Las filas ⏳ dependen de tareas abiertas (5, 15, 25, 36, 59); que Eneko.S la repase para defenderla | Hecho (10/11) |
| Presentación y ensayo | 49 | Peio | — | Ver 9.2 | Pendiente |
| Anexo I (contrato de equipo) | 1 | Adrian | [Firmado el 21/10](anexo-I-contrato-equipo.md) | — | Hecho |
| Anexo II (este documento) | 2 | Adrian | Secciones 1 a 8, al día el 10/11 | Lo que entre hasta la entrega; cerrar la 9 y la 10 después de la presentación | En curso |
| Commits de todos (Anexo IX) | 5 | Adrian | 5 de 6 personas con commits propios | Un commit de Eneko.P | En curso |
| Máquinas virtuales | 12, 13, 33, 53 | Quien tiene cada una | No se suben a Drive (30/10): cada VM está en el PC de quien la tiene ([maquinas-virtuales.md](maquinas-virtuales.md)) | Que Iker y Markel confirmen en qué PC están las suyas | En curso |
| Tecnologías habilitadoras | 58 | Eneko.P | [58-tecnologias-habilitadoras.md](../digitalizacion/58-tecnologias-habilitadoras.md) (10/11, redactado por Adrian) | Que Eneko.P lo revise y lo sepa defender | Hecho |
| Registro de uso de IA | — | Todos | [registro-ia.md](registro-ia.md) | Que cada persona revise sus entradas | En curso |

### 9.2 Presentación (propuesta)

Una parte por bloque. Cada persona presenta **lo que no ha hecho**, para demostrar que puede defender el conjunto (condición transversal de la sección 1). Duración orientativa. La última columna dice qué criterios de la [rúbrica](rubrica-anexo-VI.md) defiende cada parte, para que ninguno se quede sin enseñar:

| # | Parte | Qué enseñar en directo o en captura | Min | Rúbrica |
|---|---|---|---|---|
| 1 | El encargo y cómo nos organizamos | Requisitos (sección 2), Gantt, flujo de ramas y PR con gitleaks | 2 | — |
| 2 | Red | Plano, plan de IP, Packet Tracer y la decisión de red plana con invitados aislada | 3 | 4 |
| 3 | Puestos de trabajo | GRUB con los dos sistemas; TPV en quiosco intentando abrir otra cosa o un USB | 3 | 1 |
| 4 | ERP | Venta en el TPV por HTTPS y la factura automática (`factura_automatica.py`) | 4 | 7 |
| 5 | Datos y copias | E/R, usuario sin permisos de DDL, quitar un disco del RAID y restaurar una copia | 3 | 2, 8, 9, 10 |
| 6 | Web | `https://almichain1.duckdns.org`, Lighthouse y `terraform plan` | 2 | 5, 6 |
| 7 | Recreativa y stick | MAME arrancando sin escritorio, medidas antes y después y el stick en dos emuladores | 3 | 3, 12 |
| 8 | Seguridad | Hallazgos de la tarea 46 y cómo se cerraron | 2 | 1 y 4 (nivel 5) |
| 8b | Tecnologías habilitadoras | Nube (AWS), ERP y microcontrolador: para qué sirven en el restaurante y frente a qué alternativas (tarea 58) | 2 | 11 |
| 9 | Retrospectiva | Sección 10 | 1 | — |

**Plan B para la demo:** si falla la red del aula o el Learner Lab está parado, cada demo tiene su captura o su `.txt` en `evidencias/`. Se llevan abiertas en pestañas.

### 9.3 Lista de entrega

- [ ] `main` con todas las PR unidas y el CI en verde.
- [ ] `bash scripts/verificar-repo.sh` sin errores y `python3 scripts/gantt.py` regenerado.
- [ ] PDF de la documentación regenerado con `python3 scripts/documentacion-entrega.py` después de la última PR, y subido a la entrega.
- [ ] Backlog al día: ninguna tarea «En curso» sin explicar en *Observaciones*.
- [ ] Ninguna captura con contraseñas (revisar ampliadas: gitleaks no mira imágenes).
- [ ] Enlace de Drive del `.kdbx` accesible para el profesor; la contraseña maestra se entrega aparte, nunca en el repositorio. Las VM entregables, arrancadas o a mano en el PC de quien las tiene ([maquinas-virtuales.md](maquinas-virtuales.md)).
- [ ] Liberar la IP elástica de AWS cuando el profesor haya visto la web.

## 10. Evaluación y retrospectiva

> **Borrador del 26/10/2026** (Adrian): puntos sacados del backlog, del historial y de las incidencias. **Hay que completarlo entre todos** en una reunión de 20 minutos después de la presentación. Cada uno añade al menos un punto en cada fila.

| | |
|---|---|
| **Qué ha funcionado** | Scripts idempotentes y probados en una máquina limpia (Odoo, TPV, HTTPS, copias): repetir una instalación cuesta minutos. · Ramas, PR y gitleaks: ningún secreto en el código (81 commits revisados el 23/10). · La revisión del 23/10 ([verificacion.md](verificacion.md)) encontró 14 enlaces rotos y 2 scripts que fallaban en una instalación limpia antes de la entrega. · Las decisiones se apuntan con fecha (sección 5), así que no se repiten discusiones. |
| **Qué mejorar** | Reparto: la mayoría del software cayó en dos personas ([roles.md](roles.md)). · Las tareas físicas (stick, router, recreativa real) se dejaron para el final y dependen de material que no teníamos. · Probar con el equipo que pide el enunciado: las medidas de MAME se hicieron en una VM de 2 núcleos y 1,5 GB (tarea 17) y la red con un router sin WPA3 (tarea 24). · Revisar las capturas antes de subirlas: dos dejaban ver la contraseña Wi-Fi (tarea 24). · Hacer la revisión de seguridad antes, no al final: el hallazgo S-01 de la [tarea 46](../seguridad/46-revision-seguridad/DOCUMENTACION.md) se habría evitado al escribir la tarea 52. · Revisar las capturas ampliadas antes de subirlas: el 29/10 volvió a pasar (tarea 24, S-24). · Repasar el backlog entero de vez en cuando: el 29/10 había tareas duplicadas (17, 18 y 54) y una marcada como hecha sin empezar (48). · Comprobar que cada captura muestra lo que dice su nombre y desde qué equipo se tomó: en la tarea 25 las medidas eran del router 1, no del 2 (04/11). · Partir del material del proyecto al documentar: el 04/11 llegó un documento del stick hecho sobre otra placa (tarea 59). · Todo por PR: dos veces (27/10 y 09/11) un commit directo a `main` rompió los enlaces y la verificación. |
| **Desviaciones respecto a la planificación** | Fechas del reto movidas al 26/10 – 12/11 (decisión del 24/10). · Eneko.P sigue sin commits propios; las tareas 43 y 47 pasaron de él a otras personas, y la 17 y la 18 se cerraron con lo que ya habían hecho otros (29/10). · La recreativa se entrega en VM en vez de en un equipo físico (decisión del 29/10). · Varias tareas cambiaron de responsable (13, 14, 17, 18, 37, 43, 46). · La BD viva no pasó al RAID hasta el 27/10 (tarea 43), y eso retrasó el HTTPS en el servidor del equipo (tarea 52). · El corte técnico del 4/11 no se cumplió del todo: el 06/11 siguen abiertas la 15 (scripts en los TPV), la 25 (WDS), la 36 y la 63 (Odoo con datos), la 46 (seguridad en el servidor del equipo) y la 59 (stick), casi todas porque necesitan los equipos del aula. · *Completar con la comparación final del Gantt: tareas acabadas tarde y cuántos días.* |
| **Uso de IA y validación** | Ver [registro-ia.md](registro-ia.md). Todo lo hecho con IA se ha ejecutado y comprobado (evidencias en cada tarea); los scripts se probaron en máquinas limpias. |
| **Nota del equipo (1-10) y por qué** | *A rellenar en la reunión* |
