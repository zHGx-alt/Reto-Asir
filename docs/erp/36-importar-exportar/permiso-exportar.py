"""Tarea 36: da a gerente el grupo «Permitir exportar» (base.group_allow_export) de Odoo 19. La clave de admin entra por stdin."""
import sys, xmlrpc.client
U, D = "http://localhost:8069", "tienda"
pw = sys.stdin.read().strip()
uid = xmlrpc.client.ServerProxy(f"{U}/xmlrpc/2/common").authenticate(D, "admin", pw, {})
if not uid:
    sys.exit("No se pudo iniciar sesión como admin")
o = xmlrpc.client.ServerProxy(f"{U}/xmlrpc/2/object")
x = lambda m, f, *a, **k: o.execute_kw(D, uid, pw, m, f, list(a), k)
g = x("ir.model.data", "search_read", [["module", "=", "base"], ["name", "=", "group_allow_export"]], fields=["res_id"])[0]["res_id"]
gerente = x("res.users", "search", [["login", "=", "gerente"]])[0]
x("res.users", "write", [gerente], {"group_ids": [(4, g)]})
nombre = x("res.groups", "read", [g], fields=["name"])[0]["name"]
tiene = x("res.users", "search_count", [["id", "=", gerente], ["group_ids", "in", [g]]])
print(f"gerente: grupo «{nombre}» (base.group_allow_export) {'añadido' if tiene else 'NO añadido'} por admin.")
