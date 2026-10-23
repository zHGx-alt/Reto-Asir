# Reto-Asir · Almi-Chain

Reto 1 de ASIR1 2026-2027 (285 h): solución informática para una cadena de restaurantes. Enunciado en [Reto_1_ASIR1_2026-2027.docx](Reto_1_ASIR1_2026-2027.docx) y plan de trabajo en [almi-chain-plan.pdf](almi-chain-plan.pdf).

## Estructura

| Carpeta | Contenido |
|---|---|
| `docs/gestion/` | Anexo I, Anexo II, roles, backlog Kanban y registro de IA |
| `docs/diagramas/` | Diagramas draw.io (arquitectura, red, AWS, BD) |
| `docs/evidencias/` | Capturas y logs de pruebas |
| `iac/` | Infraestructura como código (Terraform/CloudFormation) |
| `web/` | Página web del restaurante |
| `arduino/` | Firmware y esquemas del arcade stick |
| `scripts/` | Scripts de configuración, backup y hooks de Git |

## Gestión del proyecto

- Contrato de equipo: [docs/gestion/anexo-I-contrato-equipo.md](docs/gestion/anexo-I-contrato-equipo.md)
- 11 pasos: [docs/gestion/anexo-II-11-pasos.md](docs/gestion/anexo-II-11-pasos.md)
- Diagrama de Gantt: [docs/gestion/gantt.md](docs/gestion/gantt.md) (se regenera con `python3 scripts/gantt.py`)
- Reparto de tareas: [docs/gestion/roles.md](docs/gestion/roles.md)
- Planificación (fuente del Gantt y del Kanban): [docs/gestion/backlog-kanban.csv](docs/gestion/backlog-kanban.csv)
- Uso de IA: [docs/gestion/registro-ia.md](docs/gestion/registro-ia.md)

## Archivos en Google Drive

Lo que no cabe en el repositorio (GitHub no admite archivos de más de 100 MB) o no debe estar en él (contraseñas) está en la [carpeta Reto-Asir de Google Drive](https://drive.google.com/drive/folders/13diK9g2t1CdGL-nc2t7qDt9rSzgpb_n_?usp=drive_link):

- Disco de la VM de arranque dual Windows 10 + Ubuntu (`VM-dualboot-W10-ubuntu-disk1.vmdk`, 12,5 GB) y sus credenciales. Cómo importarla en otro equipo: [docs/so/12-dual-boot.md, sección 8](docs/so/12-dual-boot.md#8-entrega-de-la-máquina-virtual).

## Contribuir

Si nunca has usado Git, empieza por la [guía de Git del equipo](CONTRIBUTING.md): instalación, flujo diario con ramas y Pull Requests, problemas habituales y chuleta de comandos.
