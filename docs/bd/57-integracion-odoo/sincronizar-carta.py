#!/usr/bin/env python3
"""
Tarea 57 · Integrar la BD propia (almi_chain) con la de Odoo (tienda).

Lee la carta de almi_chain (tabla plato) y la escribe en el TPV de Odoo por su API (XML-RPC).
almi_chain manda: si un precio cambia en la base de la cadena, al volver a ejecutar el script
cambia también en el TPV. Cada producto de Odoo queda enlazado con su plato por la referencia
interna ALMI-<id_plato>, así que se puede repetir las veces que haga falta sin duplicar nada.

Uso, en el servidor (Odoo y almi_chain están en el mismo PostgreSQL, contenedor «db»):
  read -rs ODOO_PASSWORD && export ODOO_PASSWORD     (la de gerente, de KeePassXC)
  python3 sincronizar-carta.py --simular             (solo dice qué haría, no toca Odoo)
  python3 sincronizar-carta.py                       (sincroniza)

Variables (con sus valores por defecto):
  ODOO_URL=http://localhost:8069  ODOO_DB=tienda  ODOO_USER=gerente  ODOO_PASSWORD (obligatoria)
  ALMI_PSQL="sudo docker compose -f /opt/odoo/docker-compose.yml exec -T db psql -U informes -d almi_chain"
    La lectura se hace con la cuenta informes (rol_lectura, tarea 42): solo puede leer.
"""
import csv
import io
import os
import shlex
import subprocess
import sys
import xmlrpc.client

URL = os.environ.get("ODOO_URL", "http://localhost:8069")
DB = os.environ.get("ODOO_DB", "tienda")
USUARIO = os.environ.get("ODOO_USER", "gerente")
PSQL = os.environ.get("ALMI_PSQL",
                      "sudo docker compose -f /opt/odoo/docker-compose.yml exec -T db psql -U informes -d almi_chain")
SIMULAR = "--simular" in sys.argv[1:]

# Categoría de almi_chain (CHECK de la tabla plato) -> categoría del TPV (tarea 34)
CATEGORIAS = {"entrante": "Entrantes", "principal": "Platos", "postre": "Postres", "bebida": "Bebidas"}
# Platos que en el TPV ya existían con otro nombre (carta de la tarea 36). Solo se usa la primera
# vez: después cada producto se encuentra por su referencia ALMI-<id_plato>.
NOMBRE_EN_ODOO = {"Croquetas de jamón": "Croquetas de jamón (6 uds)",
                  "Txuleta a la brasa": "Txuleta a la brasa (1 kg)",
                  "Agua mineral": "Agua 50 cl",
                  "Café": "Café solo"}

CONSULTA = """
SELECT id_plato, nombre, coalesce(descripcion, '') AS descripcion, categoria, precio, tipo_iva
FROM plato ORDER BY id_plato
"""


def leer_almi_chain():
    """Devuelve los platos de almi_chain. Usa psql en modo CSV para no depender de librerías."""
    orden = shlex.split(PSQL) + ["--csv", "-v", "ON_ERROR_STOP=1", "-c", CONSULTA]
    r = subprocess.run(orden, capture_output=True, text=True)
    if r.returncode != 0:
        sys.exit(f"No se pudo leer almi_chain:\n{r.stderr.strip()}")
    platos = list(csv.DictReader(io.StringIO(r.stdout)))
    if not platos:
        sys.exit("almi_chain no tiene platos: ¿se han cargado 06-datos.sql (tarea 41)?")
    return platos


def pvp(plato):
    """En almi_chain el precio va sin IVA; en el TPV, con el IVA incluido."""
    return round(float(plato["precio"]) * (1 + float(plato["tipo_iva"]) / 100), 2)


platos = leer_almi_chain()
print(f"almi_chain: {len(platos)} platos leídos con la cuenta de solo lectura.")

PASSWORD = os.environ.get("ODOO_PASSWORD") or sys.exit("Falta ODOO_PASSWORD (la de gerente)")
uid = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/common").authenticate(DB, USUARIO, PASSWORD, {})
if not uid:
    sys.exit(f"No se pudo iniciar sesión en Odoo como {USUARIO}")
obj = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/object", allow_none=True)


def x(modelo, metodo, *a, **kw):
    return obj.execute_kw(DB, uid, PASSWORD, modelo, metodo, list(a), kw)


def iva_incluido(tipo):
    """El mismo impuesto que crean las tareas 34 y 36: «10% S (IVA incluido)»."""
    nombre = f"{tipo}% S (IVA incluido)"
    ids = x("account.tax", "search", [["name", "=", nombre]], limit=1)
    if ids or SIMULAR:
        return ids
    base = x("account.tax", "search", [["type_tax_use", "=", "sale"], ["amount", "=", tipo],
                                        ["amount_type", "=", "percent"]], limit=1)
    if not base:
        sys.exit(f"Odoo no tiene un IVA de venta del {tipo} %")
    copia = x("account.tax", "copy", base[0], {"name": nombre, "price_include_override": "tax_included"})
    return copia if isinstance(copia, list) else [copia]


nuevos = actualizados = iguales = 0
for p in platos:
    ref = f"ALMI-{p['id_plato']}"
    tipo = int(float(p["tipo_iva"]))
    precio = pvp(p)
    cat = CATEGORIAS[p["categoria"]]

    ids = x("product.template", "search", [["default_code", "=", ref]], limit=1)
    if not ids:  # primera vez: se busca por nombre y se enlaza
        nombre_odoo = NOMBRE_EN_ODOO.get(p["nombre"], p["nombre"])
        ids = x("product.template", "search", [["name", "=", nombre_odoo], ["default_code", "=", False]], limit=1)

    if ids:
        actual = x("product.template", "read", ids, ["default_code", "list_price", "description_sale"])[0]
        cambios = {}
        if actual["default_code"] != ref:
            cambios["default_code"] = ref
        if round(actual["list_price"], 2) != precio:
            cambios["list_price"] = precio
        if (actual["description_sale"] or "") != p["descripcion"]:
            cambios["description_sale"] = p["descripcion"] or False
        if not cambios:
            iguales += 1
            print(f"  = {ref} {p['nombre']}: {precio:.2f} € (sin cambios)")
            continue
        detalle = ", ".join(f"precio {actual['list_price']:.2f} → {precio:.2f} €" if k == "list_price"
                            else "enlazado" if k == "default_code" else "descripción" for k in cambios)
        if not SIMULAR:
            # Solo precio, referencia y descripción: con una caja abierta Odoo no deja cambiar la categoría
            x("product.template", "write", ids, cambios)
        actualizados += 1
        print(f"  ~ {ref} {p['nombre']}: {detalle}")
    else:
        if not SIMULAR:
            cat_id = x("pos.category", "search", [["name", "=", cat]], limit=1)
            cat_id = cat_id[0] if cat_id else x("pos.category", "create", {"name": cat})
            x("product.template", "create", {
                "name": p["nombre"], "default_code": ref, "type": "consu", "list_price": precio,
                "available_in_pos": True, "pos_categ_ids": [(6, 0, [cat_id])],
                "taxes_id": [(6, 0, iva_incluido(tipo))], "description_sale": p["descripcion"] or False})
        nuevos += 1
        print(f"  + {ref} {p['nombre']}: {precio:.2f} € en {cat} (nuevo)")

modo = "SIMULACIÓN, no se ha cambiado nada" if SIMULAR else "hecho"
print(f"\nSincronización ({modo}): {nuevos} nuevos, {actualizados} actualizados, {iguales} sin cambios.")
