# Tarea 34 · Configurar módulos de Odoo

**Responsable:** Iker (hecha por Iker; antes estaba a nombre de Markel) · **Fecha:** 22/10/2026 · **Depende de:** 33
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

## 4. Comprobación visual
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

## 6. Facturación electrónica: TicketBAI (Batuz)
La ley obliga a que el software de facturación envíe las facturas a Hacienda:
- En **Euskadi** (Araba, Bizkaia, Gipuzkoa): **TicketBAI**. En Bizkaia, dentro del sistema **Batuz** de la Hacienda Foral. Odoo tiene el módulo `l10n_es_edi_tbai`.
- En el resto de España: **Veri\*Factu** (`l10n_es_edi_verifactu`).

**Decisión:** el restaurante está en **Bilbao** (web y tarea 41), así que le aplica **TicketBAI (Batuz)**, no Veri\*Factu. Sin TicketBAI el restaurante no podría facturar legalmente.

**Por qué no se configura en el reto:** el módulo pide el **certificado digital de la empresa** (y, para probar, el entorno de pruebas de la Hacienda Foral de Bizkaia, con su propio certificado). No tenemos ninguno, y no se puede inventar. Queda documentado así: en la instalación real, el gerente aporta el certificado, se instala `l10n_es_edi_tbai`, se elige «Bizkaia» como hacienda y se prueba una factura en el entorno de pruebas antes de pasar a producción. **Decisión del equipo (24/10/2026):** no hace falta configurarlo en el reto; queda documentado como obligación legal.

## 7. Siguientes tareas
- **35 · Caso de uso automatizado (Iker):** emitir una factura por la API. Ya están la empresa, el IVA, los diarios y los usuarios.
- **36 · Importar/exportar (Iker):** importar el catálogo de productos (CSV → `product.template`, con `available_in_pos = True`).
- **37 · Ticket (Peio):** asociar la impresora de la tarea 14 al TPV 1 (*Punto de Venta → Configuración → TPV 1 → Impresora de recibos*).

## 8. Prueba completa del TPV de barra (23/10/2026)

### 8.1 Carta, salas y mesas de ejemplo
Script: [`cargar-carta-y-mesas.py`](cargar-carta-y-mesas.py) (log: [`evidencias/salida-carta-y-mesas.log`](evidencias/salida-carta-y-mesas.log)).

| | |
|---|---|
| Carta | 15 productos en 5 categorías (Cafés, Bebidas, Entrantes, Platos, Postres). **Es de ejemplo**: la carta real se importa en la tarea 36 |
| IVA | **10 % de hostelería con el IVA incluido en el precio** (`10% S (IVA incluido)`): el PVP de la carta es exactamente lo que se cobra |
| Salas | **Sala** (mesas 1-6, 4 comensales) y **Barra** (puestos 11-14), en los dos TPV |
| Precios en pantalla | Con IVA incluido (`iface_tax_included = total`) |

### 8.2 Venta real desde la pantalla, como `cajero1`

| # | Paso | Resultado | Captura |
|---|---|---|---|
| 1 | Entrar como `cajero1` | Solo ve Conversaciones, Calendario, Contactos, Tableros, **Punto de venta**, Empleados y Aplicaciones. **No** ve Ventas, Facturación, Inventario ni Ajustes | [01](evidencias/tpv/01-apps-que-ve-el-cajero.jpg) |
| 2 | Abrir la caja del TPV Barra 1 con **100 €** de cambio | Sala con las mesas 1-6 | [02](evidencias/tpv/02-caja-abierta-sala.jpg) |
| 3 | Mesa 3: 2 menús del día, 2 cañas y 1 café | **35,50 €** (IVA incluido 3,23 €) | [03](evidencias/tpv/03-pedido-mesa-3.jpg) |
| 4 | Cobro en efectivo con 40 € | **Cambio 4,50 €** | [04](evidencias/tpv/04-cobro-efectivo-cambio.jpg) |
| 5 | Validar | Ticket = **factura simplificada 262-1-000001**, mesa 3, 4 comensales, base 32,27 € + IVA 10 % 3,23 €, QR para pedir factura completa | [05](evidencias/tpv/05-ticket-factura-simplificada.jpg) |
| 6 | Cierre de caja | Esperado **135,50 €** (100 + 35,50), contado 135,50 €, **diferencia 0,00 €** | [06](evidencias/tpv/06-cierre-de-caja-cuadrado.jpg) |
| 7 | Comprobación en el servidor | Sesión `TPV Barra 1/00001` cerrada; pedido `done`; **asiento contable `POSS/2026/10/0001` validado**: Clientes (TPV) 35,50 debe / Ventas 32,27 haber / IVA repercutido 3,23 haber | [07](evidencias/tpv/07-comprobacion-servidor.txt) |

### 8.3 Incidencias de la prueba

| # | Incidencia | Causa | Solución |
|---|---|---|---|
| 6 | **2 cañas a 2,50 € salían 4,99 €** (total 35,49 € en vez de 35,50 €) | El precio se guardaba **sin IVA** y Odoo lo redondea a 2 decimales: 2,50 / 1,10 = 2,2727 → 2,27; al sumar el IVA a 2 unidades se pierde 1 céntimo | Impuesto **`10% S (IVA incluido)`** (`price_include_override = tax_included`) y precio = PVP. Es lo correcto en hostelería, donde los precios al público llevan el IVA. El pedido erróneo quedó **cancelado** (`261-1-000001`) |
| 7 | Con la caja abierta, el script no podía cambiar la carta ni las salas (*"Please close and validate the following open PoS Session"*) | Odoo bloquea los cambios de configuración del TPV durante un turno | El script lo detecta y avisa. Con la caja abierta solo actualiza precio e impuesto, y el TPV coge los cambios con **≡ → Volver a cargar datos → Completo** |
| 8 | Aviso *"Failed to register a ServiceWorker"* al abrir el TPV | El *service worker* es lo que deja al TPV **seguir cobrando sin red**, y los navegadores **solo lo permiten con HTTPS** (o en `localhost`) | El TPV funciona igual, pero **en los TPV reales, que entran por `http://IP:8069`, no habrá modo sin conexión hasta que Odoo tenga HTTPS** (tarea 46). Es otro motivo para el proxy HTTPS |
| 9 | Almacén llamado "Tienda Reto ASIR" y una sala "Almi-Chain" de más en cada TPV | El almacén se creó con el nombre provisional de la empresa; `pos_restaurant` crea una sala por TPV | Almacén renombrado a Almi-Chain (`configurar-odoo.py`) y salas sobrantes archivadas (`cargar-carta-y-mesas.py`) |
| 10 | En una base nueva, `configurar-odoo.py` fallaba en el paso 1: *Object stock.warehouse doesn't exist* (prueba en limpio del 23/10, Adrian) | El renombrado del almacén se hacía antes de instalar Inventario; en la VM ya estaba instalado y no se notaba | Se renombra después de instalar los módulos |
| 11 | En una base nueva, `cargar-carta-y-mesas.py` fallaba al crear el primer producto: *unhashable type: 'list'* | En Odoo 19, `copy` devuelve por la API una lista de ids y el script la metía en otra lista al crear el IVA 10 % incluido | Se acepta un id o una lista. Instalación limpia completa repetida: [`evidencias/prueba-instalacion-limpia.txt`](evidencias/prueba-instalacion-limpia.txt) |

## 9. Pendiente: lo que ve el cajero

En la prueba 1 de la sección 8.2, `cajero1` ve **Contactos, Empleados, Conversaciones, Calendario y Tableros**, y puede leer facturas, diarios y usuarios. Para cobrar no le hace falta: ve datos de los clientes y del personal, y eso va contra los mínimos privilegios. Viene de que todo «Usuario interno» (`base.group_user`) tiene esos menús.

**Script preparado:** [`restringir-menus-cajero.py`](restringir-menus-cajero.py) aplica la opción 1 (grupo «Almi-Chain / Gerencia» con admin y gerente en los menús raíz) y se puede deshacer con `--deshacer`. Falta ejecutarlo en una base de pruebas y repetir la prueba 1.

Opciones, por orden de preferencia:

1. **Ocultar los menús** a quien no sea gerente: en `ir.ui.menu`, poner en los menús raíz de Contactos, Empleados, Conversaciones, Calendario y Tableros el grupo «Gerencia» (un grupo nuevo que tenga `gerente`). El cajero deja de verlos.
2. **Quitar las apps que no se usan** (Conversaciones, Calendario, Tableros), si nadie las necesita.
3. Para lectura de datos (no solo menús), revisar las reglas de acceso de `res.partner` y `hr.employee` para el grupo del cajero.

Comprobarlo repitiendo la prueba 1 con una captura nueva.
