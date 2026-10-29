# Reparto de tareas

**Equipo:** Adrian, Iker, Eneko.S, Eneko.P, Markel, Peio.

> El enunciado dice «Equipos de 4-5 personas», pero el grupo es de **6 personas** (confirmado el 24/10/2026, [Anexo I](anexo-I-contrato-equipo.md)). Eneko.P volvió el 26/10/2026 y tiene tareas desde entonces.

No hay roles fijos por bloque: las tareas se reparten de forma que cada persona trabaje en varios bloques. El objetivo es que cualquiera pueda defender el proyecto completo.

El detalle de tareas, fechas y carga por persona está en [gantt.md](gantt.md), generado desde [backlog-kanban.csv](backlog-kanban.csv).

## Criterios

- **Tipo de tarea:** cada tarea es *Software* (se hace en un ordenador o una VM), *Físico* (necesita el equipo real), *Documentación* o *Gestión*. Columna `Tipo` del CSV.
- **Responsable:** ejecuta la tarea, la documenta y deja las evidencias en `docs/evidencias/`.
- **Pull Request:** cada tarea entra en `main` por PR con el CI en verde (gitleaks); lo une el propio responsable. No hay revisor asignado (decisión del 25/10/2026: en la práctica no se revisaba, y es mejor que el reparto diga lo que se hace).
- **Equipo:** las tareas marcadas así (contrato, presentación) las valida el equipo completo.
- **Coordinación:** Adrian mantiene el Anexo II y la planificación.
- **Seguridad transversal:** cada responsable aplica el bloque 10 en su tarea; Adrian hace la revisión de seguridad final (tarea 46).

## Cambios en el reparto

### 29/10/2026

La 17, la 18 y la 54 pedían la misma medida (rendimiento y monitorización en la VM de 1 núcleo y 1 GB). Se deja solo en la 54 (Eneko.S), y la 17 y la 18 se cierran con lo que ya estaba hecho y pasan a quien lo hizo:

| # | Tarea | Antes | Ahora |
|---|---|---|---|
| 17 | Rendimiento de MAME: método, scripts y medida en VM de 2 núcleos | Eneko.P | Iker |
| 18 | Monitorización: scripts | Eneko.P | Adrian |

A Eneko.P le quedan la 31 y la 36.

### 27/10/2026

| # | Tarea | Antes | Ahora |
|---|---|---|---|
| 37 | Ticket en la impresora real | Peio | Adrian |

El ticket salió desde la VM del TPV por IPP a la Samsung ML-1660, dentro de la tarea 52; el equipo decidió ese día que la impresora de las pruebas es la Samsung ([Anexo II, sección 5](anexo-II-11-pasos.md#5-decisiones)).

### 26/10/2026 (tarde)

Markel e Iker se cambian una tarea; Markel lo cambió en el backlog.

| # | Tarea | Antes | Ahora |
|---|---|---|---|
| 13 | Bastionado de los 2 TPV en VM | Iker | Markel |
| 14 | Driver de la impresora en la VM del TPV | Markel | Iker |

La 14 y la 15 (scripts de configuración de Windows) siguen con Iker y se hacen en los TPV de la 13, así que Markel e Iker tienen que coordinarse. Tareas abiertas por persona tras el cambio: Adrian 5 (2 de gestión), Iker 5, Eneko.P 4, Eneko.S 4, Markel 4, Peio 4.

### 26/10/2026

Eneko.P vuelve al equipo. Iker y Adrian llevaban más tareas abiertas que el resto (8 y 7, frente a 3-4), así que se reparte para que todos queden en 4-5:

| # | Tarea | Antes | Ahora |
|---|---|---|---|
| 14 | Driver de la impresora en la VM del TPV | Adrian | Markel |
| 17 | Rendimiento MAME en la VM de 1 núcleo y 1 GB | Iker | Eneko.P |
| 18 | Monitorización de la recreativa | Adrian | Eneko.P |
| 31 | IaC y despliegue automatizado (Terraform + Actions) | Iker | Eneko.P |
| 36 | Importar y exportar en Odoo | Iker | Eneko.P |

Tareas abiertas por persona tras el cambio: Adrian 5 (2 de gestión), Iker 5, Eneko.P 4, Eneko.S 4, Markel 4, Peio 4. Las cuatro de Eneko.P tienen ya los scripts y la guía hechos: falta ejecutarlas y guardar las evidencias.

### 23/10/2026

Tras revisar el estado real de cada tarea ([verificacion.md](verificacion.md)):

- Las tareas con una parte en VM y otra con hardware real se separan: la recreativa en el equipo real (53) y sus medidas (54); el ticket en la impresora real (37) queda aparte del driver en la VM (14). Batocera pasa a ser su propia tarea (51) y el HTTPS de Odoo también (52).
- **El software pendiente lo llevan Adrian e Iker.**
- **Las tareas físicas, cualquiera salvo Eneko.P**, que no tiene tareas hasta que se confirme si sigue en el equipo.
- Las tareas que hizo otra persona pasan a su nombre (34, 35, 43 y 44 a Iker; 12 y 29 a Adrian), para que el responsable sea quien la hizo.

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
| 55 | Contraseñas robustas en la VM del gerente (nueva) | — | Adrian |


### Cómo se cambia

Se acuerdan en la reunión semanal, se reflejan en el CSV y se regenera el Gantt:

```bash
python3 scripts/gantt.py
```
