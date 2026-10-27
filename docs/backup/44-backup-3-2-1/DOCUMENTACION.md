# Tarea 44 · Plan de backup 3-2-1 cifrado y automatizado

**Responsable:** Iker (hecha por Iker; antes estaba a nombre de Markel) · **Fecha:** 22/10/2026 · **Depende de:** 41, 43
**Estado:** ✅ Hecha para Odoo en máquina virtual (`ServidorERP`) · 🔧 El script ya copia `almi_chain` si existe (24/10, sin probar en la VM) · ⏳ Falta crear `almi_chain` en el servidor y repetir la prueba

## 1. Resultado
Copia de seguridad **diaria, automática y cifrada** de todo lo que hace falta para recuperar Odoo, siguiendo la regla **3-2-1**:

| Regla | Cómo se cumple |
|---|---|
| **3 copias** | ① Datos vivos (PostgreSQL y adjuntos en Docker) · ② Repositorio `restic` en el **RAID 1** (`/srv/datos/restic`, tarea 43) · ③ Repositorio `restic` en el **disco USB externo** (`BACKUP_USB`) |
| **2 soportes distintos** | Discos internos en espejo (RAID) + disco USB extraíble |
| **1 fuera del local** | El gerente **se lleva el USB a casa** y lo trae **cada lunes**: esa noche se hace la copia en el USB y el martes se lo vuelve a llevar. Mientras está fuera, la copia diaria solo va al RAID (el USB fuera del local tiene, como mucho, una semana de antigüedad). Si pasan más de **7 días** sin copia en el USB, el servicio termina con error y aparece en `systemctl --failed`. Mejora recomendada: un tercer repositorio en **AWS S3** (`restic -r s3:...`) para que la copia fuera del local sea diaria y no dependa de nadie |
| **Cifrado** | `restic` cifra con **AES-256** y autentica con Poly1305. Sin la contraseña, la copia no se puede leer |
| **Automático** | `backup-odoo.timer` de systemd, cada día a las **02:30**. Si el servidor estaba apagado a esa hora, la copia se hace al encenderlo |

## 2. Qué se copia
| Qué | De dónde | Por qué |
|---|---|---|
| Base de datos `tienda` | `pg_dump -Fc` desde el contenedor `db` | Ventas, facturas, clientes, contabilidad… Un volcado es **consistente**: copiar los ficheros de PostgreSQL en caliente no lo sería |
| Base de datos `almi_chain` (tareas 40-41) | `pg_dump -Fc`, solo si existe en el mismo PostgreSQL | Es la BD del establecimiento que pide el enunciado: tiene que entrar en el plan de copias |
| Usuarios y roles de PostgreSQL | `pg_dumpall --globals-only` | Para recrear el usuario `odoo` |
| Adjuntos de Odoo (*filestore*) | Volumen `odoo_odoo-web-data` | Los PDF, imágenes y adjuntos **no están dentro de la base de datos** |
| Configuración | `/opt/odoo` (`docker-compose.yml`, `.env`, `odoo.conf`) | Para montar el servidor otra vez igual |

**Retención:** 7 copias diarias, 4 semanales y 6 mensuales (`restic forget --prune`). Después de cada copia se ejecuta `restic check` para verificar el repositorio.

## 3. Archivos
| Archivo | Para qué sirve |
|---|---|
| [`instalar-backup.sh`](instalar-backup.sh) | Instala `restic`, genera la contraseña, crea el repositorio en el RAID, prepara el USB (solo si está vacío) e instala el timer. Idempotente. |
| [`backup-odoo.sh`](backup-odoo.sh) | La copia en sí. Se instala en `/usr/local/sbin/` |
| `/etc/systemd/system/backup-odoo.{service,timer}` | Automatización. El servicio corre con `Nice=10` e `IOSchedulingClass=idle` para no frenar Odoo |
| `/root/.config/backup-odoo/restic.pass` | Contraseña de cifrado (permisos `600`, solo root) |

```bash
sudo ./instalar-backup.sh /dev/sdX     # /dev/sdX = USB nuevo y vacío (la primera vez)
sudo systemctl start backup-odoo        # copia manual
journalctl -u backup-odoo               # ver qué ha pasado
```

## 4. Pruebas
| # | Prueba | Resultado | Evidencia |
|---|---|---|---|
| 1 | Instalación | ✅ restic 0.18.0, repositorio en el RAID, USB formateado con la etiqueta `BACKUP_USB`, timer activo | [01](evidencias/01-instalar-backup.log) |
| 2 | Primera copia (`systemctl start`) | ✅ `success` en **13 s**: 21,8 MB en el RAID **y** en el USB. Al terminar, el USB se desmonta solo | [02](evidencias/02-primera-copia.log) |
| 3 | Segunda copia | ✅ Solo **6,8 MB nuevos** guardados (deduplicación) | [03](evidencias/03-cifrado-y-copias.txt) |
| 4 | **¿Está cifrado?** | ✅ "Cliente de prueba" aparece **5 veces** en el volcado y **0 veces** dentro del repositorio | [03](evidencias/03-cifrado-y-copias.txt) |
| 5 | **¿Se abre sin contraseña?** | ✅ No: `Fatal: wrong password or no key found` | [03](evidencias/03-cifrado-y-copias.txt) |
| 6 | Copias en los dos sitios | ✅ 2 instantáneas en el RAID y 2 en el USB | [03](evidencias/03-cifrado-y-copias.txt) |
| 7 | Programación | ✅ Próxima copia: viernes 23/10 a las 02:36 (02:30 + un retraso aleatorio de hasta 10 min) | [03](evidencias/03-cifrado-y-copias.txt) |
| 8 | **Restauración** | ✅ Ver la **tarea 45** | |

## 5. ⚠️ La contraseña
**Sin la contraseña de cifrado, las copias no sirven para nada**: ni siquiera nosotros podríamos recuperarlas.
- En el servidor: `/root/.config/backup-odoo/restic.pass`.
- **Fuera del servidor**: en la base de **KeePassXC** del proyecto (la misma norma que el resto de contraseñas, tarea 55). En la tienda real, en el KeePassXC del gerente, y además impresa en un sobre cerrado fuera del local. Si el servidor arde, la contraseña no puede arder con él.
- **Corrección del 24/10/2026:** durante la prueba la contraseña se guardó en un fichero de texto en el PC del técnico (`tarea-44/.credenciales-backup`, fuera de Git). Eso contradice la norma del proyecto: hay que pasarla a KeePassXC y **borrar ese fichero**.

## 6. Incidencias
| # | Incidencia | Causa | Solución |
|---|---|---|---|
| 1 | `unable to open cache: neither $XDG_CACHE_HOME nor $HOME are defined` | Los servicios de systemd no tienen `$HOME`, y restic no sabía dónde guardar su caché (iba más lento) | `export RESTIC_CACHE_DIR=/var/cache/restic`. Comprobado: 0 avisos en la siguiente ejecución |
| 2 | Al añadir el disco USB, **todos los discos cambiaron de nombre**: el del sistema pasó de `sda` a `sdd` | Linux numera los discos por orden de detección | Nada se rompió, porque todo se identifica por **UUID** (RAID) o **etiqueta** (`BACKUP_USB`), nunca por `/dev/sdX`. Es una buena lección para la documentación. |

## 7. Pendiente
- [x] Añadir la base de datos de las tareas 38–41 a `backup-odoo.sh` (24/10: se copia si existe `almi_chain`).
- [ ] Crear `almi_chain` en el PostgreSQL del servidor (tarea 40, sección 2) y repetir las pruebas 2 y 6 con las dos bases.
- [x] Pasar la contraseña de restic a KeePassXC y borrar `.credenciales-backup` del PC del técnico (27/10).
- [x] Fijar cada cuánto se renueva la copia fuera del local: cada lunes, con aviso a los 7 días (sección 1).
- [ ] (Mejora) Tercer repositorio en AWS S3, en vez del USB o además de él, para que la copia fuera del local sea automática.
- [ ] Avisar por correo si la copia falla (`OnFailure=` en el servicio).
