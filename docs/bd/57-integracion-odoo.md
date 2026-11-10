# Tarea 57: Integrar la base de datos propia (`almi_chain`) con la de Odoo (diseño)

- **Bloque:** 8 Bases de datos
- **Responsable:** Iker
- **Depende de:** tareas 40-42 (`almi_chain`), 34 y 36 (Odoo con la carta)
- **Criterio de la rúbrica:** [9. Paso a tablas e implementación](../gestion/rubrica-anexo-VI.md#9-paso-a-tablas-e-implementación). Nivel 4: «aporta una solución a la necesidad de integrar dos bases de datos distintas (la propia y Odoo)». Es acumulativo: sin el 4 no cuenta el 5 (DDL reproducible y probado, que ya está hecho).
- **Estado (10/11/2026):** ⏳ Diseño hecho por Adrian, con los datos reales de las dos bases comprobados en la VM `ServidorERP`. **Falta el script** (Iker, unas 2 h): sección 6.

## 1. El problema

El restaurante tiene **dos bases de datos** en el mismo PostgreSQL del servidor:

| Base | Qué guarda | Quién la escribe |
|---|---|---|
| `almi_chain` (tareas 38-42) | El modelo propio de la cadena: establecimientos, empleados, platos con historial de precios y alérgenos, proveedores, clientes con consentimiento de publicidad, campañas… | La aplicación propia y el gerente |
| `tienda` (Odoo, tareas 33-35) | Lo que usa el TPV y la facturación: productos, clientes, pedidos, facturas | Odoo |

Hoy no hay ningún enlace: la carta está escrita dos veces (en `06-datos.sql` y en `carta.csv` de la tarea 36) y ya no coinciden. Si el gerente cambia un precio en un sitio, el otro se queda mal.

## 2. Qué se integra y en qué sentido

**Decisión:** `almi_chain` es la **fuente de verdad** de la carta y de los clientes, y un script los lleva a Odoo **en un solo sentido** (`almi_chain` → Odoo). Odoo sigue siendo el que cobra y factura.

| Dato | Sentido | Por qué |
|---|---|---|
| **Platos y precios** | `almi_chain` → Odoo | `almi_chain` guarda el historial de precios (tarea 56) y los alérgenos; Odoo solo necesita el precio de hoy para cobrar |
| **Clientes** | `almi_chain` → Odoo | Para facturar a empresas desde el TPV con su NIF |
| **Clientes que aceptan publicidad** | `almi_chain` → lista de correo de Odoo | La campaña de la tarea 63 se envía solo a quien ha dado su consentimiento (`acepta_publicidad`) |
| Ventas del TPV | No se integran | Habría que llevarlas a `factura`/`linea_factura`, que exigen empleado y equipo (`NOT NULL`) que Odoo no tiene igual. Queda como mejora (sección 8) |

**Alternativas descartadas:**
- *Enlace directo entre bases* (`postgres_fdw` o `dblink`). Las dos están en el mismo PostgreSQL, pero escribir en las tablas de Odoo con SQL se salta sus reglas: impuestos, campos calculados y caché. Odoo lo desaconseja.
- *Exportar e importar CSV a mano.* Es lo que hace hoy la tarea 36: no es repetible ni se puede automatizar.
- *En los dos sentidos.* Si se puede cambiar el precio en los dos sitios, hay que decidir cuál gana en cada conflicto. Con un solo sentido no hay conflictos.

## 3. Lo que hay hoy en las dos bases (VM `ServidorERP`, 10/11/2026)

| `almi_chain.plato` | Precio sin IVA | PVP (+10 %) | Producto en Odoo (tras la tarea 36) | ¿Coincide el nombre? |
|---|---:|---:|---|---|
| Gilda | 2,27 | 2,50 | Gilda | ✅ |
| Croquetas de jamón | 7,27 | 8,00 | Croquetas de jamón (6 uds) | ❌ |
| Bacalao al pil-pil | 19,09 | 21,00 | Bacalao al pil-pil | ✅ |
| Txuleta a la brasa | 45,45 | 50,00 | Txuleta a la brasa (1 kg) | ❌ |
| Marmitako | 13,64 | 15,00 | Marmitako | ✅ |
| Pimientos de Gernika | 6,36 | 7,00 | Pimientos de Gernika | ✅ |
| Tarta de queso | 5,91 | 6,50 | Tarta de queso | ✅ |
| Pantxineta | 5,45 | 6,00 | Pantxineta | ✅ |
| Caña | 2,27 | 2,50 | Caña | ✅ |
| Txakoli (copa) | 3,18 | 3,50 | Txakoli (copa) | ✅ |
| Agua mineral | 1,82 | 2,00 | Agua 50 cl | ❌ |
| Café | 1,45 | 1,60 | Café solo (y Café con leche, 1,80) | ❌ |
| — | | | Menú del día (14,50) | No está en `almi_chain` |

Clientes en `almi_chain`: 4, de los que 2 aceptan publicidad.

**Conclusiones para el script:**
1. **No se puede emparejar por nombre:** 4 de 12 platos se llaman distinto en las dos bases. Hace falta una **clave de enlace**: en Odoo, el campo *Referencia interna* (`default_code`) del producto guarda `ALMI-PLATO-<id_plato>`.
2. **`almi_chain` guarda el precio sin IVA y Odoo el PVP con IVA incluido** (impuesto `10% S (IVA incluido)` de la tarea 34). El script calcula `PVP = precio × (1 + tipo_iva / 100)`, redondeado a 2 decimales **hacia arriba en el medio** (`Decimal` con `ROUND_HALF_UP`). Con `round()` de Python, `45,45 × 1,10 = 49,995` da 49,99 en vez de 50,00.
3. Las categorías son distintas: `entrante → Entrantes`, `principal → Platos`, `postre → Postres`, `bebida → Bebidas`. Los cafés no tienen categoría propia en `almi_chain`.

## 4. Correspondencia de campos

**Plato → producto** (`product.template`):

| `almi_chain` | Odoo | Notas |
|---|---|---|
| `id_plato` | `default_code` = `ALMI-PLATO-<id>` | Clave de enlace: no cambia aunque cambie el nombre |
| `nombre` | `name` | |
| `descripcion` | `description_sale` | |
| `categoria` | `pos_categ_ids` | Con la tabla de la sección 3 |
| `precio`, `tipo_iva` | `list_price` (PVP) y `taxes_id` (`10% S (IVA incluido)`) | PVP calculado (sección 3) |
| — | `available_in_pos = True`, `sale_ok = True` | |
| alérgenos (`plato_alergeno`) | Se añaden al final de `description_sale`: «Alérgenos: gluten, huevo» | Para que el camarero los vea en el TPV |

**Cliente → contacto** (`res.partner`):

| `almi_chain` | Odoo | Notas |
|---|---|---|
| `id_cliente` | `ref` = `ALMI-CLI-<id>` | Clave de enlace |
| `nombre`, `email`, `telefono` | `name`, `email`, `phone` | |
| `nif` | `vat` = `ES<nif>` | Odoo comprueba el formato del NIF español; si lo rechaza (los NIF de ejemplo no son válidos), se guarda solo en `ref` y se apunta en la salida |
| `acepta_publicidad = TRUE` | Contacto en la lista de correo `Clientes que aceptan publicidad` (`mailing.contact`) | La misma lista que crea la tarea 63 |
| `acepta_publicidad = FALSE` | Si estaba en la lista, se le quita (`mailing.subscription` con `opt_out = True`) | Quien retira el consentimiento deja de recibir correos |

## 5. Seguridad (mínimos privilegios)

- **Lectura de `almi_chain`:** con un usuario de `rol_lectura` (por ejemplo `informes`, de `08-usuarios.sql`), que solo puede hacer `SELECT`. El script **nunca escribe** en `almi_chain`.
- **Escritura en Odoo:** por la API (XML-RPC), con el usuario `gerente`, no con `admin` ni con SQL directo.
- **Contraseñas:** por variables de entorno leídas con `read -rs`, como en la tarea 36. Ninguna en el script ni en Git.
- En la VM de laboratorio, `rol_lectura` existe pero ningún usuario con `LOGIN` lo tiene: hay que crearlo con `08-usuarios.sql`.

## 6. El script que falta (Iker)

`docs/bd/scripts/10-integrar-odoo.py`, solo con la biblioteca estándar y `psycopg2` (o llamando a `psql` con `subprocess`, como prefiera). Puede reutilizar las funciones de la tarea 36 (`x()`, `iva_incluido()`, búsqueda de categorías).

```text
1. Conectar a almi_chain (usuario de rol_lectura) y a Odoo (gerente).
2. Platos:
   para cada fila de plato (con sus alérgenos):
       buscar product.template con default_code = ALMI-PLATO-<id>
       si no existe y es la primera vez: buscar por la tabla de equivalencias de nombres
           (los 4 de la sección 3: "Croquetas de jamón" → "Croquetas de jamón (6 uds)", …)
       calcular el PVP (Decimal, ROUND_HALF_UP)
       si existe: write() solo si algo cambia → «= actualizado» o «· sin cambios»
       si no: create() → «+ nuevo»
3. Clientes: lo mismo con res.partner y ref = ALMI-CLI-<id>.
4. Lista de correo: alta de los que aceptan publicidad; baja (opt_out) de los que no.
5. Resumen: «Platos: N nuevos, N actualizados, N sin cambios · Clientes: … · Lista: N altas, N bajas».
   Código de salida distinto de 0 si algo falla.
```

**Repetible:** la segunda ejecución seguida tiene que decir `0 nuevos, 0 actualizados` en todo. Eso demuestra que no duplica.

## 7. Pruebas que tiene que pasar

| # | Prueba | Esperado | Evidencia |
|---|---|---|---|
| I-1 | Primera ejecución | 12 platos enlazados (8 por nombre y 4 por equivalencia; ninguno duplicado), 4 clientes, 2 altas en la lista | `evidencias/57-01-primera.txt` |
| I-2 | Segunda ejecución sin cambios | Todo «sin cambios» | `57-02-repetir.txt` |
| I-3 | `UPDATE plato SET precio = 7.73 WHERE nombre = 'Croquetas de jamón'` (con el propietario: `informes` no puede) y volver a ejecutar | Solo ese producto «actualizado», PVP 8,50 en Odoo, y una fila nueva en `historial_precio_plato` (la pone el disparador) | `57-03-cambio-precio.txt` y captura del TPV |
| I-4 | `UPDATE cliente SET acepta_publicidad = FALSE WHERE nombre = 'Maite Ejemplo'` y ejecutar | 1 baja en la lista de correo | `57-04-baja-publicidad.txt` |
| I-5 | Intentar escribir en `almi_chain` con el usuario del script | `permission denied` | `57-05-solo-lectura.txt` |

Después de I-3, dejar el precio como estaba (7,27).

## 8. Fuera del alcance (mejoras)

- **Ventas del TPV → `factura`/`linea_factura`**, para tener en `almi_chain` las ventas de todos los locales. Haría falta relacionar el cajero de Odoo con `empleado` y el TPV con `equipo`.
- **Ejecutarlo solo**, con un temporizador de systemd cada noche antes de la copia de seguridad (02:30, tarea 44) o al cambiar la carta.
