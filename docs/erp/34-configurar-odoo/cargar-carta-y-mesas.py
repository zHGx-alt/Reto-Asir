#!/usr/bin/env python3
"""
Tarea 34 (ampliación) · Carta de ejemplo, salas y mesas para los TPV de barra de Almi-Chain.

  - Categorías del TPV: Cafés, Bebidas, Entrantes, Platos, Postres
  - Productos con el PVP de la carta y el IVA 10 % de hostelería INCLUIDO en el precio (impuesto "10% S (IVA incluido)")
  - Salas "Sala" (6 mesas) y "Barra" (4 puestos), en los dos TPV
  - Los TPV muestran precios con IVA incluido

Es una carta DE EJEMPLO para probar el TPV: la carta real se importa en la tarea 36.

Uso:
  ODOO_URL=http://localhost:8069 ODOO_DB=tienda ODOO_ADMIN_PASSWORD=... python3 cargar-carta-y-mesas.py
Idempotente: lo que ya existe (por nombre) no se duplica.
"""
import os
import sys
import xmlrpc.client

URL = os.environ.get("ODOO_URL", "http://localhost:8069")
DB = os.environ.get("ODOO_DB", "tienda")
ADMIN_PW = os.environ["ODOO_ADMIN_PASSWORD"]

IVA_HOSTELERIA = 10  # servicio de restauración: IVA reducido
CARTA = {  # categoría: [(producto, PVP con IVA)]
    "Cafés": [("Café solo", 1.50), ("Café con leche", 1.80), ("Infusión", 1.60)],
    "Bebidas": [("Agua 50 cl", 1.50), ("Refresco", 2.50), ("Caña", 2.50), ("Copa de vino", 3.00)],
    "Entrantes": [("Patatas bravas", 5.50), ("Croquetas (6 uds)", 7.00), ("Ensalada mixta", 8.50)],
    "Platos": [("Menú del día", 14.50), ("Hamburguesa Almi", 12.50), ("Entrecot", 19.00)],
    "Postres": [("Tarta de queso", 5.00), ("Flan casero", 4.00)],
}
SALAS = {  # sala: (nº de mesas, primera mesa, asientos, forma)
    "Sala": (6, 1, 4, "square"),
    "Barra": (4, 11, 1, "round"),
}

uid = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/common").authenticate(DB, "admin", ADMIN_PW, {})
if not uid:
    sys.exit("No se pudo iniciar sesión como admin")
obj = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/object", allow_none=True)


def x(modelo, metodo, *a, **kw):
    return obj.execute_kw(DB, uid, ADMIN_PW, modelo, metodo, list(a), kw)


tpvs = x("pos.config", "search", [["name", "like", "TPV Barra"]])
if not tpvs:
    sys.exit("No hay TPV de barra: ejecuta antes configurar-odoo.py")
# IVA 10 % de hostelería CON EL IVA INCLUIDO en el precio. Si el precio se guarda sin IVA, Odoo lo redondea
# a 2 decimales (2,50 / 1,10 = 2,27) y al volver a sumar el IVA se pierden céntimos: 2 cañas salían a 4,99 €.
NOMBRE_IVA = f"{IVA_HOSTELERIA}% S (IVA incluido)"
iva = x("account.tax", "search", [["name", "=", NOMBRE_IVA]], limit=1)
if not iva:
    base = x("account.tax", "search", [["type_tax_use", "=", "sale"], ["amount", "=", IVA_HOSTELERIA],
                                        ["amount_type", "=", "percent"], ["tax_scope", "=", "service"]], limit=1)
    iva = [x("account.tax", "copy", base[0], {"name": NOMBRE_IVA, "price_include_override": "tax_included"})]
nombre_iva = NOMBRE_IVA

print("==> 1/3 Carta de ejemplo")
for i, (categoria, productos) in enumerate(CARTA.items()):
    cat = x("pos.category", "search", [["name", "=", categoria]])
    cat = cat[0] if cat else x("pos.category", "create", {"name": categoria, "sequence": i})
    for nombre, pvp in productos:
        valores = {"name": nombre, "type": "consu", "available_in_pos": True,
                   "list_price": pvp,  # PVP de la carta: el IVA va incluido
                   "taxes_id": [(6, 0, iva)], "pos_categ_ids": [(6, 0, [cat])]}
        ya = x("product.template", "search", [["name", "=", nombre]])
        if ya:  # solo precio e impuesto: con una caja abierta Odoo no deja tocar categorías ni salas
            x("product.template", "write", ya, {k: valores[k] for k in ("list_price", "taxes_id")})
        else:
            x("product.template", "create", valores)
        print(f"    {categoria} · {nombre}: {pvp:.2f} € ({nombre_iva})")

print("==> 2/3 Salas y mesas")
abiertas = x("pos.session", "search_read", [["state", "!=", "closed"], ["config_id", "in", tpvs]], fields=["name"])
if abiertas:
    sys.exit("    Hay cajas abiertas (" + ", ".join(a["name"] for a in abiertas) +
             "): Odoo no deja cambiar salas ni TPV con la caja abierta. Ciérralas y vuelve a ejecutar el script.")
existentes = x("restaurant.floor", "search_read", [], fields=["name", "table_ids"], order="id")
for n, (sala, (num, primera, asientos, forma)) in enumerate(SALAS.items()):
    planta = [f for f in existentes if f["name"] == sala]
    if planta:
        planta_id = planta[0]["id"]
    else:
        # se reutilizan las salas vacías que crea Odoo al activar el modo restaurante
        libres = [f for f in existentes if f["name"] not in SALAS and not f["table_ids"]]
        if libres:
            planta_id = libres[0]["id"]
            existentes.remove(libres[0])
            x("restaurant.floor", "write", [planta_id], {"name": sala})
        else:
            planta_id = x("restaurant.floor", "create", {"name": sala})
    x("restaurant.floor", "write", [planta_id], {"sequence": n, "pos_config_ids": [(6, 0, tpvs)]})
    ya = {t["table_number"] for t in x("restaurant.table", "search_read", [["floor_id", "=", planta_id]],
                                        fields=["table_number"])}
    for k in range(num):
        numero = primera + k
        if numero in ya:
            continue
        x("restaurant.table", "create", {
            "floor_id": planta_id, "table_number": numero, "seats": asientos, "shape": forma,
            "position_h": 50 + (k % 3) * 160, "position_v": 50 + (k // 3) * 160, "width": 110, "height": 110})
    print(f"    {sala}: {num} mesas ({primera}-{primera + num - 1}), en los dos TPV")
# salas sobrantes (Odoo crea una por TPV, con 1 mesa y el nombre de la empresa): se archivan
for f in existentes:
    if f["name"] not in SALAS:
        x("restaurant.floor", "write", [f["id"]], {"active": False})

print("==> 3/3 TPV con precios con IVA incluido")
x("pos.config", "write", tpvs, {"iface_tax_included": "total"})
print("    Listo")
