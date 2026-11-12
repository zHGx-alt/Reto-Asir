# Tarea 36: Importar y exportar datos en Odoo

- **Bloque:** 7 ERP
- **Responsable:** Eneko.P (desde el 26/10; el script y el CSV los hizo Iker el 24/10)
- **Depende de:** tarea 34 (Odoo configurado, usuario `gerente`)
- **Resultado de aprendizaje:** RA.7 de LMSGI, «trabaja con sistemas empresariales de gestión de información realizando tareas de **importación, integración, aseguramiento y extracción** de la información»
- **Estado (12/11/2026):** ✅ Los seis pasos hechos en la VM `ServidorERP` del laboratorio de Adrian: el paso 1 el 10/11 (sección 3.1) y los pasos 2 a 6 el 12/11 con el usuario `gerente` (sección 3.2). Para exportar, `gerente` necesita el grupo «Permitir exportar» de Odoo 19 (sección 3.3).

## 1. Qué se hace

| RA.7 | Cómo |
|---|---|
| **Importación** | La carta real ([`carta.csv`](carta.csv): 14 productos en 5 categorías, los mismos platos que la web y la BD `almi_chain`) entra en el TPV de Odoo con su PVP e IVA del 10 % incluido |
| **Integración** | Se hace por la API de Odoo (XML-RPC), no a mano: el mismo CSV sirve para actualizar precios cuando cambie la carta, sin duplicar productos |
| **Aseguramiento** | Se ejecuta con el usuario `gerente`, no con `admin`; se validan los datos (precio numérico y no negativo, columnas obligatorias) y se informa de cada fila; las exportaciones, que llevan datos personales, no entran en Git (`.gitignore`) |
| **Extracción** | Carta, clientes, pedidos del TPV y facturas a CSV que se abren con doble clic en Excel (UTF-8 con BOM y separador «;»), por ejemplo para la gestoría |

## 2. Archivos

| Archivo | Qué es |
|---|---|
| [`carta.csv`](carta.csv) | Carta real: `categoria;producto;pvp_con_iva;descripcion` |
| [`importar-exportar.py`](importar-exportar.py) | `importar <csv>` y `exportar <carpeta>`. Solo usa la biblioteca estándar de Python |
| [`carta-con-errores.csv`](carta-con-errores.csv) | La carta con `abc` en el precio de la Gilda y `-15` en el del Marmitako, para el paso 3 |
| [`ver-carta.py`](ver-carta.py) | Paso 4: lista la carta del TPV por categorías y comprueba que no hay productos duplicados |
| [`permiso-exportar.py`](permiso-exportar.py) | Lo ejecuta `admin` una vez: da a `gerente` el grupo «Permitir exportar» (sección 3.3). La clave de `admin` entra por la entrada estándar, no por la línea de órdenes |

## 3. Procedimiento

En el servidor (o en cualquier equipo que llegue a Odoo), con la contraseña de `gerente` sacada de KeePassXC:

```bash
export ODOO_URL=http://localhost:8069 ODOO_DB=tienda ODOO_USER=gerente
read -rs ODOO_PASSWORD && export ODOO_PASSWORD
```

```bash
cd docs/erp/36-importar-exportar && mkdir -p evidencias
```

1. **Importar la carta:**
   ```bash
   python3 importar-exportar.py importar carta.csv | tee evidencias/01-importar.txt
   ```
   Tiene que acabar con `14 nuevos, 0 actualizados, 0 con errores` (o «actualizados» si ya existían).
2. **Repetirlo** para demostrar que no duplica: `… importar carta.csv | tee evidencias/02-reimportar.txt` → `0 nuevos, 14 actualizados`.
3. **Probar la validación:** copiar `carta.csv`, poner `abc` en un precio y un precio negativo en otro e importarlo → esas filas salen como `ERROR` y el resto se importa (`evidencias/03-errores.txt`).
4. **Comprobar en el TPV** que la carta aparece por categorías: `python3 ver-carta.py | tee evidencias/04-carta-en-el-tpv.txt` (o una captura del TPV).
5. **Exportar:**
   ```bash
   python3 importar-exportar.py exportar exportaciones-$(date +%Y%m%d) | tee evidencias/05-exportar.txt
   ```
   Abrir `carta.csv` y `facturas.csv` en Excel o LibreOffice (captura). **No subir la carpeta de exportación**: solo la salida del comando.
6. **Ida y vuelta:** importar el `carta.csv` exportado → `0 nuevos, 14 actualizados`: el formato de exportación sirve para volver a importar.

### 3.1 Ejecución del paso 1 (10/11/2026, laboratorio)

En la VM `ServidorERP` (Odoo 19, base `tienda`), con el script y el CSV tal cual están en el repositorio:

```text
Importación: 8 nuevos, 6 actualizados, 0 con errores (14 filas en carta.csv).
```

Salida completa: [`evidencias/01-importar-2026-11-10.txt`](evidencias/01-importar-2026-11-10.txt). Seis productos ya existían con el mismo nombre (menú del día, tarta de queso, caña, agua y los dos cafés, de la carta de ejemplo de la [tarea 34](../34-configurar-odoo/DOCUMENTACION.md#81-carta-salas-y-mesas-de-ejemplo)) y el script los **actualizó en vez de duplicarlos**; los otros ocho son nuevos. Los productos de ejemplo que no están en la carta real siguen en Odoo. Los nombres de campo de Odoo 19 (`pos_categ_ids`, `available_in_pos`, `description_sale`) funcionan sin cambios.

> Se ejecutó con el usuario `admin` porque la contraseña de `gerente` está en el KeePassXC del equipo, no en la VM. En el servidor del equipo se hace con `gerente`, como dice el procedimiento.

**Alternativa sin script (interfaz de Odoo):** *Punto de venta → Productos → ⚙ → Importar registros* con el mismo CSV; Odoo pide asociar cada columna a un campo. Sirve para enseñarlo en la defensa, pero no es repetible ni valida los datos como el script.

### 3.2 Ejecución de los pasos 2 a 6 (12/11/2026, laboratorio)

En la misma VM, ya con el usuario `gerente` (su contraseña se leyó de `/root/.credenciales-usuarios` de la VM, sin mostrarla). Antes se sacó la instantánea `antes-tarea36-pasos2-6-2026-11-12`.

| Paso | Resultado | Evidencia |
|---|---|---|
| 2. Reimportar | `0 nuevos, 14 actualizados, 0 con errores`: no duplica | [`02-reimportar-2026-11-12.txt`](evidencias/02-reimportar-2026-11-12.txt) |
| 3. CSV con errores | `0 nuevos, 12 actualizados, 2 con errores`: `ERROR línea 2: precio no válido «abc»` y `ERROR línea 7: precio no válido «-15»`; el script acaba con código 1. Después se volvió a importar `carta.csv` para dejar bien los dos precios | [`03-errores-2026-11-12.txt`](evidencias/03-errores-2026-11-12.txt) |
| 4. Carta en el TPV | 23 productos en 5 categorías (Cafés, Bebidas, Entrantes, Platos, Postres). Los 14 de `carta.csv` están una sola vez; los otros 9 son la carta de ejemplo de la tarea 34 | [`04-carta-en-el-tpv-2026-11-12.txt`](evidencias/04-carta-en-el-tpv-2026-11-12.txt) |
| 5. Exportar | Primer intento: `No tienes permisos para exportar datos` (sección 3.3). Con el permiso: `carta.csv` 23 filas, `clientes.csv` 6, `ventas-tpv.csv` 8 y `facturas.csv` 0. Los cuatro con BOM UTF-8 y «;» | [`05a-permiso-exportar-2026-11-12.txt`](evidencias/05a-permiso-exportar-2026-11-12.txt), [`05-exportar-2026-11-12.txt`](evidencias/05-exportar-2026-11-12.txt) |
| 6. Ida y vuelta | El `carta.csv` exportado se vuelve a importar: `0 nuevos, 23 actualizados, 0 con errores`. El formato de exportación sirve de entrada | [`06-ida-y-vuelta-2026-11-12.txt`](evidencias/06-ida-y-vuelta-2026-11-12.txt) |

Observaciones:

- **La ida y vuelta da 23 y no 14** porque la exportación saca todo lo que está a la venta en el TPV, también los 9 productos de ejemplo de la tarea 34. Ninguno se duplica.
- **`facturas.csv` sale vacío** porque en esta VM no hay facturas de cliente publicadas (las ventas del TPV no generan una por pedido y el presupuesto `S00001` de la tarea 63 no se ha facturado). La cabecera sale bien, y en cuanto haya una factura publicada (como las de la tarea 35) aparece.
- El estado de los pedidos sale como etiqueta de Odoo en inglés (`Posted`), no traducida.
- La carpeta `exportaciones-20261112/` se quedó en la VM: lleva nombres y correos (aunque sean de ejemplo) y `.gitignore` la excluye.

### 3.3 Permiso para exportar en Odoo 19

En Odoo 19 exportar datos no viene con los permisos de un usuario interno: hace falta el grupo **«Permitir exportar»** (`base.group_allow_export`). `gerente` no lo tenía y `export_data` respondía `No tienes permisos para exportar datos. Ponte en contacto con un administrador.` Se le da con `admin`, una vez:

```bash
python3 permiso-exportar.py < fichero-con-la-clave-de-admin   # o escribiéndola y Ctrl+D
```

A mano: *Ajustes → Usuarios → gerente → Permitir exportar*. Solo `gerente` lo tiene; los cajeros no, porque las exportaciones llevan datos personales (mínimos privilegios).

**Hay que hacerlo también en el servidor del equipo**, que se configuró con el mismo `configurar-odoo.py` de la tarea 34 y tampoco le da ese grupo a `gerente`.

## 4. Pendiente

- [x] Paso 1, importar la carta (10/11, laboratorio, sección 3.1). Los campos de producto de Odoo 19 funcionan.
- [x] Pasos 2 a 6 (12/11, laboratorio, sección 3.2). `export_data` funciona en Odoo 19 con el grupo «Permitir exportar».
- [ ] Dar a `gerente` el grupo «Permitir exportar» en el servidor del equipo (sección 3.3).
