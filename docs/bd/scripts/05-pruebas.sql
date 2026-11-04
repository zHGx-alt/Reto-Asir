-- =============================================================================
-- Almi-Chain · Tarea 40 · Script 05: pruebas de las restricciones y reglas
-- Ejecutar tras 01, 02 y 03, sobre una base de pruebas vacía:
--   psql -d almi_chain -v ON_ERROR_STOP=1 -f 05-pruebas.sql
-- Todo ocurre dentro de una transacción que termina en ROLLBACK: no deja datos.
-- ATENCIÓN: vacía las tablas y reinicia los identificadores al empezar (dentro de la
-- transacción, también se deshace). Usar SOLO en una base de pruebas.
-- Cada prueba "debe fallar" se marca OK si el gestor rechaza la operación.
-- =============================================================================

BEGIN;

TRUNCATE establecimiento, empleado, cliente, modelo_equipo, equipo, plato, articulo,
         stock, receta, factura, linea_factura, campana_marketing, envio_campana,
         proveedor, suministro, plato_alergeno, historial_precio_plato
         RESTART IDENTITY CASCADE;

-- Función auxiliar: ejecuta una sentencia y comprueba que falla (opcionalmente con cierto mensaje).
CREATE FUNCTION pg_temp.debe_fallar(p_prueba TEXT, p_sql TEXT, p_texto TEXT DEFAULT NULL) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
    BEGIN
        EXECUTE p_sql;
    EXCEPTION WHEN OTHERS THEN
        IF p_texto IS NOT NULL AND position(p_texto IN SQLERRM) = 0 THEN
            RAISE EXCEPTION 'FALLO en %: falló, pero con otro mensaje: %', p_prueba, SQLERRM;
        END IF;
        RAISE NOTICE 'OK    %  (rechazado: %)', p_prueba, left(SQLERRM, 80);
        RETURN;
    END;
    RAISE EXCEPTION 'FALLO en %: la operación debería haberse rechazado', p_prueba;
END $$;

CREATE FUNCTION pg_temp.debe_valer(p_prueba TEXT, p_cond BOOLEAN) RETURNS void
LANGUAGE plpgsql AS $$
BEGIN
    IF p_cond IS TRUE THEN RAISE NOTICE 'OK    %', p_prueba;
    ELSE RAISE EXCEPTION 'FALLO en %', p_prueba; END IF;
END $$;

-- ---- Datos mínimos ----------------------------------------------------------
INSERT INTO establecimiento (nombre, direccion, ciudad) VALUES
  ('Almi Deusto','Calle Lehendakari Aguirre 1','Bilbao'),
  ('Almi Centro','Gran Via 10','Bilbao');
INSERT INTO empleado (dni, nombre, apellidos, puesto, id_establecimiento) VALUES
  ('11111111A','Ana','Ruiz','camarero',1),
  ('22222222B','Beto','Gil','camarero',2);
INSERT INTO modelo_equipo (tipo, marca, modelo) VALUES
  ('tpv','Marca','TPV-15'), ('impresora_tickets','Marca','Imp-80'), ('despacho','Marca','PC-Gerente');
INSERT INTO equipo (id_modelo, id_establecimiento, ip) VALUES
  (1,1,'10.0.0.11'),   -- 1: TPV local 1
  (1,2,'10.0.0.11'),   -- 2: TPV local 2 (misma IP en otro local: permitido)
  (3,1,'10.0.0.5'),    -- 3: PC despacho local 1
  (2,1,'10.0.0.21');   -- 4: impresora local 1
INSERT INTO plato (nombre, categoria, precio, tipo_iva) VALUES
  ('Pintxo','entrante',3.00,10), ('Cana','bebida',2.50,21);
INSERT INTO articulo (nombre, unidad_medida) VALUES ('Pan','ud');
INSERT INTO receta VALUES (1,1,2);
INSERT INTO stock VALUES (1,1,5,1);

-- ---- Restricciones de columna ------------------------------------------------
SELECT pg_temp.debe_fallar('DNI duplicado', $$INSERT INTO empleado (dni,nombre,apellidos,puesto,id_establecimiento) VALUES ('11111111A','X','Y','otro',1)$$, 'uk_empleado_dni');
SELECT pg_temp.debe_fallar('puesto fuera de la lista', $$INSERT INTO empleado (dni,nombre,apellidos,puesto,id_establecimiento) VALUES ('33333333C','X','Y','chef',1)$$);
SELECT pg_temp.debe_fallar('IVA del 7 %', $$INSERT INTO plato (nombre,categoria,precio,tipo_iva) VALUES ('Raro','principal',5,7)$$);
SELECT pg_temp.debe_fallar('precio negativo', $$INSERT INTO plato (nombre,categoria,precio,tipo_iva) VALUES ('Neg','principal',-1,10)$$);
SELECT pg_temp.debe_fallar('publicidad sin email', $$INSERT INTO cliente (nombre,acepta_publicidad) VALUES ('Sin mail',true)$$, 'ck_cliente_publicidad_email');
SELECT pg_temp.debe_fallar('latitud fuera de rango', $$INSERT INTO establecimiento (nombre,direccion,ciudad,latitud) VALUES ('X','Y','Z',95)$$);
SELECT pg_temp.debe_fallar('IP repetida en el mismo local', $$INSERT INTO equipo (id_modelo,id_establecimiento,ip) VALUES (1,1,'10.0.0.11')$$, 'uk_equipo_ip');
SELECT pg_temp.debe_fallar('fin de campaña anterior al inicio', $$INSERT INTO campana_marketing (nombre,canal,fecha_inicio,fecha_fin) VALUES ('C','email','2026-12-01','2026-11-01')$$);
SELECT pg_temp.debe_fallar('borrar local con empleados (RESTRICT)', $$DELETE FROM establecimiento WHERE id_establecimiento = 1$$);

-- ---- R-03: impresora y TPV ---------------------------------------------------
UPDATE equipo SET id_equipo_tpv = 1 WHERE id_equipo = 4;  -- válida
SELECT pg_temp.debe_fallar('R-03 TPV con id_equipo_tpv', $$UPDATE equipo SET id_equipo_tpv = 1 WHERE id_equipo = 2$$, 'R-03');
SELECT pg_temp.debe_fallar('R-03 impresora a un PC de despacho', $$UPDATE equipo SET id_equipo_tpv = 3 WHERE id_equipo = 4$$, 'R-03');
SELECT pg_temp.debe_fallar('R-03 impresora a TPV de otro local', $$UPDATE equipo SET id_equipo_tpv = 2 WHERE id_equipo = 4$$, 'R-03');

-- ---- Facturas: R-01, R-02, R-05 ------------------------------------------------
SELECT pg_temp.debe_fallar('R-02 factura desde un PC de despacho', $$INSERT INTO factura (serie,forma_pago,id_empleado,id_equipo) VALUES ('A','efectivo',1,3)$$, 'R-02');
SELECT pg_temp.debe_fallar('R-01 empleado de otro local', $$INSERT INTO factura (serie,forma_pago,id_empleado,id_equipo) VALUES ('A','efectivo',2,1)$$, 'R-01');
INSERT INTO factura (serie,forma_pago,id_empleado,id_equipo) VALUES ('A','efectivo',1,1);          -- número automático = 1
INSERT INTO factura (serie,numero,forma_pago,id_empleado,id_equipo) VALUES ('A',2,'tarjeta',1,1);   -- correlativo explícito
SELECT pg_temp.debe_valer('R-05 numeración automática empieza en 1', (SELECT numero FROM factura WHERE serie='A' ORDER BY id_factura LIMIT 1) = 1);
SELECT pg_temp.debe_fallar('R-05 salto de número', $$INSERT INTO factura (serie,numero,forma_pago,id_empleado,id_equipo) VALUES ('A',9,'efectivo',1,1)$$, 'R-05');
SELECT pg_temp.debe_fallar('R-05 número repetido', $$INSERT INTO factura (serie,numero,forma_pago,id_empleado,id_equipo) VALUES ('A',2,'efectivo',1,1)$$, 'R-05');
INSERT INTO factura (serie,forma_pago,id_empleado,id_equipo) VALUES ('B','otro',1,1);
SELECT pg_temp.debe_valer('R-05 cada serie lleva su propia cuenta', (SELECT numero FROM factura WHERE serie='B') = 1);

-- ---- Líneas, vista y R-06 ----------------------------------------------------
INSERT INTO linea_factura VALUES ((SELECT id_factura FROM factura WHERE serie='A' AND numero=1),1,1,2,3.00,10);   -- 2 pintxos -> descuenta 2 x 2 = 4 panes
INSERT INTO linea_factura VALUES ((SELECT id_factura FROM factura WHERE serie='A' AND numero=1),2,2,1,2.50,21);   -- 1 caña (sin receta)
SELECT pg_temp.debe_valer('R-06 stock descontado (5 - 4 = 1)', (SELECT cantidad FROM stock WHERE id_establecimiento=1 AND id_articulo=1) = 1);
SELECT pg_temp.debe_valer('Vista: base = 8,50', (SELECT base_imponible FROM v_factura_totales WHERE serie='A' AND numero=1) = 8.50);
SELECT pg_temp.debe_valer('Vista: IVA = 0,60 + 0,525 -> 1,13', (SELECT iva FROM v_factura_totales WHERE serie='A' AND numero=1) = 1.13);
SELECT pg_temp.debe_valer('Vista: total = 9,63', (SELECT total FROM v_factura_totales WHERE serie='A' AND numero=1) = 9.63);
SELECT pg_temp.debe_valer('Vista: factura sin líneas vale 0', (SELECT total FROM v_factura_totales WHERE serie='A' AND numero=2) = 0);
SELECT pg_temp.debe_fallar('R-06 venta sin stock suficiente', $$INSERT INTO linea_factura SELECT id_factura,1,1,2,3.00,10 FROM factura WHERE serie='A' AND numero=2$$);
SELECT pg_temp.debe_fallar('línea con cantidad 0', $$INSERT INTO linea_factura SELECT id_factura,1,2,0,2.50,21 FROM factura WHERE serie='A' AND numero=2$$);
SELECT pg_temp.debe_fallar('línea con plato vendido no borrable (RESTRICT)', $$DELETE FROM plato WHERE id_plato = 1$$);

-- ---- Tarea 56: atributo multivaluado, relación ternaria e historial (R-07) ------
INSERT INTO plato_alergeno VALUES (1,'gluten'), (1,'pescado');
SELECT pg_temp.debe_fallar('alérgeno fuera de la lista de los 14', $$INSERT INTO plato_alergeno VALUES (2,'chocolate')$$);
SELECT pg_temp.debe_fallar('alérgeno repetido en el mismo plato', $$INSERT INTO plato_alergeno VALUES (1,'gluten')$$);

INSERT INTO proveedor (cif, nombre) VALUES ('B11111111','Panadería Uno'), ('B22222222','Panadería Dos');
INSERT INTO suministro VALUES (1,1,1,0.40), (1,1,2,0.45), (2,1,1,0.38);
SELECT pg_temp.debe_valer('ternaria: mismo proveedor y artículo, otro precio en otro local', (SELECT count(DISTINCT precio_compra) FROM suministro WHERE id_proveedor=1 AND id_articulo=1) = 2);
SELECT pg_temp.debe_valer('ternaria: el local 1 compra el pan a dos proveedores', (SELECT count(*) FROM suministro WHERE id_articulo=1 AND id_establecimiento=1) = 2);
SELECT pg_temp.debe_fallar('ternaria: misma terna repetida', $$INSERT INTO suministro VALUES (1,1,1,0.50)$$);
SELECT pg_temp.debe_fallar('ternaria: precio de compra 0', $$INSERT INTO suministro VALUES (2,1,2,0)$$);
SELECT pg_temp.debe_fallar('proveedor con CIF repetido', $$INSERT INTO proveedor (cif, nombre) VALUES ('B11111111','Otra')$$, 'uk_proveedor_cif');

SELECT pg_temp.debe_valer('R-07 el alta del plato abre su primer tramo', (SELECT count(*) FROM historial_precio_plato WHERE id_plato=1 AND fecha_hasta IS NULL AND precio=3.00) = 1);
UPDATE plato SET precio = 3.20 WHERE id_plato = 1;
SELECT pg_temp.debe_valer('R-07 subir el precio cierra un tramo y abre otro', (SELECT count(*) FROM historial_precio_plato WHERE id_plato=1) = 2 AND (SELECT precio FROM historial_precio_plato WHERE id_plato=1 AND fecha_hasta IS NULL) = 3.20);
UPDATE plato SET descripcion = 'Con pan' WHERE id_plato = 1;
SELECT pg_temp.debe_valer('R-07 cambiar la descripción no crea tramo', (SELECT count(*) FROM historial_precio_plato WHERE id_plato=1) = 2);
SELECT pg_temp.debe_valer('R-07 la línea ya vendida conserva su precio (3,00)', (SELECT precio_unitario FROM linea_factura WHERE id_plato=1 AND num_linea=1) = 3.00);
SELECT pg_temp.debe_fallar('historial: dos tramos abiertos', $$INSERT INTO historial_precio_plato (id_plato,fecha_desde,precio,tipo_iva) VALUES (1,'2020-01-01',1,10)$$, 'ux_historial_abierto');
SELECT pg_temp.debe_fallar('historial: fin anterior al inicio', $$INSERT INTO historial_precio_plato VALUES (1,'2020-01-02','2020-01-01',1,10)$$, 'ck_historial_fechas');

-- ---- R-04: permisos del rol de la aplicación ------------------------------------
SET LOCAL ROLE rol_aplicacion;
SELECT pg_temp.debe_fallar('rol aplicación no escribe en el historial', $$INSERT INTO historial_precio_plato VALUES (2,'2020-01-01',NULL,1,10)$$, 'permission denied');
SELECT pg_temp.debe_fallar('rol aplicación no corrige el historial', $$UPDATE historial_precio_plato SET precio = 0$$, 'permission denied');
UPDATE plato SET precio = 2.80 WHERE id_plato = 2;   -- sí puede cambiar el precio; R-07 apunta el tramo
SELECT pg_temp.debe_valer('rol aplicación cambia el precio y R-07 lo apunta', (SELECT precio FROM historial_precio_plato WHERE id_plato=2 AND fecha_hasta IS NULL) = 2.80);
SELECT pg_temp.debe_fallar('R-04 UPDATE de FACTURA', $$UPDATE factura SET forma_pago='otro' WHERE serie='A' AND numero=1$$, 'permission denied');
SELECT pg_temp.debe_fallar('R-04 DELETE de FACTURA', $$DELETE FROM factura WHERE serie='A' AND numero=1$$, 'permission denied');
SELECT pg_temp.debe_fallar('R-04 UPDATE de LINEA_FACTURA', $$UPDATE linea_factura SET cantidad=9$$, 'permission denied');
SELECT pg_temp.debe_fallar('R-04 DELETE de LINEA_FACTURA', $$DELETE FROM linea_factura$$, 'permission denied');
SELECT pg_temp.debe_fallar('rol aplicación no crea equipos', $$INSERT INTO equipo (id_modelo,id_establecimiento) VALUES (1,1)$$, 'permission denied');
INSERT INTO factura (serie,forma_pago,id_empleado,id_equipo) VALUES ('C','efectivo',1,1);  -- sí puede emitir
SELECT pg_temp.debe_valer('rol aplicación sí puede emitir facturas', (SELECT COUNT(*) FROM factura WHERE serie='C') = 1);
RESET ROLE;

SET LOCAL ROLE rol_lectura;
SELECT pg_temp.debe_fallar('rol lectura no inserta', $$INSERT INTO cliente (nombre) VALUES ('X')$$, 'permission denied');
RESET ROLE;

ROLLBACK;
