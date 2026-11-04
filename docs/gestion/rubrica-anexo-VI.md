# Rúbrica de competencias técnicas (Anexo VI) · Reto 1 Almi-Chain

Transcripción de [rubrica-anexo-VI.pdf](rubrica-anexo-VI.pdf), que el profesor entregó el 04/11/2026. El texto de cada nivel es el del PDF; solo cambia el formato.

**Escala:** 5 Excelente trabajo · 4 Gran trabajo · 3 Buen trabajo · 2 Hay que trabajar más · 1 A trabajar duro.

**Los niveles se suman:** cada nivel empieza por «además de lo anterior», así que para tener un 5 hay que cumplir también lo que piden el 3 y el 4.

| # | Módulo | Criterio (tareas de la rúbrica) |
|---|---|---|
| 1 | Implantación de sistemas operativos | [Instalación de S.O. arranque dual y configurar una impresora](#1-instalación-de-so-arranque-dual-y-configurar-una-impresora) |
| 2 | Implantación de sistemas operativos | [Plan de copias de seguridad y configurar disco redundante](#2-plan-de-copias-de-seguridad-y-configurar-disco-redundante) |
| 3 | Implantación de sistemas operativos | [Optimizar y monitorizar máquina recreativa; restricción de cuentas](#3-optimizar-y-monitorizar-máquina-recreativa-restricción-de-cuentas-de-usuarios-y-equipos) |
| 4 | Planificación y administración de redes | [WAN, esquema de conectividad y ampliación de cobertura Wi-Fi](#4-elección-de-conectividad-wan-diseño-y-esquema-de-conectividad-configuración-de-ampliación-de-cobertura-wi-fi) |
| 5 | Lenguajes de marcas y SGI | [Diseño de la página web](#5-diseño-de-la-página-web) |
| 6 | Lenguajes de marcas y SGI | [Implementación de la página web](#6-implementación-de-la-página-web) |
| 7 | Lenguajes de marcas y SGI | [Implementación de un ERP](#7-implementación-de-un-erp) |
| 8 | Gestión de bases de datos | [Diseña el modelo lógico de la base de datos](#8-diseña-el-modelo-lógico-de-la-base-de-datos) |
| 9 | Gestión de bases de datos | [Paso a tablas e implementación](#9-paso-a-tablas-e-implementación) |
| 10 | Gestión de bases de datos | [Plan de copias de seguridad](#10-plan-de-copias-de-seguridad) |
| 11 | Digitalización aplicada a los sectores productivos | [Análisis y justificación de las THD empleadas](#11-análisis-y-justificación-de-las-thd-empleadas-en-el-reto-cloudaws-erp-tpv) |
| 12 | Digitalización aplicada a los sectores productivos | [Montaje y programación del arcade stick](#12-montaje-y-programación-del-arcade-stick-con-arduino-como-controlador) |

## Implantación de sistemas operativos

### 1. Instalación de S.O. arranque dual y configurar una impresora

**RA:** R1. Instala sistemas operativos, analizando sus características e interpretando la documentación técnica.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, el sistema queda endurecido (mínimos privilegios, servicios reducidos) y la instalación está documentada de forma reproducible. |
| 4 | Además de lo anterior, instala el arranque dual con las configuraciones adecuadas en VirtualBox (RAM, disco, Guest Additions...) y configura una impresora para la impresión de tickets. |
| 3 | Instala el sistema operativo con un arranque dual básico. |
| 2 | Instala el sistema operativo e intenta el arranque dual con algún error. |
| 1 | Instala S.O. sin arranque dual. |

### 2. Plan de copias de seguridad y configurar disco redundante

**RA:** R3. Asegura la información del sistema, describiendo los procedimientos y utilizando copias de seguridad y sistemas tolerantes a fallos.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, las copias están automatizadas y verificadas con una prueba de restauración documentada. |
| 4 | Además de lo anterior, realiza un plan de copias de seguridad en local y remoto documentando el plan. |
| 3 | Realiza copias de seguridad y las realiza en un disco redundante. |
| 2 | Realiza un plan de copias de seguridad. |
| 1 | Realiza el plan de copias de seguridad pero no es adecuado. |

### 3. Optimizar y monitorizar máquina recreativa; restricción de cuentas de usuarios y equipos

**RA:** R2. Configura el software de base, analizando las necesidades de explotación del sistema informático. R6. Detecta problemas de rendimiento, monitorizando el sistema con las herramientas adecuadas y documentando el procedimiento.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, monitoriza el rendimiento con herramientas adecuadas y deja constancia documentada de las pruebas de rendimiento (antes y después de optimizar). |
| 4 | Además de lo anterior, implementa un front-end gráfico para la experiencia del jugador (selección de juego, pantalla completa, etc.). |
| 3 | Además de lo anterior, optimiza el sistema de forma que la máquina pueda correr con 1 núcleo y 1 GB de RAM, eliminando elementos innecesarios, y configura usuarios restringidos para que solo puedan jugar y nada más. |
| 2 | Además de lo anterior, optimiza el sistema sobre el que está instalado MAME. |
| 1 | Instala MAME y emula videojuegos en una máquina virtual. |

## Planificación y administración de redes

### 4. Elección de conectividad WAN; diseño y esquema de conectividad; configuración de ampliación de cobertura Wi-Fi

**RA:** R1. Reconoce la estructura de las redes de datos identificando sus elementos y principios de funcionamiento. R2. Integra ordenadores y periféricos en redes cableadas e inalámbricas, evaluando su funcionamiento y prestaciones. R7. Conecta redes privadas a redes públicas identificando y aplicando diferentes tecnologías.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, la red se documenta con un diagrama de arquitectura claro, se configura de forma segura (WPA2/WPA3, red de clientes separada, credenciales por defecto cambiadas) y se justifica la cobertura (WDS) con pruebas de conectividad. |
| 4 | Además de lo anterior, crea un esquema de red correcto de acuerdo a las necesidades de la empresa. |
| 3 | Además de lo anterior, elige una conectividad WAN de acuerdo a las necesidades de la empresa. |
| 2 | Configura los routers Wi-Fi para ampliar la cobertura de la red (WDS). |
| 1 | Configura un router Wi-Fi. |

## Lenguajes de marcas y sistemas de gestión de información

### 5. Diseño de la página web

**RA:** RA1. Reconoce las características de lenguajes de marcas analizando e interpretando fragmentos de código.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, el diseño cumple accesibilidad (WCAG AA) y se justifica con criterios de usabilidad. |
| 4 | Además de lo anterior, el diseño sigue patrones de diseño moderno, con una UX amigable. |
| 3 | Además de lo anterior, el diseño refleja la responsividad de la página (móvil, tablet y escritorio). |
| 2 | Realiza un diseño de la página web que se ajusta a la página real, con una herramienta adecuada. |
| 1 | Realiza un diseño de la página que no se ajusta a la página real. |

### 6. Implementación de la página web

**RA:** RA2. Utiliza lenguajes de marcas para la transmisión de información a través de la Web analizando la estructura de los documentos e identificando sus elementos.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, la web se sirve por HTTPS con dominio propio y se despliega de forma reproducible (IaC) en la nube, con rendimiento medido. |
| 4 | Además de lo anterior, la página está alojada en AWS. |
| 3 | Además de lo anterior, es responsiva y se adapta a tablets, móviles y dispositivos grandes. |
| 2 | Además de lo anterior, la página es estética y cuenta con los elementos que se piden en el enunciado. |
| 1 | Implementa una página web con HTML y CSS. |

### 7. Implementación de un ERP

**RA:** RA7. Trabaja con sistemas empresariales de gestión de información realizando tareas de importación, integración, aseguramiento y extracción de la información.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, se automatiza un caso de uso real de extremo a extremo en el ERP (p. ej. emitir una factura). |
| 4 | Además de lo anterior, se usan de forma correcta el resto de módulos del ERP. |
| 3 | El ERP cuenta con todos los módulos necesarios. Se hace uso del TPV. |
| 2 | El ERP cuenta con algunos de los módulos necesarios. |
| 1 | Instala un ERP. |

## Gestión de bases de datos

### 8. Diseña el modelo lógico de la base de datos

**RA:** RA1. Reconoce los elementos de las bases de datos analizando sus funciones y valorando la utilidad de sistemas gestores. RA2. Diseña modelos lógicos normalizados interpretando diagramas entidad/relación.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, el modelo está normalizado y justificado, y contempla integridad y seguridad de los datos. |
| 4 | Además de lo anterior, el diagrama tiene historiales y atributos especiales. |
| 3 | El diagrama entidad relación tiene relaciones binarias y ternarias, así como atributos en estas, que se corresponden con las necesidades de diseño. |
| 2 | El diagrama entidad-relación solo contempla las relaciones básicas. |
| 1 | Realiza un diagrama entidad-relación con errores de bulto. |

### 9. Paso a tablas e implementación

**RA:** RA3. Realiza el diseño físico de bases de datos utilizando asistentes, herramientas gráficas y el lenguaje de definición de datos.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, la implementación es reproducible mediante script de creación (DDL) y se verifica con datos de prueba. |
| 4 | Además de lo anterior, aporta una solución a la necesidad de integrar dos bases de datos distintas (la propia y Odoo). |
| 3 | Implementa las tablas respetando el modelo entidad-relación y teniendo en cuenta la integridad relacional. |
| 2 | Implementa las tablas respetando el modelo entidad-relación pero sin tener en cuenta la integridad relacional. |
| 1 | Implementa las tablas en un sistema gestor con errores. |

### 10. Plan de copias de seguridad

**RA:** RA6. Ejecuta tareas de aseguramiento de la información, analizándolas y aplicando mecanismos de salvaguarda y transferencia.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, el plan está automatizado y se verifica con una prueba de restauración. |
| 4 | Además de lo anterior, realiza las copias sobre un dispositivo redundante. |
| 3 | Diseña e implementa un plan de copias de seguridad con una herramienta adecuada. |
| 2 | Realiza una copia de seguridad puntual. |
| 1 | Realiza una copia de seguridad con errores. |

## Digitalización aplicada a los sectores productivos

### 11. Análisis y justificación de las THD empleadas en el reto (cloud/AWS, ERP-TPV)

**RA:** RA2. Caracteriza las THD necesarias para la transformación digital. (THD: tecnologías habilitadoras digitales.)

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, compara alternativas y justifica la elección según las necesidades de la empresa. |
| 4 | Caracteriza correctamente las THD usadas (cloud, ERP) y su aplicación en el reto. |
| 3 | Describe las THD usadas con alguna imprecisión. |
| 2 | Identifica las THD pero no describe sus aplicaciones. |
| 1 | No identifica las tecnologías empleadas. |

### 12. Montaje y programación del arcade stick con Arduino como controlador

**RA:** RA2. Caracteriza las THD necesarias para la transformación digital.

| Nivel | Descripción |
|---|---|
| 5 | Además de lo anterior, el montaje está documentado de forma reproducible (esquema de conexiones, lista de componentes con presupuesto, código comentado y versionado en Git, pruebas de cada control) y se justifica el uso del microcontrolador como tecnología habilitadora (sistemas embebidos/IoT) frente a alternativas comerciales. |
| 4 | Además de lo anterior, el input es personalizable (remapeo de controles sin reprogramar o con el código parametrizado), gestiona el antirrebote de los botones y se comprueba su funcionamiento en más de un emulador o front-end. |
| 3 | Además de lo anterior, programa el Arduino como dispositivo HID (gamepad o teclado), de modo que el sistema operativo lo reconoce sin drivers adicionales y funciona en MAME. |
| 2 | Monta y cablea correctamente el joystick y los botones al Arduino y programa un sketch que lee todas las entradas (comprobable por monitor serie), pero el equipo no lo reconoce como mando. |
| 1 | Monta el arcade stick con Arduino con errores de cableado o un programa que no lee correctamente las entradas. |

## Ayudas del profesor

- **Ayuda sin consecuencia** (explicación de conceptos, guía al alumno, entrega o muestra de recursos): −0 puntos.
- **Ayuda leve** (corrección de errores en el diseño o implementación, errores claros): −1 punto.
- **Ayuda explícita** (el profesor realiza la tarea, se sienta a hacerlo y el alumno solo mira): −2 puntos.
