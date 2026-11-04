# Tarea 39: Modelo lógico normalizado (3FN)

- **Bloque:** 8 BD
- **Depende de:** tarea 38 (modelo E/R, Adrian)
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Resultado de aprendizaje:** Gestión de BD, RA.2: «Diseña modelos lógicos normalizados interpretando diagramas entidad/relación»
- **Estado:** hecha. 04/11: ampliada con la tarea 56 (sección 9)

## 1. Resumen

Se parte del modelo E/R de la tarea 38 (12 entidades) y se pasa al modelo relacional, normalizado hasta la tercera forma normal (3FN). Al analizar las dependencias funcionales se han encontrado **cuatro problemas** en el E/R que impiden la 3FN. El equipo ha aceptado las correcciones y se corrigen aquí y en el E/R de la tarea 38.

Resultado: **13 tablas**, todas en 3FN (y en forma normal de Boyce-Codd, BCNF, según el análisis de la sección 4). La tarea 56 (04/11) añade **4 tablas** más (relación ternaria, historial y atributo multivaluado), también en 3FN y BCNF: **17 en total** (sección 9).

### Cambios respecto al E/R de la tarea 38

| Id | Cambio | Motivo |
|---|---|---|
| C-01 | Se eliminan `base_imponible`, `iva` y `total` de FACTURA. Se calculan con una vista a partir de las líneas. | `total = base_imponible + iva` es una dependencia entre atributos no clave (viola la 3FN), y los tres se pueden calcular desde LINEA_FACTURA (redundancia). |
| C-02 | Se añade `tipo_iva` a LINEA_FACTURA y a PLATO. | Sin el tipo de IVA por línea no se puede calcular el IVA si hay productos con tipos distintos (en restauración suelen coexistir). |
| C-03 | Nueva tabla MODELO_EQUIPO con `marca`, `modelo` y `tipo`. EQUIPO apunta a ella. | En EQUIPO, `modelo` determina `marca` y `tipo`: dependencia transitiva (`id_equipo` → `modelo` → `marca`, `tipo`) que viola la 3FN. |
| C-04 | `UNIQUE (serie, numero)` en FACTURA y valores permitidos (CHECK) en los campos de texto con lista cerrada (`puesto`, `categoria`, `tipo`, `forma_pago`). | Integridad. No es un problema de 3FN, pero evita duplicados y errores de escritura. |

Estos cambios se han aplicado también al modelo E/R de la tarea 38, que queda coherente con este documento.

## 2. Reglas de paso del E/R al modelo relacional

1. Cada entidad fuerte se convierte en una tabla con su clave primaria.
2. Las entidades débiles (LINEA_FACTURA) y las relaciones N:M (STOCK, RECETA, ENVIO_CAMPANA) se convierten en tablas con **clave primaria compuesta**, formada por las claves de las entidades que relacionan. STOCK, RECETA y ENVIO_CAMPANA llevan además atributos propios.
3. Cada relación 1:N se resuelve poniendo la clave del lado 1 como clave foránea en el lado N.
4. La relación reflexiva «impresora conectada a TPV» se resuelve con una clave foránea de EQUIPO hacia EQUIPO.
5. Las relaciones opcionales (0..1) dan claves foráneas que admiten NULL (`id_cliente` en FACTURA, `id_equipo_tpv` en EQUIPO).
6. Se aplican los cambios C-01 a C-04.

## 3. Esquema relacional

Notación: **negrita** = clave primaria; *cursiva* = clave foránea; `UK` = clave alternativa (única).

```
ESTABLECIMIENTO (id_establecimiento, nombre, direccion, ciudad, telefono, latitud, longitud)
    UK: (direccion, ciudad)

EMPLEADO (id_empleado, dni, nombre, apellidos, puesto, email, telefono, fecha_alta, id_establecimiento)
    UK: dni
    FK: id_establecimiento → ESTABLECIMIENTO

CLIENTE (id_cliente, nif, nombre, email, telefono, acepta_publicidad)
    UK: nif

MODELO_EQUIPO (id_modelo, tipo, marca, modelo)
    UK: (marca, modelo)

EQUIPO (id_equipo, id_modelo, id_establecimiento, sistema_operativo, ip, ubicacion, precio, id_equipo_tpv)
    FK: id_modelo → MODELO_EQUIPO
    FK: id_establecimiento → ESTABLECIMIENTO
    FK: id_equipo_tpv → EQUIPO (opcional, solo impresoras)
    UK: (id_establecimiento, ip)

PLATO (id_plato, nombre, descripcion, categoria, precio, tipo_iva, es_estrella, url_imagen)
    UK: nombre

ARTICULO (id_articulo, nombre, unidad_medida)
    UK: nombre

STOCK (id_establecimiento, id_articulo, cantidad, stock_minimo)
    PK compuesta: (id_establecimiento, id_articulo)
    FK: id_establecimiento → ESTABLECIMIENTO
    FK: id_articulo → ARTICULO

RECETA (id_plato, id_articulo, cantidad)
    PK compuesta: (id_plato, id_articulo)
    FK: id_plato → PLATO
    FK: id_articulo → ARTICULO

FACTURA (id_factura, serie, numero, fecha_hora, forma_pago, id_cliente, id_empleado, id_equipo)
    UK: (serie, numero)
    FK: id_cliente → CLIENTE (opcional)
    FK: id_empleado → EMPLEADO
    FK: id_equipo → EQUIPO (TPV que la emite)

LINEA_FACTURA (id_factura, num_linea, id_plato, cantidad, precio_unitario, tipo_iva)
    PK compuesta: (id_factura, num_linea)
    FK: id_factura → FACTURA
    FK: id_plato → PLATO

CAMPANA_MARKETING (id_campana, nombre, canal, fecha_inicio, fecha_fin)

ENVIO_CAMPANA (id_campana, id_cliente, fecha_envio)
    PK compuesta: (id_campana, id_cliente)
    FK: id_campana → CAMPANA_MARKETING
    FK: id_cliente → CLIENTE
```

### Diagrama

```mermaid
erDiagram
    ESTABLECIMIENTO ||--o{ EMPLEADO : "trabaja en"
    ESTABLECIMIENTO ||--o{ EQUIPO : "tiene"
    ESTABLECIMIENTO ||--o{ STOCK : "almacena"
    ARTICULO ||--o{ STOCK : "está en"
    MODELO_EQUIPO ||--o{ EQUIPO : "es de modelo"
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
    PLATO ||--o{ PLATO_ALERGENO : "contiene alérgeno"
    PLATO ||--|{ HISTORIAL_PRECIO_PLATO : "tuvo precio"
    PROVEEDOR ||--o{ SUMINISTRO : "suministra"
    ARTICULO ||--o{ SUMINISTRO : "es suministrado"
    ESTABLECIMIENTO ||--o{ SUMINISTRO : "recibe"

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
        string puesto
        string email
        string telefono
        date fecha_alta
        int id_establecimiento FK
    }
    CLIENTE {
        int id_cliente PK
        string nif UK
        string nombre
        string email
        string telefono
        boolean acepta_publicidad
    }
    MODELO_EQUIPO {
        int id_modelo PK
        string tipo
        string marca
        string modelo
    }
    EQUIPO {
        int id_equipo PK
        int id_modelo FK
        int id_establecimiento FK
        string sistema_operativo
        string ip
        string ubicacion
        decimal precio
        int id_equipo_tpv FK
    }
    PLATO {
        int id_plato PK
        string nombre UK
        string descripcion
        string categoria
        decimal precio
        decimal tipo_iva
        boolean es_estrella
        string url_imagen
    }
    ARTICULO {
        int id_articulo PK
        string nombre UK
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
    FACTURA {
        int id_factura PK
        string serie
        int numero
        datetime fecha_hora
        string forma_pago
        int id_cliente FK
        int id_empleado FK
        int id_equipo FK
    }
    LINEA_FACTURA {
        int id_factura PK, FK
        int num_linea PK
        int id_plato FK
        int cantidad
        decimal precio_unitario
        decimal tipo_iva
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
    PROVEEDOR {
        int id_proveedor PK
        string cif UK
        string nombre
        string telefono
        string email
    }
    SUMINISTRO {
        int id_proveedor PK, FK
        int id_articulo PK, FK
        int id_establecimiento PK, FK
        decimal precio_compra
    }
    PLATO_ALERGENO {
        int id_plato PK, FK
        string alergeno PK
    }
    HISTORIAL_PRECIO_PLATO {
        int id_plato PK, FK
        datetime fecha_desde PK
        datetime fecha_hasta
        decimal precio
        decimal tipo_iva
    }
```

## 4. Normalización paso a paso

### 4.1 Primera forma normal (1FN)

Una tabla está en 1FN si todos sus atributos son atómicos (un solo valor por celda) y no hay grupos repetidos.

- No hay atributos multivaluados: un teléfono y un correo por fila, un solo valor en `ip`. El único multivaluado del E/R, `alergeno` (tarea 56), va en su propia tabla PLATO_ALERGENO (sección 9).
- Las facturas con varios platos no repiten columnas (`plato1`, `plato2`…): se separan en LINEA_FACTURA, una fila por plato.
- Los platos con varios ingredientes se resuelven en RECETA, y los clientes con varias campañas en ENVIO_CAMPANA.
- `direccion` se trata como un valor único (calle y número): no se necesita consultar sus partes por separado.

**Todas las tablas cumplen 1FN.**

### 4.2 Segunda forma normal (2FN)

Una tabla está en 2FN si está en 1FN y ningún atributo no clave depende solo de una parte de una clave compuesta. Solo importa en las tablas con clave compuesta:

| Tabla | Clave | Dependencia | ¿2FN? |
|---|---|---|---|
| STOCK | (`id_establecimiento`, `id_articulo`) | `cantidad` y `stock_minimo` dependen de la pareja: es el stock de un artículo **en un local** | Sí |
| RECETA | (`id_plato`, `id_articulo`) | `cantidad` depende de la pareja: cuánto lleva **ese plato de ese artículo** | Sí |
| LINEA_FACTURA | (`id_factura`, `num_linea`) | `id_plato`, `cantidad`, `precio_unitario` y `tipo_iva` dependen de la línea concreta, no solo de la factura | Sí |
| ENVIO_CAMPANA | (`id_campana`, `id_cliente`) | `fecha_envio` depende de la pareja: cuándo se envió **esa campaña a ese cliente** | Sí |

Las demás tablas tienen clave simple, así que cumplen 2FN directamente.

### 4.3 Tercera forma normal (3FN)

Una tabla está en 3FN si está en 2FN y ningún atributo no clave depende de otro atributo no clave (no hay dependencias transitivas).

**Problemas del E/R original y su corrección:**

| Tabla en el E/R | Dependencia que viola la 3FN | Corrección |
|---|---|---|
| FACTURA | `total` = `base_imponible` + `iva`. Además, los tres se calculan desde las líneas. | C-01: se eliminan y se calculan en una vista (ver 6.2). |
| EQUIPO | `id_equipo` → `modelo` → `marca`, `tipo`. | C-03: la tabla MODELO_EQUIPO guarda `marca` y `tipo` una sola vez por modelo. |

**Casos que parecen dependencias pero no lo son:**

- **`precio_unitario` y `tipo_iva` en LINEA_FACTURA** parecen depender de `id_plato` (que tiene `precio` y `tipo_iva`). No es una dependencia funcional: el precio y el IVA de un plato cambian con el tiempo, y la factura debe conservar el valor vigente **en el momento de la venta**. Es una copia deliberada de un dato histórico.
- **`latitud` y `longitud` en ESTABLECIMIENTO** se podrían deducir de la dirección, pero (`direccion`, `ciudad`) es una clave alternativa de la tabla. Un determinante que es clave no viola la 3FN.
- **`sistema_operativo`, `ip`, `ubicacion` y `precio` en EQUIPO** son propios de cada equipo concreto (el sistema instalado, la IP asignada, el precio pagado), no del modelo. No dependen de `id_modelo`.

### 4.4 Comprobación por tabla

| Tabla | Dependencias funcionales | 3FN | BCNF |
|---|---|---|---|
| ESTABLECIMIENTO | `id_establecimiento` → todo; (`direccion`, `ciudad`) → todo | Sí | Sí |
| EMPLEADO | `id_empleado` → todo; `dni` → todo | Sí | Sí |
| CLIENTE | `id_cliente` → todo; `nif` → todo | Sí | Sí |
| MODELO_EQUIPO | `id_modelo` → todo; (`marca`, `modelo`) → `tipo` | Sí | Sí |
| EQUIPO | `id_equipo` → todo; (`id_establecimiento`, `ip`) → todo | Sí | Sí |
| PLATO | `id_plato` → todo; `nombre` → todo | Sí | Sí |
| ARTICULO | `id_articulo` → todo; `nombre` → todo | Sí | Sí |
| STOCK | (`id_establecimiento`, `id_articulo`) → `cantidad`, `stock_minimo` | Sí | Sí |
| RECETA | (`id_plato`, `id_articulo`) → `cantidad` | Sí | Sí |
| FACTURA | `id_factura` → todo; (`serie`, `numero`) → todo | Sí | Sí |
| LINEA_FACTURA | (`id_factura`, `num_linea`) → todo | Sí | Sí |
| CAMPANA_MARKETING | `id_campana` → todo | Sí | Sí |
| ENVIO_CAMPANA | (`id_campana`, `id_cliente`) → `fecha_envio` | Sí | Sí |

En todas, cada determinante es una clave (primaria o alternativa).

## 5. Diccionario de datos

Los tipos están pensados para PostgreSQL; se adaptan fácilmente a otros gestores. Las claves primarias simples se generan automáticamente (`GENERATED ALWAYS AS IDENTITY`).

**ESTABLECIMIENTO**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_establecimiento | INTEGER | No | PK |
| nombre | VARCHAR(100) | No | |
| direccion | VARCHAR(200) | No | UK con `ciudad` |
| ciudad | VARCHAR(100) | No | |
| telefono | VARCHAR(20) | Sí | |
| latitud | NUMERIC(9,6) | Sí | CHECK entre -90 y 90 |
| longitud | NUMERIC(9,6) | Sí | CHECK entre -180 y 180 |

**EMPLEADO**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_empleado | INTEGER | No | PK |
| dni | VARCHAR(9) | No | UK |
| nombre | VARCHAR(100) | No | |
| apellidos | VARCHAR(150) | No | |
| puesto | VARCHAR(20) | No | CHECK en (`gerente`, `camarero`, `cocina`, `barra`, `otro`) |
| email | VARCHAR(254) | Sí | |
| telefono | VARCHAR(20) | Sí | |
| fecha_alta | DATE | No | por defecto, la fecha actual |
| id_establecimiento | INTEGER | No | FK → ESTABLECIMIENTO |

**CLIENTE**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_cliente | INTEGER | No | PK |
| nif | VARCHAR(9) | Sí | UK (varios NULL permitidos) |
| nombre | VARCHAR(150) | No | |
| email | VARCHAR(254) | Sí | |
| telefono | VARCHAR(20) | Sí | |
| acepta_publicidad | BOOLEAN | No | por defecto `false`; CHECK: si es `true`, `email` no puede ser NULL |

**MODELO_EQUIPO**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_modelo | INTEGER | No | PK |
| tipo | VARCHAR(20) | No | CHECK en (`despacho`, `tpv`, `recreativa`, `impresora_tickets`) |
| marca | VARCHAR(50) | No | UK con `modelo` |
| modelo | VARCHAR(100) | No | |

**EQUIPO**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_equipo | INTEGER | No | PK |
| id_modelo | INTEGER | No | FK → MODELO_EQUIPO |
| id_establecimiento | INTEGER | No | FK → ESTABLECIMIENTO |
| sistema_operativo | VARCHAR(50) | Sí | |
| ip | VARCHAR(45) | Sí | UK con `id_establecimiento` |
| ubicacion | VARCHAR(100) | Sí | |
| precio | NUMERIC(10,2) | Sí | CHECK ≥ 0 |
| id_equipo_tpv | INTEGER | Sí | FK → EQUIPO; solo para impresoras (ver regla R-03) |

**PLATO**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_plato | INTEGER | No | PK |
| nombre | VARCHAR(100) | No | UK |
| descripcion | VARCHAR(500) | Sí | |
| categoria | VARCHAR(20) | No | CHECK en (`entrante`, `principal`, `postre`, `bebida`) |
| precio | NUMERIC(8,2) | No | CHECK ≥ 0 |
| tipo_iva | NUMERIC(4,2) | No | CHECK en (4, 10, 21) |
| es_estrella | BOOLEAN | No | por defecto `false` |
| url_imagen | VARCHAR(255) | Sí | |

**ARTICULO**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_articulo | INTEGER | No | PK |
| nombre | VARCHAR(100) | No | UK |
| unidad_medida | VARCHAR(10) | No | CHECK en (`kg`, `g`, `l`, `ml`, `ud`) |

**STOCK**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_establecimiento | INTEGER | No | PK (1/2), FK → ESTABLECIMIENTO |
| id_articulo | INTEGER | No | PK (2/2), FK → ARTICULO |
| cantidad | NUMERIC(10,3) | No | CHECK ≥ 0 |
| stock_minimo | NUMERIC(10,3) | No | por defecto 0; CHECK ≥ 0 |

**RECETA**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_plato | INTEGER | No | PK (1/2), FK → PLATO |
| id_articulo | INTEGER | No | PK (2/2), FK → ARTICULO |
| cantidad | NUMERIC(10,3) | No | CHECK > 0 |

**FACTURA**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_factura | INTEGER | No | PK |
| serie | VARCHAR(10) | No | UK con `numero` |
| numero | INTEGER | No | CHECK > 0 |
| fecha_hora | TIMESTAMP | No | por defecto, el momento actual |
| forma_pago | VARCHAR(20) | No | CHECK en (`efectivo`, `tarjeta`, `otro`) |
| id_cliente | INTEGER | Sí | FK → CLIENTE (NULL = ticket simplificado) |
| id_empleado | INTEGER | No | FK → EMPLEADO |
| id_equipo | INTEGER | No | FK → EQUIPO (el TPV que la emite) |

**LINEA_FACTURA**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_factura | INTEGER | No | PK (1/2), FK → FACTURA |
| num_linea | INTEGER | No | PK (2/2), CHECK > 0 |
| id_plato | INTEGER | No | FK → PLATO |
| cantidad | INTEGER | No | CHECK > 0 |
| precio_unitario | NUMERIC(8,2) | No | CHECK ≥ 0 (precio en el momento de la venta) |
| tipo_iva | NUMERIC(4,2) | No | CHECK en (4, 10, 21) (tipo en el momento de la venta) |

**CAMPANA_MARKETING**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_campana | INTEGER | No | PK |
| nombre | VARCHAR(100) | No | |
| canal | VARCHAR(20) | No | CHECK en (`email`, `sms`, `redes`) |
| fecha_inicio | DATE | No | |
| fecha_fin | DATE | Sí | CHECK ≥ `fecha_inicio` |

**ENVIO_CAMPANA**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_campana | INTEGER | No | PK (1/2), FK → CAMPANA_MARKETING |
| id_cliente | INTEGER | No | PK (2/2), FK → CLIENTE |
| fecha_envio | TIMESTAMP | No | por defecto, el momento actual |

## 6. Integridad

### 6.1 Acciones de las claves foráneas

| Clave foránea | Al borrar el padre | Razón |
|---|---|---|
| EMPLEADO → ESTABLECIMIENTO | RESTRICT | No se borra un local con personal. |
| EQUIPO → ESTABLECIMIENTO, MODELO_EQUIPO | RESTRICT | No se borra un local o un modelo que tienen equipos. |
| EQUIPO → EQUIPO (`id_equipo_tpv`) | SET NULL | Si se retira un TPV, la impresora queda sin asignar. |
| FACTURA → CLIENTE, EMPLEADO, EQUIPO | RESTRICT | Las facturas se conservan por obligación legal. Para borrar a un cliente (derecho de supresión del RGPD), se anonimizan sus datos en lugar de borrar la fila. |
| LINEA_FACTURA → FACTURA | CASCADE | Entidad débil: sin factura, la línea no existe. |
| LINEA_FACTURA → PLATO | RESTRICT | No se borra un plato que se ha vendido (se puede dejar de ofrecer). |
| STOCK → ESTABLECIMIENTO, ARTICULO | RESTRICT | Se conserva el histórico de inventario. |
| RECETA → PLATO | CASCADE | Si se elimina el plato, su receta no tiene sentido. |
| RECETA → ARTICULO | RESTRICT | No se borra un artículo usado en recetas. |
| ENVIO_CAMPANA → CAMPANA_MARKETING, CLIENTE | CASCADE | Los envíos son registros dependientes. |
| PLATO_ALERGENO, HISTORIAL_PRECIO_PLATO → PLATO | CASCADE | Son el multivaluado y la débil del plato. Un plato vendido no se puede borrar (LINEA_FACTURA lo impide), así que el historial de lo vendido se conserva. |
| SUMINISTRO → PROVEEDOR | CASCADE | Si se deja de trabajar con un proveedor, sus tarifas sobran. |
| SUMINISTRO → ARTICULO, ESTABLECIMIENTO | RESTRICT | No se borra un artículo o un local con tarifas de compra. |

### 6.2 Vista de totales de factura (sustituye a los atributos eliminados)

La vista `v_factura_totales` calcula por factura:

- `base_imponible` = suma de `cantidad` × `precio_unitario` de sus líneas.
- `iva` = suma de `cantidad` × `precio_unitario` × `tipo_iva` / 100.
- `total` = `base_imponible` + `iva`.

Si el equipo prefiere guardar esos importes en la factura por rendimiento o por requisito fiscal, es una **desnormalización deliberada**, y debería documentarse como tal con una restricción que obligue a que coincidan con la vista.

### 6.3 Reglas que una clave foránea no puede expresar

Estas reglas se aplican con disparadores (triggers) o con permisos. Están implementadas y probadas en la tarea 40 (scripts DDL): R-01, R-02, R-03, R-05, R-06 y R-07 en `02-reglas.sql`, y R-04 en `03-roles.sql`.

| Id | Regla |
|---|---|
| R-01 | El empleado que atiende una factura y el equipo (TPV) que la emite pertenecen al mismo establecimiento. |
| R-02 | El equipo de una factura es de tipo `tpv`. |
| R-03 | `id_equipo_tpv` solo se rellena si el modelo es `impresora_tickets`, y apunta a un `tpv` del mismo establecimiento. |
| R-04 | Las facturas emitidas no se modifican ni se borran: el rol de la aplicación no tiene permisos de UPDATE ni DELETE sobre FACTURA y LINEA_FACTURA (mínimos privilegios). |
| R-05 | La numeración de cada serie es correlativa y sin huecos. |
| R-06 | Una venta descuenta del STOCK los artículos de la RECETA del plato, en el establecimiento del TPV. |
| R-07 | (Tarea 56.) Cada alta o cambio de precio o IVA de un plato cierra su tramo abierto de HISTORIAL_PRECIO_PLATO y abre otro. Solo lo escribe la base de datos: la aplicación lee el historial pero no puede modificarlo. |

## 7. Preguntas abiertas para Adrian y Peio

Los scripts de la tarea 40 se escribieron con el supuesto indicado en cada punto. Si la respuesta es otra, hay que cambiar el modelo, el E/R y los scripts.

1. ¿Los tipos de IVA 4, 10 y 21 % son los que queréis admitir? (El equipo de Odoo debe usar los mismos.) **Supuesto adoptado: sí.**
2. ¿Se necesita registrar la baja de empleados y la retirada de platos? Se resolvería con un campo `activo` o `fecha_baja`, que ahora no existe en el E/R. **Supuesto adoptado: no.**
3. Las listas de valores permitidos (`puesto`, `categoria`, `canal`, `forma_pago`) están como CHECK. Si cambian a menudo, se pueden pasar a tablas de catálogo. **Supuesto adoptado: se mantienen como CHECK.**

## 8. Siguiente paso

Hecho en la tarea 40: scripts SQL con tablas, claves, restricciones, índices, vista, reglas R-01 a R-06 y roles, probados en PostgreSQL 16. La única restricción añadida al pasar a SQL es que un equipo no puede apuntar a sí mismo en `id_equipo_tpv` (`CHECK id_equipo_tpv <> id_equipo`); no cambia el esquema.

## 9. Ampliación de la tarea 56

La tarea 56 añade al E/R una relación ternaria, un historial y atributos especiales ([tarea 38, sección 6](38-modelo-er.md#6-ampliación-de-la-tarea-56-relación-ternaria-historial-y-atributos-especiales)). Aquí, su paso a tablas y su normalización.

### 9.1 Reglas de paso

7. **Relación ternaria** (*suministra*): una tabla cuya clave primaria son las claves de las **tres** entidades, más los atributos de la relación (`precio_compra`). Con cardinalidades (0,n) en los tres lados no se puede quitar ninguna de las tres de la clave.
8. **Atributo multivaluado** (`alergeno`): no cabe en una celda (1FN), así que va a una tabla aparte con la clave del plato y el valor; la clave es la pareja.
9. **Historial** (entidad débil): tabla con la clave del plato más la clave parcial `fecha_desde`.
10. **Atributo derivado** (`total`): no se guarda; se calcula en la vista `v_factura_totales` (sección 6.2).

### 9.2 Esquema relacional

```
PROVEEDOR (id_proveedor, cif, nombre, telefono, email)
    UK: cif

SUMINISTRO (id_proveedor, id_articulo, id_establecimiento, precio_compra)
    PK compuesta: (id_proveedor, id_articulo, id_establecimiento)
    FK: id_proveedor → PROVEEDOR
    FK: id_articulo → ARTICULO
    FK: id_establecimiento → ESTABLECIMIENTO

PLATO_ALERGENO (id_plato, alergeno)
    PK compuesta: (id_plato, alergeno)
    FK: id_plato → PLATO

HISTORIAL_PRECIO_PLATO (id_plato, fecha_desde, fecha_hasta, precio, tipo_iva)
    PK compuesta: (id_plato, fecha_desde)
    FK: id_plato → PLATO
    Única parcial: id_plato donde fecha_hasta es nulo (un solo tramo abierto por plato)
```

### 9.3 Normalización

| Tabla | 1FN | 2FN | 3FN y BCNF |
|---|---|---|---|
| PROVEEDOR | Valores atómicos | Clave simple | `id_proveedor` → todo y `cif` → todo: los dos determinantes son claves |
| SUMINISTRO | Sí | `precio_compra` depende de la **terna completa**: ni de proveedor y artículo (cobra distinto en cada local), ni de artículo y local (hay varios proveedores), ni de proveedor y local (cada artículo tiene su precio) | Solo hay un atributo no clave: no puede haber dependencias transitivas |
| PLATO_ALERGENO | Es justo lo que arregla la 1FN: un alérgeno por fila en vez de una lista en PLATO | Sin atributos no clave | Sí |
| HISTORIAL_PRECIO_PLATO | Sí | `precio`, `tipo_iva` y `fecha_hasta` dependen del plato **y** de la fecha de inicio, no solo del plato | `fecha_hasta` no se calcula de otro atributo no clave (es el inicio del tramo siguiente, que está en otra fila); el único determinante es la clave |

**¿Por qué no partir SUMINISTRO en tres tablas binarias?** Con (proveedor, artículo), (proveedor, local) y (artículo, local), si Mayorista vende café y cerveza, sirve a Abando y a Deusto, Abando compra café y cerveza y Deusto compra cerveza (a otro proveedor), al juntarlas saldría que Mayorista sirve cerveza a Deusto, que no es verdad: la descomposición no es sin pérdida. Y `precio_compra` no tendría tabla donde ir.

**¿Duplica el historial el precio de PLATO?** `PLATO.precio` es el precio actual, y el tramo abierto del historial tiene el mismo valor. Es una redundancia controlada: la mantiene un disparador (R-07), y nadie más puede escribir en el historial. Se deja en PLATO para no cambiar el TPV ni las consultas, que leen `PLATO.precio`.

### 9.4 Diccionario de datos

**PROVEEDOR**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_proveedor | INTEGER | No | PK, identidad |
| cif | VARCHAR(9) | No | UK |
| nombre | VARCHAR(150) | No | |
| telefono | VARCHAR(20) | Sí | |
| email | VARCHAR(254) | Sí | |

**SUMINISTRO**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_proveedor | INTEGER | No | PK (1/3), FK → PROVEEDOR |
| id_articulo | INTEGER | No | PK (2/3), FK → ARTICULO |
| id_establecimiento | INTEGER | No | PK (3/3), FK → ESTABLECIMIENTO |
| precio_compra | NUMERIC(10,2) | No | CHECK > 0 (por unidad de medida del artículo) |

**PLATO_ALERGENO**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_plato | INTEGER | No | PK (1/2), FK → PLATO |
| alergeno | VARCHAR(20) | No | PK (2/2), CHECK en los 14 del Reglamento UE 1169/2011: `gluten`, `crustaceos`, `huevos`, `pescado`, `cacahuetes`, `soja`, `lacteos`, `frutos_cascara`, `apio`, `mostaza`, `sesamo`, `sulfitos`, `altramuces`, `moluscos` |

**HISTORIAL_PRECIO_PLATO**

| Columna | Tipo | Nulo | Restricciones |
|---|---|---|---|
| id_plato | INTEGER | No | PK (1/2), FK → PLATO |
| fecha_desde | TIMESTAMP | No | PK (2/2) |
| fecha_hasta | TIMESTAMP | Sí | CHECK > `fecha_desde`; nulo = precio actual (uno solo por plato) |
| precio | NUMERIC(8,2) | No | CHECK ≥ 0 |
| tipo_iva | NUMERIC(4,2) | No | CHECK en (4, 10, 21) |

### 9.5 Integridad y seguridad

- **Integridad:** claves primarias compuestas (no se repite una terna, un alérgeno en el mismo plato ni un tramo), claves ajenas con sus acciones (sección 6.1), CHECK en precios, fechas y la lista de alérgenos, y un índice único parcial que impide dos precios «actuales» a la vez.
- **Seguridad:** el historial solo lo escribe el disparador R-07 (`SECURITY DEFINER`). El rol de la aplicación puede cambiar el precio de un plato, pero no puede insertar, cambiar ni borrar tramos: nadie puede maquillar el historial desde el TPV. Proveedores, tarifas y alérgenos los mantiene la aplicación (INSERT, UPDATE o DELETE según la tabla); el rol de lectura solo consulta.
