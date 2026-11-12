# Tarea 57: Integrar la BD propia con la de Odoo

- **Bloque:** 8 BD
- **Responsable:** Iker
- **Depende de:** tarea 34 (Odoo configurado, usuario `gerente`) y tarea 40 (base `almi_chain`)
- **Rúbrica:** GBD RA3, nivel 4
- **Estado (12/11/2026, cerrada):** script hecho y probado en local contra un Odoo simulado ([`evidencias/00-prueba-local-simulada.txt`](evidencias/00-prueba-local-simulada.txt)). **Queda como mejora** ejecutarlo en `ServidorERP` y guardar las evidencias 01 a 03 (sección 4).

## 1. Qué se hace

Hasta ahora las dos bases iban por separado: la tarea 36 metía la carta en Odoo desde un CSV, a mano. Con [`sincronizar-carta.py`](sincronizar-carta.py) la carta sale de **`almi_chain`** (tabla `plato`) y se escribe en el TPV de **Odoo** (base `tienda`) por su API XML-RPC.

- **`almi_chain` manda.** Si un precio cambia en la base de la cadena, al volver a lanzar el script cambia en el TPV.
- **Enlace entre las bases:** cada producto de Odoo guarda en su *referencia interna* (`default_code`) el `id_plato` de `almi_chain`, con la forma `ALMI-<id_plato>`. Desde la segunda vez el producto se busca por esa referencia y no por el nombre.
- **Repetible:** si no hay cambios no toca nada (`0 nuevos, 0 actualizados, 12 sin cambios`). Con `--simular` dice qué haría sin escribir.
- **Precio:** en `almi_chain` va sin IVA (`precio` y `tipo_iva`); en el TPV, con el IVA incluido. El script calcula `precio × (1 + tipo_iva / 100)` redondeado a 2 decimales, por ejemplo Gilda 2,27 € → 2,50 €.
- **Mínimos privilegios:** lee `almi_chain` con la cuenta `informes` (`rol_lectura`, tarea 42), que no puede modificar nada, y escribe en Odoo con `gerente`, no con `admin`.

| `almi_chain` (`plato`) | Odoo (`product.template`) |
|---|---|
| `id_plato` | `default_code` = `ALMI-<id_plato>` |
| `nombre` | `name` (solo al crearlo) |
| `descripcion` | `description_sale` |
| `precio` + `tipo_iva` | `list_price` (con IVA) y `taxes_id` = «10% S (IVA incluido)» |
| `categoria` (`entrante`, `principal`, `postre`, `bebida`) | `pos_categ_ids` (Entrantes, Platos, Postres, Bebidas), solo al crearlo |

Cuatro platos tenían en el TPV un nombre algo distinto por la carta de la tarea 36 (por ejemplo «Croquetas de jamón (6 uds)»). Para no duplicarlos, la primera vez se enlazan con el diccionario `NOMBRE_EN_ODOO` del script. Los productos que solo existen en Odoo («Menú del día», «Café con leche») no se tocan.

Al actualizar solo se cambian la referencia, el precio y la descripción: con una caja abierta Odoo no deja cambiar la categoría (lo mismo que en la tarea 34).

## 2. Archivos

| Archivo | Qué es |
|---|---|
| [`sincronizar-carta.py`](sincronizar-carta.py) | El script. Solo usa la biblioteca estándar de Python y `psql` |
| [`evidencias/`](evidencias/) | Salidas de las pruebas |

## 3. Procedimiento

En el servidor (`ServidorERP`), con la contraseña de `gerente` sacada de KeePassXC:

```bash
cd docs/bd/57-integracion-odoo
sudo -v                                   # sudo, porque tecnico no está en el grupo docker
read -rs ODOO_PASSWORD && export ODOO_PASSWORD
```

1. **Ver qué haría, sin tocar nada:**
   ```bash
   python3 sincronizar-carta.py --simular | tee evidencias/01-simular.txt
   ```
2. **Sincronizar dos veces.** La segunda tiene que acabar en `0 nuevos, 0 actualizados, 12 sin cambios`:
   ```bash
   python3 sincronizar-carta.py | tee evidencias/02-sincronizar.txt
   python3 sincronizar-carta.py | tee -a evidencias/02-sincronizar.txt
   ```
3. **Cambiar un precio en `almi_chain` y comprobar que llega al TPV.** Lo cambia el propietario de las tablas, no la aplicación, y el disparador R-07 lo apunta en `historial_precio_plato`:
   ```bash
   sudo docker compose -f /opt/odoo/docker-compose.yml exec -T db psql -U odoo -d almi_chain \
     -c "UPDATE plato SET precio = 1.64 WHERE nombre = 'Café'"
   python3 sincronizar-carta.py | tee evidencias/03-cambio-de-precio.txt
   ```
   Tiene que salir `~ ALMI-12 Café: precio 1.71 → 1.80 €` y nada más. Captura del producto en el TPV con el precio nuevo: `evidencias/04-precio-en-el-tpv.png`.

Si `almi_chain` está en otro sitio, la orden de lectura se cambia con la variable `ALMI_PSQL`, y la de Odoo con `ODOO_URL`, `ODOO_DB` y `ODOO_USER` (como en la tarea 36).

## 4. Mejora (no hecha)

- [ ] Ejecutar los pasos 1 a 3 en `ServidorERP` y guardar las salidas y la captura en `evidencias/`.
- [ ] Si `informes` no puede entrar por el socket del contenedor (depende de `pg_hba.conf`), añadir `-h localhost` a `ALMI_PSQL` y la contraseña en `PGPASSWORD`.
