# Tarea 35 · Caso de uso de principio a fin automatizado: emitir una factura

**Responsable (Kanban):** Adrian · **Hecha por:** Iker · **Revisa:** Iker → *cambiar a otro revisor* · **Fecha:** 22/10/2026 · **Depende de:** 34
**Estado:** ✅ Hecha en máquina virtual

> El reto pide *"Elección e implementación del ERP + TPV, automatizando al menos un caso de uso real (p. ej. emisión de una factura)"*.

## 1. Resultado
El script [`factura_automatica.py`](factura_automatica.py) emite una factura completa sin tocar la pantalla, en menos de 10 segundos:

```
[1/6] Cliente: Cliente de prueba (id 10)
[2/6] Producto: Partida recreativa a 2.50 € + IVA 21% S (id 6)
[3/6] Pedido S00004 confirmado (sale), total 12.10 €
[4/6] Factura INV/2026/00002 validada el 2026-10-22: base 10.00 € + IVA 2.10 € = 12.10 €
[5/6] Cobro registrado: estado de pago 'paid'
[6/6] PDF guardado en tarea-35/evidencias/INV_2026_00002.pdf (24 KB)

OK · S00004 → INV/2026/00002 · 12.10 € · paid
```

![Factura generada](evidencias/factura-2-1.png)

PDF: [`evidencias/INV_2026_00002.pdf`](evidencias/INV_2026_00002.pdf).

## 2. Qué hace (el mismo recorrido que el gerente a mano)

| Paso | En pantalla sería… | Por la API |
|---|---|---|
| 1. Cliente | *Contactos → Nuevo* | `res.partner` · `search` / `create` |
| 2. Producto | *Ventas → Productos → Nuevo* | `product.template` · `create` (servicio, IVA 21 % S, disponible en el TPV) |
| 3. Pedido | *Ventas → Nuevo → Confirmar* | `sale.order` · `create` + `action_confirm` |
| 4. Factura | *Crear factura → Confirmar* | asistente `sale.advance.payment.inv` · `create_invoices` + `account.move` · `action_post` |
| 5. Cobro | *Registrar pago* | asistente `account.payment.register` · `action_create_payments` |
| 6. PDF | *Imprimir → Factura* | `GET /report/pdf/account.report_invoice/<id>`, con una sesión web |

## 3. Cómo se usa
```bash
ODOO_URL=http://localhost:8069 ODOO_DB=tienda ODOO_USER=gerente ODOO_PASSWORD=<contraseña de gerente> \
python3 factura_automatica.py --cliente "Bar Pepe" --producto "Alquiler recreativa (día)" --precio 40 --cantidad 1
```
Opciones: `--cliente`, `--email`, `--producto`, `--precio` (sin IVA), `--cantidad` y `--pdf-dir`.

**Seguridad:**
- Se ejecuta con el usuario **`gerente`**, no con `admin` (mínimos privilegios).
- La contraseña va en una variable de entorno, nunca escrita en el script.
- Solo usa librerías estándar de Python, sin dependencias externas.

## 4. Pruebas

| # | Prueba | Resultado |
|---|---|---|
| 1 | Ejecución completa | ✅ Pedido confirmado, factura validada y cobrada, PDF descargado |
| 2 | Importes | ✅ 4 × 2,50 € = 10,00 € + IVA 21 % 2,10 € = 12,10 € |
| 3 | Numeración | ✅ Correlativa: `INV/2026/00001`, `INV/2026/00002` |
| 4 | Ejecución repetida | ✅ Reutiliza el cliente y el producto y crea un pedido y una factura nuevos |
| 5 | Permisos | ✅ Con `gerente` funciona. Sin el grupo *Productos / Crear*, Odoo lo impide (ver incidencia 1) |

## 5. Incidencias

| # | Incidencia | Causa | Solución |
|---|---|---|---|
| 1 | `No puede crear informes 'Product'` | En Odoo 19, crear productos necesita el grupo **Productos / Crear** (`product.group_product_manager`), y el gerente no lo tenía | Añadido al gerente en `configurar-odoo.py` (tarea 34). Los cajeros siguen sin él. |
| 2 | `cannot marshal None unless allow_none is enabled` al crear la factura | El botón *Crear factura* **sí se ejecuta**, pero devuelve una acción de pantalla con valores `None` que XML-RPC no puede enviar | Función `boton()`: ignora solo ese error concreto y el resultado se comprueba leyendo los datos. El intento fallido dejó una factura en borrador (eliminada) y el pedido S00002 (cancelado). |
| 3 | La primera factura (`INV/2026/00001`) salió con **IVA 21 % G (bienes)** | El script cogía el primer impuesto del 21 % que encontraba | Ahora elige el IVA según el tipo de producto (`tax_scope = service` → **21 % S**). La 00001 queda como factura de prueba: una factura validada no se borra; si hiciera falta, se anula con una **factura rectificativa**. |

## 6. Ideas para ampliarlo
- **Automatizar dentro de Odoo:** que cada pedido del TPV genere la factura solo (*Punto de Venta → Configuración → Facturación*) o una acción automática.
- **Programarlo:** un `systemd timer` o un trabajo de GitHub Actions que facture cada mes los alquileres de recreativas.
- **TicketBAI / Veri\*Factu:** ver la tarea 34, §6. Con el módulo instalado, `action_post` enviaría además la factura a Hacienda.
