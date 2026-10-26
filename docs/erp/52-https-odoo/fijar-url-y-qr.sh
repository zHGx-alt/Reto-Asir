#!/usr/bin/env bash
# Tarea 52 (hallazgo S-19 de la tarea 46) · Fija la URL de Odoo (web.base.url + freeze) y quita el QR de
# factura del ticket: el cliente está en la Wi-Fi de invitados y no llega al servidor.
#
# Uso (en el servidor):  sudo ./fijar-url-y-qr.sh [URL]     (por defecto https://192.168.10.10)
# Idempotente. Se aplica en el TPV al abrir una sesión de caja nueva (cerrar la caja y volver a abrirla).
set -euo pipefail
URL_BASE=${1:-https://192.168.10.10}
set -a; . /opt/odoo/.env; set +a
python3 - "$URL_BASE" <<'EOF'
import os, sys, xmlrpc.client
url, db, pw, base = "http://localhost:8069", os.environ["ODOO_DB"], os.environ["ODOO_ADMIN_PASSWORD"], sys.argv[1]
uid = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/common").authenticate(db, "admin", pw, {})
m = xmlrpc.client.ServerProxy(f"{url}/xmlrpc/2/object")
x = lambda modelo, metodo, *args, **k: m.execute_kw(db, uid, pw, modelo, metodo, list(args), k)

print("### 1. URL base")
print("antes:", x("ir.config_parameter", "get_param", "web.base.url"), "· freeze:", x("ir.config_parameter", "get_param", "web.base.url.freeze"))
x("ir.config_parameter", "set_param", "web.base.url", base)
x("ir.config_parameter", "set_param", "web.base.url.freeze", "True")
print("ahora:", x("ir.config_parameter", "get_param", "web.base.url"), "· freeze:", x("ir.config_parameter", "get_param", "web.base.url.freeze"))

print("\n### 2. QR de factura en el ticket")
for modelo in ("res.company", "pos.config"):
    campos = {n: d for n, d in x(modelo, "fields_get", attributes=["type", "string", "store"]).items()
              if "qr" in n and d["type"] == "boolean" and d.get("store")}
    for nombre, d in campos.items():
        registros = x(modelo, "search_read", [], fields=[nombre, "name"])
        for r in registros:
            print(f"{modelo}.{nombre} ({d['string']}) · {r['name']}: {r[nombre]}", end="")
            if "ticket" in nombre and r[nombre]:
                x(modelo, "write", [r["id"]], {nombre: False})
                print(" → False", end="")
            print()
EOF
