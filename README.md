# Reto-Asir · Almi-Chain

Reto 1 de ASIR1 2026-2027 (285 h): solución informática para una cadena de restaurantes. Enunciado en [Reto_1_ASIR1_2026-2027.docx](Reto_1_ASIR1_2026-2027.docx) y plan de trabajo en [almi-chain-plan.pdf](almi-chain-plan.pdf).

**Para entender el proyecto entero** (qué pide el enunciado, qué pieza lo resuelve y cómo se relacionan la red, Odoo, la web, la base de datos y las copias): [LOGICA_RETO.md](LOGICA_RETO.md).

## Estado

**35 de 55 tareas hechas** (27/10/2026; lo que hay que corregir, en [CORRECIONES.md](CORRECIONES.md)). Lo hecho y lo que falta, tarea por tarea y separado en software y montaje físico: [Gantt](docs/gestion/gantt.md). Cómo se ha comprobado: [verificacion.md](docs/gestion/verificacion.md). Para repetir las comprobaciones automáticas:

```bash
bash scripts/verificar-repo.sh
```

## Estructura

| Carpeta | Contenido |
|---|---|
| `docs/gestion/` | Anexo I, Anexo II, reparto, backlog, Gantt, registro de IA y verificación |
| `docs/hardware/` | Necesidades, hardware, software y presupuesto (tareas 7-10) |
| `docs/diagramas/` | Diagrama de arquitectura (tarea 11) y wireframes (tarea 27) |
| `docs/so/` | Arranque dual del gerente (tarea 12), bastionado de los TPV (13 y 15) e impresora (14 y 37) |
| `docs/arcade/` | Recreativa MAME, rendimiento, Batocera y monitorización (tareas 16-18) |
| `docs/redes/` | Comparativa WAN, plano y direccionamiento, red segura (tareas 22-24) |
| `docs/web/` | Wireframes (tarea 27) y hosting en AWS (tarea 30) |
| `docs/erp/` | Comparativa de ERP, Odoo con Docker, configuración, factura automática, importar y exportar, y HTTPS (tareas 32-36 y 52) |
| `docs/bd/` | Modelo E/R, modelo lógico 3FN, DDL, datos, consultas y usuarios, con evidencias (tareas 38-42) |
| `docs/backup/` | RAID 1, copias 3-2-1 y prueba de restauración (tareas 43-45) |
| `docs/evidencias/` | Capturas del arranque dual, la web y el hosting |
| `iac/` | Infraestructura como código: Terraform de la web en AWS (tarea 31) |
| `web/` | Página web del restaurante |
| `arduino/` | Firmware y esquema del arcade stick |
| `scripts/` | Gantt, verificación, hooks de Git, servidor web y monitorización de la recreativa |

## Gestión del proyecto

- Contrato de equipo: [docs/gestion/anexo-I-contrato-equipo.md](docs/gestion/anexo-I-contrato-equipo.md)
- 11 pasos: [docs/gestion/anexo-II-11-pasos.md](docs/gestion/anexo-II-11-pasos.md)
- Diagrama de Gantt: [docs/gestion/gantt.md](docs/gestion/gantt.md) (se regenera con `python3 scripts/gantt.py`)
- Reparto de tareas: [docs/gestion/roles.md](docs/gestion/roles.md)
- Verificación del estado: [docs/gestion/verificacion.md](docs/gestion/verificacion.md)
- Planificación (fuente del Gantt y del Kanban): [docs/gestion/backlog-kanban.csv](docs/gestion/backlog-kanban.csv)
- Uso de IA: [docs/gestion/registro-ia.md](docs/gestion/registro-ia.md)

## Web publicada

La web está en **<https://almichain1.duckdns.org>**, alojada en AWS (bucket S3 + EC2 con nginx y certificado de Let's Encrypt). Solo responde mientras el Learner Lab está arrancado. Cómo se montó y cómo se actualiza: [docs/web/30-hosting-aws.md](docs/web/30-hosting-aws.md).

## Archivos en Google Drive

Lo que no cabe en el repositorio (GitHub no admite archivos de más de 100 MB) o no debe estar en él (contraseñas) está en la [carpeta Reto-Asir de Google Drive](https://drive.google.com/drive/folders/13diK9g2t1CdGL-nc2t7qDt9rSzgpb_n_?usp=drive_link):

- Disco de la VM de arranque dual Windows 10 + Ubuntu (`VM-dualboot-W10-ubuntu-disk1.vmdk`, 12,5 GB) y sus credenciales, en una base cifrada de KeePassXC (`.kdbx`), que no sirve sin su contraseña maestra (solo en local). Cómo importarla en otro equipo: [docs/so/12-dual-boot.md, sección 8](docs/so/12-dual-boot.md#8-entrega-de-la-máquina-virtual).

## Contribuir

Si nunca has usado Git, empieza por la [guía de Git del equipo](CONTRIBUTING.md): instalación, flujo diario con ramas y Pull Requests, problemas habituales y chuleta de comandos.
