# Reto-Asir · Almi-Chain

Reto 1 de ASIR1 2026-2027 (285 h): solución informática para una cadena de restaurantes. Enunciado en [Reto_1_ASIR1_2026-2027.docx](Reto_1_ASIR1_2026-2027.docx) y plan de trabajo en [almi-chain-plan.pdf](almi-chain-plan.pdf).

**Para entender el proyecto entero** (qué pide el enunciado, qué pieza lo resuelve y cómo se relacionan la red, Odoo, la web, la base de datos y las copias): [LOGICA_RETO.md](LOGICA_RETO.md). Para montarlo desde cero, en orden: [LOGICA_RETO, sección 15](LOGICA_RETO.md#15-montarlo-desde-cero-en-orden). Pruebas de cada bloque: [tabla de pruebas](docs/gestion/47-tabla-pruebas.md).

**Documentación completa en un solo PDF** (la que se entrega al profesor): portada, índice y todos los documentos del repositorio ordenados por bloques. Se genera con Docker y Google Chrome:

```bash
python3 scripts/documentacion-entrega.py
```

Sale en `entrega/Almi-Chain-documentacion.pdf` (no se sube a Git por tamaño). Si se añade un documento nuevo en `docs/`, hay que meterlo en la lista `PARTES` del script; si no, avisa y no genera nada.

## Estado

**60 de 64 tareas hechas** (12/11/2026; lo que hay que corregir, en [CORRECIONES.md](CORRECIONES.md); la rúbrica, en [rubrica-anexo-VI.md](docs/gestion/rubrica-anexo-VI.md)). Lo hecho y lo que falta, tarea por tarea y separado en software y montaje físico: [Gantt](docs/gestion/gantt.md). Cómo se ha comprobado: [verificacion.md](docs/gestion/verificacion.md). Para repetir las comprobaciones automáticas:

```bash
bash scripts/verificar-repo.sh
```

## Estructura

| Carpeta | Contenido |
|---|---|
| `docs/gestion/` | Anexo I, Anexo II, rúbrica, reparto, backlog, Gantt, inventario de VM, tabla de pruebas (47), registro de IA y verificación |
| `docs/hardware/` | Necesidades, hardware, software y presupuesto (tareas 7-10) |
| `docs/diagramas/` | Diagrama de arquitectura (tarea 11) y wireframes (tarea 27) |
| `docs/so/` | Arranque dual del gerente con cifrado y servicios reducidos (tareas 12 y 64), bastionado de los TPV (13 y 15) e impresora (14 y 37) |
| `docs/arcade/` | Recreativa MAME, rendimiento, Batocera y monitorización (tareas 16-18 y 51), recreativa en el equipo real y sus medidas en 1 núcleo y 1 GB (53 y 54) |
| `docs/redes/` | Comparativa WAN, plano, direccionamiento y Packet Tracer, red segura, WDS y análisis con nmap y Wireshark (tareas 22-26) |
| `docs/web/` | Wireframes (tarea 27) y hosting en AWS (tarea 30) |
| `docs/erp/` | Comparativa de ERP, Odoo con Docker, configuración, factura automática, importar y exportar, y HTTPS (tareas 32-36 y 52) |
| `docs/bd/` | Modelo E/R en notación Chen, modelo lógico 3FN, DDL, datos, consultas y usuarios, con evidencias (tareas 38-42 y 56) |
| `docs/backup/` | RAID 1, copias 3-2-1 (RAID, USB y S3), prueba de restauración, recuperación en una máquina nueva (RTO) y su paso a paso (tareas 43-45, 48 y 60) |
| `docs/seguridad/` | Revisión de seguridad transversal (tarea 46) |
| `docs/evidencias/` | Capturas del arranque dual, la web y el hosting |
| `iac/` | Infraestructura como código: Terraform de la web en AWS (tarea 31) |
| `web/` | Página web del restaurante |
| `arduino/` | Firmware, esquema, prueba del antirrebote y scripts de prueba del arcade stick (tareas 19-21, 50 y 59) |
| `scripts/` | Gantt, PDF de la documentación completa, verificación, hooks de Git, servidor web, monitorización de la recreativa y scripts del PC del gerente (cifrado y servicios, tareas 12 y 64) |

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

- Las credenciales, en una base cifrada de KeePassXC (`.kdbx`), que no sirve sin su contraseña maestra (solo en local).

Las **máquinas virtuales no están en Drive** (decisión del 30/10): cada una se queda en el PC de quien la tiene. Lista: [docs/gestion/maquinas-virtuales.md](docs/gestion/maquinas-virtuales.md).

## Contribuir

Si nunca has usado Git, empieza por la [guía de Git del equipo](CONTRIBUTING.md): instalación, flujo diario con ramas y Pull Requests, problemas habituales y chuleta de comandos.
