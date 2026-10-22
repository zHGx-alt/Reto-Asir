-- =============================================================================
-- Almi-Chain · Tarea 40 · Script 04: borrado completo (solo para pruebas)
-- Deshace 01, 02 y 03 en orden inverso. ¡Elimina TODOS los datos!
-- =============================================================================

BEGIN;

DROP VIEW IF EXISTS v_factura_totales;

DROP TABLE IF EXISTS envio_campana, campana_marketing, linea_factura, factura,
                     receta, stock, articulo, plato, equipo, modelo_equipo,
                     cliente, empleado, establecimiento CASCADE;

DROP FUNCTION IF EXISTS fn_equipo_impresora_tpv();
DROP FUNCTION IF EXISTS fn_factura_coherencia();
DROP FUNCTION IF EXISTS fn_factura_numeracion();
DROP FUNCTION IF EXISTS fn_linea_descuenta_stock();

-- Los roles son globales del servidor: se eliminan solo si no los usa otra base.
-- DROP ROLE IF EXISTS rol_aplicacion;
-- DROP ROLE IF EXISTS rol_lectura;

COMMIT;
