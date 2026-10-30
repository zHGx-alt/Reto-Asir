#!/usr/bin/env python3
"""
Corrección 2.3 · Comprueba qué aplicaciones ve cada usuario en el menú principal de Odoo.

Inicia sesión como cada usuario y pide los menús que pinta el navegador (load_web_menus), que ya
vienen filtrados por sus grupos. Un search_read de ir.ui.menu por RPC no sirve: no aplica ese filtro.
Va por JSON-RPC: load_web_menus devuelve un diccionario con claves numéricas, que XML-RPC no sabe enviar.

Uso (como root en el servidor; las contraseñas se leen de /root/.credenciales-usuarios y no se muestran):
  sudo bash -c 'set -a; . /opt/odoo/.env; python3 ver-menus-usuarios.py' | tee ~/52-menus-cajero.txt
Esperado: cajero1 y cajero2 solo con Punto de venta; gerente y admin con todas.
"""
import os
import sys
import json
import urllib.request

URL = os.environ.get("ODOO_URL", "http://localhost:8069")
DB = os.environ.get("ODOO_DB", "tienda")
USUARIOS = ["cajero1", "cajero2", "gerente", "admin"]

cred = {}
try:
    with open("/root/.credenciales-usuarios") as f:
        cred = dict(l.strip().split("=", 1) for l in f if "=" in l)
except OSError as e:
    print(f"AVISO: {e}", file=sys.stderr)
if os.environ.get("ODOO_ADMIN_PASSWORD"):
    cred.setdefault("admin", os.environ["ODOO_ADMIN_PASSWORD"])



def rpc(servicio, metodo, *args):
    datos = json.dumps({"jsonrpc": "2.0", "method": "call", "id": 1,
                        "params": {"service": servicio, "method": metodo, "args": list(args)}}).encode()
    pet = urllib.request.Request(f"{URL}/jsonrpc", datos, {"Content-Type": "application/json"})
    r = json.load(urllib.request.urlopen(pet, timeout=30))
    if "error" in r:
        raise RuntimeError(r["error"].get("data", {}).get("message") or r["error"])
    return r["result"]


for login in USUARIOS:
    pw = cred.get(login)
    if not pw:
        print(f"{login:8} sin contraseña en /root/.credenciales-usuarios, se salta")
        continue
    uid = rpc("common", "authenticate", DB, login, pw, {})
    if not uid:
        print(f"{login:8} no inicia sesión")
        continue
    menus = rpc("object", "execute_kw", DB, uid, pw, "ir.ui.menu", "load_web_menus", [[], False])
    apps = [menus[str(i)]["name"] for i in menus["root"]["children"]]
    print(f"{login:8} ({len(apps):2}): {', '.join(apps)}")
