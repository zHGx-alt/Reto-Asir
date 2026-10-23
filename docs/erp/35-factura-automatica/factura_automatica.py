#!/usr/bin/env python3
"""
Tarea 35 · Caso de uso de principio a fin automatizado: emitir una factura en Odoo.

Hace por la API (XML-RPC), sin clics, el mismo recorrido que haría el gerente a mano:
  1. Busca o crea el cliente
  2. Busca o crea el producto
  3. Crea el pedido de venta y lo confirma
  4. Genera la factura y la valida (asiento contable con IVA 21 %)
  5. Registra el cobro
  6. Descarga el PDF de la factura

Uso:
  ODOO_URL=http://localhost:8069 ODOO_DB=tienda ODOO_USER=gerente ODOO_PASSWORD=... \
  python3 factura_automatica.py --cliente "Cliente de prueba" --producto "Partida recreativa" --precio 2.50 --cantidad 4

Se ejecuta con el usuario "gerente", no con admin (mínimos privilegios).
"""
import argparse
import http.cookiejar
import json
import os
import sys
import urllib.request
import xmlrpc.client

URL = os.environ.get("ODOO_URL", "http://localhost:8069")
DB = os.environ.get("ODOO_DB", "tienda")
USUARIO = os.environ.get("ODOO_USER", "gerente")
PASSWORD = os.environ["ODOO_PASSWORD"]

p = argparse.ArgumentParser(description="Emite una factura de principio a fin en Odoo")
p.add_argument("--cliente", default="Cliente de prueba")
p.add_argument("--email", default="cliente.prueba@example.com")
p.add_argument("--producto", default="Partida recreativa")
p.add_argument("--precio", type=float, default=2.50, help="precio sin IVA")
p.add_argument("--cantidad", type=float, default=4)
p.add_argument("--pdf-dir", default=".")
args = p.parse_args()

uid = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/common").authenticate(DB, USUARIO, PASSWORD, {})
if not uid:
    sys.exit(f"No se pudo iniciar sesión como {USUARIO}")
obj = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/object", allow_none=True)


def x(modelo, metodo, *a, **kw):
    return obj.execute_kw(DB, uid, PASSWORD, modelo, metodo, list(a), kw)


def boton(modelo, metodo, *a, **kw):
    """Pulsa un botón de Odoo. Algunos devuelven una acción de pantalla con valores None que XML-RPC
    no sabe enviar: el botón ya se ha ejecutado, así que ese error se ignora y el resultado se comprueba después."""
    try:
        return x(modelo, metodo, *a, **kw)
    except xmlrpc.client.Fault as e:
        if "cannot marshal None" not in e.faultString:
            raise


def paso(n, texto):
    print(f"[{n}/6] {texto}", flush=True)


# 1. Cliente
cliente = x("res.partner", "search", [["name", "=", args.cliente]], limit=1)
cliente = cliente[0] if cliente else x("res.partner", "create", {
    "name": args.cliente, "email": args.email,
    "country_id": x("res.country", "search", [["code", "=", "ES"]])[0]})
paso(1, f"Cliente: {args.cliente} (id {cliente})")

# 2. Producto: es un servicio (una partida), así que lleva el IVA 21 % de SERVICIOS ("21% S"), no el de bienes ("21% G").
#    En la localización española la diferencia importa para la declaración del IVA (modelo 303).
iva21 = x("account.tax", "search", [["type_tax_use", "=", "sale"], ["amount", "=", 21],
                                     ["amount_type", "=", "percent"], ["tax_scope", "=", "service"]], limit=1)
producto = x("product.product", "search", [["name", "=", args.producto]], limit=1)
if producto:
    producto = producto[0]
    x("product.product", "write", [producto], {"taxes_id": [(6, 0, iva21)]})
else:
    plantilla = x("product.template", "create", {
        "name": args.producto, "type": "service", "list_price": args.precio,
        "invoice_policy": "order", "taxes_id": [(6, 0, iva21)], "available_in_pos": True})
    producto = x("product.product", "search", [["product_tmpl_id", "=", plantilla]])[0]
nombre_iva = x("account.tax", "read", iva21, fields=["name"])[0]["name"]
paso(2, f"Producto: {args.producto} a {args.precio:.2f} € + IVA {nombre_iva} (id {producto})")

# 3. Pedido de venta
pedido = x("sale.order", "create", {
    "partner_id": cliente,
    "order_line": [(0, 0, {"product_id": producto, "product_uom_qty": args.cantidad, "price_unit": args.precio})]})
boton("sale.order", "action_confirm", [pedido])
p_info = x("sale.order", "read", [pedido], fields=["name", "state", "amount_total"])[0]
paso(3, f"Pedido {p_info['name']} confirmado ({p_info['state']}), total {p_info['amount_total']:.2f} €")

# 4. Factura: asistente "Crear factura" del pedido y validación
asistente = x("sale.advance.payment.inv", "create", {"advance_payment_method": "delivered",
                                                      "sale_order_ids": [(6, 0, [pedido])]})
boton("sale.advance.payment.inv", "create_invoices", [asistente])
factura = x("sale.order", "read", [pedido], fields=["invoice_ids"])[0]["invoice_ids"][-1]
boton("account.move", "action_post", [factura])
f_info = x("account.move", "read", [factura],
           fields=["name", "state", "amount_untaxed", "amount_tax", "amount_total", "invoice_date"])[0]
paso(4, f"Factura {f_info['name']} validada el {f_info['invoice_date']}: "
        f"base {f_info['amount_untaxed']:.2f} € + IVA {f_info['amount_tax']:.2f} € = {f_info['amount_total']:.2f} €")

# 5. Cobro: asistente "Registrar pago"
ctx = {"active_model": "account.move", "active_ids": [factura]}
pago = x("account.payment.register", "create", {}, context=ctx)
boton("account.payment.register", "action_create_payments", [pago], context=ctx)
estado_pago = x("account.move", "read", [factura], fields=["payment_state"])[0]["payment_state"]
paso(5, f"Cobro registrado: estado de pago '{estado_pago}'")

# 6. PDF (el informe se descarga por HTTP con una sesión web)
cookies = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(http.cookiejar.CookieJar()))
cuerpo = json.dumps({"jsonrpc": "2.0", "params": {"db": DB, "login": USUARIO, "password": PASSWORD}}).encode()
cookies.open(urllib.request.Request(f"{URL}/web/session/authenticate", cuerpo,
                                    {"Content-Type": "application/json"}))
pdf = cookies.open(f"{URL}/report/pdf/account.report_invoice/{factura}").read()
if not pdf.startswith(b"%PDF"):
    sys.exit("El servidor no devolvió un PDF")
ruta = os.path.join(args.pdf_dir, f"{f_info['name'].replace('/', '_')}.pdf")
with open(ruta, "wb") as f:
    f.write(pdf)
paso(6, f"PDF guardado en {ruta} ({len(pdf) // 1024} KB)")
print(f"\nOK · {p_info['name']} → {f_info['name']} · {f_info['amount_total']:.2f} € · {estado_pago}")
