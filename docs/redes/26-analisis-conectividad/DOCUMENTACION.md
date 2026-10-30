# Tarea 26 · Análisis de conectividad con Wireshark y nmap

**Responsable:** Eneko.S · **Fechas:** 04–05/11/2026 · **Depende de:** tarea 25 (WDS; y antes, la 24: red segura con invitados)
**Estado:** ⏳ Plan, filtros y script de nmap preparados el 27/10; script probado contra servicios locales. Falta ejecutarlo en la red del local.

Objetivo: comprobar **con herramientas de análisis**, y no solo con `ping`, que la red se comporta como dice el plan de la [tarea 23](../23-plano-direccionamiento.md):

1. **nmap:** qué equipos y qué puertos se ven desde cada red. Lo importante: desde la Wi-Fi de invitados **no se ve la LAN** (hallazgos S-06 y S-13 de la [tarea 46](../../seguridad/46-revision-seguridad/DOCUMENTACION.md)).
2. **Wireshark:** cómo funciona por dentro lo que usa el restaurante (DHCP, DNS, ARP, TCP) y que el tráfico con Odoo va **cifrado**.

Packet Tracer no tiene Wireshark ni nmap (solo enseña paquetes simulados), así que se hace con los equipos reales. Si el día de la prueba no está montada la red física, la parte LAN se puede hacer con las VM del proyecto en `192.168.10.0/24` (servidor de la tarea 52 y TPV provisional) y la parte de invitados queda pendiente.

> ⚠️ Escanear **solo** la red del reto y con permiso del profesor. Escanear redes ajenas puede ser delito.

## 1. Material

- Portátil con Ubuntu (o el PC del gerente arrancado en Ubuntu), con `nmap` y Wireshark: `sudo apt install nmap wireshark` (al instalar Wireshark, aceptar que los usuarios sin privilegios capturen y añadirse al grupo: `sudo usermod -aG wireshark $USER`, cerrar sesión y volver a entrar).
- Acceso a la LAN (cable o Wi-Fi del personal) y a la Wi-Fi de invitados.
- El script [`analizar-red.sh`](analizar-red.sh) de esta carpeta.

## 2. nmap: pruebas automáticas

```bash
bash docs/redes/26-analisis-conectividad/analizar-red.sh lan         # conectado a la LAN
bash docs/redes/26-analisis-conectividad/analizar-red.sh invitados   # conectado a la Wi-Fi de invitados
```

**Si la red del aula no es la del plan.** La práctica de WDS de la tarea 25 ([README](../25-wds/README.md)) se hizo con dos TL-WR841N en `192.168.1.0/24` (router 1 en `.1`, router 2 en `.101`), no con los Archer C6 en `192.168.10.0/24`. Si el día de la prueba la red es esa, se indican las direcciones reales y se apunta en la sección 5:

```bash
RED_LAN=192.168.1.0/24 ROUTER=192.168.1.1 ROUTER2=192.168.1.101 SERVIDOR=<IP> TPV1=<IP> TPV2=<IP> GERENTE=<IP> \
  bash docs/redes/26-analisis-conectividad/analizar-red.sh lan
```

Cada ejecución guarda la salida de cada prueba en `evidencias/<rol>-<fecha>/` y un `resumen.txt` con el veredicto: **OK** (lo esperado), **REVISAR** (no coincide con el plan) o **INFO** (dato para la documentación). Las direcciones salen de la tabla 4.3 de la tarea 23; si alguna cambia: `SERVIDOR=192.168.10.11 bash analizar-red.sh lan`.

### 2.1 Desde la LAN

| # | Prueba | Comando de nmap | Esperado | Resultado |
|---|---|---|---|---|
| L1 | Equipos encendidos | `-sn 192.168.10.0/24` | Los de la tabla 4.3 (.1, .2, .3, .10, .20, .31, .32) | |
| L2 | Servidor, todos los puertos | `-Pn -p- 192.168.10.10` | Solo 22, 80 y 443 (tarea 46, comprobación 2) | |
| L3 | Odoo directo y PostgreSQL | `-Pn -p 8069,5432 192.168.10.10` | Cerrados: solo se entra por nginx | |
| L4 | Servicios y versiones | `-Pn -sV -p 22,80,443 192.168.10.10` | OpenSSH y nginx | |
| L5 | Versiones de TLS | `-Pn --script ssl-enum-ciphers -p 443 192.168.10.10` | Solo TLS 1.2 y 1.3 | |
| L6-L8 | TPV 1, TPV 2 y gerente | `-Pn 192.168.10.31` (y .32, .20) | Ningún puerto abierto (cortafuegos de cada equipo) | |
| L9 | Router 1 | `-Pn -p 21,22,23,53,80,443,1900,8080 192.168.10.1` | DNS y panel web; sin Telnet ni FTP | |

### 2.2 Desde la Wi-Fi de invitados

| # | Prueba | Comando de nmap | Esperado | Resultado |
|---|---|---|---|---|
| I1 | ¿Se ve la LAN? | `-sn 192.168.10.0/24` | 0 equipos (tarea 46, comprobación 1) | |
| I2 | Puertos de la LAN | `-Pn -p 22,80,443,8069 192.168.10.0/24` | Ninguno abierto | |
| I3 | Paneles de los routers | `-Pn -p 80,443 192.168.10.1 192.168.10.2` | Cerrados (tarea 25, W6) | |
| I4 | Otros clientes de invitados | `-sn <red de invitados>/24` | Solo el propio equipo y la puerta de enlace (aislamiento, W7) | |
| I5 | Panel desde la puerta de enlace de invitados | `-Pn -p 80,443 <puerta de enlace>` | Cerrado | |

**Si algo sale REVISAR:** no es un fallo de la prueba, es un hallazgo. Se apunta en la sección 5 y se avisa al responsable (red: Peio, tareas 24 y 25; servidor: Adrian, tarea 52; TPV: Markel e Iker, tareas 13 y 15).

## 3. Wireshark: capturas

Abrir Wireshark, elegir la interfaz (la Wi-Fi o la de cable) y capturar mientras se hace cada acción. Aplicar el filtro de la tabla, hacer la captura de pantalla y guardar la captura (`Archivo → Exportar paquetes especificados`, solo los mostrados) como `.pcapng`.

| # | Qué se ve | Cómo provocarlo | Filtro | Qué hay que señalar en la captura |
|---|---|---|---|---|
| W1 | **DHCP** (Discover, Offer, Request, Ack) | Desconectar y volver a conectar la Wi-Fi (o `sudo dhclient -r && sudo dhclient`) | `dhcp` | Los 4 mensajes, la IP ofrecida, la puerta de enlace y el DNS (opción 6) |
| W2 | **ARP** | `ping` a la puerta de enlace después de `sudo ip neigh flush all` | `arp` | Pregunta *Who has* y respuesta con la MAC |
| W3 | **DNS** | Abrir una web cualquiera | `dns` | Consulta y respuesta; a qué servidor se pregunta (el router) |
| W4 | **TCP**: conexión y rechazo | `nc -zv 192.168.10.10 443` y `nc -zv 192.168.10.10 8069` | `tcp.flags.syn == 1 \|\| tcp.flags.reset == 1` | Tres pasos (SYN, SYN-ACK, ACK) en el 443; en el 8069, RST (cerrado) o nada (filtrado) |
| W5 | **HTTPS con Odoo** | Desde la LAN, entrar en `https://192.168.10.10` con un usuario de prueba | `ip.addr == 192.168.10.10 && tls` | *Client Hello* con la versión de TLS; los datos van como *Application Data*: **no se lee la contraseña** |
| W6 | **Aislamiento de invitados** | Desde la Wi-Fi de invitados, `ping -c 4 192.168.10.10` | `icmp` | Salen los *Echo request* y no vuelve ningún *Echo reply* |
| W7 | Durante el escaneo de nmap | Capturar mientras se ejecuta I2 | `ip.dst == 192.168.10.0/24` | Los SYN que envía nmap sin respuesta (filtrado) |

**Seguridad de las capturas:** una captura puede contener datos de otras personas y, si algo va sin cifrar, contraseñas. Capturar solo durante la prueba, usar un usuario de prueba en Odoo y revisar cada `.pcapng` antes de subirlo. Si alguno tuviera algo sensible, se sube solo la captura de pantalla. gitleaks no analiza los `.pcapng` ni las imágenes.

Para hacerlo desde la terminal (sin la interfaz gráfica), `tshark` acepta los mismos filtros:

```bash
tshark -i wlp2s0 -a duration:30 -w evidencias/w1-dhcp.pcapng     # capturar 30 s
tshark -r evidencias/w1-dhcp.pcapng -Y dhcp                         # ver solo DHCP
```

## 4. Evidencias (en `evidencias/`)

| Fichero | Qué |
|---|---|
| `lan-<fecha>/` y `invitados-<fecha>/` | Salida de `analizar-red.sh` (un `.txt` por prueba y `resumen.txt`) |
| `w1-dhcp.png` … `w7-escaneo.png` | Capturas de pantalla de Wireshark con lo señalado |
| `w1-dhcp.pcapng` … | Capturas filtradas (solo si no tienen datos sensibles) |

## 5. Resultados y hallazgos (rellenar)

| Prueba | Resultado | ¿Coincide con el plan? | Acción |
|---|---|---|---|
| | | | |

## 6. Conclusión (rellenar)

*(¿Está aislada la Wi-Fi de invitados? ¿El servidor solo expone lo necesario? ¿Va cifrado el tráfico con Odoo? ¿Qué hay que corregir y quién?)*

## 7. Pruebas del script (27/10/2026)

`analizar-red.sh` se probó en un Linux con nmap 7.94 contra servicios montados en la propia máquina, sustituyendo las IP por direcciones locales:

| Caso | Resultado |
|---|---|
| «Servidor» con un servicio en el 8069 y otro en el 80 | L2 y L3 dan REVISAR y muestran los puertos abiertos |
| «Servidor» con TLS 1.2 y 1.3 en el 443 (`openssl s_server`) | L5 da OK con `TLSv1.2 TLSv1.3` |
| «TPV», «gerente» y «router» sin servicios | OK |
| Rol `invitados` con los routers sin panel | I2 e I3 dan OK |
| Salida | Un `.txt` por prueba y `resumen.txt` en `evidencias/<rol>-<fecha>/` |

## 8. Pendiente

- [x] Red de invitados aislada (tarea 24, 30/10).
- [ ] WDS (tarea 25) montado.
- [ ] Ejecutar `analizar-red.sh lan` y `analizar-red.sh invitados`.
- [ ] Capturas W1 a W7 con Wireshark.
- [ ] Rellenar las secciones 5 y 6 y avisar de los hallazgos a cada responsable.
- [ ] Marcar como hechas las comprobaciones 1 y 2 de la tarea 46.
