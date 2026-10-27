#!/usr/bin/env python3
"""
Tarea 36 · Importar y exportar datos de Odoo por su API (XML-RPC). RA.7 de LMSGI:
«importación, integración, aseguramiento y extracción de la información».

  importar <carta.csv>   Carga o actualiza la carta del TPV (categorías y productos con su PVP).
                         Repetible: busca por nombre, no duplica, y dice qué ha creado y qué ha actualizado.
  exportar <carpeta>     Saca a CSV la carta, los clientes, los pedidos del TPV y las facturas.
                         Los CSV llevan datos personales: la carpeta NO se sube a Git (.gitignore).

Uso (con el usuario gerente, no con admin: mínimos privilegios):
  read -rs ODOO_PASSWORD && export ODOO_PASSWORD     (la pide sin mostrarla ni dejarla en el historial)
  ODOO_URL=http://localhost:8069 ODOO_DB=tienda ODOO_USER=gerente \
  python3 importar-exportar.py importar carta.csv
  python3 importar-exportar.py exportar exportaciones-$(date +%Y%m%d)

El CSV de la carta va separado por «;» (como lo guarda Excel en español) con las columnas
categoria;producto;pvp_con_iva;descripcion. El PVP lleva el IVA del 10 % de hostelería incluido.
"""
import csv
import os
import sys
import xmlrpc.client
from pathlib import Path

URL = os.environ.get("ODOO_URL", "http://localhost:8069")
DB = os.environ.get("ODOO_DB", "tienda")
USUARIO = os.environ.get("ODOO_USER", "gerente")
PASSWORD = os.environ["ODOO_PASSWORD"]
IVA_HOSTELERIA = 10
NOMBRE_IVA = f"{IVA_HOSTELERIA}% S (IVA incluido)"  # el mismo que crea cargar-carta-y-mesas.py (tarea 34)

uid = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/common").authenticate(DB, USUARIO, PASSWORD, {})
if not uid:
    sys.exit(f"No se pudo iniciar sesión como {USUARIO}")
obj = xmlrpc.client.ServerProxy(f"{URL}/xmlrpc/2/object", allow_none=True)


def x(modelo, metodo, *a, **kw):
    return obj.execute_kw(DB, uid, PASSWORD, modelo, metodo, list(a), kw)


def iva_incluido():
    """IVA del 10 % con el precio con IVA incluido (si no, Odoo redondea y se pierden céntimos)."""
    iva = x("account.tax", "search", [["name", "=", NOMBRE_IVA]], limit=1)
    if iva:
        return iva
    base = x("account.tax", "search", [["type_tax_use", "=", "sale"], ["amount", "=", IVA_HOSTELERIA],
                                        ["amount_type", "=", "percent"], ["tax_scope", "=", "service"]], limit=1)
    if not base:
        sys.exit(f"No hay un IVA de venta del {IVA_HOSTELERIA} %: ¿está instalado el plan contable español (tarea 34)?")
    copia = x("account.tax", "copy", base[0], {"name": NOMBRE_IVA, "price_include_override": "tax_included"})
    return copia if isinstance(copia, list) else [copia]


def importar(ruta):
    with open(ruta, encoding="utf-8-sig", newline="") as f:
        filas = list(csv.DictReader(f, delimiter=";"))
    columnas = {"categoria", "producto", "pvp_con_iva"}
    if not filas or not columnas <= set(filas[0]):
        sys.exit(f"{ruta}: tiene que tener las columnas {', '.join(sorted(columnas))} separadas por «;»")

    iva = iva_incluido()
    categorias, creados, actualizados, errores = {}, 0, 0, []
    for n, fila in enumerate(filas, start=2):  # la línea 1 es la cabecera
        nombre, cat = fila["producto"].strip(), fila["categoria"].strip()
        try:
            pvp = float(fila["pvp_con_iva"].replace(",", "."))
            if pvp < 0:
                raise ValueError
        except ValueError:
            errores.append(f"línea {n}: precio no válido «{fila['pvp_con_iva']}»")
            continue
        if not nombre or not cat:
            errores.append(f"línea {n}: falta el producto o la categoría")
            continue
        if cat not in categorias:
            ids = x("pos.category", "search", [["name", "=", cat]], limit=1)
            categorias[cat] = ids[0] if ids else x("pos.category", "create", {"name": cat})
        valores = {"list_price": pvp, "available_in_pos": True, "taxes_id": [(6, 0, iva)],
                   "pos_categ_ids": [(6, 0, [categorias[cat]])],
                   "description_sale": (fila.get("descripcion") or "").strip() or False}
        ya = x("product.template", "search", [["name", "=", nombre]], limit=1)
        if ya:
            x("product.template", "write", ya, valores)
            actualizados += 1
            print(f"  = {cat} · {nombre}: {pvp:.2f} € (actualizado)")
        else:
            x("product.template", "create", {"name": nombre, "type": "consu", **valores})
            creados += 1
            print(f"  + {cat} · {nombre}: {pvp:.2f} € (nuevo)")

    print(f"\nImportación: {creados} nuevos, {actualizados} actualizados, {len(errores)} con errores "
          f"({len(filas)} filas en {ruta}).")
    for e in errores:
        print(f"  ERROR {e}")
    return 1 if errores else 0


def exportar(carpeta):
    destino = Path(carpeta)
    destino.mkdir(parents=True, exist_ok=True)
    empresa = x("res.company", "search_read", [], fields=["partner_id"], limit=1)[0]["partner_id"][0]
    # (fichero, modelo, filtro, columnas de Odoo, cabecera del CSV)
    tablas = [
        ("carta.csv", "product.template", [["available_in_pos", "=", True]],
         ["pos_categ_ids/name", "name", "list_price", "description_sale"],
         ["categoria", "producto", "pvp_con_iva", "descripcion"]),
        ("clientes.csv", "res.partner", [["user_ids", "=", False], ["id", "!=", empresa], ["active", "=", True]],
         ["name", "vat", "email", "phone", "city"],
         ["nombre", "nif", "email", "telefono", "ciudad"]),
        ("ventas-tpv.csv", "pos.order", [],
         ["name", "date_order", "config_id/name", "partner_id/name", "amount_tax", "amount_total", "state"],
         ["pedido", "fecha", "tpv", "cliente", "iva", "total", "estado"]),
        ("facturas.csv", "account.move", [["move_type", "in", ["out_invoice", "out_refund"]], ["state", "=", "posted"]],
         ["name", "invoice_date", "partner_id/name", "amount_untaxed", "amount_tax", "amount_total", "payment_state"],
         ["factura", "fecha", "cliente", "base", "iva", "total", "cobro"]),
    ]
    for fichero, modelo, filtro, campos, cabecera in tablas:
        ids = x(modelo, "search", filtro, order="id")
        datos = x(modelo, "export_data", ids, campos)["datas"] if ids else []
        # utf-8-sig y «;»: Excel en español lo abre bien con doble clic
        with open(destino / fichero, "w", encoding="utf-8-sig", newline="") as f:
            w = csv.writer(f, delimiter=";")
            w.writerow(cabecera)
            w.writerows(datos)
        print(f"  {fichero}: {len(datos)} filas ({modelo})")
    print(f"\nExportado en {destino.resolve()}. Contiene datos personales: no subirlo a Git ni enviarlo sin cifrar.")
    return 0


if __name__ == "__main__":
    if len(sys.argv) != 3 or sys.argv[1] not in ("importar", "exportar"):
        sys.exit(__doc__)
    sys.exit(importar(sys.argv[2]) if sys.argv[1] == "importar" else exportar(sys.argv[2]))
