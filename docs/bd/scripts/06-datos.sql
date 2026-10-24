-- =============================================================================
-- Almi-Chain · Tarea 41 · Script 06: datos de prueba
-- Carga un ejemplo coherente de la cadena: 2 locales, su personal, sus equipos
-- (los de las tareas 8 y 10), la carta, el almacén, clientes, una campaña y ventas.
-- Las ventas se hacen con INSERT normales: los disparadores de 02-reglas.sql numeran
-- las facturas (R-05), comprueban TPV y empleado (R-01, R-02) y descuentan el stock (R-06).
--
-- Requiere 01, 02 y 03 sobre una base VACÍA:
--   psql -d almi_chain -v ON_ERROR_STOP=1 -f 06-datos.sql
-- Si la base ya tiene datos, el script se para sin tocar nada.
-- Todos los datos son inventados (personas, NIF, teléfonos y correos de ejemplo).
-- =============================================================================

BEGIN;

DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM establecimiento) THEN
        RAISE EXCEPTION 'La base ya tiene datos: 06-datos.sql solo se carga en una base vacía';
    END IF;
END $$;

-- ---- Locales ----------------------------------------------------------------
-- Base central de la cadena (ver tarea 38, apartado «Una base central»).
INSERT INTO establecimiento (nombre, direccion, ciudad, telefono, latitud, longitud) VALUES
  ('Almi-Chain Abando', 'Calle Ejemplo 1',  'Bilbao', '944000001', 43.263000, -2.935000),
  ('Almi-Chain Deusto', 'Calle Ejemplo 25', 'Bilbao', '944000002', 43.271000, -2.946000);

-- ---- Personal ----------------------------------------------------------------
INSERT INTO empleado (dni, nombre, apellidos, puesto, email, fecha_alta, id_establecimiento)
SELECT v.dni, v.nombre, v.apellidos, v.puesto, v.email, v.alta::date, e.id_establecimiento
FROM (VALUES
  ('00000001R', 'Nerea',  'Etxeberria Ruiz', 'gerente',  'gerente.abando@ejemplo.test', '2026-01-07', 'Almi-Chain Abando'),
  ('00000002W', 'Jon',    'Agirre Sanz',     'barra',    NULL,                          '2026-02-02', 'Almi-Chain Abando'),
  ('00000003A', 'Ane',    'Lopez Uribe',     'camarero', NULL,                          '2026-03-16', 'Almi-Chain Abando'),
  ('00000004G', 'Mikel',  'Garcia Ortiz',    'cocina',   NULL,                          '2026-01-07', 'Almi-Chain Abando'),
  ('00000005M', 'Leire',  'Zubizarreta Gil', 'gerente',  'gerente.deusto@ejemplo.test', '2026-04-01', 'Almi-Chain Deusto'),
  ('00000006Y', 'Unai',   'Martin Bilbao',   'barra',    NULL,                          '2026-04-01', 'Almi-Chain Deusto')
) AS v(dni, nombre, apellidos, puesto, email, alta, local)
JOIN establecimiento e ON e.nombre = v.local;

-- ---- Equipos (modelos de las tareas 8 y 10) --------------------------------
INSERT INTO modelo_equipo (tipo, marca, modelo) VALUES
  ('despacho',          'Lenovo', 'ThinkCentre Neo 50q Gen 4'),
  ('tpv',               'Iggual', 'AIO B156.88.N100'),
  ('impresora_tickets', 'Epson',  'TM-T20IV'),
  ('recreativa',        'Genérico', 'PC de 1 núcleo y 1 GB');

-- IP: las del plan de direccionamiento (tarea 23). Impresoras por USB y recreativa
-- en la Wi-Fi de invitados: sin IP fija.
INSERT INTO equipo (id_modelo, id_establecimiento, sistema_operativo, ip, ubicacion, precio)
SELECT m.id_modelo, e.id_establecimiento, v.so, v.ip, v.ubicacion, v.precio
FROM (VALUES
  ('ThinkCentre Neo 50q Gen 4', 'Almi-Chain Abando', 'Windows 10 Pro + Ubuntu LTS', '192.168.10.20', 'Despacho', 792.67),
  ('AIO B156.88.N100',          'Almi-Chain Abando', 'Windows 10',                  '192.168.10.31', 'Barra',    538.99),
  ('AIO B156.88.N100',          'Almi-Chain Abando', 'Windows 10',                  '192.168.10.32', 'Barra',    538.99),
  ('PC de 1 núcleo y 1 GB',     'Almi-Chain Abando', 'Debian 13 + MAME 0.276',      NULL,            'Comedor',  NULL),
  ('AIO B156.88.N100',          'Almi-Chain Deusto', 'Windows 10',                  '192.168.10.31', 'Barra',    538.99)
) AS v(modelo, local, so, ip, ubicacion, precio)
JOIN modelo_equipo m ON m.modelo = v.modelo
JOIN establecimiento e ON e.nombre = v.local;

-- Una impresora por TPV, conectada por USB a ese TPV (R-03).
INSERT INTO equipo (id_modelo, id_establecimiento, sistema_operativo, ip, ubicacion, precio, id_equipo_tpv)
SELECT m.id_modelo, t.id_establecimiento, NULL, NULL, 'Barra (USB al TPV ' || t.ip || ')', 199.86, t.id_equipo
FROM equipo t
JOIN modelo_equipo mt ON mt.id_modelo = t.id_modelo AND mt.tipo = 'tpv'
CROSS JOIN modelo_equipo m
WHERE m.modelo = 'TM-T20IV';

-- ---- Carta (precio sin IVA; en hostelería el IVA es del 10 %) ---------------
INSERT INTO plato (nombre, descripcion, categoria, precio, tipo_iva, es_estrella) VALUES
  ('Gilda',                 'Pintxo de guindilla, anchoa y aceituna',      'entrante',   2.27, 10, FALSE),
  ('Croquetas de jamón',    '6 unidades',                                  'entrante',   7.27, 10, TRUE),
  ('Bacalao al pil-pil',    'Lomo de bacalao con su emulsión',             'principal', 19.09, 10, TRUE),
  ('Txuleta a la brasa',    'Para dos personas, 1 kg',                     'principal', 45.45, 10, TRUE),
  ('Marmitako',             'Guiso de bonito y patata',                    'principal', 13.64, 10, FALSE),
  ('Pimientos de Gernika',  'Fritos, con sal en escamas (plato nuevo, sin ventas: C-05)', 'entrante', 6.36, 10, FALSE),
  ('Tarta de queso',        'Al horno, cremosa',                           'postre',     5.91, 10, TRUE),
  ('Pantxineta',            'Hojaldre con crema y almendra',               'postre',     5.45, 10, FALSE),
  ('Caña',                  'Cerveza de barril',                           'bebida',     2.27, 10, FALSE),
  ('Txakoli (copa)',        'Getariako Txakolina',                         'bebida',     3.18, 10, FALSE),
  ('Agua mineral',          '50 cl',                                       'bebida',     1.82, 10, FALSE),
  ('Café',                  'Solo o con leche',                            'bebida',     1.45, 10, FALSE);

-- ---- Almacén ------------------------------------------------------------------
INSERT INTO articulo (nombre, unidad_medida) VALUES
  ('Anchoa', 'ud'), ('Guindilla', 'ud'), ('Aceituna', 'ud'),
  ('Masa de croqueta', 'kg'), ('Bacalao', 'kg'), ('Aceite de oliva', 'l'),
  ('Chuleta de vaca', 'kg'), ('Bonito', 'kg'), ('Patata', 'kg'),
  ('Queso crema', 'kg'), ('Cerveza de barril', 'l'), ('Txakoli', 'l'), ('Café en grano', 'kg');

-- Cantidad por ración de cada plato (R-06 la descuenta al vender).
INSERT INTO receta (id_plato, id_articulo, cantidad)
SELECT p.id_plato, a.id_articulo, v.cantidad
FROM (VALUES
  ('Gilda', 'Anchoa', 1), ('Gilda', 'Guindilla', 2), ('Gilda', 'Aceituna', 1),
  ('Croquetas de jamón', 'Masa de croqueta', 0.180),
  ('Bacalao al pil-pil', 'Bacalao', 0.250), ('Bacalao al pil-pil', 'Aceite de oliva', 0.100),
  ('Txuleta a la brasa', 'Chuleta de vaca', 1.000),
  ('Marmitako', 'Bonito', 0.200), ('Marmitako', 'Patata', 0.250),
  ('Tarta de queso', 'Queso crema', 0.120),
  ('Caña', 'Cerveza de barril', 0.200),
  ('Txakoli (copa)', 'Txakoli', 0.120),
  ('Café', 'Café en grano', 0.008)
) AS v(plato, articulo, cantidad)
JOIN plato p ON p.nombre = v.plato
JOIN articulo a ON a.nombre = v.articulo;

-- Stock inicial de cada local. La txuleta de Abando se deja justa a propósito:
-- tras las ventas queda por debajo del mínimo (consulta C-08 de 07-consultas.sql).
INSERT INTO stock (id_establecimiento, id_articulo, cantidad, stock_minimo)
SELECT e.id_establecimiento, a.id_articulo, v.cantidad, v.minimo
FROM (VALUES
  ('Almi-Chain Abando', 'Anchoa', 120, 30), ('Almi-Chain Abando', 'Guindilla', 200, 50),
  ('Almi-Chain Abando', 'Aceituna', 200, 50), ('Almi-Chain Abando', 'Masa de croqueta', 5, 1),
  ('Almi-Chain Abando', 'Bacalao', 6, 2), ('Almi-Chain Abando', 'Aceite de oliva', 20, 5),
  ('Almi-Chain Abando', 'Chuleta de vaca', 4, 3), ('Almi-Chain Abando', 'Bonito', 5, 1),
  ('Almi-Chain Abando', 'Patata', 25, 5), ('Almi-Chain Abando', 'Queso crema', 4, 1),
  ('Almi-Chain Abando', 'Cerveza de barril', 50, 10), ('Almi-Chain Abando', 'Txakoli', 12, 3),
  ('Almi-Chain Abando', 'Café en grano', 3, 1),
  ('Almi-Chain Deusto', 'Anchoa', 80, 30), ('Almi-Chain Deusto', 'Guindilla', 150, 50),
  ('Almi-Chain Deusto', 'Aceituna', 150, 50), ('Almi-Chain Deusto', 'Masa de croqueta', 3, 1),
  ('Almi-Chain Deusto', 'Cerveza de barril', 30, 10), ('Almi-Chain Deusto', 'Café en grano', 2, 1)
) AS v(local, articulo, cantidad, minimo)
JOIN establecimiento e ON e.nombre = v.local
JOIN articulo a ON a.nombre = v.articulo;

-- ---- Clientes y marketing -----------------------------------------------------
INSERT INTO cliente (nif, nombre, email, telefono, acepta_publicidad) VALUES
  ('B00000001', 'Eventos Ejemplo S.L.',  'reservas@eventos.ejemplo.test', '944000100', TRUE),
  (NULL,        'Maite Ejemplo',         'maite@ejemplo.test',            NULL,        TRUE),
  (NULL,        'Iñaki Ejemplo',         'inaki@ejemplo.test',            NULL,        FALSE),
  ('00000007F', 'Koldo Ejemplo',         NULL,                            '600000001', FALSE);

INSERT INTO campana_marketing (nombre, canal, fecha_inicio, fecha_fin) VALUES
  ('Menú de otoño 2026', 'email', '2026-10-01', '2026-11-30'),
  ('Txakoli nuevo',      'redes', '2026-11-01', NULL);

-- La de otoño solo puede llegar a quien acepta publicidad (y tiene correo, por el CHECK).
INSERT INTO envio_campana (id_campana, id_cliente, fecha_envio)
SELECT c.id_campana, cl.id_cliente, '2026-10-01 10:00'
FROM campana_marketing c
JOIN cliente cl ON cl.acepta_publicidad AND cl.nombre = 'Maite Ejemplo'
WHERE c.nombre = 'Menú de otoño 2026';

-- ---- Ventas -------------------------------------------------------------------
-- pg_temp.venta: una factura con sus líneas, como la haría el TPV.
-- El precio y el IVA de cada línea se copian del plato en el momento de la venta.
CREATE FUNCTION pg_temp.venta(p_serie TEXT, p_local TEXT, p_ip_tpv TEXT, p_dni TEXT,
                              p_cliente TEXT, p_pago TEXT, p_fecha TIMESTAMP,
                              p_platos TEXT[], p_cantidades INTEGER[]) RETURNS void
LANGUAGE plpgsql AS $$
DECLARE
    v_factura INTEGER;
BEGIN
    INSERT INTO factura (serie, fecha_hora, forma_pago, id_cliente, id_empleado, id_equipo)
    VALUES (p_serie, p_fecha, p_pago,
            (SELECT id_cliente FROM cliente WHERE nombre = p_cliente),
            (SELECT id_empleado FROM empleado WHERE dni = p_dni),
            (SELECT q.id_equipo FROM equipo q
               JOIN establecimiento e ON e.id_establecimiento = q.id_establecimiento
              WHERE e.nombre = p_local AND q.ip = p_ip_tpv))
    RETURNING id_factura INTO v_factura;

    INSERT INTO linea_factura (id_factura, num_linea, id_plato, cantidad, precio_unitario, tipo_iva)
    SELECT v_factura, l.n, p.id_plato, p_cantidades[l.n], p.precio, p.tipo_iva
    FROM generate_subscripts(p_platos, 1) AS l(n)
    JOIN plato p ON p.nombre = p_platos[l.n];
END $$;

-- Abando, TPV 1 (serie A1) y TPV 2 (serie A2); Deusto, TPV 1 (serie D1).
DO $$
BEGIN
PERFORM pg_temp.venta('A1', 'Almi-Chain Abando', '192.168.10.31', '00000002W', NULL, 'efectivo', '2026-10-19 13:40',
       ARRAY['Gilda','Caña','Café'], ARRAY[4,4,2]);
PERFORM pg_temp.venta('A1', 'Almi-Chain Abando', '192.168.10.31', '00000002W', NULL, 'tarjeta', '2026-10-19 14:25',
       ARRAY['Croquetas de jamón','Bacalao al pil-pil','Tarta de queso','Agua mineral'], ARRAY[1,2,2,2]);
PERFORM pg_temp.venta('A2', 'Almi-Chain Abando', '192.168.10.32', '00000003A', 'Eventos Ejemplo S.L.', 'tarjeta', '2026-10-19 15:10',
       ARRAY['Txuleta a la brasa','Marmitako','Txakoli (copa)','Pantxineta','Café'], ARRAY[1,2,4,2,4]);
PERFORM pg_temp.venta('A1', 'Almi-Chain Abando', '192.168.10.31', '00000003A', 'Maite Ejemplo', 'efectivo', '2026-10-20 21:05',
       ARRAY['Txuleta a la brasa','Tarta de queso','Txakoli (copa)'], ARRAY[1,1,2]);
PERFORM pg_temp.venta('A2', 'Almi-Chain Abando', '192.168.10.32', '00000002W', NULL, 'tarjeta', '2026-10-20 21:40',
       ARRAY['Gilda','Croquetas de jamón','Caña'], ARRAY[2,1,3]);
PERFORM pg_temp.venta('A1', 'Almi-Chain Abando', '192.168.10.31', '00000002W', 'Koldo Ejemplo', 'tarjeta', '2026-10-21 14:00',
       ARRAY['Bacalao al pil-pil','Txuleta a la brasa','Agua mineral'], ARRAY[1,1,1]);
PERFORM pg_temp.venta('D1', 'Almi-Chain Deusto', '192.168.10.31', '00000006Y', NULL, 'efectivo', '2026-10-20 12:30',
       ARRAY['Gilda','Caña','Café'], ARRAY[6,5,3]);
PERFORM pg_temp.venta('D1', 'Almi-Chain Deusto', '192.168.10.31', '00000006Y', 'Iñaki Ejemplo', 'tarjeta', '2026-10-21 13:15',
       ARRAY['Croquetas de jamón','Caña'], ARRAY[2,2]);
END $$;

COMMIT;

-- Resumen de lo cargado
SELECT 'establecimiento' AS tabla, count(*) AS filas FROM establecimiento
UNION ALL SELECT 'empleado', count(*) FROM empleado
UNION ALL SELECT 'modelo_equipo', count(*) FROM modelo_equipo
UNION ALL SELECT 'equipo', count(*) FROM equipo
UNION ALL SELECT 'plato', count(*) FROM plato
UNION ALL SELECT 'articulo', count(*) FROM articulo
UNION ALL SELECT 'stock', count(*) FROM stock
UNION ALL SELECT 'receta', count(*) FROM receta
UNION ALL SELECT 'cliente', count(*) FROM cliente
UNION ALL SELECT 'campana_marketing', count(*) FROM campana_marketing
UNION ALL SELECT 'envio_campana', count(*) FROM envio_campana
UNION ALL SELECT 'factura', count(*) FROM factura
UNION ALL SELECT 'linea_factura', count(*) FROM linea_factura;
