-- =============================================================================
-- Almi-Chain · Tarea 41 · Script 07: consultas de los datos
-- Preguntas reales del negocio sobre los datos de 06-datos.sql. Solo lee: se puede
-- ejecutar con un usuario de rol_lectura.
--   psql -d almi_chain -f 07-consultas.sql > ../evidencias/41-consultas.txt
-- Cada consulta lleva su código (C-01…) y qué técnica usa.
-- =============================================================================

\echo '== C-01 Carta con el precio al público (IVA incluido) · SELECT con expresión y ORDER BY'
SELECT categoria, nombre, precio AS base,
       round(precio * (1 + tipo_iva / 100), 2) AS pvp,
       CASE WHEN es_estrella THEN 'sí' ELSE '' END AS estrella
FROM plato
ORDER BY CASE categoria WHEN 'entrante' THEN 1 WHEN 'principal' THEN 2
                        WHEN 'postre' THEN 3 ELSE 4 END, nombre;

\echo '== C-02 Facturas con su local, TPV, empleado, cliente y total · JOIN de 5 tablas y vista'
SELECT f.serie || '-' || f.numero AS factura,
       to_char(f.fecha_hora, 'DD/MM HH24:MI') AS fecha,
       e.nombre AS local, q.ip AS tpv,
       emp.nombre AS empleado,
       COALESCE(c.nombre, '(ticket simplificado)') AS cliente,
       f.forma_pago, t.total
FROM factura f
JOIN equipo q            ON q.id_equipo = f.id_equipo
JOIN establecimiento e   ON e.id_establecimiento = q.id_establecimiento
JOIN empleado emp        ON emp.id_empleado = f.id_empleado
LEFT JOIN cliente c      ON c.id_cliente = f.id_cliente
JOIN v_factura_totales t ON t.id_factura = f.id_factura
ORDER BY f.fecha_hora;

\echo '== C-03 Ventas por local y día · GROUP BY con SUM y COUNT'
SELECT e.nombre AS local, f.fecha_hora::date AS dia,
       count(*) AS facturas, sum(t.base_imponible) AS base, sum(t.iva) AS iva, sum(t.total) AS total
FROM factura f
JOIN equipo q            ON q.id_equipo = f.id_equipo
JOIN establecimiento e   ON e.id_establecimiento = q.id_establecimiento
JOIN v_factura_totales t ON t.id_factura = f.id_factura
GROUP BY e.nombre, f.fecha_hora::date
ORDER BY local, dia;

\echo '== C-04 Los 5 platos más vendidos de la cadena · JOIN, GROUP BY, ORDER BY y LIMIT'
SELECT p.nombre, p.categoria, sum(l.cantidad) AS unidades,
       sum(l.cantidad * l.precio_unitario) AS base_vendida
FROM linea_factura l
JOIN plato p ON p.id_plato = l.id_plato
GROUP BY p.id_plato, p.nombre, p.categoria
ORDER BY unidades DESC, base_vendida DESC
LIMIT 5;

\echo '== C-05 Platos que no se han vendido nunca · subconsulta con NOT EXISTS'
SELECT p.nombre, p.categoria
FROM plato p
WHERE NOT EXISTS (SELECT 1 FROM linea_factura l WHERE l.id_plato = p.id_plato)
ORDER BY p.nombre;

\echo '== C-06 Facturas por encima del importe medio · subconsulta escalar'
SELECT t.serie || '-' || t.numero AS factura, t.total,
       (SELECT round(avg(total), 2) FROM v_factura_totales) AS media
FROM v_factura_totales t
WHERE t.total > (SELECT avg(total) FROM v_factura_totales)
ORDER BY t.total DESC;

\echo '== C-07 Ventas por empleado, solo quien ha vendido más de 100 € · GROUP BY con HAVING'
SELECT emp.nombre || ' ' || emp.apellidos AS empleado, emp.puesto,
       count(*) AS facturas, sum(t.total) AS total_vendido
FROM factura f
JOIN empleado emp        ON emp.id_empleado = f.id_empleado
JOIN v_factura_totales t ON t.id_factura = f.id_factura
GROUP BY emp.id_empleado, emp.nombre, emp.apellidos, emp.puesto
HAVING sum(t.total) > 100
ORDER BY total_vendido DESC;

\echo '== C-08 Artículos por debajo del stock mínimo (lista de la compra) · JOIN y comparación entre columnas'
SELECT e.nombre AS local, a.nombre AS articulo, s.cantidad, s.stock_minimo, a.unidad_medida
FROM stock s
JOIN establecimiento e ON e.id_establecimiento = s.id_establecimiento
JOIN articulo a        ON a.id_articulo = s.id_articulo
WHERE s.cantidad < s.stock_minimo
ORDER BY local, articulo;

\echo '== C-09 Consumo de materia prima por las ventas, por local · JOIN de 5 tablas con receta'
SELECT e.nombre AS local, a.nombre AS articulo,
       sum(l.cantidad * r.cantidad) AS consumido, a.unidad_medida
FROM linea_factura l
JOIN factura f         ON f.id_factura = l.id_factura
JOIN equipo q          ON q.id_equipo = f.id_equipo
JOIN establecimiento e ON e.id_establecimiento = q.id_establecimiento
JOIN receta r          ON r.id_plato = l.id_plato
JOIN articulo a        ON a.id_articulo = r.id_articulo
GROUP BY e.nombre, a.nombre, a.unidad_medida
ORDER BY local, consumido DESC;

\echo '== C-10 Clientes que aceptan publicidad y aún no han recibido la campaña de otoño · subconsulta con NOT IN'
SELECT c.nombre, c.email
FROM cliente c
WHERE c.acepta_publicidad
  AND c.id_cliente NOT IN (SELECT ec.id_cliente
                             FROM envio_campana ec
                             JOIN campana_marketing cm ON cm.id_campana = ec.id_campana
                            WHERE cm.nombre = 'Menú de otoño 2026')
ORDER BY c.nombre;

\echo '== C-11 Cada impresora con su TPV · autocombinación (equipo consigo mismo)'
SELECT e.nombre AS local, mi.marca || ' ' || mi.modelo AS impresora,
       t.ip AS tpv, mt.marca || ' ' || mt.modelo AS modelo_tpv
FROM equipo i
JOIN modelo_equipo mi  ON mi.id_modelo = i.id_modelo AND mi.tipo = 'impresora_tickets'
JOIN equipo t          ON t.id_equipo = i.id_equipo_tpv
JOIN modelo_equipo mt  ON mt.id_modelo = t.id_modelo
JOIN establecimiento e ON e.id_establecimiento = i.id_establecimiento
ORDER BY local, tpv;

\echo '== C-12 Inventario de equipos y su coste por local · LEFT JOIN, GROUP BY y COALESCE'
SELECT e.nombre AS local, m.tipo, count(q.id_equipo) AS equipos,
       COALESCE(sum(q.precio), 0) AS coste
FROM establecimiento e
CROSS JOIN (SELECT DISTINCT tipo FROM modelo_equipo) tipos
LEFT JOIN modelo_equipo m ON m.tipo = tipos.tipo
LEFT JOIN equipo q        ON q.id_modelo = m.id_modelo AND q.id_establecimiento = e.id_establecimiento
GROUP BY e.nombre, m.tipo
ORDER BY local, m.tipo;
