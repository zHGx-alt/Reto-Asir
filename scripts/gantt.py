#!/usr/bin/env python3
"""Genera docs/gestion/gantt.md (diagrama Mermaid + carga por persona)
a partir de docs/gestion/backlog-kanban.csv.

Uso: python3 scripts/gantt.py
"""
import csv
import datetime as dt
from collections import defaultdict
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
CSV = RAIZ / "docs/gestion/backlog-kanban.csv"
SALIDA = RAIZ / "docs/gestion/gantt.md"
ESTADO_MERMAID = {"Hecho": "done, ", "En curso": "active, ", "Pendiente": ""}


def fecha(s):
    return dt.date.fromisoformat(s)


def dias_laborables(ini, fin):
    return sum(1 for i in range((fin - ini).days + 1)
               if (ini + dt.timedelta(i)).weekday() < 5)


def validar(tareas):
    errores = []
    for t in tareas:
        ini, fin = fecha(t["Inicio"]), fecha(t["Fin"])
        if fin < ini:
            errores.append(f"#{t['ID']}: Fin anterior a Inicio")
        if ini.weekday() >= 5 or fin.weekday() >= 5:
            errores.append(f"#{t['ID']}: empieza o acaba en fin de semana")
        if t["Responsable"] == t["Revisa"]:
            errores.append(f"#{t['ID']}: el responsable no puede revisarse a sí mismo")
        if t["Estado"] not in ESTADO_MERMAID:
            errores.append(f"#{t['ID']}: estado desconocido '{t['Estado']}'")
    if errores:
        raise SystemExit("Errores en el CSV:\n  " + "\n  ".join(errores))


def main():
    with CSV.open(encoding="utf-8") as f:
        tareas = list(csv.DictReader(f))
    validar(tareas)

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
        "```mermaid",
        "gantt",
        "    dateFormat YYYY-MM-DD",
        "    axisFormat %d/%m",
        "    excludes weekends",
    ]
    bloque_actual = None
    for t in tareas:
        if t["Bloque"] != bloque_actual:
            bloque_actual = t["Bloque"]
            lineas.append(f"    section {bloque_actual}")
        # Mermaid toma la fecha de fin como exclusiva: se suma un día.
        fin = fecha(t["Fin"]) + dt.timedelta(days=1)
        nombre = t["Tarea"].replace(":", " ").replace(";", ",")
        lineas.append(f"    {nombre} · {t['Responsable']} :"
                      f"{ESTADO_MERMAID[t['Estado']]}t{t['ID']}, {t['Inicio']}, {fin}")
    lineas += ["```", ""]

    por_persona = defaultdict(list)
    revisiones = defaultdict(int)
    for t in tareas:
        por_persona[t["Responsable"]].append(t)
        if t["Revisa"] != "Equipo":
            revisiones[t["Revisa"]] += 1

    lineas += [
        "## Carga por persona",
        "",
        "| Persona | Tareas | Días-tarea | Revisiones | Bloques que toca |",
        "|---|---|---|---|---|",
    ]
    for persona, ts in sorted(por_persona.items()):
        dias = sum(dias_laborables(fecha(t["Inicio"]), fecha(t["Fin"])) for t in ts)
        bloques = sorted({t["Bloque"].split()[0] for t in ts}, key=int)
        lineas.append(f"| {persona} | {len(ts)} | {dias} | {revisiones[persona]} | "
                      f"{', '.join(bloques)} |")
    lineas.append("")

    lineas += ["## Tareas por persona", ""]
    for persona, ts in sorted(por_persona.items()):
        lineas += [f"### {persona}", "",
                   "| # | Tarea | Bloque | Fechas | Revisa | Estado |",
                   "|---|---|---|---|---|---|"]
        for t in ts:
            lineas.append(f"| {t['ID']} | {t['Tarea']} | {t['Bloque']} | "
                          f"{fecha(t['Inicio']):%d/%m}–{fecha(t['Fin']):%d/%m} | "
                          f"{t['Revisa']} | {t['Estado']} |")
        lineas.append("")

    SALIDA.write_text("\n".join(lineas), encoding="utf-8")
    print(f"Generado {SALIDA.relative_to(RAIZ)} ({len(tareas)} tareas)")


if __name__ == "__main__":
    main()
