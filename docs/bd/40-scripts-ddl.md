# Tarea 40: Scripts DDL

- **Bloque:** 8 BD
- **Depende de:** tarea 39 (modelo lógico 3FN)
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** hecha. 04/11: ampliada con la tarea 56 (4 tablas, regla R-07, 16 pruebas y 3 consultas más; sección 9)
- **Gestor:** PostgreSQL 17, el mismo que usa Odoo en el servidor. Probado en 16 (22/10), en 18.3 (24/10, tareas 41 y 42) y en 17.11 desde el 29/10, que es el que usa `scripts/verificar-repo.sh`

## 1. Qué se entrega

Nueve scripts SQL. Los cinco primeros convierten el modelo lógico de la tarea 39 en una base de datos real. Se guardan en `docs/bd/scripts/` (o la carpeta que use el equipo).

| Script | Qué hace |
|---|---|
| `01-crear-tablas.sql` | Crea las 17 tablas (13 + 4 de la tarea 56) con claves, restricciones, índices y la vista `v_factura_totales` |
| `02-reglas.sql` | Implementa con disparadores las reglas R-01, R-02, R-03, R-05, R-06 y R-07 (historial de precios) |
| `03-roles.sql` | Crea los roles `rol_aplicacion` y `rol_lectura` y sus permisos (regla R-04) |
| `04-borrar.sql` | Deshace todo en orden inverso, para repetir pruebas |
| `05-pruebas.sql` | 49 pruebas de restricciones y reglas (33 + 16 de la tarea 56); termina en `ROLLBACK` |
| `06-datos.sql` | **Tarea 41.** Datos de prueba: 2 locales, personal, equipos, carta, almacén, clientes, campaña y 8 ventas. Con la tarea 56, también alérgenos, proveedores con sus tarifas por local y una subida de precio |
| `07-consultas.sql` | **Tarea 41.** 15 consultas del negocio (JOIN, agregados, HAVING, subconsultas); las 3 últimas, de la tarea 56 |
| `08-usuarios.sql` | **Tarea 42.** Cuentas con `LOGIN`: `tpv_app` (rol_aplicacion) e `informes` (rol_lectura); contraseñas por variable, nunca en el repositorio |
| `09-pruebas-usuarios.sql` | **Tarea 42.** 9 pruebas de mínimos privilegios con cada cuenta |

## 2. Cómo ejecutarlos

Una **base central** de la cadena, con los datos de cada establecimiento separados por `id_establecimiento` (decisión explicada en la [tarea 38, apartado 1.1](38-modelo-er.md#11-una-base-central-para-toda-la-cadena)). En el servidor va en el **mismo PostgreSQL que Odoo** (contenedor `db`), como otra base con sus propios roles: así queda en el RAID (tarea 43) y entra en las copias (tarea 44).

En el servidor, desde `docs/bd/scripts/`:

```
docker compose -f /opt/odoo/docker-compose.yml exec -T db createdb -U odoo almi_chain
for s in 01-crear-tablas 02-reglas 03-roles; do
  docker compose -f /opt/odoo/docker-compose.yml exec -T db psql -U odoo -d almi_chain -v ON_ERROR_STOP=1 < $s.sql
done
```

Fuera del servidor (por ejemplo, para probar en un PostgreSQL local), en este orden:

```
createdb almi_chain
psql -d almi_chain -v ON_ERROR_STOP=1 -f 01-crear-tablas.sql
psql -d almi_chain -v ON_ERROR_STOP=1 -f 02-reglas.sql
psql -d almi_chain -v ON_ERROR_STOP=1 -f 03-roles.sql
```

Para probar (solo en una base de pruebas, porque vacía las tablas al empezar y lo deshace al terminar):

```
psql -d almi_chain_pruebas -v ON_ERROR_STOP=1 -f 05-pruebas.sql
```

## 3. Decisiones de diseño

- **Orden de creación:** primero las tablas de las que dependen otras, porque una clave foránea no puede apuntar a una tabla que aún no existe.
- **Identificadores:** `GENERATED ALWAYS AS IDENTITY`, como indica el diccionario de datos de la tarea 39.
- **Acciones de las claves foráneas:** las de la sección 6.1 de la tarea 39 (RESTRICT, CASCADE y SET NULL).
- **Índices:** PostgreSQL no crea índices en las claves foráneas. Se añaden en las que no encabezan ya una clave, para acelerar uniones y borrados.
- **Transacciones:** cada script va entre `BEGIN` y `COMMIT`. Si algo falla con `ON_ERROR_STOP=1`, no queda nada a medias.
- **Numeración de facturas (R-05):** un disparador asigna el número siguiente de la serie, o comprueba que el recibido es ese. Un bloqueo por serie evita que dos ventas simultáneas obtengan el mismo número.
- **Stock (R-06):** al insertar una línea, un disparador descuenta del STOCK del local del TPV los artículos de la receta del plato. Si no hay stock suficiente, el `CHECK (cantidad >= 0)` rechaza la venta. Los artículos sin fila de STOCK en ese local no se descuentan. El disparador es `SECURITY DEFINER`, así que `rol_aplicacion` no necesita permiso de UPDATE directo para ese descuento.
- **Mínimos privilegios (R-04):** `rol_aplicacion` solo puede hacer INSERT en FACTURA y LINEA_FACTURA. No puede crear ni modificar locales, equipos ni modelos: eso lo hace el propietario. Las personas o servicios se crean aparte (`CREATE ROLE ... LOGIN PASSWORD ...`) y se añaden al grupo. Las contraseñas no van en el repositorio.

## 4. Supuestos (las 3 dudas abiertas de la tarea 39)

| Id | Supuesto adoptado | Si cambia |
|---|---|---|
| S-1 | IVA admitido: 4, 10 y 21 % | Cambiar el `CHECK` de `plato.tipo_iva` y `linea_factura.tipo_iva` |
| S-2 | Sin baja de empleados ni retirada de platos | Añadir `activo` o `fecha_baja` a EMPLEADO y PLATO (y al E/R) |
| S-3 | Listas de valores como `CHECK` | Pasarlas a tablas de catálogo |

## 5. Pruebas realizadas

Se ejecutaron en un PostgreSQL 16 limpio: los tres scripts de creación, el borrado y la recreación, y `03-roles.sql` por segunda vez (es repetible). `05-pruebas.sql` se ejecutó dos veces seguidas con **33 pruebas correctas**, y la tabla FACTURA quedó vacía después.

| Grupo | Qué se comprueba |
|---|---|
| Restricciones de columna | DNI duplicado, puesto fuera de lista, IVA del 7 %, precio negativo, publicidad sin email, latitud fuera de rango, IP repetida en un local, fechas de campaña, borrar un local con empleados |
| R-03 | Un TPV no puede tener `id_equipo_tpv`; una impresora no se conecta a un PC de despacho ni a un TPV de otro local |
| R-01, R-02 | Factura desde un equipo que no es TPV, o con un empleado de otro local |
| R-05 | Numeración automática, salto de número, número repetido y series independientes |
| R-06 | Descuento de stock correcto (5 − 4 = 1) y rechazo de una venta sin stock |
| Vista | Base 8,50, IVA 1,13 y total 9,63 en una factura de ejemplo; una factura sin líneas vale 0 |
| R-04 | `rol_aplicacion` no puede modificar ni borrar facturas ni líneas, pero sí emitirlas; `rol_lectura` no inserta |

## 6. Límites

- No se ha probado la concurrencia real (dos TPV emitiendo a la vez); el bloqueo por serie es la defensa prevista.
- Si un empleado cambia de local después de emitir facturas, R-01 no se vuelve a comprobar sobre las facturas antiguas.
- El stock puede quedar sin descontar si el artículo no tiene fila de STOCK en ese local; hay que cargarlas al dar de alta el local.
- Los datos de ejemplo están en `06-datos.sql` (tarea 41). El RAID 1 y las copias son las tareas 43 y 44.
- Odoo gestiona su propia base de datos (`tienda`). `almi_chain` es otra base en el mismo PostgreSQL (sección 2).

## 7. Tarea 41: datos de prueba y consultas

**Datos** ([`06-datos.sql`](scripts/06-datos.sql)): un ejemplo coherente con el resto del proyecto. Dos locales en Bilbao, 6 empleados, los equipos de las tareas 8 y 10 con las IP de la tarea 23 (las impresoras, por USB a su TPV), 11 platos con IVA del 10 % (hostelería), 13 artículos con sus recetas y su stock, 4 clientes (uno es una empresa con NIF, para factura completa), 2 campañas y **8 ventas**. Las ventas se insertan como lo haría el TPV: los disparadores numeran las facturas por serie (R-05), comprueban el TPV y el empleado (R-01 y R-02) y descuentan el stock (R-06). El stock de chuleta de Abando se deja justo para que quede por debajo del mínimo. Todos los datos son inventados. El script se para si la base ya tiene datos.

**Consultas** ([`07-consultas.sql`](scripts/07-consultas.sql)):

| Código | Pregunta del negocio | Técnica |
|---|---|---|
| C-01 | Carta con el precio al público | Expresión calculada, `CASE`, `ORDER BY` |
| C-02 | Facturas con local, TPV, empleado, cliente y total | `JOIN` de 5 tablas, `LEFT JOIN`, vista |
| C-03 | Ventas por local y día | `GROUP BY`, `SUM`, `COUNT` |
| C-04 | Los 5 platos más vendidos | `GROUP BY`, `ORDER BY`, `LIMIT` |
| C-05 | Platos que no se han vendido nunca | Subconsulta con `NOT EXISTS` |
| C-06 | Facturas por encima del importe medio | Subconsulta escalar con `AVG` |
| C-07 | Empleados que han vendido más de 100 € | `HAVING` |
| C-08 | Artículos por debajo del stock mínimo | Comparación entre columnas |
| C-09 | Consumo de materia prima por local | `JOIN` con RECETA y agregado |
| C-10 | Clientes con publicidad aceptada que no han recibido la campaña | Subconsulta con `NOT IN` |
| C-11 | Cada impresora con su TPV | Autocombinación de EQUIPO |
| C-12 | Inventario de equipos y coste por local | `CROSS JOIN`, `LEFT JOIN`, `COALESCE` |
| C-13 | Platos sin gluten y sus otros alérgenos (tarea 56) | Atributo multivaluado, `NOT EXISTS`, `string_agg` |
| C-14 | Proveedor más barato de cada artículo en cada local (tarea 56) | Relación ternaria, `DISTINCT ON`, `count() OVER` |
| C-15 | Precio cobrado en cada venta de café frente al vigente ese día (tarea 56) | Historial con rango de fechas |

**Cómo se ejecuta** (tras 01, 02 y 03, en una base vacía):

```
psql -d almi_chain -v ON_ERROR_STOP=1 -f 06-datos.sql
psql -d almi_chain -f 07-consultas.sql > ../evidencias/41-consultas.txt
```

`scripts/verificar-repo.sh` ya lo incluye: carga los datos, comprueba que hay 8 facturas y ejecuta las 15 consultas.

**Ejecutado el 24/10/2026** en un PostgreSQL 18.3 vacío: 13 tablas con datos (8 facturas, 26 líneas) y las 12 consultas sin errores. Salida completa: [`evidencias/41-datos-y-consultas.txt`](evidencias/41-datos-y-consultas.txt). Los resultados tienen sentido: C-05 devuelve el plato sin ventas (Pimientos de Gernika), C-08 la chuleta de Abando por debajo del mínimo, C-11 las tres impresoras con su TPV.

**Pendiente:** crear la base en el servidor (sección 2).

## 8. Tarea 42: usuarios con acceso y mínimos privilegios

Los roles de `03-roles.sql` son grupos sin `LOGIN`. [`08-usuarios.sql`](scripts/08-usuarios.sql) crea las cuentas que de verdad se conectan:

| Cuenta | Grupo | Puede | No puede | Límite de conexiones |
|---|---|---|---|---|
| `tpv_app` | `rol_aplicacion` | Leer todo, vender (INSERT de facturas), dar de alta clientes | DDL, modificar o borrar facturas (R-04), tocar locales y equipos | 10 |
| `informes` | `rol_lectura` | Leer todo (gerente, gestoría) | Escribir nada | 3 |

- Las contraseñas se generan en KeePassXC y se pasan al ejecutar como variables de psql, leídas antes con `read -rs` para que no queden en `~/.bash_history` (tarea 46, S-22): no se escriben en ningún fichero. El script es repetible (si la cuenta existe, solo cambia la contraseña).
- Solo esas dos cuentas y el propietario pueden **conectarse** a la base (`REVOKE CONNECT ... FROM PUBLIC`).
- [`09-pruebas-usuarios.sql`](scripts/09-pruebas-usuarios.sql) se ejecuta con cada cuenta y comprueba 9 casos; todo termina en `ROLLBACK`.

```
read -rsp 'tpv_app: ' PASS_TPV; echo; read -rsp 'informes: ' PASS_INF; echo
psql -d almi_chain -v ON_ERROR_STOP=1 -v pass_tpv="$PASS_TPV" -v pass_informes="$PASS_INF" -f 08-usuarios.sql; unset PASS_TPV PASS_INF
psql -d almi_chain -U tpv_app  -v cuenta=tpv_app  -f 09-pruebas-usuarios.sql
psql -d almi_chain -U informes -v cuenta=informes -f 09-pruebas-usuarios.sql
```

**Resultado (24/10/2026):** 9/9 con cada cuenta. Evidencia: [`evidencias/42-usuarios-y-permisos.txt`](evidencias/42-usuarios-y-permisos.txt). `scripts/verificar-repo.sh` repite todo (con Docker o, si no hay, con un PostgreSQL local en un clúster temporal).

## 9. Tarea 56: ampliación del modelo

La tarea 56 amplía el E/R con una relación ternaria, un historial y atributos especiales ([tarea 38, sección 6](38-modelo-er.md#6-ampliación-de-la-tarea-56-relación-ternaria-historial-y-atributos-especiales); paso a tablas en la [tarea 39, sección 9](39-modelo-logico-3fn.md#9-ampliación-de-la-tarea-56)). Se ha metido en los mismos scripts, para que la base se siga creando de una vez con 01, 02 y 03:

| Script | Qué se añade |
|---|---|
| `01-crear-tablas.sql` | PROVEEDOR; SUMINISTRO (la ternaria, con clave de tres columnas y `precio_compra`); PLATO_ALERGENO (el multivaluado, con los 14 alérgenos como `CHECK`); HISTORIAL_PRECIO_PLATO (con un índice único parcial: un solo tramo abierto por plato); 2 índices |
| `02-reglas.sql` | **R-07:** al dar de alta un plato se abre su tramo de precio; al cambiar el precio o el IVA se cierra el tramo y se abre otro. Cambiar el nombre no crea tramo. `SECURITY DEFINER`, como R-06 |
| `03-roles.sql` | `rol_aplicacion` mantiene proveedores, tarifas y alérgenos, pero **solo lee** el historial: no puede inventarlo ni corregirlo |
| `04-borrar.sql` | Borra las 4 tablas y la función de R-07 |
| `05-pruebas.sql` | 16 pruebas: alérgeno fuera de la lista o repetido; la ternaria admite el mismo proveedor y artículo con otro precio en otro local, y el mismo artículo y local con dos proveedores, pero no la misma terna dos veces ni un precio 0; CIF repetido; R-07 abre el primer tramo, cierra y abre al subir el precio, no crea tramo al cambiar la descripción y la línea ya vendida conserva su precio; no se permiten dos tramos abiertos ni un fin anterior al inicio; la aplicación no escribe ni corrige el historial, pero al cambiar un precio R-07 lo apunta |
| `06-datos.sql` | 16 alérgenos en 8 platos, 4 proveedores, 15 tarifas (la chuleta cuesta distinto en cada local; el café y la cerveza de Abando, a dos proveedores), la carta vigente desde el 1/1/2026 y una subida del café después de las ventas |
| `07-consultas.sql` | C-13, C-14 y C-15 (sección 7) |

**Pruebas (04/11/2026)** en un PostgreSQL 16 vacío: 01, 02 y 03 sin errores (03 dos veces: repetible); 04 borra todo y se vuelve a crear; `05-pruebas.sql` **49/49** dos veces seguidas, sin dejar facturas; 06 carga las 17 tablas; las 15 consultas sin errores; 08, y 09 con las dos cuentas, 9/9. Resultados: C-13 da 8 platos sin gluten; C-14, el proveedor más barato y cuántos hay (2 para el café y la cerveza de Abando); C-15, las tres ventas de café a 1,45 € aunque hoy valga 1,55 €. Salida completa: [`evidencias/56-ampliacion-er.txt`](evidencias/56-ampliacion-er.txt). `scripts/verificar-repo.sh` espera ahora 49 pruebas y 15 consultas.

**En una base ya creada** (por ejemplo, la del servidor), como solo tiene datos de prueba, lo más sencillo es rehacerla: `04-borrar.sql`, después 01, 02 y 03, y `06-datos.sql`.
