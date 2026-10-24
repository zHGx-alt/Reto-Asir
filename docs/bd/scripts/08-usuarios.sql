-- =============================================================================
-- Almi-Chain · Tarea 42 · Script 08: usuarios con acceso (LOGIN) y mínimos privilegios
-- Crea las cuentas reales y las mete en los roles de grupo de 03-roles.sql:
--   tpv_app    → rol_aplicacion (el programa de caja: lee, vende, no borra facturas ni hace DDL)
--   informes   → rol_lectura    (gerente o gestoría: solo consulta)
-- Las contraseñas NO están en el repositorio: se generan en KeePassXC y se pasan al ejecutar
-- (psql no las guarda en el historial si se usan variables):
--   psql -d almi_chain -v ON_ERROR_STOP=1 -v pass_tpv='...' -v pass_informes='...' -f 08-usuarios.sql
-- Repetible: si las cuentas existen, solo cambia la contraseña.
-- Requiere 01, 02 y 03, y ejecutarse con el propietario de las tablas.
-- =============================================================================

\if :{?pass_tpv}
\else
  \echo 'Falta la contraseña: -v pass_tpv=...'
  \quit
\endif
\if :{?pass_informes}
\else
  \echo 'Falta la contraseña: -v pass_informes=...'
  \quit
\endif

BEGIN;

-- Crear o actualizar cada cuenta. format(%L) pone la contraseña entre comillas de forma segura.
SELECT format(CASE WHEN EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'tpv_app')
                   THEN 'ALTER ROLE tpv_app LOGIN PASSWORD %L'
                   ELSE 'CREATE ROLE tpv_app LOGIN PASSWORD %L' END, :'pass_tpv') \gexec
SELECT format(CASE WHEN EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'informes')
                   THEN 'ALTER ROLE informes LOGIN PASSWORD %L'
                   ELSE 'CREATE ROLE informes LOGIN PASSWORD %L' END, :'pass_informes') \gexec

-- Sin privilegios de administración, y con un límite de conexiones por si se filtra la contraseña.
ALTER ROLE tpv_app  NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION CONNECTION LIMIT 10;
ALTER ROLE informes NOSUPERUSER NOCREATEDB NOCREATEROLE NOREPLICATION CONNECTION LIMIT 3;

GRANT rol_aplicacion TO tpv_app;
GRANT rol_lectura    TO informes;

-- Solo estas cuentas (y el propietario) pueden conectarse a esta base.
SELECT format('REVOKE CONNECT ON DATABASE %I FROM PUBLIC', current_database()) \gexec
SELECT format('GRANT CONNECT ON DATABASE %I TO tpv_app, informes', current_database()) \gexec

COMMIT;

\echo 'Cuentas y grupos:'
SELECT r.rolname AS cuenta, r.rolcanlogin AS login, r.rolconnlimit AS max_conexiones,
       string_agg(g.rolname, ', ') AS grupos
FROM pg_roles r
LEFT JOIN pg_auth_members m ON m.member = r.oid
LEFT JOIN pg_roles g        ON g.oid = m.roleid
WHERE r.rolname IN ('tpv_app', 'informes')
GROUP BY r.rolname, r.rolcanlogin, r.rolconnlimit
ORDER BY r.rolname;
