# Tarea 36: Importar y exportar datos en Odoo

- **Bloque:** 7 ERP
- **Responsable:** Eneko.P (desde el 26/10; el script y el CSV los hizo Iker el 24/10)
- **Depende de:** tarea 34 (Odoo configurado, usuario `gerente`)
- **Resultado de aprendizaje:** RA.7 de LMSGI, «trabaja con sistemas empresariales de gestión de información realizando tareas de **importación, integración, aseguramiento y extracción** de la información»
- **Estado (10/11/2026):** 🟡 Paso 1 hecho en la VM `ServidorERP` del laboratorio de Adrian el 10/11 (sección 3.1): la carta entra en Odoo 19 sin errores. **Faltan los pasos 2 a 6** (Eneko.P), sobre todo la exportación (sección 4).

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
4. **Comprobar en el TPV** que la carta aparece por categorías (captura `evidencias/04-carta-en-el-tpv.png`).
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

## 4. Pendiente

- [x] Paso 1, importar la carta (10/11, laboratorio, sección 3.1). Los campos de producto de Odoo 19 funcionan.
- [ ] Pasos 2 a 6 (Eneko.P, unos 20 min): reimportar (`0 nuevos, 14 actualizados`), probar la validación con un CSV con errores, captura de la carta en el TPV, exportar y la ida y vuelta. Si `export_data` falla en Odoo 19, apuntar el error aquí.
