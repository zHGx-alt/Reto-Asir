-- =============================================================================
-- Almi-Chain · Tarea 42 · Script 09: pruebas de mínimos privilegios con las cuentas reales
-- Se ejecuta DOS veces, una con cada cuenta de 08-usuarios.sql:
--   psql -d almi_chain -U tpv_app  -v cuenta=tpv_app  -f 09-pruebas-usuarios.sql
--   psql -d almi_chain -U informes -v cuenta=informes -f 09-pruebas-usuarios.sql
-- Cada prueba dice OK si el resultado es el esperado. Todo termina en ROLLBACK: no deja datos.
-- Necesita los datos de 06-datos.sql.
-- =============================================================================

\set ON_ERROR_STOP 1
\echo '== Pruebas con la cuenta' :cuenta '(conectado como' :USER ')'

BEGIN;

CREATE PROCEDURE pg_temp.prueba(p_nombre TEXT, p_sql TEXT, p_debe_valer BOOLEAN)
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        EXECUTE p_sql;
    EXCEPTION WHEN OTHERS THEN
        IF p_debe_valer THEN
            RAISE EXCEPTION 'FALLO  %: tenía que poder y no puede (%)', p_nombre, SQLERRM;
        END IF;
        RAISE NOTICE 'OK     %  (rechazado: %)', p_nombre, SQLERRM;
        RETURN;
    END;
    IF NOT p_debe_valer THEN
        RAISE EXCEPTION 'FALLO  %: tenía que rechazarse y se ha permitido', p_nombre;
    END IF;
    RAISE NOTICE 'OK     %  (permitido)', p_nombre;
END $$;

-- Comunes a las dos cuentas: nada de DDL ni de tocar facturas emitidas.
CALL pg_temp.prueba('leer la carta', 'SELECT count(*) FROM plato', TRUE);
CALL pg_temp.prueba('crear una tabla (DDL)', 'CREATE TABLE public.intruso (id int)', FALSE);
CALL pg_temp.prueba('borrar la tabla factura (DDL)', 'DROP TABLE factura', FALSE);
CALL pg_temp.prueba('modificar una factura emitida (R-04)', 'UPDATE factura SET forma_pago = ''otro''', FALSE);
CALL pg_temp.prueba('borrar facturas (R-04)', 'DELETE FROM linea_factura', FALSE);
CALL pg_temp.prueba('dar de alta un local', 'INSERT INTO establecimiento (nombre, direccion, ciudad) VALUES (''X'', ''X'', ''X'')', FALSE);

\if :{?cuenta}
\else
  \set cuenta ninguna
\endif
SELECT :'cuenta' = 'tpv_app' AS es_tpv \gset

\if :es_tpv
-- El TPV vende y da de alta clientes, pero no cambia la configuración.
CALL pg_temp.prueba('emitir una factura', $q$
    INSERT INTO factura (serie, forma_pago, id_empleado, id_equipo)
    SELECT 'PRUEBA', 'efectivo', e.id_empleado, q.id_equipo
    FROM empleado e JOIN equipo q ON q.id_establecimiento = e.id_establecimiento
    JOIN modelo_equipo m ON m.id_modelo = q.id_modelo AND m.tipo = 'tpv'
    WHERE e.dni = '00000002W' LIMIT 1 $q$, TRUE);
CALL pg_temp.prueba('dar de alta un cliente', 'INSERT INTO cliente (nombre) VALUES (''Cliente de prueba'')', TRUE);
CALL pg_temp.prueba('cambiar la IP de un equipo', 'UPDATE equipo SET ip = ''10.9.9.9''', FALSE);
\else
-- Informes: solo lectura.
CALL pg_temp.prueba('consultar el total de ventas', 'SELECT sum(total) FROM v_factura_totales', TRUE);
CALL pg_temp.prueba('emitir una factura', 'INSERT INTO factura (serie, forma_pago, id_empleado, id_equipo) VALUES (''X'', ''efectivo'', 1, 1)', FALSE);
CALL pg_temp.prueba('dar de alta un cliente', 'INSERT INTO cliente (nombre) VALUES (''X'')', FALSE);
\endif

ROLLBACK;
\echo '== Fin: todas las pruebas de' :cuenta 'son correctas'
