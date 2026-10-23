# Tarea 34 · Configurar módulos de Odoo

**Responsable (Kanban):** Markel · **Hecha por:** Iker · **Revisa:** Adrian · **Fecha:** 22/10/2026 · **Depende de:** 33
**Estado:** ✅ Hecha en máquina virtual

## 1. Resultado
Odoo 19 (servidor de la tarea 33) queda preparado para la tienda:

| Elemento | Configuración |
|---|---|
| Empresa | `Almi-Chain` (nombre provisional: se cambia con la variable `EMPRESA`) · España · EUR |
| Contabilidad | **Plan General Contable PYMES 2008** (`l10n_es`, plantilla `es_pymes`) · IVA de venta 21 % (`21% G`) |
| Aplicaciones | Facturación, Ventas, **CRM**, **Empleados**, **Email Marketing**, Inventario y Punto de Venta **en modo restaurante** (`pos_restaurant`), como pide el enunciado |
| Puntos de venta | **TPV Barra 1** y **TPV Barra 2** (modo restaurante), uno por cada TPV físico de la tarea 7 |
| Formas de pago | `Efectivo TPV 1` → diario `Caja TPV 1` · `Efectivo TPV 2` → diario `Caja TPV 2` · `Tarjeta` (común) → diario `Bank` |
| Usuarios | `gerente` (todo) · `cajero1` y `cajero2` (solo TPV) |

## 2. Cómo se hace
Todo por la API de Odoo (XML-RPC), sin clics, con [`configurar-odoo.py`](configurar-odoo.py). Es reproducible e idempotente.

```bash
ODOO_URL=http://localhost:8069 ODOO_DB=tienda \
ODOO_ADMIN_PASSWORD=<la de /opt/odoo/.env> EMPRESA="Nombre real de la tienda" \
python3 configurar-odoo.py
```
- Log de la ejecución: [`evidencias/salida-configurar-odoo.log`](evidencias/salida-configurar-odoo.log).
- Segunda ejecución sin cambios (idempotencia): [`evidencias/segunda-ejecucion.txt`](evidencias/segunda-ejecucion.txt).
- Las contraseñas de los usuarios nuevos se generan al azar y se guardan en `.credenciales-usuarios` (permisos `600`). **No se suben al repositorio.**

Orden importante: **primero se pone España como país de la empresa y después se instala Facturación**.
Así Odoo instala solo la localización española (`l10n_es`) y el plan contable PYMES.

## 3. Usuarios y mínimos privilegios

| Usuario | Grupos | Para qué |
|---|---|---|
| `admin` | Administrador | Solo mantenimiento. Contraseña en `/opt/odoo/.env`. |
| `gerente` | Usuario interno + Responsable de TPV, Ventas e Inventario + Administrador de Facturación + Productos / Crear | Gestión diaria de la tienda y del catálogo |
| `cajero1` | Usuario interno + **TPV: usuario** | Cobrar en el TPV 1 |
| `cajero2` | Usuario interno + **TPV: usuario** | Cobrar en el TPV 2 |

Permisos del cajero, comprobados con la API ([`evidencias/pruebas-permisos.txt`](evidencias/pruebas-permisos.txt)):

| Qué | Leer | Modificar | Crear | Borrar |
|---|---|---|---|---|
| Pedidos del TPV (`pos.order`) | ✅ | ✅ | ✅ | ✅* |
| Facturas, plan contable y diarios | ✅ | ⛔ | ⛔ | ⛔ |
| Productos | ✅ | ⛔ | ⛔ | ⛔ |
| Usuarios y grupos | ✅ | ⛔ | ⛔ | ⛔ |
| Pedidos de venta del back-office (`sale.order`) | ⛔ "Póngase en contacto con su administrador" | | | |

\* Odoo no deja borrar pedidos que ya están pagados.

El cajero puede **leer** la contabilidad porque el TPV la necesita para hacer facturas y tickets, pero **no puede cambiar nada**:
ni precios, ni facturas, ni permisos.
Ni el gerente ni los cajeros pueden crear usuarios: solo `admin`.

## 4. Comprobación visual (para el revisor)
Entrar en <http://localhost:8069> como `admin` y sacar captura de:
1. **Punto de Venta**: aparecen las tarjetas *TPV 1* y *TPV 2*.
2. **Ajustes → Usuarios**: aparecen `gerente`, `cajero1` y `cajero2`.
3. **Facturación → Configuración → Impuestos**: aparece *21% G*.
4. Entrar como `cajero1`: solo se ve la aplicación **Punto de Venta**.

## 5. Incidencias

| # | Incidencia | Causa | Solución |
|---|---|---|---|
| 1 | `IndexError` al buscar la moneda EUR | EUR viene **desactivada** de serie y las búsquedas ignoran lo inactivo | Buscar con el contexto `active_test=False` y activarla |
| 2 | "Punto de Venta no ha creado ningún TPV" | Odoo 19 ya no crea un TPV de ejemplo al instalarse | El script crea los diarios de caja, las formas de pago y los dos TPV |
| 3 | No se puede compartir el efectivo entre TPV | En Odoo, cada forma de pago en efectivo va ligada a una caja y solo puede estar en un TPV | Una caja y un método `Efectivo` por TPV. La `Tarjeta` sí se comparte. |
| 4 | `localhost:8069` enseñaba una web de ejemplo ("My Website", "Your Logo") en vez del panel | Se activó a mano la app **Sitio web** desde *Aplicaciones*, y Odoo pasa a usar la web pública como página de inicio | Desinstalar `website` (y sus dependencias `website_sms`, `website_mail` y `website_payment`). La web de la tienda va aparte, en AWS (tareas 27–31), y así no queda una página pública de más. El panel también está siempre en `/odoo`. |
| 5 | En el login apareció **"¿No tiene una cuenta?"**: cualquiera podía registrarse | Al instalar el Sitio web, Odoo pone `auth_signup.invitation_scope = b2c` (registro libre), y al desinstalarlo se queda así | Puesto a `b2b` (solo por invitación). Ahora `/web/signup` → 404 y se comprobó que nadie se había registrado. Añadido a `configurar-odoo.py`. |

## 6. Decisión pendiente para el equipo: TicketBAI / Veri*Factu
La ley obliga a que el software de facturación envíe las facturas a Hacienda:
- En **Euskadi** (Araba, Bizkaia, Gipuzkoa): **TicketBAI**. Odoo tiene el módulo `l10n_es_edi_tbai`.
- En el resto de España: **Veri\*Factu** (`l10n_es_edi_verifactu`).

Los dos módulos están disponibles en este Odoo, pero **no se han instalado** porque necesitan un certificado digital de la empresa
y, en las pruebas, el entorno de test de Hacienda. Hay que decidir cuál aplica y si se configura en modo de pruebas
(preguntárselo al profesor en la tarea 6).

## 7. Siguientes tareas
- **35 · Caso de uso automatizado (Adrian):** emitir una factura por la API. Ya están la empresa, el IVA, los diarios y los usuarios.
- **36 · Importar/exportar (Peio):** importar el catálogo de productos (CSV → `product.template`, con `available_in_pos = True`).
- **37 · Ticket (Eneko.P):** asociar la impresora de la tarea 14 al TPV 1 (*Punto de Venta → Configuración → TPV 1 → Impresora de recibos*).
