# Reparto de tareas

**Equipo:** Adrian, Iker, Eneko.S, Eneko.P, Markel, Peio.

No hay roles fijos por bloque: las 49 tareas se reparten de forma que cada persona trabaje en 6-8 bloques distintos y revise tareas de los bloques en los que no ha trabajado. El objetivo es que cualquiera pueda defender el proyecto completo.

El detalle de tareas, fechas y carga por persona está en [gantt.md](gantt.md), generado desde [backlog-kanban.csv](backlog-kanban.csv).

## Criterios

- **Carga:** 8-9 tareas y 7-8 revisiones por persona.
- **Responsable:** ejecuta la tarea, la documenta y deja las evidencias en `docs/evidencias/`.
- **Revisor:** valida la tarea en el Pull Request antes de unirla a `main`. Nunca coincide con el responsable.
- **Equipo:** las tareas marcadas así (contrato, presentación) las valida el equipo completo.
- **Coordinación:** Adrian mantiene el Anexo II y la planificación.
- **Seguridad transversal:** cada responsable aplica el bloque 10 en su tarea; Eneko.S hace la revisión final.

## Cambios en el reparto

Se acuerdan en la reunión semanal, se reflejan en el CSV y se regenera el Gantt:

```bash
python3 scripts/gantt.py
```
