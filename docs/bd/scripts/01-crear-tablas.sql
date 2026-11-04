-- =============================================================================
-- Almi-Chain · Tarea 40 · Script 01: tablas, índices y vista
-- Gestor: PostgreSQL 16 (válido desde PostgreSQL 12)
-- Origen: modelo lógico 3FN de la tarea 39 (17 tablas + vista v_factura_totales).
-- Tarea 56: PROVEEDOR y SUMINISTRO (relación ternaria), PLATO_ALERGENO (atributo
-- multivaluado) e HISTORIAL_PRECIO_PLATO (historial; lo rellena R-07 en 02-reglas.sql).
--
-- Se ejecuta UNA VEZ en la base central de la cadena (ver tarea 38, apartado 1.1):
--   psql -d almi_chain -v ON_ERROR_STOP=1 -f 01-crear-tablas.sql
--
-- Supuestos adoptados (a confirmar con Adrian y Peio):
--   S-1  Tipos de IVA admitidos: 4, 10 y 21 %.
--   S-2  No se registra baja de empleados ni retirada de platos (sin campo "activo").
--   S-3  Las listas de valores permitidos son CHECK, no tablas de catálogo.
-- =============================================================================

BEGIN;

-- Orden: primero las tablas de las que dependen otras (por las claves foráneas).

CREATE TABLE establecimiento (
    id_establecimiento INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre             VARCHAR(100) NOT NULL,
    direccion          VARCHAR(200) NOT NULL,
    ciudad             VARCHAR(100) NOT NULL,
    telefono           VARCHAR(20),
    latitud            NUMERIC(9,6) CHECK (latitud  BETWEEN -90  AND 90),
    longitud           NUMERIC(9,6) CHECK (longitud BETWEEN -180 AND 180),
    CONSTRAINT uk_establecimiento_direccion UNIQUE (direccion, ciudad)
);

CREATE TABLE empleado (
    id_empleado        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dni                VARCHAR(9)   NOT NULL,
    nombre             VARCHAR(100) NOT NULL,
    apellidos          VARCHAR(150) NOT NULL,
    puesto             VARCHAR(20)  NOT NULL
                       CHECK (puesto IN ('gerente','camarero','cocina','barra','otro')),
    email              VARCHAR(254),
    telefono           VARCHAR(20),
    fecha_alta         DATE         NOT NULL DEFAULT CURRENT_DATE,
    id_establecimiento INTEGER      NOT NULL
                       REFERENCES establecimiento (id_establecimiento) ON DELETE RESTRICT,
    CONSTRAINT uk_empleado_dni UNIQUE (dni)
);

CREATE TABLE cliente (
    id_cliente        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nif               VARCHAR(9),                       -- varios NULL permitidos
    nombre            VARCHAR(150) NOT NULL,
    email             VARCHAR(254),
    telefono          VARCHAR(20),
    acepta_publicidad BOOLEAN      NOT NULL DEFAULT FALSE,
    CONSTRAINT uk_cliente_nif UNIQUE (nif),
    CONSTRAINT ck_cliente_publicidad_email
        CHECK (NOT acepta_publicidad OR email IS NOT NULL)
);

CREATE TABLE modelo_equipo (
    id_modelo INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    tipo      VARCHAR(20)  NOT NULL
              CHECK (tipo IN ('despacho','tpv','recreativa','impresora_tickets')),
    marca     VARCHAR(50)  NOT NULL,
    modelo    VARCHAR(100) NOT NULL,
    CONSTRAINT uk_modelo_equipo UNIQUE (marca, modelo)
);

CREATE TABLE equipo (
    id_equipo          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    id_modelo          INTEGER NOT NULL
                       REFERENCES modelo_equipo (id_modelo) ON DELETE RESTRICT,
    id_establecimiento INTEGER NOT NULL
                       REFERENCES establecimiento (id_establecimiento) ON DELETE RESTRICT,
    sistema_operativo  VARCHAR(50),
    ip                 VARCHAR(45),
    ubicacion          VARCHAR(100),
    precio             NUMERIC(10,2) CHECK (precio >= 0),
    id_equipo_tpv      INTEGER
                       REFERENCES equipo (id_equipo) ON DELETE SET NULL,  -- solo impresoras (R-03)
    CONSTRAINT uk_equipo_ip UNIQUE (id_establecimiento, ip),
    CONSTRAINT ck_equipo_no_se_apunta_a_si_mismo
        CHECK (id_equipo_tpv IS NULL OR id_equipo_tpv <> id_equipo)
);

CREATE TABLE plato (
    id_plato    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL,
    descripcion VARCHAR(500),
    categoria   VARCHAR(20)  NOT NULL
                CHECK (categoria IN ('entrante','principal','postre','bebida')),
    precio      NUMERIC(8,2) NOT NULL CHECK (precio >= 0),
    tipo_iva    NUMERIC(4,2) NOT NULL CHECK (tipo_iva IN (4, 10, 21)),
    es_estrella BOOLEAN      NOT NULL DEFAULT FALSE,
    url_imagen  VARCHAR(255),
    CONSTRAINT uk_plato_nombre UNIQUE (nombre)
);

-- Tarea 56. Atributo multivaluado de PLATO: un plato tiene 0 o más alérgenos.
-- Lista de los 14 alérgenos de declaración obligatoria (Reglamento UE 1169/2011, anexo II).
CREATE TABLE plato_alergeno (
    id_plato INTEGER     NOT NULL
             REFERENCES plato (id_plato) ON DELETE CASCADE,
    alergeno VARCHAR(20) NOT NULL
             CHECK (alergeno IN ('gluten','crustaceos','huevos','pescado','cacahuetes',
                                 'soja','lacteos','frutos_cascara','apio','mostaza',
                                 'sesamo','sulfitos','altramuces','moluscos')),
    PRIMARY KEY (id_plato, alergeno)
);

-- Tarea 56. Historial de precios de PLATO (entidad débil): un tramo por cada precio
-- que ha tenido. El tramo abierto (fecha_hasta NULL) es el precio actual.
-- Lo escribe el disparador R-07 de 02-reglas.sql; la aplicación solo puede leerlo.
CREATE TABLE historial_precio_plato (
    id_plato    INTEGER      NOT NULL
                REFERENCES plato (id_plato) ON DELETE CASCADE,
    fecha_desde TIMESTAMP    NOT NULL,
    fecha_hasta TIMESTAMP,
    precio      NUMERIC(8,2) NOT NULL CHECK (precio >= 0),
    tipo_iva    NUMERIC(4,2) NOT NULL CHECK (tipo_iva IN (4, 10, 21)),
    PRIMARY KEY (id_plato, fecha_desde),
    CONSTRAINT ck_historial_fechas CHECK (fecha_hasta IS NULL OR fecha_hasta > fecha_desde)
);
-- Un solo tramo abierto por plato (índice único parcial).
CREATE UNIQUE INDEX ux_historial_abierto ON historial_precio_plato (id_plato) WHERE fecha_hasta IS NULL;

CREATE TABLE articulo (
    id_articulo   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre        VARCHAR(100) NOT NULL,
    unidad_medida VARCHAR(10)  NOT NULL
                  CHECK (unidad_medida IN ('kg','g','l','ml','ud')),
    CONSTRAINT uk_articulo_nombre UNIQUE (nombre)
);

-- Tarea 56.
CREATE TABLE proveedor (
    id_proveedor INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    cif          VARCHAR(9)   NOT NULL,
    nombre       VARCHAR(150) NOT NULL,
    telefono     VARCHAR(20),
    email        VARCHAR(254),
    CONSTRAINT uk_proveedor_cif UNIQUE (cif)
);

CREATE TABLE stock (
    id_establecimiento INTEGER NOT NULL
                       REFERENCES establecimiento (id_establecimiento) ON DELETE RESTRICT,
    id_articulo        INTEGER NOT NULL
                       REFERENCES articulo (id_articulo) ON DELETE RESTRICT,
    cantidad           NUMERIC(10,3) NOT NULL CHECK (cantidad >= 0),
    stock_minimo       NUMERIC(10,3) NOT NULL DEFAULT 0 CHECK (stock_minimo >= 0),
    PRIMARY KEY (id_establecimiento, id_articulo)
);

-- Tarea 56. Relación ternaria PROVEEDOR–ARTICULO–ESTABLECIMIENTO: qué proveedor sirve
-- qué artículo a qué local, y a qué precio. La clave son las tres claves ajenas: el
-- precio depende de las tres a la vez (el mismo proveedor cobra distinto en cada local,
-- y un local compra el mismo artículo a varios proveedores).
CREATE TABLE suministro (
    id_proveedor       INTEGER NOT NULL
                       REFERENCES proveedor (id_proveedor) ON DELETE CASCADE,
    id_articulo        INTEGER NOT NULL
                       REFERENCES articulo (id_articulo) ON DELETE RESTRICT,
    id_establecimiento INTEGER NOT NULL
                       REFERENCES establecimiento (id_establecimiento) ON DELETE RESTRICT,
    precio_compra      NUMERIC(10,2) NOT NULL CHECK (precio_compra > 0),  -- por unidad_medida del artículo
    PRIMARY KEY (id_proveedor, id_articulo, id_establecimiento)
);

CREATE TABLE receta (
    id_plato    INTEGER NOT NULL
                REFERENCES plato (id_plato) ON DELETE CASCADE,
    id_articulo INTEGER NOT NULL
                REFERENCES articulo (id_articulo) ON DELETE RESTRICT,
    cantidad    NUMERIC(10,3) NOT NULL CHECK (cantidad > 0),
    PRIMARY KEY (id_plato, id_articulo)
);

CREATE TABLE factura (
    id_factura  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    serie       VARCHAR(10) NOT NULL,
    numero      INTEGER     NOT NULL CHECK (numero > 0),   -- lo asigna el disparador (R-05)
    fecha_hora  TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    forma_pago  VARCHAR(20) NOT NULL
                CHECK (forma_pago IN ('efectivo','tarjeta','otro')),
    id_cliente  INTEGER REFERENCES cliente  (id_cliente)  ON DELETE RESTRICT,  -- NULL = ticket simplificado
    id_empleado INTEGER NOT NULL REFERENCES empleado (id_empleado) ON DELETE RESTRICT,
    id_equipo   INTEGER NOT NULL REFERENCES equipo   (id_equipo)   ON DELETE RESTRICT,
    CONSTRAINT uk_factura_serie_numero UNIQUE (serie, numero)
);

CREATE TABLE linea_factura (
    id_factura      INTEGER NOT NULL
                    REFERENCES factura (id_factura) ON DELETE CASCADE,
    num_linea       INTEGER NOT NULL CHECK (num_linea > 0),
    id_plato        INTEGER NOT NULL
                    REFERENCES plato (id_plato) ON DELETE RESTRICT,
    cantidad        INTEGER NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(8,2) NOT NULL CHECK (precio_unitario >= 0),  -- precio en el momento de la venta
    tipo_iva        NUMERIC(4,2) NOT NULL CHECK (tipo_iva IN (4, 10, 21)), -- tipo en el momento de la venta
    PRIMARY KEY (id_factura, num_linea)
);

CREATE TABLE campana_marketing (
    id_campana   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    nombre       VARCHAR(100) NOT NULL,
    canal        VARCHAR(20)  NOT NULL CHECK (canal IN ('email','sms','redes')),
    fecha_inicio DATE         NOT NULL,
    fecha_fin    DATE,
    CONSTRAINT ck_campana_fechas CHECK (fecha_fin IS NULL OR fecha_fin >= fecha_inicio)
);

CREATE TABLE envio_campana (
    id_campana  INTEGER NOT NULL
                REFERENCES campana_marketing (id_campana) ON DELETE CASCADE,
    id_cliente  INTEGER NOT NULL
                REFERENCES cliente (id_cliente) ON DELETE CASCADE,
    fecha_envio TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_campana, id_cliente)
);

-- Índices en claves foráneas que no encabezan ya una clave primaria o única.
-- (PostgreSQL no los crea solos y aceleran uniones y borrados.)
CREATE INDEX ix_empleado_establecimiento ON empleado (id_establecimiento);
CREATE INDEX ix_equipo_modelo            ON equipo (id_modelo);
CREATE INDEX ix_equipo_tpv               ON equipo (id_equipo_tpv);
CREATE INDEX ix_stock_articulo           ON stock (id_articulo);
CREATE INDEX ix_receta_articulo          ON receta (id_articulo);
CREATE INDEX ix_factura_cliente          ON factura (id_cliente);
CREATE INDEX ix_factura_empleado         ON factura (id_empleado);
CREATE INDEX ix_factura_equipo           ON factura (id_equipo);
CREATE INDEX ix_factura_fecha            ON factura (fecha_hora);
CREATE INDEX ix_linea_plato              ON linea_factura (id_plato);
CREATE INDEX ix_envio_cliente            ON envio_campana (id_cliente);
CREATE INDEX ix_suministro_articulo_local ON suministro (id_articulo, id_establecimiento);
CREATE INDEX ix_suministro_local          ON suministro (id_establecimiento);

-- Vista que sustituye a base_imponible, iva y total (cambio C-01 de la tarea 39).
CREATE VIEW v_factura_totales AS
SELECT f.id_factura,
       f.serie,
       f.numero,
       COALESCE(SUM(l.cantidad * l.precio_unitario), 0)::NUMERIC(12,2)                     AS base_imponible,
       COALESCE(SUM(l.cantidad * l.precio_unitario * l.tipo_iva / 100), 0)::NUMERIC(12,2)  AS iva,
       (COALESCE(SUM(l.cantidad * l.precio_unitario), 0)
        + COALESCE(SUM(l.cantidad * l.precio_unitario * l.tipo_iva / 100), 0))::NUMERIC(12,2) AS total
FROM factura f
LEFT JOIN linea_factura l ON l.id_factura = f.id_factura
GROUP BY f.id_factura, f.serie, f.numero;

COMMIT;
