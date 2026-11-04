-- =============================================================================
-- Almi-Chain · Tarea 40 · Script 03: roles y permisos (mínimos privilegios, R-04)
-- Roles de grupo sin acceso directo (NOLOGIN). Las personas o servicios se crean
-- aparte y se añaden al grupo, con contraseña fuera del repositorio:
--   CREATE ROLE odoo_tpv LOGIN PASSWORD '<contraseña>';
--   GRANT rol_aplicacion TO odoo_tpv;
-- Requiere haber ejecutado 01 y 02, y ejecutarse con el propietario de las tablas.
-- =============================================================================

BEGIN;

DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_aplicacion') THEN
        CREATE ROLE rol_aplicacion NOLOGIN;
    END IF;
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'rol_lectura') THEN
        CREATE ROLE rol_lectura NOLOGIN;
    END IF;
END $$;

-- Partimos de cero: nadie salvo el propietario toca nada.
REVOKE ALL ON ALL TABLES    IN SCHEMA public FROM PUBLIC, rol_aplicacion, rol_lectura;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC, rol_aplicacion, rol_lectura;

-- Aplicación (TPV / ERP): lee todo, gestiona los datos de uso diario.
GRANT SELECT ON ALL TABLES IN SCHEMA public TO rol_aplicacion;
GRANT INSERT, UPDATE ON cliente, plato, articulo, stock, receta,
                        campana_marketing, envio_campana, empleado        TO rol_aplicacion;
GRANT DELETE ON envio_campana, receta                                     TO rol_aplicacion;
-- Tarea 56: compras y alérgenos los mantiene la aplicación. El historial de precios
-- solo lo escribe R-07: la aplicación lo lee pero no puede tocarlo.
GRANT INSERT, UPDATE ON proveedor, suministro                             TO rol_aplicacion;
GRANT INSERT, DELETE ON plato_alergeno                                    TO rol_aplicacion;
GRANT DELETE ON suministro                                                TO rol_aplicacion;

-- R-04: las facturas emitidas no se modifican ni se borran. Solo INSERT.
GRANT INSERT ON factura, linea_factura TO rol_aplicacion;

-- Configuración de locales y equipos: solo el propietario (administrador).

-- Lectura (informes, copias de seguridad lógicas, contabilidad).
GRANT SELECT ON ALL TABLES IN SCHEMA public TO rol_lectura;

COMMIT;
