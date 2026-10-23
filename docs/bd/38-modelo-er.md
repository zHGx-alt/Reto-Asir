# Modelo E/R — Base de datos de establecimiento (Almi-Chain)

Tarea #38 del backlog (bloque 8 BD). Fuente: `Reto_1_ASIR1_2026-2027.docx`.

> **Versión revisada.** Se han aplicado los cambios C-01 a C-04 acordados al normalizar el modelo en la tarea #39 (3FN). Están resumidos en la sección 5.

## 1. Qué dice el enunciado sobre la BD

El documento **no trae un enunciado de BD propio** (no hay lista de datos, atributos ni reglas de negocio).
Lo que hay sobre la base de datos es esto:

| Ubicación en el documento | Texto |
|---|---|
| «El reto», párrafo 5 | «Por último, quieren diseñar las bases de datos que habrá en cada establecimiento. Esta BD se almacenará en un dispositivo redundante…» |
| «Tareas a realizar», punto 14 | «Diseño del modelo E/R y tablas de la base de datos.» |
| «Tareas a realizar», punto 15 | «Implementación de la base de datos y consulta de sus datos.» |
| Resultados de aprendizaje, Gestión de BD, RA.2 | «Diseña modelos lógicos normalizados interpretando diagramas entidad/relación.» |

Por tanto, el **dominio** de la BD se deduce del resto del enunciado: qué es la empresa, qué gestiona y qué hay en cada local.
Abajo se indica para cada elemento si sale **literal** del texto (📄) o es una **decisión de diseño** del equipo (🛠).

Referencias usadas:

- **R1** = «El reto», párrafo 1 («Una cadena de restaurantes nos ha contratado…»)
- **R2** = «El reto», párrafo 2 («El gerente necesita, para su despacho…»)
- **R3** = «El reto», párrafo 3 («Quieren utilizar otro equipo como máquina recreativa…»)
- **R5** = «El reto», párrafo 5 («La empresa, que se quiere dar a conocer…»)
- **T*n*** = «Tareas a realizar», punto *n*

### 1.1 Una base central para toda la cadena

El enunciado habla de «las bases de datos que habrá en cada establecimiento». Hay dos formas de leerlo, y el modelo tiene que ser coherente con una de ellas:

| | Una base por local | **Una base central (elegida)** |
|---|---|---|
| ESTABLECIMIENTO | Tendría una sola fila (el propio local): sobra | Una fila por local |
| Clientes, platos, campañas | Se repiten en cada local y se desincronizan | Comunes a la cadena: se dan de alta una vez |
| STOCK, empleados, equipos, facturas | De ese local | De cada local, separados por `id_establecimiento` |
| Informes de la cadena (ventas por local, platos más vendidos) | Hay que juntar varias bases | Una consulta (tarea 41, C-03 y C-04) |

**Decisión:** el modelo es el de una **base central** de la cadena, que guarda los datos de **cada establecimiento** separados por la clave `id_establecimiento` (por eso existen ESTABLECIMIENTO y STOCK por local). Así se cumple la frase del enunciado («los datos de cada establecimiento») sin repetir la carta ni los clientes. Mientras la cadena sea el local piloto, la base está en el servidor de ese local, en el mismo PostgreSQL que Odoo y sobre el RAID (tareas 40 y 43). Si se abren más locales, se movería a un servidor central o a la nube, con acceso por VPN desde cada local.

Si el profesor entiende el enunciado como «una base distinta en cada local», el cambio es pequeño: quitar ESTABLECIMIENTO y las claves `id_establecimiento`, y cargar en cada local solo sus datos.

## 2. Diagrama

```mermaid
erDiagram
    ESTABLECIMIENTO ||--o{ EMPLEADO : "trabaja en"
    ESTABLECIMIENTO ||--o{ EQUIPO : "tiene"
    MODELO_EQUIPO ||--o{ EQUIPO : "es de modelo"
    ESTABLECIMIENTO ||--o{ STOCK : "almacena"
    ARTICULO ||--o{ STOCK : "está en"
    EQUIPO |o--o{ EQUIPO : "impresora conectada a TPV"
    EQUIPO ||--o{ FACTURA : "emite (TPV)"
    EMPLEADO ||--o{ FACTURA : "atiende"
    CLIENTE |o--o{ FACTURA : "recibe"
    FACTURA ||--|{ LINEA_FACTURA : "contiene"
    PLATO ||--o{ LINEA_FACTURA : "se vende en"
    PLATO ||--o{ RECETA : "lleva"
    ARTICULO ||--o{ RECETA : "se usa en"
    CLIENTE ||--o{ ENVIO_CAMPANA : "recibe"
    CAMPANA_MARKETING ||--o{ ENVIO_CAMPANA : "se envía"

    ESTABLECIMIENTO {
        int id_establecimiento PK
        string nombre
        string direccion
        string ciudad
        string telefono
        decimal latitud
        decimal longitud
    }
    EMPLEADO {
        int id_empleado PK
        string dni UK
        string nombre
        string apellidos
        string puesto "gerente, camarero, cocina..."
        string email
        string telefono
        date fecha_alta
        int id_establecimiento FK
    }
    CLIENTE {
        int id_cliente PK
        string nif UK "opcional"
        string nombre
        string email
        string telefono
        boolean acepta_publicidad
    }
    FACTURA {
        int id_factura PK
        string serie "UK con numero"
        int numero "UK con serie"
        datetime fecha_hora
        string forma_pago "efectivo, tarjeta, otro"
        int id_cliente FK "nulo = ticket simplificado"
        int id_empleado FK
        int id_equipo FK "TPV que la emite"
    }
    LINEA_FACTURA {
        int id_factura PK, FK
        int num_linea PK
        int id_plato FK
        int cantidad
        decimal precio_unitario "vigente en la venta"
        decimal tipo_iva "vigente en la venta"
    }
    PLATO {
        int id_plato PK
        string nombre
        string descripcion
        string categoria
        decimal precio
        decimal tipo_iva "4, 10 o 21"
        boolean es_estrella
        string url_imagen
    }
    ARTICULO {
        int id_articulo PK
        string nombre
        string unidad_medida
    }
    STOCK {
        int id_establecimiento PK, FK
        int id_articulo PK, FK
        decimal cantidad
        decimal stock_minimo
    }
    RECETA {
        int id_plato PK, FK
        int id_articulo PK, FK
        decimal cantidad
    }
    CAMPANA_MARKETING {
        int id_campana PK
        string nombre
        string canal
        date fecha_inicio
        date fecha_fin
    }
    ENVIO_CAMPANA {
        int id_campana PK, FK
        int id_cliente PK, FK
        datetime fecha_envio
    }
    MODELO_EQUIPO {
        int id_modelo PK
        string tipo "despacho, TPV, recreativa, impresora_tickets"
        string marca
        string modelo
    }
    EQUIPO {
        int id_equipo PK
        int id_modelo FK
        string sistema_operativo
        string ip
        string ubicacion
        decimal precio
        int id_establecimiento FK
        int id_equipo_tpv FK "solo impresoras"
    }
```

> El diagrama está en notación «pata de gallo» (Mermaid, se ve en GitHub). En la asignatura suele pedirse la notación **Chen**: hay que confirmarlo con el profesor (duda de la tarea 6) y, si la pide, pasarlo a draw.io
> con las mismas entidades y cardinalidades. `STOCK`, `RECETA`, `ENVIO_CAMPANA` y `LINEA_FACTURA` son relaciones N:M o entidades débiles,
> no entidades fuertes.
> Los importes de la factura (base imponible, IVA y total) no se guardan en FACTURA: se calculan a partir de sus líneas. `(marca, modelo)` es única en MODELO_EQUIPO.

## 3. Trazabilidad: de dónde sale cada cosa

### Entidades

| Entidad | Origen | Texto exacto / justificación |
|---|---|---|
| ESTABLECIMIENTO | 📄 R1, R5 | «Una cadena de restaurantes…» (R1); «las bases de datos que habrá en cada establecimiento» (R5) |
| EMPLEADO | 📄 R5, R2 | ERP para gestionar «el personal» (R5); «El gerente» (R2) → el gerente es un valor de `puesto`, no una entidad aparte |
| CLIENTE | 📄 R5 | ERP para gestionar «la relación con los clientes» (R5) |
| FACTURA | 📄 R5, T12 | ERP para gestionar «las facturas» (R5); «automatizando al menos un caso de uso real (p. ej. emisión de una factura)» (T12). Los importes (base, IVA, total) se calculan desde las líneas, no se almacenan (3FN) |
| LINEA_FACTURA | 🛠 | Una factura tiene varios platos con cantidad y precio → entidad débil de FACTURA (necesaria para normalizar, RA.2 de BD) |
| PLATO | 📄 R5 | «un slideshow para mostrar sus platos estrella» (R5). Es un restaurante: lo que se factura son platos |
| ARTICULO | 📄 R5 | ERP para gestionar el «inventariado» (R5) → artículos/ingredientes del almacén |
| STOCK | 🛠 sobre R5 | El inventario es por local («cada establecimiento», R5) → N:M ESTABLECIMIENTO–ARTICULO con cantidad |
| RECETA | 🛠 | No aparece en el texto. Une inventario y ventas (qué artículos consume cada plato). Se puede quitar si se quiere un modelo mínimo |
| CAMPANA_MARKETING | 📄 R5 | ERP para gestionar «marketing» (R5) |
| ENVIO_CAMPANA | 🛠 | N:M CLIENTE–CAMPAÑA: a qué clientes se envía cada campaña |
| EQUIPO | 📄 R2, R3, T1, T13 | «un equipo con arranque dual» para el despacho, «dos equipos de barra (que funcionarán como TPV…) e impresoras de tickets» (R2); «otro equipo como máquina recreativa» (R3); T1 «configuración y presupuesto de equipos e impresoras» |
| MODELO_EQUIPO | 🛠 sobre R2, R3, T2 | T2 pide «identificar y documentar el hardware necesario»: marca, modelo y tipo se guardan una sola vez por modelo y no se repiten en cada equipo (3FN) |

### Relaciones y cardinalidades

| Relación | Card. | Origen | Justificación |
|---|---|---|---|
| EMPLEADO *trabaja en* ESTABLECIMIENTO | N:1 | 🛠 sobre R1/R5 | Cada empleado pertenece a un local de la cadena |
| EQUIPO *está en* ESTABLECIMIENTO | N:1 | 📄 R2 | Los equipos de R2 son del local (despacho, barra) |
| MODELO_EQUIPO *describe a* EQUIPO | 1:N | 🛠 sobre R2/R3 | Un modelo (marca, modelo, tipo) se repite en varios equipos y se guarda una sola vez |
| Impresora *conectada a* TPV | 0..N:0..1 (reflexiva) | 📄 R2 | «dos equipos de barra (TPV) e impresoras de tickets» |
| TPV *emite* FACTURA | 1:N | 📄 R2 + T12 | Los TPV de barra cobran; T12 pide «ERP + TPV» con emisión de factura |
| EMPLEADO *atiende* FACTURA | 1:N | 🛠 | Saber quién cobra (trazabilidad/seguridad, T18) |
| CLIENTE *recibe* FACTURA | 0..1:N | 🛠 | Un ticket de barra puede no tener cliente identificado → FK opcional |
| FACTURA *contiene* LINEA_FACTURA | 1:1..N | 🛠 | Toda factura tiene al menos una línea |
| PLATO *se vende en* LINEA_FACTURA | 1:N | 🛠 | Cada línea es un plato |
| PLATO–ARTICULO (RECETA) | N:M | 🛠 | Ver arriba |
| ESTABLECIMIENTO–ARTICULO (STOCK) | N:M | 🛠 sobre R5 | Ver arriba |
| CLIENTE–CAMPAÑA (ENVIO) | N:M | 🛠 sobre R5 | Ver arriba |

### Atributos destacables

| Atributo | Origen |
|---|---|
| `ESTABLECIMIENTO.latitud/longitud` | 📄 R5: la web debe tener «geolocalización» → se guardan las coordenadas del local |
| `PLATO.es_estrella`, `PLATO.url_imagen` | 📄 R5: «slideshow para mostrar sus platos estrella» |
| `EMPLEADO.puesto` | 📄 R2: «El gerente» (más el personal genérico de R5) |
| `MODELO_EQUIPO.tipo` | 📄 R2/R3: despacho, TPV, impresora de tickets, recreativa |
| `PLATO.tipo_iva` | 🛠 sobre R5 (facturas): en restauración conviven tipos de IVA distintos (4, 10 o 21 %) |
| `LINEA_FACTURA.precio_unitario`, `LINEA_FACTURA.tipo_iva` | 🛠 sobre R5: copia del precio y del IVA vigentes en la venta; la factura no cambia si el plato sube de precio después |
| `EQUIPO.sistema_operativo`, `ip`, `precio` | 📄 R2: «detalles tanto del hardware como del software», «presupuesto»; T6 necesidades de comunicación |
| `CLIENTE.acepta_publicidad` | 🛠 sobre R5 (marketing) + RGPD: no se envían campañas sin consentimiento |
| Resto (nombre, dni, fechas, importes…) | 🛠 el documento no define ningún atributo; son los mínimos para identificar y operar cada entidad |

## 4. Qué se ha dejado fuera a propósito

No aparecen en el documento y no se modelan: **proveedores, mesas, reservas, pedidos de cocina, nóminas/turnos**.
Si el equipo los quiere, encajan sin romper el modelo (p. ej. PROVEEDOR 1:N ARTICULO, MESA 1:N FACTURA).
La red (WAN, WDS, R4), la web en AWS y el arcade stick no son datos de negocio, así que no entran en la BD.

## 5. Cambios de esta versión (tarea #39)

| Id | Cambio | Motivo |
|---|---|---|
| C-01 | Se eliminan `base_imponible`, `iva` y `total` de FACTURA. | `total = base_imponible + iva` y los tres se calculan desde las líneas: dependencia que viola la 3FN y redundancia. |
| C-02 | Se añade `tipo_iva` a LINEA_FACTURA y a PLATO. | Hace falta para calcular el IVA con tipos distintos. |
| C-03 | Nueva entidad MODELO_EQUIPO (`tipo`, `marca`, `modelo`); EQUIPO pasa a tener `id_modelo`. | En EQUIPO, `modelo` determinaba `marca` y `tipo`: dependencia transitiva. |
| C-04 | `(serie, numero)` única en FACTURA y valores permitidos en `puesto`, `categoria`, `tipo` y `forma_pago`. | Integridad. |

El detalle de la normalización (1FN, 2FN, 3FN), el diccionario de datos y las restricciones están en el documento de la tarea #39.
