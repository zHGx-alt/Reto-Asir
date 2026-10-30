# Máquinas virtuales del reto: quién tiene cada una

**Decisión del 30/10/2026:** las VM **no se suben a Google Drive**. Ocupan decenas de GB, en Drive solo cabe una y cada exportación se queda vieja en cuanto se toca la VM (la del gerente del 23/10 ya no tiene ni las actualizaciones ni el cifrado del 29/10). En su lugar, **cada VM se queda en el PC de quien la tiene**, que la conserva hasta la entrega (12/11) y la arranca si el profesor la pide. Lo que demuestra cada tarea está en el repositorio: guía, scripts y evidencias.

## 1. Inventario

| VM | Tareas | Quién la tiene | Dónde | Recursos | Para qué sirve hoy |
|---|---|---|---|---|---|
| `VM-dualboot-W10-ubuntu` | 12, 55 | **Adrian** | PC de Adrian, VirtualBox | 4 CPU, 8 GB, disco de 60 GB (64 GB con las instantáneas) | **Entregable:** el equipo del gerente. Instantánea vigente: `tarea12-cifrado-y-actualizado-2026-10-29` |
| `ServidorERP` (laboratorio) | 52, 37 (y pruebas de 34-35) | **Adrian** | PC de Adrian, VirtualBox, red NAT `reto-lan` (`192.168.10.10`) | 2 CPU, 4 GB, disco de 30 GB (7,6 GB usados) | Odoo por HTTPS y el ticket impreso. No tiene el RAID: es el laboratorio, no el servidor del equipo |
| `win-11` | 52, 37 | **Adrian** | PC de Adrian, VirtualBox (`192.168.10.60`) | 3 CPU, 8 GB | TPV **provisional** de las pruebas 5-6 de la 52. Es una VM personal: no se entrega |
| `ServidorERP` del equipo | 33-35, 40-45 | **Iker** | PC de Iker (a confirmar) | — | **Entregable:** el servidor con el RAID 1, la BD de Odoo en el RAID y las copias |
| VM de los TPV | 13, 15 | **Markel** | PC de Markel ([tarea 52, 4.2](../erp/52-https-odoo/DOCUMENTACION.md)) | — | **Entregable:** los TPV bastionados |
| `Recreativa-53` | 53, 54 | **Eneko.S** | PC de Eneko.S, VirtualBox ([tarea 53](../arcade/53-recreativa-fisica/DOCUMENTACION.md)) | 1 CPU, 1 GB, disco de 20 GB | **Entregable:** la recreativa (Debian + MAME con el stick) |
| `Recreativa` | 16, 17 | Iker (a confirmar) | — | 2 CPU, 1,5 GB | Primeras medidas de la 17. Sustituida por `Recreativa-53` |
| `Recreativa-1GB` | 17, 51 | Iker (a confirmar) | — | 1 CPU, 1 GB | Comparativa con Batocera. Sustituida por `Recreativa-53` |
| `Batocera` | 51 | Iker | — | 1 CPU, 1 GB | Descartada el 26/10 (tarea 51) |

«A confirmar»: la VM existe según su tarea, pero el repositorio no dice en qué PC está. Quien la tenga, que cambie la fila.

## 2. Normas

- **No borrar** una VM entregable hasta después de la evaluación. Antes de un cambio grande, instantánea con fecha en el nombre.
- **Contraseñas:** en el KeePassXC del equipo, nunca en la VM, en el repositorio ni en Drive.
- **Si alguien más necesita una VM** (por ejemplo, para ensayar la presentación), se pide a quien la tiene. Si hay que pasarla, se exporta en ese momento (`VBoxManage export <VM> -o <VM>.ova`) y se copia en un disco USB, no por Drive.
- En Drive queda la exportación del gerente del **23/10** (`VM-dualboot-W10-ubuntu-disk1.vmdk`), que está **desfasada**: no es la referencia.
