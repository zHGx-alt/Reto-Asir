#!/usr/bin/env python3
"""
Tarea 34 (sección 9) · Oculta a los cajeros las aplicaciones que no necesitan para cobrar.

El cajero (Usuario interno + TPV: usuario) ve por defecto Contactos, Empleados, Conversaciones,
Calendario y Tableros. Este script:
  1. Crea el grupo «Almi-Chain / Gerencia» y mete en él a admin y a gerente.
  2. Pone ese grupo en los menús raíz de esas aplicaciones: quien no está en él, no los ve.
Así el cajero solo ve el Punto de venta. Ocultar el menú no quita el permiso de lectura de los datos
(eso lo dan las reglas de acceso del grupo «Usuario interno»), pero cierra el camino normal para verlos.

Uso:
  read -rs ODOO_ADMIN_PASSWORD && export ODOO_ADMIN_PASSWORD     (la pide sin mostrarla ni dejarla en el historial)
  ODOO_URL=http://localhost:8069 ODOO_DB=tienda python3 restringir-menus-cajero.py
  ... python3 restringir-menus-cajero.py --deshacer      (quita el grupo de los menús)
Idempotente. Los menús que no existan en esta versión de Odoo se saltan y se avisa.
"""
import os
import sys
import xmlrpc.client

URL = os.environ.get("ODOO_URL", "http://localhost:8069")
DB = os.environ.get("ODOO_DB", "tienda")
ADMIN_PW = os.environ["ODOO_ADMIN_PASSWORD"]
NOMBRE_GRUPO = "Almi-Chain / Gerencia"
USUARIOS_GERENCIA = ["admin", "gerente"]
# Menús raíz que el cajero no necesita (identificador externo en Odoo)
MENUS = {
    "contacts.menu_contacts": "Contactos",
    "hr.menu_hr_root": "Empleados",
    "mail.menu_root_discuss": "Conversaciones",
    "calendar.mail_menu_calendar": "Calendario",
    "spreadsheet_dashboard.spreadsheet_dashboard_menu_root": "Tableros",
}

uid = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/common").authenticate(DB, "admin", ADMIN_PW, {})
if not uid:
    sys.exit("No se pudo iniciar sesión como admin: revisa ODOO_ADMIN_PASSWORD")
obj = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/object", allow_none=True)


def x(modelo, metodo, *a, **kw):
    return obj.execute_kw(DB, uid, ADMIN_PW, modelo, metodo, list(a), kw)


def ref(xmlid):
    modulo, nombre = xmlid.split(".")
    r = x("ir.model.data", "search_read", [["module", "=", modulo], ["name", "=", nombre]], fields=["res_id"])
    return r[0]["res_id"] if r else None


def campo(modelo, *candidatos):
    """Nombre del campo de grupos (Odoo 19 usa group_ids; versiones anteriores, groups_id)."""
    existentes = x(modelo, "fields_get", attributes=["type"])
    for c in candidatos:
        if c in existentes:
            return c
    sys.exit(f"{modelo} no tiene ninguno de los campos {candidatos}")


campo_menu = campo("ir.ui.menu", "group_ids", "groups_id")
campo_usuario = campo("res.users", "group_ids", "groups_id")
deshacer = "--deshacer" in sys.argv

grupo = x("res.groups", "search", [["name", "=", NOMBRE_GRUPO]], limit=1)
grupo = grupo[0] if grupo else x("res.groups", "create", {"name": NOMBRE_GRUPO})
print(f"==> Grupo «{NOMBRE_GRUPO}» (id {grupo})")

for login in USUARIOS_GERENCIA:
    u = x("res.users", "search", [["login", "=", login]], limit=1)
    if u:
        x("res.users", "write", u, {campo_usuario: [(4, grupo)]})
        print(f"    {login}: en el grupo")
    else:
        print(f"    AVISO: no existe el usuario {login}")

print(f"==> Menús {'(deshaciendo)' if deshacer else ''}")
for xmlid, nombre in MENUS.items():
    menu = ref(xmlid)
    if not menu:
        print(f"    {nombre}: no está instalado en esta base ({xmlid}), se salta")
        continue
    x("ir.ui.menu", "write", [menu], {campo_menu: [(3 if deshacer else 4, grupo)]})
    print(f"    {nombre}: {'visible para todos' if deshacer else 'solo gerencia'}")

print("\nListo. Comprobación: entrar como cajero1; solo debe ver Punto de venta (tarea 34, sección 8.2, prueba 1).")
