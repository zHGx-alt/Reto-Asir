# Tarea 58: Tecnologías habilitadoras digitales del reto

- **Bloque:** 11 Entrega (Digitalización aplicada a los sectores productivos, RA2)
- **Responsable:** Eneko.P · redactado por Adrian el 10/11/2026 a partir de lo que hay montado en el repositorio
- **Depende de:** tareas 30 (AWS) y 32 (ERP)
- **Criterio de la rúbrica:** [11. Análisis y justificación de las THD empleadas en el reto](../gestion/rubrica-anexo-VI.md#11-análisis-y-justificación-de-las-thd-empleadas-en-el-reto-cloudaws-erp-tpv). Nivel 4: «caracteriza correctamente las THD usadas (cloud, ERP) y su aplicación en el reto». Nivel 5: «compara alternativas y justifica la elección según las necesidades de la empresa».

## 1. Qué es una THD y cuáles usa el reto

Las **tecnologías habilitadoras digitales** (THD) son las que permiten a una empresa digitalizar su forma de trabajar: no son un producto concreto, sino una familia de tecnologías (nube, IoT, inteligencia artificial, ciberseguridad, sistemas de gestión integrados, big data, blockchain, robótica, fabricación aditiva, realidad aumentada…). Una empresa no necesita todas: elige las que resuelven sus necesidades.

Almi-Chain es una **cadena pequeña de restaurantes** con un local (y previsión de más), sin informático propio y con poco presupuesto. Lo que necesita, según el enunciado, es: cobrar y facturar sin errores, que los datos no se pierdan, que el local se pueda replicar en otro sitio, una web visible, Wi-Fi para clientes y una recreativa como reclamo. Con eso, estas son las THD que se han usado:

| THD | Dónde está en el reto | Necesidad del restaurante que cubre |
|---|---|---|
| **Computación en la nube** (AWS) | Web en S3 + EC2 (tareas [30](../web/30-hosting-aws.md) y [31](../../iac/README.md)); tercera copia de seguridad en S3 ([tarea 44, sección 8.2](../backup/44-backup-3-2-1/DOCUMENTACION.md#82-tercer-repositorio-en-aws-s3-copia-3b)) | Web siempre accesible sin servidor propio; copia fuera del local que no depende de que alguien se lleve un USB |
| **Infraestructura como código y automatización** | Terraform y GitHub Actions ([tarea 31](../../iac/README.md)); preseed del servidor y scripts de instalación (tareas 33, 43, 44, 45) | Montar otra vez la web, el servidor o un local nuevo en minutos y siempre igual |
| **Sistemas de gestión empresarial: ERP con TPV** | Odoo Community 19 en Docker (tareas [32](../erp/32-comparativa-erp.md), [33](../erp/33-odoo-docker/DOCUMENTACION.md), [34](../erp/34-configurar-odoo/DOCUMENTACION.md), [35](../erp/35-factura-automatica/DOCUMENTACION.md), [52](../erp/52-https-odoo/DOCUMENTACION.md)) | Cobrar en el TPV, que la venta vaya sola a facturación e inventario, y tener clientes, personal y marketing en un mismo sitio |
| **Sistemas embebidos / IoT** | Arcade stick con Arduino Leonardo (ATmega32U4) como mando USB ([firmware y montaje](../../arduino/mando-joystick/README.md)) | Un mando a medida, reprogramable y barato para la recreativa del local |
| **Virtualización y contenedores** | Odoo y PostgreSQL en Docker Compose; los equipos se probaron en máquinas virtuales ([maquinas-virtuales.md](../gestion/maquinas-virtuales.md)) | Instalar y actualizar el ERP sin tocar el sistema; probar todo antes de comprar el hardware |
| **Ciberseguridad** | HTTPS (web y Odoo), copias cifradas con AES-256 (restic), cortafuegos en cada equipo, red de invitados aislada, contraseñas en KeePassXC, gitleaks ([tarea 46](../seguridad/46-revision-seguridad/DOCUMENTACION.md)) | Proteger los datos de clientes y ventas (RGPD) y que un cliente en la Wi-Fi no llegue a la caja |
| **Inteligencia artificial** | Asistentes de IA (Claude, Claude Code) para redactar, programar y revisar, con [registro de cada uso](../gestion/registro-ia.md) | Hacer más trabajo con un equipo pequeño; siempre revisado y probado por una persona |

**THD que no se usan, y por qué:**

- **Big data y analítica avanzada:** con un local, los informes de ventas de Odoo bastan. Tendría sentido con muchos locales (comparar ventas por local y por hora).
- **Blockchain:** el nombre «Almi-Chain» viene de *cadena* de restaurantes, no de blockchain. No hay ninguna necesidad que lo pida: la factura legal va por Verifactu/TicketBAI, que no usa blockchain.
- **Robótica, fabricación aditiva y realidad aumentada:** no encajan en un restaurante de este tamaño.

## 2. Computación en la nube (AWS)

**Qué es.** Usar servidores, almacenamiento y red de un proveedor por Internet, pagando por uso, en lugar de comprarlos. Sus características son el **autoservicio** (se crea un servidor en minutos desde la consola o con código), la **elasticidad** (se amplía o se apaga cuando se quiere), el **pago por uso** y la **alta disponibilidad** (el proveedor guarda varias copias en sus centros de datos). Según lo que gestiona el proveedor se habla de IaaS (máquinas: EC2), PaaS (plataformas) y SaaS (aplicaciones ya hechas).

**Cómo se usa en el reto:**

| Servicio | Tipo | Para qué | Evidencia |
|---|---|---|---|
| **S3** (almacenamiento de objetos) | IaaS/almacenamiento | Guarda la web (bucket privado `almi-chain-web-2026`) y la **tercera copia** de seguridad cifrada (`almi-chain-backup-2026`) | [tarea 30](../web/30-hosting-aws.md), [restauración desde S3: 23 OK en 166 s](../backup/45-restauracion/evidencias/restauracion-s3-2026-11-04.log) |
| **EC2** (`t3.micro`, Ubuntu 24.04) | IaaS | nginx que sirve la web por HTTPS con Let's Encrypt | [tarea 30](../web/30-hosting-aws.md) |
| **IP elástica** + DuckDNS | Red | Dominio `almichain1.duckdns.org` fijo aunque la instancia cambie | [tarea 30](../web/30-hosting-aws.md) |

**Qué aporta al restaurante:** la web está en Internet sin tener un servidor en el local ni abrir puertos del router; y la copia de seguridad sale del local cada noche, de modo que un incendio o un robo no se llevan los datos (regla 3-2-1 de la [tarea 44](../backup/44-backup-3-2-1/DOCUMENTACION.md)).

**Alternativas comparadas:**

| Opción | Ventajas | Inconvenientes | Valoración |
|---|---|---|---|
| **AWS (S3 + EC2)** ✅ | Es la plataforma de clase (AWS Academy, sin coste para el equipo); HTTPS y dominio propios; se automatiza con Terraform; el mismo proveedor sirve para la web y las copias | Más complejo que un hosting; el Learner Lab apaga la instancia al acabar la sesión y obliga a un rol con permisos amplios | **Elegida** |
| Hosting compartido (web en un panel tipo cPanel) | Barato y sencillo | No sirve para las copias; sin control del servidor ni IaC; no enseña nada del módulo | Descartada |
| Servidor web en el local (en la ServidorERP) | Sin cuota mensual | Abrir puertos del router a Internet; si cae la luz o la fibra, cae la web; el servidor del ERP queda expuesto | Descartada por seguridad |
| Otras nubes (Azure, Google Cloud) | Equivalentes en servicios | Sin cuentas de alumno en el centro; habría que aprender otra consola | Descartadas |
| Copia remota en un NAS en casa del gerente | Sin cuota | Depende de la conexión y del equipo de casa; hay que mantenerlo | Descartada: S3 es más fiable y cuesta céntimos |

**Coste:** la `t3.micro` cuesta unos 0,01 $/h encendida y la IP elástica unos 3,6 $/mes; el bucket, céntimos ([tarea 30, sección 8](../web/30-hosting-aws.md#8-limitaciones-y-coste)). Para el restaurante, una cuenta de AWS normal (no el Learner Lab) con un rol de mínimos privilegios.

## 3. Infraestructura como código y automatización

**Qué es.** Describir la infraestructura (servidores, redes, permisos) en ficheros de texto que una herramienta aplica, en lugar de hacerlo a mano en un panel. El fichero se guarda en Git: se puede revisar, repetir y deshacer. La automatización (CI/CD) aplica los cambios sola cuando se sube algo al repositorio.

**Cómo se usa en el reto:**

- **Terraform** crea el bucket, la instancia con disco cifrado e IMDSv2, el grupo de seguridad y la IP elástica; `terraform plan` sin cambios demuestra que lo desplegado es lo que dice el código ([evidencias](../../iac/evidencias/)).
- **GitHub Actions** publica la web en S3 al cambiar `web/` ([`desplegar-web.yml`](../../.github/workflows/desplegar-web.yml)) y pasa gitleaks a cada cambio.
- **Preseed y scripts** instalan el servidor, el RAID, las copias y la recuperación completa: el servidor se recuperó desde cero en una máquina nueva en **14 min** ([tarea 45, sección 6](../backup/45-restauracion/DOCUMENTACION.md)).

**Qué aporta:** abrir un segundo local o recuperar uno caído deja de depender de que alguien se acuerde de cómo se hizo.

**Alternativas:** hacerlo a mano en la consola (rápido una vez, imposible de repetir igual), CloudFormation (solo AWS, más largo de escribir) o Ansible (mejor para configurar equipos que para crear recursos en la nube). Se eligió **Terraform** porque es el más usado, sirve para varios proveedores y el plan enseña qué va a cambiar antes de aplicarlo.

## 4. ERP con TPV (Odoo Community)

**Qué es.** Un ERP (*Enterprise Resource Planning*) es un programa que reúne en **una sola base de datos** las áreas de la empresa: ventas, facturación, compras, inventario, clientes (CRM), personal y marketing. Cada venta actualiza a la vez el stock, la contabilidad y la ficha del cliente, sin pasar datos de un programa a otro. El **TPV** (terminal punto de venta) es la parte con la que se cobra en el local.

**Cómo se usa en el reto:**

| Qué | Dónde |
|---|---|
| Odoo 19 + PostgreSQL 17 en Docker, con HTTPS por un proxy nginx | [tareas 33](../erp/33-odoo-docker/DOCUMENTACION.md) y [52](../erp/52-https-odoo/DOCUMENTACION.md) |
| Módulos instalados y configurados por API (XML-RPC): facturación, ventas, TPV de restaurante, CRM, empleados, inventario y marketing por correo; cajeros con permisos mínimos | [tarea 34](../erp/34-configurar-odoo/DOCUMENTACION.md) |
| Caso de uso automatizado de extremo a extremo: una venta del TPV acaba en factura | [tarea 35](../erp/35-factura-automatica/DOCUMENTACION.md) |
| Copias diarias de la base de Odoo y restauración comprobada | tareas 44 y 45 |

**Qué aporta:** el camarero cobra en una pantalla táctil, la factura sale sola y el gerente ve ventas y stock sin hojas de cálculo. Con más locales, todos trabajan sobre la misma base.

**Alternativas comparadas** (matriz de la [tarea 32, sección 5](../erp/32-comparativa-erp.md#5-matriz-de-puntuación), sobre 5):

| ERP | Puntuación | Por qué no gana / por qué gana |
|---|---|---|
| **Odoo Community** ✅ | **4,55** | TPV táctil integrado pensado para hostelería, localización española oficial, Docker + PostgreSQL, mucha documentación en español y gratuito (LGPL-3) |
| ERPNext | 3,65 | Completo y libre, pero su TPV está menos orientado a hostelería, la localización española hay que hacerla a mano y es más pesado de instalar |
| Dolibarr | 3,45 | Ligero, pero interfaz más básica, API menos completa y módulos de terceros para lo que falta |
| ERP en la nube de pago (SaaS) | — | Sin servidor propio, pero cuota mensual por usuario y los datos fuera del restaurante; no se puede automatizar ni copiar igual |
| TPV suelto + programa de facturación | — | Más barato al principio, pero los datos quedan en dos sitios: es justo lo que un ERP evita |

**Límites:** Community no trae los informes contables completos de Enterprise (los saca la gestoría con los datos exportados) y Verifactu/TicketBAI no está configurado (riesgos E-01 y E-02 de la tarea 32).

## 5. Sistemas embebidos e IoT (Arduino)

**Qué es.** Un **sistema embebido** es un pequeño ordenador (microcontrolador) dentro de un aparato, programado para una sola tarea. Cuando además se conecta a una red para enviar o recibir datos se habla de **IoT** (*Internet de las cosas*). Sus características: bajo coste, bajo consumo, arranque instantáneo y un programa (firmware) que se puede cambiar.

**Cómo se usa en el reto:** el arcade stick de la recreativa lleva un **Arduino Leonardo** (ATmega32U4). El firmware lo presenta al PC como un **mando USB estándar (HID)**, sin drivers; lee la palanca y 4 botones con antirrebote por software, y el mapeo de botones se cambia por el puerto serie y se guarda en la EEPROM, sin reprogramar. Se probó en la placa el 27/10, en MAME y en Batocera ([README del stick](../../arduino/mando-joystick/README.md)).

**Qué aporta:** un mando a medida del mueble de la recreativa, que se adapta a cualquier juego sin tocar el código y se repara cambiando una placa barata.

**Alternativas comparadas:**

| Opción | Ventajas | Inconvenientes | Valoración |
|---|---|---|---|
| **Arduino Leonardo (ATmega32U4)** ✅ | USB nativo: el PC lo ve como mando sin drivers; EEPROM para guardar el mapeo; firmware propio y documentado; mucha documentación | Hay que programarlo y cablearlo | **Elegida** |
| Arduino Uno (ATmega328P) | Muy común | Su chip no hace USB: no puede ser un mando HID sin cambiar el firmware del conversor USB | Descartada |
| Encoder USB comercial de arcade («zero delay») | Se conecta y funciona | Mapeo fijo, sin antirrebote configurable ni EEPROM; no se puede ampliar (luces, contador de partidas) | Descartada: no permite personalizar |
| Raspberry Pi Pico (RP2040) | Más potente y barata | Menos material de clase; las librerías de mando son menos maduras | Posible alternativa |

**Siguiente paso IoT:** el mismo microcontrolador, con una placa con Wi-Fi (por ejemplo ESP32), podría enviar al gerente cuántas partidas se juegan al día. No se ha hecho porque el enunciado no lo pide.

## 6. Virtualización y contenedores

**Qué es.** La **virtualización** ejecuta varios sistemas completos en un mismo equipo (máquinas virtuales). Los **contenedores** (Docker) empaquetan una aplicación con lo que necesita y comparten el núcleo del sistema: arrancan en segundos y se actualizan cambiando la imagen.

**Cómo se usa:** todos los equipos del restaurante (servidor, PC del gerente con arranque dual, TPV, recreativa de 1 núcleo y 1 GB) se probaron primero en VirtualBox; Odoo y PostgreSQL van en contenedores con Docker Compose, con versión fija.

**Alternativas:** instalar Odoo directamente en el sistema (más difícil de actualizar y de copiar) o Kubernetes (pensado para muchos servidores; exagerado para uno). Se eligió **Docker Compose**: un fichero describe Odoo, la base de datos y el proxy, y la recuperación lo reutiliza tal cual.

## 7. Ciberseguridad

**Qué es.** El conjunto de medidas que protegen la confidencialidad, la integridad y la disponibilidad de los datos. Es una THD porque sin ella el resto (nube, ERP, Wi-Fi) no se puede usar con datos reales.

**Cómo se usa:**

| Medida | Dónde |
|---|---|
| Cifrado en tránsito: HTTPS en la web (Let's Encrypt) y en Odoo (proxy nginx) | Tareas 30 y 52 |
| Cifrado en reposo: copias con restic (AES-256), BitLocker y fscrypt en el PC del gerente, disco de la EC2 cifrado | Tareas 44, 12 y 31 |
| Segmentación: Wi-Fi de invitados aislada; cortafuegos en cada equipo | Tareas 24, 26, 13 y 33 |
| Mínimos privilegios: cajeros con menús limitados, roles de PostgreSQL, usuarios estándar | Tareas 34, 42 y 55 |
| Gestión de secretos: KeePassXC; gitleaks en cada cambio del repositorio | Tarea 46 |

**Alternativas:** se priorizó lo que no cuesta dinero y se puede probar (software libre: restic, nginx, Let's Encrypt, KeePassXC) frente a soluciones de pago (antivirus corporativos, gestores de contraseñas en la nube). La revisión completa, con los riesgos aceptados, está en la [tarea 46](../seguridad/46-revision-seguridad/DOCUMENTACION.md).

## 8. Inteligencia artificial

**Qué es.** Programas que generan texto, código o respuestas a partir de lo que se les pide (modelos de lenguaje). Las versiones **agénticas** además ejecutan acciones: leen ficheros, lanzan comandos y prueban lo que han hecho.

**Cómo se usa:** el enunciado permite la IA. El equipo usó Claude y Claude Code para redactar documentos, escribir scripts y revisar el repositorio. Cada uso relevante está en el [registro de IA](../gestion/registro-ia.md), con **qué se comprobó a mano**: la IA propone y una persona prueba (por ejemplo, el firmware del stick se generó con IA y se comprobó en la placa).

**Alternativas:** no usar IA (más horas para el mismo resultado con 6 personas y 3 semanas) o usarla sin registro (no se podría defender qué ha hecho cada uno). Se eligió usarla **con registro y revisión**. Límite: la IA se equivoca con seguridad; por eso todo lo que entra al repositorio pasa por pruebas y Pull Request.

## 9. Resumen: necesidad → tecnología → por qué esa

| Necesidad del restaurante | THD | Elegida | Frente a | Motivo principal |
|---|---|---|---|---|
| Web visible y segura | Nube | AWS S3 + EC2 | Hosting compartido, servidor en el local | HTTPS, IaC y sin abrir el router |
| Copia fuera del local | Nube | S3 con restic | NAS en casa, solo USB | Diaria, cifrada y sin depender de nadie |
| Repetir el montaje | IaC | Terraform, preseed, scripts | A mano | Servidor recuperado en 14 min |
| Cobrar y facturar | ERP-TPV | Odoo Community | ERPNext, Dolibarr, SaaS | 4,55/5: TPV de hostelería y localización española |
| Mando de la recreativa | Embebidos | Arduino Leonardo | Encoder USB, Uno | HID sin drivers y mapeo sin reprogramar |
| Instalar y probar sin hardware | Virtualización | VirtualBox y Docker | Instalación directa | Pruebas antes de comprar; recuperación con el mismo fichero |
| Proteger datos de clientes | Ciberseguridad | HTTPS, AES-256, aislamiento | Soluciones de pago | Gratis y comprobado con pruebas |
| Equipo pequeño, poco tiempo | IA | Claude con registro | Sin IA | Más trabajo hecho, revisado por personas |
