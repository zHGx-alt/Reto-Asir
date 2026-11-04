#!/usr/bin/env python3
"""Genera docs/gestion/gantt.svg (diagrama de Gantt) y docs/gestion/gantt.md
(diagrama, avisos, tareas hechas y sin hacer, y carga por persona) a partir de
docs/gestion/backlog-kanban.csv.

Uso: python3 scripts/gantt.py
"""
import csv
import datetime as dt
from html import escape
from collections import defaultdict
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
CSV = RAIZ / "docs/gestion/backlog-kanban.csv"
SALIDA = RAIZ / "docs/gestion/gantt.md"
SVG = RAIZ / "docs/gestion/gantt.svg"
SVG_FINAL = RAIZ / "docs/gestion/gantt-final.svg"
# Tramo final: del día de la rúbrica a la víspera de la presentación (decisión del 04/11/2026).
FINAL_INI, FINAL_FIN = dt.date(2026, 11, 4), dt.date(2026, 11, 11)
ESTADOS = ("Pendiente", "En curso", "Hecho")
# Software: se hace en un ordenador o una VM. Físico: necesita montar o tocar el equipo real.
TIPOS = ("Gestión", "Documentación", "Software", "Físico")
# Un color fijo por persona, en orden alfabético (paleta validada para daltonismo).
COLORES = ["#2a78d6", "#eb6834", "#1baf7a", "#eda100", "#e87ba4", "#008300"]
DIAS_SEMANA = "LMXJV"


def fecha(s):
    return dt.date.fromisoformat(s)


def dias_laborables(ini, fin):
    return sum(1 for i in range((fin - ini).days + 1)
               if (ini + dt.timedelta(i)).weekday() < 5)


def dependencias(t):
    return t["Depende de"].split()


def buscar_ciclo(por_id):
    """Devuelve una lista de IDs que forman un ciclo, o None si no hay."""
    estado = {}  # 1 = visitando, 2 = terminado

    def visitar(i, camino):
        estado[i] = 1
        for d in dependencias(por_id[i]):
            if estado.get(d) == 1:
                return camino[camino.index(d):] + [d]
            if d not in estado:
                ciclo = visitar(d, camino + [d])
                if ciclo:
                    return ciclo
        estado[i] = 2
        return None

    for i in por_id:
        if i not in estado:
            ciclo = visitar(i, [i])
            if ciclo:
                return ciclo
    return None


def validar(tareas):
    """Aborta si el CSV tiene errores; devuelve los avisos de dependencias."""
    errores, avisos = [], []
    por_id = {t["ID"]: t for t in tareas}
    for t in tareas:
        for d in dependencias(t):
            if d == t["ID"]:
                errores.append(f"#{t['ID']}: depende de sí misma")
            elif d not in por_id:
                errores.append(f"#{t['ID']}: depende de #{d}, que no existe")
            elif t["Estado"] == por_id[d]["Estado"] == "Hecho":
                continue  # las dos hechas: son fechas reales, no hay nada que replanificar
            elif fecha(t["Inicio"]) <= fecha(por_id[d]["Fin"]):
                avisos.append(f"#{t['ID']} ({t['Tarea']}) empieza el "
                              f"{fecha(t['Inicio']):%d/%m} y necesita #{d} "
                              f"({por_id[d]['Tarea']}), que acaba el "
                              f"{fecha(por_id[d]['Fin']):%d/%m}")
    if not errores:
        ciclo = buscar_ciclo(por_id)
        if ciclo:
            errores.append("dependencia circular: " + " → ".join(f"#{i}" for i in ciclo))
    for t in tareas:
        ini, fin = fecha(t["Inicio"]), fecha(t["Fin"])
        if fin < ini:
            errores.append(f"#{t['ID']}: Fin anterior a Inicio")
        if ini.weekday() >= 5 or fin.weekday() >= 5:
            errores.append(f"#{t['ID']}: empieza o acaba en fin de semana")
        if t["Estado"] not in ESTADOS:
            errores.append(f"#{t['ID']}: estado desconocido '{t['Estado']}'")
        if t["Tipo"] not in TIPOS:
            errores.append(f"#{t['ID']}: tipo desconocido '{t['Tipo']}'")
        if t["Evidencia"] and not (RAIZ / t["Evidencia"]).exists():
            errores.append(f"#{t['ID']}: no existe la evidencia {t['Evidencia']}")
    if errores:
        raise SystemExit("Errores en el CSV:\n  " + "\n  ".join(errores))
    return avisos


def generar_svg(tareas, por_id, svg=SVG, titulo="Diagrama de Gantt", ini=None, fin=None, personas=None):
    """Dibuja el Gantt solo con días laborables: filas agrupadas por bloque,
    nombre de la tarea a la izquierda y barra con el color del responsable.
    Con ini/fin se dibuja solo ese tramo y las barras se recortan a él."""
    ini = ini or min(fecha(t["Inicio"]) for t in tareas)
    fin = fin or max(fecha(t["Fin"]) for t in tareas)
    dias = [ini + dt.timedelta(i) for i in range((fin - ini).days + 1)]
    dias = [d for d in dias if d.weekday() < 5]
    col_dia = {d: i for i, d in enumerate(dias)}
    personas = personas or sorted({t["Responsable"] for t in tareas})
    color = {p: COLORES[i % len(COLORES)] for i, p in enumerate(personas)}

    m, w_id, w_tarea, w_resp, w_dep, w_dia = 16, 28, 400, 84, 74, 40
    x_tl = m + w_id + w_tarea + w_resp + w_dep
    ancho = x_tl + w_dia * len(dias) + m
    h_fila, h_bloque, y0 = 22, 26, 92

    filas, bloque = [], None
    for t in tareas:
        if t["Bloque"] != bloque:
            bloque = t["Bloque"]
            filas.append(("bloque", bloque))
        filas.append(("tarea", t))
    alto_tabla = sum(h_bloque if k == "bloque" else h_fila for k, _ in filas)
    y_leyenda = y0 + alto_tabla + 24
    alto = y_leyenda + 40

    o = [f'<svg xmlns="http://www.w3.org/2000/svg" width="{ancho}" height="{alto}" '
         f'viewBox="0 0 {ancho} {alto}" font-family="system-ui, -apple-system, '
         f'Segoe UI, Roboto, sans-serif" font-size="12">',
         '<style>.t{fill:#0b0b0b}.s{fill:#52514e}.m{fill:#8a8984}.b{font-weight:600}</style>',
         f'<rect width="{ancho}" height="{alto}" fill="#fcfcfb"/>',
         f'<text x="{m}" y="28" class="t b" font-size="16">Almi-Chain · {escape(titulo)}</text>',
         f'<text x="{m}" y="48" class="s">{ini:%d/%m/%Y} – {fin:%d/%m/%Y} · '
         f'{len(dias)} días laborables (sin fines de semana) · {len(tareas)} tareas</text>']

    # Cabecera: semanas de calendario (de lunes a viernes) y días.
    semanas = []
    for i, d in enumerate(dias):
        if not semanas or d.isocalendar()[1] != dias[semanas[-1][0]].isocalendar()[1]:
            semanas.append([i, i])
        semanas[-1][1] = i
    inicio_semana = {a for a, _ in semanas}
    for n, (a, b) in enumerate(semanas, 1):
        x = x_tl + a * w_dia
        rango = f" {dias[a]:%d/%m}–{dias[b]:%d/%m}" if b - a >= 2 else ""
        o.append(f'<text x="{x + 4}" y="70" class="t b">Semana {n}'
                 f'<tspan class="s" font-weight="400">{rango}</tspan></text>')
    for i, d in enumerate(dias):
        x = x_tl + i * w_dia + w_dia / 2
        o.append(f'<text x="{x}" y="86" text-anchor="middle" class="s" font-size="11">'
                 f'{DIAS_SEMANA[d.weekday()]} {d.day}</text>')
    for etiqueta, x in (("#", m), ("Tarea", m + w_id), ("Responsable", m + w_id + w_tarea),
                        ("Necesita", m + w_id + w_tarea + w_resp)):
        o.append(f'<text x="{x}" y="86" class="s b" font-size="11">{etiqueta}</text>')

    # Cuadrícula: línea fina por día, más marcada al cambiar de semana.
    for i in range(len(dias) + 1):
        x = x_tl + i * w_dia
        fuerte = i in inicio_semana or i == len(dias)
        o.append(f'<line x1="{x}" y1="{y0 - 18 if fuerte else y0}" x2="{x}" y2="{y0 + alto_tabla}" '
                 f'stroke="{"#b8b7b0" if fuerte else "#e6e5e0"}" stroke-width="1"/>')

    y = y0
    for k, v in filas:
        if k == "bloque":
            o.append(f'<rect x="{m}" y="{y}" width="{ancho - 2 * m}" height="{h_bloque}" '
                     f'fill="#efeeea" fill-opacity="0.85"/>')
            o.append(f'<text x="{m + 6}" y="{y + 17}" class="t b">{escape(v)}</text>')
            y += h_bloque
            continue
        t = v
        cy = y + h_fila / 2 + 4
        hecho = t["Estado"] == "Hecho"
        clase = "m" if hecho else "t"
        nombre = escape(t["Tarea"].replace(";", ","))
        deps = ", ".join(dependencias(t)) or "—"
        o.append(f'<line x1="{m}" y1="{y + h_fila}" x2="{ancho - m}" y2="{y + h_fila}" '
                 f'stroke="#f0efeb"/>')
        o.append(f'<text x="{m}" y="{cy}" class="s">{t["ID"]}</text>')
        o.append(f'<text x="{m + w_id}" y="{cy}" class="{clase}">{nombre}'
                 f'{" ✓" if hecho else ""}'
                 f'{"<tspan class=\"s\"> · físico</tspan>" if t["Tipo"] == "Físico" else ""}</text>')
        o.append(f'<circle cx="{m + w_id + w_tarea + 5}" cy="{cy - 4}" r="4.5" '
                 f'fill="{color[t["Responsable"]]}"/>')
        o.append(f'<text x="{m + w_id + w_tarea + 14}" y="{cy}" class="t">{escape(t["Responsable"])}</text>')
        o.append(f'<text x="{m + w_id + w_tarea + w_resp}" y="{cy}" class="s">{deps}</text>')
        a = col_dia[max(fecha(t["Inicio"]), dias[0])]
        b = col_dia[min(fecha(t["Fin"]), dias[-1])]
        bx, bw = x_tl + a * w_dia + 2, (b - a + 1) * w_dia - 4
        estilo = ' stroke="#0b0b0b" stroke-width="1.5"' if t["Estado"] == "En curso" else ""
        if hecho:
            estilo += ' fill-opacity="0.4"'
        o.append(f'<rect x="{bx}" y="{y + 4}" width="{bw}" height="{h_fila - 8}" rx="4" '
                 f'fill="{color[t["Responsable"]]}"{estilo}>'
                 f'<title>{t["ID"]}. {nombre} · {escape(t["Responsable"])} · '
                 f'{fecha(t["Inicio"]):%d/%m}–{fecha(t["Fin"]):%d/%m} · {t["Estado"]}</title></rect>')
        y += h_fila

    # Leyenda: personas y estados.
    x = m
    for p in personas:
        o.append(f'<rect x="{x}" y="{y_leyenda}" width="22" height="12" rx="4" fill="{color[p]}"/>')
        o.append(f'<text x="{x + 28}" y="{y_leyenda + 10}" class="t">{escape(p)}</text>')
        x += 100
    x += 20
    o.append(f'<rect x="{x}" y="{y_leyenda}" width="22" height="12" rx="4" fill="#8a8984" '
             f'stroke="#0b0b0b" stroke-width="1.5"/>')
    o.append(f'<text x="{x + 28}" y="{y_leyenda + 10}" class="s">En curso</text>')
    x += 100
    o.append(f'<rect x="{x}" y="{y_leyenda}" width="22" height="12" rx="4" fill="#8a8984" '
             f'fill-opacity="0.4"/>')
    o.append(f'<text x="{x + 28}" y="{y_leyenda + 10}" class="s">Hecho ✓</text>')
    o.append("</svg>")
    svg.write_text("\n".join(o) + "\n", encoding="utf-8")


def main():
    with CSV.open(encoding="utf-8") as f:
        tareas = list(csv.DictReader(f))
    avisos = validar(tareas)
    por_id = {t["ID"]: t for t in tareas}

    ini_proyecto = min(fecha(t["Inicio"]) for t in tareas)
    fin_proyecto = max(fecha(t["Fin"]) for t in tareas)

    lineas = [
        "# Planificación · Diagrama de Gantt",
        "",
        f"Del {ini_proyecto:%d/%m/%Y} al {fin_proyecto:%d/%m/%Y} "
        f"({dias_laborables(ini_proyecto, fin_proyecto)} días laborables).",
        "",
        "> Fichero generado con `python3 scripts/gantt.py` a partir de "
        "[backlog-kanban.csv](backlog-kanban.csv). Para cambiar fechas o "
        "responsables, edita el CSV y vuelve a generarlo.",
        "",
        "> **Fechas.** En las tareas *Hecho*, Inicio y Fin son las fechas **reales** en que se hicieron "
        "(sacadas de los documentos y del historial de Git); en el resto, las planificadas. "
        "El reto oficial va del lunes 26/10 al jueves 12/11/2026; el Gantt empieza el 21/10 porque el "
        "equipo empezó a preparar el repositorio y el material antes. Corte técnico el miércoles 4/11 (ese día "
        "dan la rúbrica); lo que queda, la documentación y el ensayo, hasta el 11/11 (plan del 04/11/2026).",
        "",
        "![Diagrama de Gantt](gantt.svg)",
        "",
        "Cada barra tiene el color de su responsable. La columna *Necesita* indica "
        "qué tareas tienen que estar terminadas antes de empezar.",
        "",
    ]
    generar_svg(tareas, por_id)

    # Tramo final: solo lo que queda, del 04/11 al 11/11, y reparto por persona.
    todas_personas = sorted({t["Responsable"] for t in tareas})
    final = [t for t in tareas if t["Estado"] != "Hecho" and fecha(t["Fin"]) >= FINAL_INI]
    generar_svg(final, por_id, SVG_FINAL, f"Plan final {FINAL_INI:%d/%m}–{FINAL_FIN:%d/%m}",
                FINAL_INI, FINAL_FIN, todas_personas)
    carga = defaultdict(list)
    for t in final:
        carga[t["Responsable"]].append(t)
    lineas += [
        f"## Plan final ({FINAL_INI:%d/%m} – {FINAL_FIN:%d/%m})",
        "",
        "Replanificado el 04/11/2026 con la rúbrica (Anexo VI, [rubrica-anexo-VI.pdf](rubrica-anexo-VI.pdf)) "
        "y la auditoría del repositorio: lo que queda, repartido para que cada persona tenga una carga parecida. "
        "Las tareas 56 a 62 salen de criterios de la rúbrica que el repositorio aún no cubre.",
        "",
        "![Plan final](gantt-final.svg)",
        "",
        "| Persona | Días de trabajo | Tareas |",
        "|---|---|---|",
    ]
    for persona in todas_personas:
        ts = sorted(carga[persona], key=lambda t: fecha(t["Inicio"]))
        dias_p = {FINAL_INI + dt.timedelta(i) for t in ts
                  for i in range((fecha(t["Fin"]) - FINAL_INI).days + 1)
                  if FINAL_INI + dt.timedelta(i) >= fecha(t["Inicio"])
                  and (FINAL_INI + dt.timedelta(i)).weekday() < 5}
        lista = "; ".join(f"#{t['ID']} {t['Tarea']} ({max(fecha(t['Inicio']), FINAL_INI):%d/%m}–"
                          f"{fecha(t['Fin']):%d/%m})" for t in ts)
        lineas.append(f"| {persona} | {len(dias_p)} | {lista or '—'} |")
    lineas += ["", "*Días de trabajo:* días laborables del tramo en que la persona tiene al menos una tarea. "
               "Las tareas 2 y 5 de Adrian son de seguimiento y ocupan poco cada día.", ""]

    if avisos:
        lineas += ["## ⚠️ Avisos de dependencias", "",
                   "Tareas que empiezan antes de que acabe una tarea que necesitan:", ""]
        lineas += [f"- {a}" for a in avisos]
        lineas.append("")

    def enlace(t):
        return f"[{Path(t['Evidencia']).name}](../../{t['Evidencia']})" if t["Evidencia"] else "—"

    hechas = [t for t in tareas if t["Estado"] == "Hecho"]
    sin_hacer = [t for t in tareas if t["Estado"] != "Hecho"]
    lineas += [
        "## Resumen",
        "",
        f"**{len(hechas)} de {len(tareas)} tareas hechas ({100 * len(hechas) // len(tareas)} %).** "
        "*Hecho* significa que el entregable existe y tiene evidencias; las comprobaciones del "
        "23/10/2026 están en [verificacion.md](verificacion.md).",
        "",
        "| Tipo | Hechas | En curso | Pendientes | Total |",
        "|---|---|---|---|---|",
    ]
    for tipo in TIPOS:
        ts = [t for t in tareas if t["Tipo"] == tipo]
        n = {e: sum(t["Estado"] == e for t in ts) for e in ESTADOS}
        lineas.append(f"| {tipo} | {n['Hecho']} | {n['En curso']} | {n['Pendiente']} | {len(ts)} |")
    lineas += ["", "*Software* se hace en un ordenador o en una máquina virtual; *Físico* necesita "
               "el equipo real (montar, cablear o configurar hardware).", ""]

    lineas += ["## Tareas sin terminar", "",
               "Ordenadas por estado y fecha de fin. *Qué falta* sale de revisar el documento de cada tarea.", "",
               "| # | Tarea | Tipo | Responsable | Fin | Estado | Qué falta | Evidencia |",
               "|---|---|---|---|---|---|---|---|"]
    for t in sorted(sin_hacer, key=lambda t: (t["Estado"] != "En curso", fecha(t["Fin"]), int(t["ID"]))):
        lineas.append(f"| {t['ID']} | {t['Tarea']} | {t['Tipo']} | {t['Responsable']} | "
                      f"{fecha(t['Fin']):%d/%m} | {t['Estado']} | {t['Observaciones'] or '—'} | {enlace(t)} |")
    lineas.append("")

    por_persona = defaultdict(list)
    for t in tareas:
        por_persona[t["Responsable"]].append(t)

    lineas += [
        "## Carga por persona",
        "",
        "| Persona | Tareas | Sin terminar | Software sin terminar | Físicas sin terminar | Días-tarea | Bloques que toca |",
        "|---|---|---|---|---|---|---|",
    ]
    for persona, ts in sorted(por_persona.items()):
        dias = sum(dias_laborables(fecha(t["Inicio"]), fecha(t["Fin"])) for t in ts)
        bloques = sorted({t["Bloque"].split()[0] for t in ts}, key=int)
        abiertas = [t for t in ts if t["Estado"] != "Hecho"]
        lineas.append(f"| {persona} | {len(ts)} | {len(abiertas)} | "
                      f"{sum(t['Tipo'] == 'Software' for t in abiertas)} | "
                      f"{sum(t['Tipo'] == 'Físico' for t in abiertas)} | {dias} | "
                      f"{', '.join(bloques)} |")
    lineas.append("")

    lineas += ["## Tareas por persona", "",
               "Solo las que están en curso o pendientes; las hechas están al final, en *Tareas hechas*.", ""]
    for persona, ts in sorted(por_persona.items()):
        abiertas = sorted((t for t in ts if t["Estado"] != "Hecho"),
                          key=lambda t: (t["Estado"] != "En curso", fecha(t["Fin"]), int(t["ID"])))
        lineas += [f"### {persona}", ""]
        if not abiertas:
            lineas += ["Nada en curso ni pendiente.", ""]
            continue
        lineas += ["| # | Tarea | Bloque | Tipo | Fechas | Depende de | Estado |",
                   "|---|---|---|---|---|---|---|"]
        for t in abiertas:
            deps = ", ".join(f"#{d} ({por_id[d]['Responsable']})" for d in dependencias(t))
            lineas.append(f"| {t['ID']} | {t['Tarea']} | {t['Bloque']} | {t['Tipo']} | "
                          f"{fecha(t['Inicio']):%d/%m}–{fecha(t['Fin']):%d/%m} | "
                          f"{deps or '—'} | {t['Estado']} |")
        lineas.append("")

    lineas += ["## Tareas hechas", "",
               "| # | Tarea | Bloque | Tipo | Responsable | Comprobación | Evidencia |",
               "|---|---|---|---|---|---|---|"]
    for t in sorted(hechas, key=lambda t: int(t["ID"])):
        lineas.append(f"| {t['ID']} | {t['Tarea']} | {t['Bloque']} | {t['Tipo']} | {t['Responsable']} | "
                      f"{t['Observaciones'] or '—'} | {enlace(t)} |")
    lineas.append("")

    SALIDA.write_text("\n".join(lineas), encoding="utf-8")
    print(f"Generado {SALIDA.relative_to(RAIZ)} ({len(tareas)} tareas)")
    if avisos:
        print(f"\n{len(avisos)} aviso(s) de dependencias:")
        for a in avisos:
            print(f"  - {a}")


if __name__ == "__main__":
    main()
