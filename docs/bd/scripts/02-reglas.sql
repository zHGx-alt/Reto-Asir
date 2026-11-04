-- =============================================================================
-- Almi-Chain · Tarea 40 · Script 02: reglas que una clave foránea no expresa
-- Implementa R-01, R-02, R-03, R-05, R-06 y R-07 de la tarea 39 con disparadores.
-- (R-04 se aplica con permisos en 03-roles.sql.)
-- Requiere haber ejecutado 01-crear-tablas.sql.
-- =============================================================================

BEGIN;

-- R-03: id_equipo_tpv solo en impresoras de tickets, y apunta a un TPV del mismo local.
CREATE FUNCTION fn_equipo_impresora_tpv() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_tipo_propio  VARCHAR(20);
    v_tipo_destino VARCHAR(20);
    v_local_destino INTEGER;
BEGIN
    IF NEW.id_equipo_tpv IS NULL THEN
        RETURN NEW;
    END IF;

    SELECT tipo INTO v_tipo_propio FROM modelo_equipo WHERE id_modelo = NEW.id_modelo;
    IF v_tipo_propio <> 'impresora_tickets' THEN
        RAISE EXCEPTION 'R-03: solo una impresora de tickets puede tener id_equipo_tpv (el equipo es de tipo %)', v_tipo_propio;
    END IF;

    SELECT m.tipo, e.id_establecimiento
      INTO v_tipo_destino, v_local_destino
      FROM equipo e JOIN modelo_equipo m ON m.id_modelo = e.id_modelo
     WHERE e.id_equipo = NEW.id_equipo_tpv;
    IF v_tipo_destino <> 'tpv' THEN
        RAISE EXCEPTION 'R-03: la impresora debe conectarse a un equipo de tipo tpv (el destino es %)', v_tipo_destino;
    END IF;
    IF v_local_destino <> NEW.id_establecimiento THEN
        RAISE EXCEPTION 'R-03: la impresora y su TPV deben ser del mismo establecimiento';
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER tg_equipo_impresora_tpv
BEFORE INSERT OR UPDATE ON equipo
FOR EACH ROW EXECUTE FUNCTION fn_equipo_impresora_tpv();

-- R-01 y R-02: el equipo de la factura es un TPV y el empleado es del mismo local.
CREATE FUNCTION fn_factura_coherencia() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_tipo        VARCHAR(20);
    v_local_tpv   INTEGER;
    v_local_emp   INTEGER;
BEGIN
    SELECT m.tipo, e.id_establecimiento
      INTO v_tipo, v_local_tpv
      FROM equipo e JOIN modelo_equipo m ON m.id_modelo = e.id_modelo
     WHERE e.id_equipo = NEW.id_equipo;
    IF v_tipo <> 'tpv' THEN
        RAISE EXCEPTION 'R-02: la factura debe emitirse desde un equipo de tipo tpv (es %)', v_tipo;
    END IF;

    SELECT id_establecimiento INTO v_local_emp FROM empleado WHERE id_empleado = NEW.id_empleado;
    IF v_local_emp <> v_local_tpv THEN
        RAISE EXCEPTION 'R-01: el empleado y el TPV de la factura deben ser del mismo establecimiento';
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER tg_factura_coherencia
BEFORE INSERT ON factura
FOR EACH ROW EXECUTE FUNCTION fn_factura_coherencia();

-- R-05: numeración correlativa y sin huecos por serie.
-- Si numero llega NULL se asigna el siguiente; si llega con valor, debe ser el siguiente.
-- El bloqueo consultivo evita que dos ventas simultáneas obtengan el mismo número.
CREATE FUNCTION fn_factura_numeracion() RETURNS trigger
LANGUAGE plpgsql AS $$
DECLARE
    v_siguiente INTEGER;
BEGIN
    PERFORM pg_advisory_xact_lock(hashtext('factura_serie_' || NEW.serie));
    SELECT COALESCE(MAX(numero), 0) + 1 INTO v_siguiente FROM factura WHERE serie = NEW.serie;
    IF NEW.numero IS NULL THEN
        NEW.numero := v_siguiente;
    ELSIF NEW.numero <> v_siguiente THEN
        RAISE EXCEPTION 'R-05: la serie % debe continuar en el número % (se recibió %)', NEW.serie, v_siguiente, NEW.numero;
    END IF;
    RETURN NEW;
END $$;

CREATE TRIGGER tg_factura_numeracion
BEFORE INSERT ON factura
FOR EACH ROW EXECUTE FUNCTION fn_factura_numeracion();

-- R-06: cada línea vendida descuenta del STOCK los artículos de la RECETA del plato,
-- en el establecimiento del TPV. Si no queda stock suficiente, el CHECK (cantidad >= 0)
-- de STOCK rechaza la venta. Los artículos sin fila de STOCK en ese local no se descuentan.
-- SECURITY DEFINER: así el rol de la aplicación no necesita UPDATE directo sobre STOCK.
CREATE FUNCTION fn_linea_descuenta_stock() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
BEGIN
    UPDATE stock s
       SET cantidad = s.cantidad - r.cantidad * NEW.cantidad
      FROM receta r, factura f, equipo e
     WHERE r.id_plato = NEW.id_plato
       AND f.id_factura = NEW.id_factura
       AND e.id_equipo = f.id_equipo
       AND s.id_establecimiento = e.id_establecimiento
       AND s.id_articulo = r.id_articulo;
    RETURN NEW;
END $$;

CREATE TRIGGER tg_linea_descuenta_stock
AFTER INSERT ON linea_factura
FOR EACH ROW EXECUTE FUNCTION fn_linea_descuenta_stock();

-- R-07 (tarea 56): historial de precios. Al dar de alta un plato se abre su primer tramo;
-- cada cambio de precio o de IVA cierra el tramo abierto y abre otro. Cambiar el nombre
-- o la descripción no crea tramo. clock_timestamp(): hora real aunque haya varios
-- cambios en la misma transacción.
-- SECURITY DEFINER: la aplicación puede cambiar el precio del plato, pero no tiene
-- permiso para escribir ni corregir el historial a mano (03-roles.sql).
CREATE FUNCTION fn_plato_historial_precio() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public, pg_temp AS $$
DECLARE
    v_ahora TIMESTAMP := clock_timestamp();
BEGIN
    IF TG_OP = 'UPDATE' THEN
        IF NEW.precio = OLD.precio AND NEW.tipo_iva = OLD.tipo_iva THEN
            RETURN NEW;
        END IF;
        UPDATE historial_precio_plato
           SET fecha_hasta = v_ahora
         WHERE id_plato = NEW.id_plato AND fecha_hasta IS NULL;
    END IF;
    INSERT INTO historial_precio_plato (id_plato, fecha_desde, precio, tipo_iva)
    VALUES (NEW.id_plato, v_ahora, NEW.precio, NEW.tipo_iva);
    RETURN NEW;
END $$;

CREATE TRIGGER tg_plato_historial_precio
AFTER INSERT OR UPDATE OF precio, tipo_iva ON plato
FOR EACH ROW EXECUTE FUNCTION fn_plato_historial_precio();

COMMIT;
