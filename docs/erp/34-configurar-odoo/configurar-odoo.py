#!/usr/bin/env python3
"""
Tarea 34 · Configura Odoo para la tienda por su API (XML-RPC), sin clics y de forma repetible.

  1. Datos de la empresa: Almi-Chain, España, EUR
  2. Módulos que pide el enunciado: Facturación (+ PGC español), Ventas, CRM (clientes), Empleados (personal),
     Email Marketing (marketing), Inventario y Punto de Venta en modo restaurante
  3. Dos TPV de barra: "TPV Barra 1" y "TPV Barra 2"
  4. Usuarios con mínimos privilegios: gerente (todo) y cajero1/cajero2 (solo TPV)

Uso:
  ODOO_URL=http://localhost:8069 ODOO_DB=tienda ODOO_ADMIN_PASSWORD=... \
  EMPRESA="Nombre de la tienda" python3 configurar-odoo.py

Las contraseñas de los usuarios nuevos se generan al azar y se guardan en CREDENCIALES (permisos 600).
Se puede ejecutar varias veces: lo que ya existe no se vuelve a crear.
"""
import os
import secrets
import sys
import xmlrpc.client

URL = os.environ.get("ODOO_URL", "http://localhost:8069")
DB = os.environ.get("ODOO_DB", "tienda")
ADMIN_PW = os.environ["ODOO_ADMIN_PASSWORD"]
EMPRESA = os.environ.get("EMPRESA", "Almi-Chain")
CREDENCIALES = os.environ.get("CREDENCIALES", ".credenciales-usuarios")

# Enunciado: "facturas, relación con los clientes, personal, marketing, inventariado" + TPV de barra
MODULOS = ["account", "sale_management", "crm", "hr", "mass_mailing", "stock", "point_of_sale", "pos_restaurant"]
TPVS = ["TPV Barra 1", "TPV Barra 2"]
NOMBRES_ANTIGUOS = {"TPV 1": "TPV Barra 1", "TPV 2": "TPV Barra 2"}  # versión anterior del script
# login: (nombre, grupos). Los cajeros solo tienen "Usuario interno" + "TPV: usuario".
USUARIOS = {
    "gerente": ("Gerente", ["base.group_user", "point_of_sale.group_pos_manager",
                            "sales_team.group_sale_manager", "stock.group_stock_manager",
                            "account.group_account_manager", "product.group_product_manager"]),
    "cajero1": ("Camarero barra 1", ["base.group_user", "point_of_sale.group_pos_user"]),
    "cajero2": ("Camarero barra 2", ["base.group_user", "point_of_sale.group_pos_user"]),
}


def paso(texto):
    print(f"\n==> {texto}", flush=True)


common = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/common")
uid = common.authenticate(DB, "admin", ADMIN_PW, {})
if not uid:
    sys.exit("No se pudo iniciar sesión como admin: revisa ODOO_ADMIN_PASSWORD")
obj = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/object", allow_none=True)


def x(modelo, metodo, *args, **kw):
    return obj.execute_kw(DB, uid, ADMIN_PW, modelo, metodo, list(args), kw)


def ref(xmlid):
    modulo, nombre = xmlid.split(".")
    r = x("ir.model.data", "search_read", [["module", "=", modulo], ["name", "=", nombre]],
          fields=["res_id"], limit=1)
    if not r:
        sys.exit(f"No existe {xmlid}")
    return r[0]["res_id"]


paso(f"1/4 Empresa: {EMPRESA} (España, EUR)")
es = x("res.country", "search", [["code", "=", "ES"]])[0]
# EUR viene desactivada de serie: hay que buscar también entre las inactivas
eur = x("res.currency", "search", [["name", "=", "EUR"]], context={"active_test": False})[0]
x("res.currency", "write", [eur], {"active": True})
x("res.company", "write", [1], {"name": EMPRESA, "country_id": es, "currency_id": eur})
print("   ", x("res.company", "read", [1], fields=["name", "country_id", "currency_id"])[0])

paso("2/4 Instalando módulos (puede tardar unos minutos)")
for nombre in MODULOS:
    mod = x("ir.module.module", "search_read", [["name", "=", nombre]], fields=["state"])[0]
    if mod["state"] == "installed":
        print(f"    {nombre}: ya instalado")
        continue
    print(f"    {nombre}: instalando...", flush=True)
    x("ir.module.module", "button_immediate_install", [mod["id"]])
instalados = x("ir.module.module", "search_read",
               [["name", "in", MODULOS + ["l10n_es"]]], fields=["name", "state"])
for m in instalados:
    print(f"    {m['name']}: {m['state']}")
# el almacén se crea con el nombre que tuviera la empresa al instalar Inventario
# (va después de instalar los módulos: en una base nueva stock.warehouse aún no existe)
almacenes = x("stock.warehouse", "search", [])
if almacenes:
    x("stock.warehouse", "write", almacenes, {"name": EMPRESA})
plan = x("res.company", "read", [1], fields=["chart_template"])[0]["chart_template"]
iva21 = x("account.tax", "search_read", [["type_tax_use", "=", "sale"], ["amount", "=", 21],
                                          ["amount_type", "=", "percent"]], fields=["name"], limit=1)
print(f"    Plan contable: {plan} · IVA de venta 21 %: {iva21[0]['name'] if iva21 else 'NO ENCONTRADO'}")

paso("3/4 Puntos de venta (cada TPV con su caja de efectivo; la tarjeta va al banco)")


def buscar_o_crear(modelo, dominio, valores):
    ids = x(modelo, "search", dominio, limit=1)
    return ids[0] if ids else x(modelo, "create", valores)


banco = x("account.journal", "search", [["type", "=", "bank"]], limit=1)[0]
tarjeta = buscar_o_crear("pos.payment.method", [["name", "=", "Tarjeta"]],
                         {"name": "Tarjeta", "payment_method_type": "none", "journal_id": banco})
for n, nombre in enumerate(TPVS, start=1):
    caja = buscar_o_crear("account.journal", [["code", "=", f"CAJ{n}"]],
                          {"name": f"Caja {nombre}", "type": "cash", "code": f"CAJ{n}"})
    efectivo = buscar_o_crear("pos.payment.method", [["name", "in", [f"Efectivo {nombre}", f"Efectivo TPV {n}"]]],
                              {"name": f"Efectivo {nombre}", "payment_method_type": "none", "journal_id": caja})
    antiguo = [k for k, v in NOMBRES_ANTIGUOS.items() if v == nombre]
    ids_antiguos = x("pos.config", "search", [["name", "in", antiguo]]) if antiguo else []
    if ids_antiguos:
        x("pos.config", "write", ids_antiguos, {"name": nombre})
        x("account.journal", "write", [caja], {"name": f"Caja {nombre}"})
        x("pos.payment.method", "write", [efectivo], {"name": f"Efectivo {nombre}"})
        print(f"    {antiguo[0]} -> renombrado a {nombre}")
    if x("pos.config", "search", [["name", "=", nombre]]):
        tpv = x("pos.config", "search", [["name", "=", nombre]])[0]
        x("pos.config", "write", [tpv], {"module_pos_restaurant": True})
        print(f"    {nombre}: listo (modo restaurante)")
    else:
        x("pos.config", "create", {"name": nombre, "module_pos_restaurant": True,
                                   "payment_method_ids": [(6, 0, [efectivo, tarjeta])]})
        print(f"    {nombre}: creado en modo restaurante (Efectivo {nombre} + Tarjeta)")

paso("4/4 Usuarios (mínimos privilegios)")
# Nadie puede darse de alta solo: las cuentas las crea el administrador ("b2b" = solo por invitación).
# Instalar apps como Sitio web pone "b2c" (registro libre) y deja un "¿No tiene una cuenta?" en el login.
x("ir.config_parameter", "set_param", "auth_signup.invitation_scope", "b2b")
print("    Registro libre de usuarios: desactivado (solo por invitación)")
nuevas = {}
for login, (nombre, grupos) in USUARIOS.items():
    ids_grupos = [ref(g) for g in grupos]
    existe = x("res.users", "search", [["login", "=", login]])
    if existe:
        x("res.users", "write", existe, {"group_ids": [(6, 0, ids_grupos)]})
        print(f"    {login}: ya existe (grupos actualizados)")
        continue
    pw = secrets.token_urlsafe(12)
    x("res.users", "create", {"name": nombre, "login": login, "password": pw,
                              "lang": "es_ES", "tz": "Europe/Madrid",
                              "group_ids": [(6, 0, ids_grupos)]})
    nuevas[login] = pw
    print(f"    {login}: creado")

if nuevas:
    fd = os.open(CREDENCIALES, os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o600)
    with os.fdopen(fd, "a") as f:
        for login, pw in nuevas.items():
            f.write(f"{login}={pw}\n")
    print(f"    Contraseñas nuevas guardadas en {CREDENCIALES} (no se muestran)")

print("\nListo.")
