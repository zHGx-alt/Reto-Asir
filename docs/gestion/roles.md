# Reparto de tareas

**Equipo:** Adrian, Iker, Eneko.S, Eneko.P, Markel, Peio.

No hay roles fijos por bloque: las tareas se reparten de forma que cada persona trabaje en varios bloques y revise tareas de los bloques en los que no ha trabajado. El objetivo es que cualquiera pueda defender el proyecto completo.

El detalle de tareas, fechas y carga por persona está en [gantt.md](gantt.md), generado desde [backlog-kanban.csv](backlog-kanban.csv).

## Criterios

- **Tipo de tarea:** cada tarea es *Software* (se hace en un ordenador o una VM), *Físico* (necesita el equipo real), *Documentación* o *Gestión*. Columna `Tipo` del CSV.
- **Responsable:** ejecuta la tarea, la documenta y deja las evidencias en `docs/evidencias/`.
- **Revisor:** valida la tarea en el Pull Request antes de unirla a `main`. Nunca coincide con el responsable.
- **Equipo:** las tareas marcadas así (contrato, presentación) las valida el equipo completo.
- **Coordinación:** Adrian mantiene el Anexo II y la planificación.
- **Seguridad transversal:** cada responsable aplica el bloque 10 en su tarea; Eneko.S hace la revisión final.

## Cambios en el reparto

### 23/10/2026

Tras revisar el estado real de cada tarea ([verificacion.md](verificacion.md)):

- Las tareas con una parte en VM y otra con hardware real se separan: la recreativa en el equipo real (53) y sus medidas (54); el ticket en la impresora real (37) queda aparte del driver en la VM (14). Batocera pasa a ser su propia tarea (51) y el HTTPS de Odoo también (52).
- **El software pendiente lo llevan Adrian e Iker.**
- **Las tareas físicas, cualquiera salvo Eneko.P**, que no tiene tareas ni revisiones hasta que se confirme si sigue en el equipo.
- Las tareas que hizo otra persona pasan a su nombre (34, 35, 43 y 44 a Iker; 12 y 29 a Adrian), para que el revisor no sea quien la hizo.

| # | Tarea | Antes | Ahora |
|---|---|---|---|
| 12 | Dual boot (VM) | Eneko.P | Adrian |
| 13 | Bastionado de los TPV (VM) | Markel | Iker |
| 14 | Driver de la impresora en la VM del TPV | Peio | Adrian |
| 15 | Scripts de configuración de Windows | Eneko.S | Iker |
| 18 | Monitorización de la recreativa | Eneko.S | Adrian |
| 19 | Montaje del arcade stick (físico) | Eneko.P | Markel |
| 21 | Stick con MAME y otro emulador (físico) | Eneko.P | Markel |
| 29 | W3C y Lighthouse | Eneko.P | Adrian |
| 34 | Módulos de Odoo | Markel | Iker |
| 35 | Factura automática | Adrian | Iker |
| 36 | Importar y exportar en Odoo | Peio | Iker |
| 37 | Ticket en la impresora real (físico) | Eneko.P | Peio |
| 42 | Usuarios de BD | Markel | Adrian |
| 43 | RAID 1 | Eneko.P | Iker |
| 44 | Copias 3-2-1 | Markel | Iker |
| 46 | Revisión de seguridad | Eneko.S | Adrian |
| 47 | Tabla de pruebas | Eneko.P | Eneko.S |
| 51 | Batocera frente a Debian (nueva) | — | Iker |
| 52 | HTTPS delante de Odoo (nueva) | — | Adrian |
| 53 | Recreativa en el equipo real (nueva, físico) | — | Eneko.S |
| 54 | Medidas en el equipo real (nueva, físico) | — | Eneko.S |

Las revisiones que tenía Eneko.P pasan a otras personas (columna `Revisa` del CSV).

### Cómo se cambia

Se acuerdan en la reunión semanal, se reflejan en el CSV y se regenera el Gantt:

```bash
python3 scripts/gantt.py
```
