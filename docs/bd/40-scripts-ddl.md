# Tarea 40: Scripts DDL

- **Bloque:** 8 BD
- **Depende de:** tarea 39 (modelo lógico 3FN)
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** pendiente de revisión (revisa: Adrian)
- **Gestor:** PostgreSQL 16 (probado en esa versión)

## 1. Qué se entrega

Cinco scripts SQL que convierten el modelo lógico de la tarea 39 en una base de datos real. Se guardan en `docs/bd/scripts/` (o la carpeta que use el equipo).

| Script | Qué hace |
|---|---|
| `01-crear-tablas.sql` | Crea las 13 tablas con claves, restricciones, índices y la vista `v_factura_totales` |
| `02-reglas.sql` | Implementa con disparadores las reglas R-01, R-02, R-03, R-05 y R-06 |
| `03-roles.sql` | Crea los roles `rol_aplicacion` y `rol_lectura` y sus permisos (regla R-04) |
| `04-borrar.sql` | Deshace todo en orden inverso, para repetir pruebas |
| `05-pruebas.sql` | 33 pruebas de restricciones y reglas; termina en `ROLLBACK` |

## 2. Cómo ejecutarlos

Una base de datos por establecimiento, como pide el enunciado. En cada una, en este orden:

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
- No incluye datos de ejemplo (`INSERT`), el RAID 1 ni las copias de seguridad: son tareas aparte.
- Odoo gestiona su propia base de datos. Si estas tablas van en la misma base o en una aparte es una decisión pendiente del equipo.
