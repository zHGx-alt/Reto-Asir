#!/usr/bin/env python3
"""
Tarea 63 · Usa con datos los módulos de Odoo que solo estaban instalados: CRM, Ventas, Empleados,
Marketing por correo e Inventario, con el caso del restaurante de GUIA.md.

Se puede repetir: busca cada registro por nombre antes de crearlo y no duplica. Lo que hace:
  0. (admin) da a gerente Empleados: Administrador y Marketing por correo: Usuario.
  1-5. (gerente) el resto, con mínimos privilegios.

Uso (en el servidor, como root; las contraseñas se leen de /root/.credenciales-usuarios y de
/opt/odoo/.env y no se muestran):
  sudo bash -c 'set -a; . /opt/odoo/.env; python3 caso-63.py' | tee 63-caso-$(date +%F).txt
"""
import datetime
import os
import sys
import xmlrpc.client

URL = os.environ.get("ODOO_URL", "http://localhost:8069")
DB = os.environ.get("ODOO_DB", "tienda")
with open("/root/.credenciales-usuarios") as f:
    CRED = dict(l.strip().split("=", 1) for l in f if "=" in l)
CRED["admin"] = os.environ["ODOO_ADMIN_PASSWORD"]
OBJ = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/object", allow_none=True)


def sesion(login):
    uid = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/common").authenticate(DB, login, CRED[login], {})
    if not uid:
        sys.exit(f"No se pudo iniciar sesión como {login}")

    def x(modelo, metodo, *a, **kw):
        try:
            return OBJ.execute_kw(DB, uid, CRED[login], modelo, metodo, list(a), kw)
        except xmlrpc.client.Fault as e:  # botones que devuelven None: Odoo ya lo ha hecho
            if "cannot marshal None" in e.faultString:
                return None
            raise
    return uid, x


def uno(x, modelo, dominio, valores):
    """Busca un registro; si no está, lo crea. Devuelve (id, creado)."""
    ids = x(modelo, "search", dominio, limit=1)
    if ids:
        return ids[0], False
    return x(modelo, "create", valores), True


def producto(x, nombre):
    ids = x("product.product", "search", [["name", "=", nombre]], limit=1)
    if not ids:
        sys.exit(f"No está el producto «{nombre}»: ¿se importó la carta (tarea 36)?")
    return ids[0]


def stock(x, pid):
    return x("product.product", "read", [pid], fields=["qty_available"])[0]["qty_available"]


# 0. Permisos de gerente (admin) ---------------------------------------------------------------
_, xa = sesion("admin")
gerente = xa("res.users", "search", [["login", "=", "gerente"]])[0]
grupos = []
for modulo, nombre in [("hr", "group_hr_manager"), ("mass_mailing", "group_mass_mailing_user")]:
    grupos += xa("ir.model.data", "search_read", [["module", "=", modulo], ["name", "=", nombre]],
                 fields=["res_id"])
xa("res.users", "write", [gerente], {"group_ids": [(4, g["res_id"]) for g in grupos]})
print(f"0. Permisos: gerente con Empleados (Administrador) y Marketing por correo (Usuario).")

uid, x = sesion("gerente")

# 1. CRM: oportunidad que pasa por las etapas ---------------------------------------------------
cliente, _ = uno(x, "res.partner", [["name", "=", "Talleres Ejemplo S.L."]],
                 {"name": "Talleres Ejemplo S.L.", "is_company": True, "email": "compras@example.com",
                  "city": "Bilbao"})
etapas = {e["sequence"]: e["id"] for e in x("crm.stage", "search_read", [], fields=["sequence"])}
cierre = (datetime.date.today() + datetime.timedelta(days=7)).isoformat()
op, nueva = uno(x, "crm.lead", [["name", "=", "Comida de empresa 20 personas"]],
                {"name": "Comida de empresa 20 personas", "type": "opportunity", "partner_id": cliente,
                 "expected_revenue": 600, "date_deadline": cierre, "user_id": uid,
                 "stage_id": etapas[min(etapas)]})
if nueva:
    for seq in sorted(etapas)[1:3]:  # Nuevo → Cualificado → Propuesta (cada cambio queda en el historial)
        x("crm.lead", "write", [op], {"stage_id": etapas[seq]})
print(f"1. CRM: oportunidad {op} «Comida de empresa 20 personas», 600 €, cierre {cierre}.")

# 2. Ventas: presupuesto desde la oportunidad, enviado y confirmado -----------------------------
pedido, _ = uno(x, "sale.order", [["opportunity_id", "=", op]],
                {"partner_id": cliente, "opportunity_id": op, "order_line": [
                    (0, 0, {"product_id": producto(x, n), "product_uom_qty": 20})
                    for n in ("Menú del día", "Txakoli (copa)", "Tarta de queso")]})
estado = x("sale.order", "read", [pedido], fields=["state"])[0]["state"]
if estado == "draft":
    x("sale.order", "action_quotation_sent", [pedido])
    estado = "sent"
if estado == "sent":
    x("sale.order", "action_confirm", [pedido])
if not x("crm.lead", "read", [op], fields=["stage_id"])[0]["stage_id"][0] == etapas[max(etapas)]:
    x("crm.lead", "action_set_won", [op])
so = x("sale.order", "read", [pedido], fields=["name", "state", "amount_untaxed", "amount_total"])[0]
lead = x("crm.lead", "read", [op], fields=["stage_id"])[0]
print(f"2. Ventas: {so['name']} ({so['state']}), {so['amount_untaxed']:.2f} € sin IVA, "
      f"{so['amount_total']:.2f} € con IVA. Oportunidad en «{lead['stage_id'][1]}».")

# 3. Empleados ------------------------------------------------------------------------------
dep = {d: uno(x, "hr.department", [["name", "=", d]], {"name": d})[0] for d in ("Sala", "Cocina")}
plantilla = [  # nombre, puesto, departamento, correo
    ("Ane Gerente", "Gerente", "Sala", "gerente@example.com"),
    ("Jon Camarero", "Camarero", "Sala", "jon@example.com"),
    ("Miren Cocina", "Cocinera", "Cocina", "miren@example.com"),
    ("Iñigo Barra", "Barra", "Sala", "inigo@example.com"),
]
emp = {}
for nombre, puesto, d, correo in plantilla:
    job, _ = uno(x, "hr.job", [["name", "=", puesto]], {"name": puesto, "department_id": dep[d]})
    emp[nombre], _ = uno(x, "hr.employee", [["name", "=", nombre]],
                         {"name": nombre, "job_id": job, "job_title": puesto, "department_id": dep[d],
                          "work_email": correo})
if not x("hr.employee", "search", [["user_id", "=", gerente]]):
    x("hr.employee", "write", [emp["Ane Gerente"]], {"user_id": gerente})
x("hr.employee", "write", [emp["Jon Camarero"], emp["Iñigo Barra"]], {"parent_id": emp["Ane Gerente"]})
x("hr.department", "write", [dep["Sala"]], {"manager_id": emp["Ane Gerente"]})
print(f"3. Empleados: {len(emp)} en Sala y Cocina; Ane Gerente enlazada al usuario gerente y "
      f"responsable de Jon e Iñigo.")

# 4. Marketing por correo: lista y campaña de prueba -----------------------------------------
lista, _ = uno(x, "mailing.list", [["name", "=", "Clientes que aceptan publicidad"]],
               {"name": "Clientes que aceptan publicidad"})
for i in (1, 2, 3):
    uno(x, "mailing.contact", [["email", "=", f"cliente{i}@example.com"]],
        {"name": f"Cliente {i}", "email": f"cliente{i}@example.com", "list_ids": [(4, lista)]})
modelo_lista = x("ir.model", "search", [["model", "=", "mailing.list"]])[0]
cuerpo = ("<div class='o_layout o_basic_theme'><div class='container o_mail_wrapper oe_unremovable'>"
          "<div class='row'><div class='col o_mail_wrapper_td bg-white oe_structure o_editable'>"
          "<h1>Menú de temporada de otoño</h1><p>Ya tenemos la carta de otoño: marmitako, pimientos de "
          "Gernika y pantxineta. Reserva tu mesa.</p><p><a href='https://almichain1.duckdns.org' "
          "style='padding:8px 16px;background:#714B67;color:#fff;text-decoration:none'>Reservar</a></p>"
          "</div></div></div></div>")
campana, nueva = uno(x, "mailing.mailing", [["subject", "=", "Menú de temporada de otoño"]],
                     {"subject": "Menú de temporada de otoño", "mailing_model_id": modelo_lista,
                      "contact_list_ids": [(6, 0, [lista])]})
x("mailing.mailing", "write", [campana], {"email_from": "Almi-Chain <reservas@example.com>",
                                          "reply_to": "reservas@example.com", "body_html": cuerpo,
                                          "body_arch": cuerpo})
if nueva:
    prueba = x("mailing.mailing.test", "create", {"email_to": "prueba@example.com", "mass_mailing_id": campana})
    x("mailing.mailing.test", "send_mail_test", [prueba])
print(f"4. Marketing: lista «Clientes que aceptan publicidad» con "
      f"{x('mailing.contact', 'search_count', [['list_ids', 'in', [lista]]])} contactos; campaña {campana} "
      f"en borrador, con envío de prueba a prueba@example.com.")

# 5. Inventario: 48 → venta de 2 → 46 → ajuste a 45 ------------------------------------------
agua = producto(x, "Agua 50 cl")
plantilla_agua = x("product.product", "read", [agua], fields=["product_tmpl_id"])[0]["product_tmpl_id"][0]
almacen = x("stock.warehouse", "search_read", [], fields=["lot_stock_id"], limit=1)[0]["lot_stock_id"][0]


def contar(cantidad):
    quant = x("stock.quant", "search", [["product_id", "=", agua], ["location_id", "=", almacen]], limit=1)
    if not quant:
        quant = [x("stock.quant", "create", {"product_id": agua, "location_id": almacen,
                                             "inventory_quantity": cantidad})]
    else:
        x("stock.quant", "write", quant, {"inventory_quantity": cantidad})
    x("stock.quant", "action_apply_inventory", quant)


if not x("product.template", "read", [plantilla_agua], fields=["is_storable"])[0]["is_storable"]:
    x("product.template", "write", [plantilla_agua], {"is_storable": True})
    contar(48)
    inicial = stock(x, agua)
    venta = x("sale.order", "create", {"partner_id": cliente, "order_line": [
        (0, 0, {"product_id": agua, "product_uom_qty": 2})]})
    x("sale.order", "action_confirm", [venta])
    for albaran in x("stock.picking", "search", [["sale_id", "=", venta]]):
        for mov in x("stock.move", "search_read", [["picking_id", "=", albaran]], fields=["product_uom_qty"]):
            x("stock.move", "write", [mov["id"]], {"quantity": mov["product_uom_qty"], "picked": True})
        x("stock.picking", "button_validate", [albaran])
    tras_venta = stock(x, agua)
    contar(45)
    nombre_venta = x("sale.order", "read", [venta], fields=["name"])[0]["name"]
    print(f"5. Inventario: Agua 50 cl {inicial:g} → venta {nombre_venta} de 2 → {tras_venta:g} → "
          f"ajuste físico → {stock(x, agua):g}.")
else:
    print(f"5. Inventario: ya hecho antes; Agua 50 cl con {stock(x, agua):g} unidades.")

movs = x("stock.move.line", "search_read", [["product_id", "=", agua]],
         fields=["date", "reference", "location_id", "location_dest_id", "quantity"], order="date, id")
for m in movs:
    print(f"   {m['date']}  {m['reference']:<28} {m['location_id'][1]:>26} → {m['location_dest_id'][1]:<26} "
          f"{m['quantity']:g}")
