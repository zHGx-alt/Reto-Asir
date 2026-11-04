#!/usr/bin/env python3
"""Diagrama E/R de la tarea 38 en notación Chen (ampliado en la tarea 56).

Genera dos ficheros con las mismas posiciones:
  docs/bd/38-modelo-er-chen.svg     (se ve en GitHub)
  docs/bd/38-modelo-er-chen.drawio  (para retocarlo en draw.io)

Uso: python3 scripts/bd/er-chen.py
"""
import math
from pathlib import Path
from xml.sax.saxutils import escape

RAIZ = Path(__file__).resolve().parents[2]
SALIDA = RAIZ / "docs" / "bd"



def c(i):  # columna de la cuadrícula
    return 480 + 440 * i


def r(j):  # fila de la cuadrícula
    return 360 + 370 * j


ANCHO, ALTO = c(7) + 460, r(5) + 820


# Entidades: nombre -> (x, y, débil, [(atributo, ángulo, distancia, clave)])
# clave: "pk" = identificador (subrayado), "parcial" = clave parcial de la débil (subrayado discontinuo),
#        "multi" = multivaluado (doble elipse), "derivado" = se calcula (elipse discontinua)
ENTIDADES = {
    "CAMPANA_MARKETING": (c(0), r(0), False, [
        ("id_campana", 200, 175, "pk"), ("nombre", 245, 190, ""), ("canal", 295, 190, ""),
        ("fecha_inicio", 340, 190, ""), ("fecha_fin", 20, 200, ""),
    ]),
    "CLIENTE": (c(0), r(2), False, [
        ("id_cliente", 235, 180, "pk"), ("nif", 205, 230, ""), ("nombre", 175, 185, ""),
        ("email", 145, 235, ""), ("telefono", 118, 185, ""), ("acepta_publicidad", 80, 200, ""),
    ]),
    "EMPLEADO": (c(2), r(0), False, [
        ("id_empleado", 125, 185, "pk"), ("dni", 160, 235, ""), ("nombre", 190, 185, ""),
        ("apellidos", 218, 235, ""), ("puesto", 248, 175, ""), ("email", 280, 235, ""),
        ("telefono", 315, 180, ""), ("fecha_alta", 340, 245, ""),
    ]),
    "FACTURA": (c(2), r(2), False, [
        ("id_factura", 200, 185, "pk"), ("serie", 225, 210, ""), ("numero", 320, 205, ""),
        ("fecha_hora", 345, 190, ""), ("forma_pago", 150, 185, ""), ("total", 20, 190, "derivado"),
    ]),
    "LINEA_FACTURA": (c(2), r(5), True, [
        ("num_linea", 200, 190, "parcial"), ("cantidad", 160, 200, ""),
        ("precio_unitario", 120, 175, ""), ("tipo_iva", 70, 170, ""),
    ]),
    "ESTABLECIMIENTO": (c(4), r(0), False, [
        ("id_establecimiento", 200, 200, "pk"), ("nombre", 232, 250, ""), ("direccion", 262, 175, ""),
        ("ciudad", 292, 250, ""), ("telefono", 345, 200, ""), ("latitud", 140, 190, ""),
        ("longitud", 40, 190, ""),
    ]),
    "EQUIPO": (c(4), r(2), False, [
        ("id_equipo", 205, 185, "pk"), ("sistema_operativo", 240, 210, ""), ("ip", 322, 185, ""),
        ("ubicacion", 150, 185, ""), ("precio", 120, 200, ""),
    ]),
    "MODELO_EQUIPO": (c(4), r(4), False, [
        ("id_modelo", 200, 195, "pk"), ("tipo", 160, 195, ""), ("marca", 340, 185, ""),
        ("modelo", 20, 185, ""),
    ]),
    "PLATO": (c(4), r(5), False, [
        ("id_plato", 225, 200, "pk"), ("nombre", 315, 200, ""), ("descripcion", 25, 175, ""),
        ("categoria", 50, 240, ""), ("precio", 70, 175, ""), ("tipo_iva", 110, 175, ""),
        ("es_estrella", 130, 240, ""), ("url_imagen", 155, 175, ""), ("alergeno", 345, 190, "multi"),
    ]),
    # Tarea 56: historial (entidad débil de PLATO) y PROVEEDOR (relación ternaria)
    "HISTORIAL_PRECIO_PLATO": (c(4), r(5) + 570, True, [
        ("fecha_desde", 200, 200, "parcial"), ("fecha_hasta", 160, 200, ""),
        ("precio", 20, 180, ""), ("tipo_iva", 340, 180, ""),
    ]),
    "PROVEEDOR": (c(7) + 60, r(5), False, [
        ("id_proveedor", 340, 175, "pk"), ("email", 15, 185, ""), ("cif", 50, 185, ""),
        ("nombre", 85, 185, ""), ("telefono", 120, 190, ""),
    ]),
    "ARTICULO": (c(6), r(5), False, [
        ("id_articulo", 15, 185, "pk"), ("nombre", 45, 185, ""), ("unidad_medida", 100, 165, ""),
    ]),
}

# Relaciones: nombre -> (x, y, texto, tabla, tipo, identificadora, [atributos], [(entidad, cardinalidad, papel)])
# Cardinalidad (mín,máx) junto a cada entidad: cuántas ocurrencias de ESA entidad
# se relacionan con UNA ocurrencia de la otra (convención de clase, ver leyenda).
RELACIONES = {
    "envio": (c(0), r(1), "se envía a", "ENVIO_CAMPANA", "N:M", False,
              [("fecha_envio", 0, 175)],
              [("CAMPANA_MARKETING", "(0,n)", ""), ("CLIENTE", "(0,n)", "")]),
    "recibe": (c(1), r(2), "recibe", "", "1:N", False, [],
               [("CLIENTE", "(0,1)", ""), ("FACTURA", "(0,n)", "")]),
    "atiende": (c(2), r(1), "atiende", "", "1:N", False, [],
                [("EMPLEADO", "(1,1)", ""), ("FACTURA", "(0,n)", "")]),
    "trabaja": (c(3), r(0), "trabaja en", "", "1:N", False, [],
                [("EMPLEADO", "(0,n)", ""), ("ESTABLECIMIENTO", "(1,1)", "")]),
    "tiene": (c(4), r(1), "tiene", "", "1:N", False, [],
              [("ESTABLECIMIENTO", "(1,1)", ""), ("EQUIPO", "(0,n)", "")]),
    "emite": (c(3), r(2), "emite", "", "1:N", False, [],
              [("FACTURA", "(0,n)", ""), ("EQUIPO", "(1,1)", "")]),
    "conectada": (c(5), r(2), "conectada a", "", "1:N", False, [],
                  [("EQUIPO", "(0,1)", "TPV"), ("EQUIPO", "(0,n)", "impresora")]),
    "es_de": (c(4), r(3), "es de", "", "1:N", False, [],
              [("EQUIPO", "(0,n)", ""), ("MODELO_EQUIPO", "(1,1)", "")]),
    "almacena": (c(6), r(0), "almacena", "STOCK", "N:M", False,
                 [("cantidad", 350, 190), ("stock_minimo", 25, 200)],
                 [("ESTABLECIMIENTO", "(0,n)", ""), ("ARTICULO", "(0,n)", "")]),
    "contiene": (c(2), (r(3) + r(4)) // 2, "contiene", "", "1:N", True, [],
                 [("FACTURA", "(1,1)", ""), ("LINEA_FACTURA", "(1,n)", "")]),
    "se_vende": (c(3), r(5), "se vende en", "", "1:N", False, [],
                 [("LINEA_FACTURA", "(0,n)", ""), ("PLATO", "(1,1)", "")]),
    "lleva": (c(5), r(5), "lleva", "RECETA", "N:M", False,
              [("cantidad", 90, 130)],
              [("PLATO", "(0,n)", ""), ("ARTICULO", "(0,n)", "")]),
    # Tarea 56
    "tuvo": (c(4), r(5) + 300, "tuvo precio", "", "1:N", True, [],
             [("PLATO", "(1,1)", ""), ("HISTORIAL_PRECIO_PLATO", "(1,n)", "")]),
    "suministra": (c(7) + 60, (r(3) + r(4)) // 2, "suministra", "SUMINISTRO", "N:M:P", False,
                   [("precio_compra", 0, 190)],
                   [("ESTABLECIMIENTO", "(0,n)", ""), ("ARTICULO", "(0,n)", ""), ("PROVEEDOR", "(0,n)", "")]),
}

# Relación ternaria: la línea a ESTABLECIMIENTO rodea el diagrama por arriba
# (sale del lado derecho de la entidad, sube y baja hasta el rombo).
RODEO_Y = r(0) - 130
RODEO_X = c(4) + 90

# Etiquetas de cardinalidad colocadas a mano donde dos se pisarían
ETIQUETAS_FIJAS = {
    ("almacena", "ARTICULO"): (c(6) - 40, r(5) - 44),
}


def etiqueta(rel, ent, puntos, dy):
    return ETIQUETAS_FIJAS.get((rel, ent)) or pos_etiqueta(puntos, dy)

ENT_H = 64


def ent_w(nombre):
    return max(230, len(nombre) * 11 + 30)


ENT_W = 230
ATR_H = 38
FUENTE = "DejaVu Sans, Arial, sans-serif"


def ancho_texto(texto, px=15):
    return len(texto) * px * 0.6


def ancho_atributo(nombre):
    return max(96, ancho_texto(nombre) + 34)


def ancho_rombo(texto):
    return max(150, ancho_texto(texto, 16) + 80)


def pos_atributo(x, y, ang, dist):
    a = math.radians(ang)
    return x + dist * 1.25 * math.cos(a), y + dist * math.sin(a)


def salida_rect(x, y, hw, hh, tx, ty):
    """Punto donde la recta del centro (x,y) hacia (tx,ty) sale del rectángulo."""
    dx, dy = tx - x, ty - y
    if dx == 0 and dy == 0:
        return x, y
    t = min(hw / abs(dx) if dx else 1e9, hh / abs(dy) if dy else 1e9)
    return x + dx * t, y + dy * t


def lineas_relacion(nombre):
    """Tramos (polilíneas) de cada participante y dónde va su etiqueta."""
    rx, ry, texto, _tabla, _tipo, _ident, _atr, partes = RELACIONES[nombre]
    tramos = []
    if nombre == "conectada":  # reflexiva: dos tramos de EQUIPO al rombo
        ex, ey = ENTIDADES["EQUIPO"][:2]
        for (ent, card, papel), dy in zip(partes, (-1, 1)):
            puntos = [(ex + ENT_W / 2, ey + dy * 16), (rx - ancho_rombo(texto) / 4, ry + dy * 84 / 4)]
            tramos.append((ent, puntos, card, papel, dy))
        return tramos
    for ent, card, papel in partes:
        ex, ey = ENTIDADES[ent][:2]
        if nombre == "suministra" and ent == "ESTABLECIMIENTO":
            puntos = [(RODEO_X, ey), (RODEO_X, RODEO_Y), (rx, RODEO_Y), (rx, ry)]
        else:
            puntos = [(ex, ey), (rx, ry)]
        tramos.append((ent, puntos, card, papel, 0))
    return tramos


def pos_etiqueta(puntos, dy_reflexiva):
    (x1, y1), (x2, y2) = puntos[0], puntos[1]
    if dy_reflexiva:
        return x1 + 95, y1 + dy_reflexiva * 24
    sx, sy = salida_rect(x1, y1, ENT_W / 2, ENT_H / 2, x2, y2)
    d = math.hypot(x2 - x1, y2 - y1)
    ux, uy = (x2 - x1) / d, (y2 - y1) / d
    px, py = -uy, ux  # perpendicular
    if py < 0 or (py == 0 and px < 0):
        px, py = -px, -py
    return sx + ux * 34 + px * 16 - (0 if abs(ux) > 0.5 else -px * 14), sy + uy * 22 + py * 16


# ---------------------------------------------------------------- SVG

def svg():
    o = []
    o.append(f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {ANCHO} {ALTO}" '
             f'width="{ANCHO}" height="{ALTO}" font-family="{FUENTE}">')
    o.append('<title>Modelo E/R de Almi-Chain en notación Chen (tarea 38)</title>')
    o.append(f'<rect width="{ANCHO}" height="{ALTO}" fill="#ffffff"/>')
    o.append('<g stroke="#333" stroke-width="2" fill="none">')
    # Líneas entidad-atributo y relación-atributo
    for ent, (x, y, _d, atrs) in ENTIDADES.items():
        for nombre, ang, dist, _k in atrs:
            ax, ay = pos_atributo(x, y, ang, dist)
            o.append(f'<line x1="{x:.0f}" y1="{y:.0f}" x2="{ax:.0f}" y2="{ay:.0f}" stroke="#888" stroke-width="1.5"/>')
    for rel, (x, y, _t, _tb, _tp, _i, atrs, _p) in RELACIONES.items():
        for nombre, ang, dist in atrs:
            ax, ay = pos_atributo(x, y, ang, dist)
            o.append(f'<line x1="{x:.0f}" y1="{y:.0f}" x2="{ax:.0f}" y2="{ay:.0f}" stroke="#888" stroke-width="1.5"/>')
    # Líneas entidad-relación
    for rel in RELACIONES:
        ident = RELACIONES[rel][5]
        for ent, puntos, _card, _papel, _dy in lineas_relacion(rel):
            pts = " ".join(f"{px:.0f},{py:.0f}" for px, py in puntos)
            o.append(f'<polyline points="{pts}"/>')
    o.append('</g>')

    # Atributos
    for ent, (x, y, _d, atrs) in ENTIDADES.items():
        for nombre, ang, dist, clave in atrs:
            o.append(atributo_svg(*pos_atributo(x, y, ang, dist), nombre, clave))
    for rel, (x, y, _t, _tb, _tp, _i, atrs, _p) in RELACIONES.items():
        for nombre, ang, dist in atrs:
            o.append(atributo_svg(*pos_atributo(x, y, ang, dist), nombre, ""))

    # Relaciones
    for rel, (x, y, texto, tabla, tipo, ident, _a, _p) in RELACIONES.items():
        w, h = ancho_rombo(texto), 84
        rombo = f"{x},{y-h/2} {x+w/2},{y} {x},{y+h/2} {x-w/2},{y}"
        o.append(f'<polygon points="{rombo}" fill="#fff6e0" stroke="#b07800" stroke-width="2"/>')
        if ident:
            w2, h2 = w - 22, h - 14
            o.append(f'<polygon points="{x},{y-h2/2} {x+w2/2},{y} {x},{y+h2/2} {x-w2/2},{y}" '
                     f'fill="none" stroke="#b07800" stroke-width="2"/>')
        o.append(f'<text x="{x}" y="{y+6}" text-anchor="middle" font-size="16" fill="#222">{escape(texto)}</text>')
        o.append(f'<text x="{x+w/4+6:.0f}" y="{y-h/4-8:.0f}" text-anchor="start" font-size="16" font-weight="bold" fill="#b07800">{tipo}</text>')
        if tabla:
            # en la ternaria, a la derecha: por la izquierda baja la línea a ARTICULO
            lado = ("start", x + 12) if rel == "suministra" else ("end", x - 12)
            o.append(f'<text x="{lado[1]}" y="{y+h/2+18}" text-anchor="{lado[0]}" font-size="14" fill="#666">tabla {tabla}</text>')

    # Entidades
    for ent, (x, y, debil, _a) in ENTIDADES.items():
        w = ent_w(ent)
        x0, y0 = x - w / 2, y - ENT_H / 2
        o.append(f'<rect x="{x0}" y="{y0}" width="{w}" height="{ENT_H}" fill="#e3effb" stroke="#1f5f99" stroke-width="2.5"/>')
        if debil:
            o.append(f'<rect x="{x0+6}" y="{y0+6}" width="{w-12}" height="{ENT_H-12}" fill="none" stroke="#1f5f99" stroke-width="2"/>')
        o.append(f'<text x="{x}" y="{y+6}" text-anchor="middle" font-size="17" font-weight="bold" fill="#123">{ent}</text>')

    # Cardinalidades
    for rel in RELACIONES:
        for _ent, puntos, card, papel, dy in lineas_relacion(rel):
            lx, ly = etiqueta(rel, _ent, puntos, dy)
            txt = f"{papel} {card}" if papel else card
            o.append(f'<text x="{lx:.0f}" y="{ly:.0f}" text-anchor="middle" font-size="15" font-weight="bold" fill="#a3001b">{escape(txt)}</text>')

    o.append(leyenda_svg())
    o.append('</svg>')
    return "\n".join(o) + "\n"


def atributo_svg(x, y, nombre, clave):
    w = ancho_atributo(nombre)
    subrayado = ' text-decoration="underline"' if clave == "pk" else ""
    trazo = ' stroke-dasharray="6,4"' if clave == "derivado" else ""
    s = f'<ellipse cx="{x:.0f}" cy="{y:.0f}" rx="{w/2:.0f}" ry="{ATR_H/2}" fill="#ffffff" stroke="#555" stroke-width="1.5"{trazo}/>\n'
    if clave == "multi":  # multivaluado: doble elipse
        s += f'<ellipse cx="{x:.0f}" cy="{y:.0f}" rx="{w/2-5:.0f}" ry="{ATR_H/2-5}" fill="none" stroke="#555" stroke-width="1.5"/>\n'
    s += (f'<text x="{x:.0f}" y="{y+5:.0f}" text-anchor="middle" font-size="15" fill="#222"{subrayado}>{escape(nombre)}</text>')
    if clave == "parcial":  # clave parcial: subrayado discontinuo
        tw = len(nombre) * 15 * 0.55
        s += (f'\n<line x1="{x-tw/2:.0f}" y1="{y+10:.0f}" x2="{x+tw/2:.0f}" y2="{y+10:.0f}" '
              f'stroke="#222" stroke-width="1.5" stroke-dasharray="5,3"/>')
    return s


LEYENDA = [
    "Modelo E/R de Almi-Chain · notación Chen · tareas 38 y 56",
    "",
    "Rectángulo: entidad · doble rectángulo: entidad débil",
    "Rombo: relación · doble rombo: relación identificadora",
    "Rombo con tres líneas: relación ternaria (suministra)",
    "Elipse: atributo · subrayado: identificador",
    "Subrayado discontinuo: clave parcial de la débil",
    "Doble elipse: multivaluado · discontinua: derivado",
    "",
    "(mín,máx) junto a una entidad: cuántas ocurrencias de",
    "esa entidad se relacionan con UNA de la otra.",
    "Ej.: EMPLEADO (0,n) · ESTABLECIMIENTO (1,1): un local",
    "tiene de 0 a n empleados; un empleado, uno y solo uno.",
    "Encima del rombo, el tipo: 1:N, N:M o N:M:P.",
    "",
    "Las claves ajenas no se dibujan: son las relaciones.",
    "Las N:M con atributos son tablas en el modelo lógico",
    "(tarea 39): STOCK, RECETA, ENVIO_CAMPANA y SUMINISTRO.",
]

LEYENDA_Y = r(3) + 120


def leyenda_svg():
    x, y, w = 60, LEYENDA_Y, 820
    h = 40 + 34 * len(LEYENDA)
    s = [f'<rect x="{x}" y="{y}" width="{w}" height="{h}" fill="#fafafa" stroke="#999" stroke-width="1.5" rx="8"/>']
    for i, linea in enumerate(LEYENDA):
        peso = ' font-weight="bold" font-size="20"' if i == 0 else ' font-size="17"'
        s.append(f'<text x="{x+24}" y="{y+42+34*i}"{peso} fill="#222">{escape(linea)}</text>')
    return "\n".join(s)


# ---------------------------------------------------------------- draw.io

def drawio():
    celdas = []
    ids = {}
    n = [2]

    def nuevo():
        n[0] += 1
        return f"c{n[0]}"

    def vertice(valor, estilo, x, y, w, h):
        i = nuevo()
        celdas.append(f'<mxCell id="{i}" value="{escape(valor, {chr(34): "&quot;"})}" style="{estilo}" vertex="1" parent="1">'
                      f'<mxGeometry x="{x:.0f}" y="{y:.0f}" width="{w:.0f}" height="{h:.0f}" as="geometry"/></mxCell>')
        return i

    def arista(a, b, estilo="endArrow=none;html=1;strokeWidth=2;", puntos=()):
        i = nuevo()
        pts = "".join(f'<mxPoint x="{px:.0f}" y="{py:.0f}"/>' for px, py in puntos)
        geo = f'<mxGeometry relative="1" as="geometry">{"<Array as=%spoints%s>" % (chr(34), chr(34)) + pts + "</Array>" if pts else ""}</mxGeometry>'
        celdas.append(f'<mxCell id="{i}" style="{estilo}" edge="1" parent="1" source="{a}" target="{b}">{geo}</mxCell>')

    def atributo(x, y, nombre, clave, padre):
        w = ancho_atributo(nombre)
        if clave == "pk":
            valor = f"<u>{nombre}</u>"
        elif clave == "parcial":
            valor = f'<span style="text-decoration: underline dashed">{nombre}</span>'
        else:
            valor = nombre
        estilo = "ellipse;whiteSpace=wrap;html=1;fontSize=14;"
        if clave == "multi":
            estilo = "ellipse;shape=doubleEllipse;whiteSpace=wrap;html=1;fontSize=14;"
        elif clave == "derivado":
            estilo += "dashed=1;"
        i = vertice(valor, estilo, x - w / 2, y - ATR_H / 2, w, ATR_H)
        arista(padre, i, "endArrow=none;html=1;strokeColor=#888888;")

    for ent, (x, y, debil, atrs) in ENTIDADES.items():
        estilo = ("shape=ext;double=1;" if debil else "") + "rounded=0;whiteSpace=wrap;html=1;fontStyle=1;fontSize=16;fillColor=#dae8fc;strokeColor=#1f5f99;"
        ids[ent] = vertice(ent, estilo, x - ent_w(ent) / 2, y - ENT_H / 2, ent_w(ent), ENT_H)
        for nombre, ang, dist, clave in atrs:
            atributo(*pos_atributo(x, y, ang, dist), nombre, clave, ids[ent])

    for rel, (x, y, texto, tabla, tipo, ident, atrs, partes) in RELACIONES.items():
        w, h = ancho_rombo(texto), 84
        estilo = "rhombus;whiteSpace=wrap;html=1;fontSize=15;fillColor=#fff2cc;strokeColor=#b07800;" + ("double=1;" if ident else "")
        valor = texto + (f'<br><font style="font-size:11px" color="#666666">tabla {tabla}</font>' if tabla else "")
        rid = vertice(valor, estilo, x - w / 2, y - h / 2, w, h)
        vertice(tipo, "text;html=1;align=left;fontStyle=1;fontColor=#b07800;fontSize=15;", x + w / 4 + 6, y - h / 4 - 26, 60, 24)
        for nombre, ang, dist in atrs:
            atributo(*pos_atributo(x, y, ang, dist), nombre, "", rid)
        for ent, puntos, card, papel, dy in lineas_relacion(rel):
            estilo_l = "endArrow=none;html=1;strokeWidth=2;"
            if rel == "conectada":
                arista(ids[ent], rid, estilo_l + f"exitX=1;exitY={0.5 + dy * 0.25};entryX=0.25;entryY={0.5 + dy * 0.25};")
            elif len(puntos) > 2:  # rodeo de la ternaria
                ex = (RODEO_X - (ENTIDADES[ent][0] - ent_w(ent) / 2)) / ent_w(ent)
                arista(ids[ent], rid, estilo_l + f"exitX={ex:.2f};exitY=0;entryX=0.5;entryY=0;", puntos[1:3])
            else:
                arista(ids[ent], rid, estilo_l)
            lx, ly = etiqueta(rel, ent, puntos, dy)
            txt = f"{papel} {card}" if papel else card
            vertice(txt, "text;html=1;align=center;fontStyle=1;fontColor=#a3001b;fontSize=14;", lx - 50, ly - 16, 100, 22)

    leyenda = "<br>".join(escape(linea) if linea else "&nbsp;" for linea in LEYENDA)
    vertice(f"<b>{LEYENDA[0]}</b><br>" + leyenda.split("<br>", 1)[1],
            "rounded=1;whiteSpace=wrap;html=1;align=left;verticalAlign=top;spacingLeft=20;spacingTop=12;fontSize=18;fillColor=#fafafa;strokeColor=#999999;",
            60, LEYENDA_Y, 820, 30 + 23 * len(LEYENDA))

    return ('<mxfile host="er-chen.py">\n<diagram name="E/R Chen" id="er-chen">\n'
            f'<mxGraphModel dx="1400" dy="900" grid="1" gridSize="10" page="1" pageWidth="{ANCHO}" pageHeight="{ALTO}">\n'
            '<root><mxCell id="0"/><mxCell id="1" parent="0"/>\n' + "\n".join(celdas) +
            '\n</root></mxGraphModel>\n</diagram>\n</mxfile>\n')


if __name__ == "__main__":
    (SALIDA / "38-modelo-er-chen.svg").write_text(svg(), encoding="utf-8")
    (SALIDA / "38-modelo-er-chen.drawio").write_text(drawio(), encoding="utf-8")
    print("Generados docs/bd/38-modelo-er-chen.svg y docs/bd/38-modelo-er-chen.drawio")
