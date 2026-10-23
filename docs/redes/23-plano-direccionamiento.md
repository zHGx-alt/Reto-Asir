# Tarea 23: Plano del local y plan de direccionamiento IP

- **Bloque:** 5 Redes
- **Responsable:** Adrian · **Revisa:** Iker
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** borrador, pendiente de revisión
- **Fecha:** 23/10/2026
- **La necesitan:** tarea 24 (red segura), tarea 25 (WDS) y tarea 11 (diagrama de arquitectura)

## 1. Alcance

El enunciado pide un *"plano del local con cableado y Wi-Fi"* y un *"plan de direccionamiento IP y segmentación (TPV, gerente, clientes, arcade)"*. Este documento recoge las dos cosas:

- **Plano:** dónde va cada equipo, por dónde pasa el cable y dónde se colocan los dos routers Wi-Fi.
- **Direccionamiento:** qué red y qué IP tiene cada equipo, y cómo se separan los grupos.

La configuración del router se hace en las tareas 24 (red segura) y 25 (WDS). Aquí solo se decide qué hay que configurar.

## 2. Supuestos

El enunciado no da el plano ni las medidas del local. Se trabaja con estos supuestos:

| # | Supuesto | Motivo |
|---|---|---|
| S-01 | Local de una planta de 20 × 12 m: despacho, aseos, almacén, cocina, comedor y barra | Tamaño habitual de un restaurante pequeño. Basta para justificar el segundo router (WDS) |
| S-02 | La fibra de DIGI entra por el despacho del gerente y ahí va el armario de red | El despacho es la única estancia que se cierra con llave, así que el router y el servidor quedan fuera del alcance de los clientes |
| S-03 | Internet: DIGI 1 Gb con su router, que hace de ONT ([tarea 22](../gestion/tarea-22.md)) | Operador elegido en la tarea 22 |
| S-04 | Router principal y router WDS: 2 × TP-Link Archer C6 V3 ([tarea 10](../hardware/10-presupuesto-hardware.md), apartado 4.4) | Equipos elegidos en el presupuesto |
| S-05 | No hay switch: los 4 puertos LAN del router principal son todos los puertos con cable | No está en el presupuesto |
| S-06 | Las impresoras de tickets van por USB a su TPV, así que no llevan IP ([tarea 8](../hardware/08-tabla-hardware.md), apartado 3.3) | Decisión de la tarea 8 |
| S-07 | El cable va por canaleta a ras de techo o por falso techo y se usa Cat6 | Soporta 1 Gb/s con margen y es barato |

## 3. Plano del local

![Plano del local](23-plano-local.svg)

Ficheros: [23-plano-local.svg](23-plano-local.svg) (imagen) y [23-plano-local.drawio](23-plano-local.drawio) (se abre y se edita en [app.diagrams.net](https://app.diagrams.net)).

### 3.1 Armario de red (despacho)

En el despacho hay un armario pequeño o una balda con:

- El router de DIGI (ONT), donde llega la fibra.
- El **router 1** (Archer C6, principal), conectado por su puerto WAN al router de DIGI.
- El **servidor de Odoo**, con cable al router 1.

### 3.2 Cableado

| Tirada | Desde → hasta | Puerto del router 1 | Longitud aprox. |
|---|---|---|---|
| 1 | Router 1 → servidor Odoo | LAN 1 | 1 m (dentro del armario) |
| 2 | Router 1 → PC del gerente | LAN 2 | 5 m |
| 3 | Router 1 → TPV 1 (barra) | LAN 3 | 20 m |
| 4 | Router 1 → TPV 2 (barra) | LAN 4 | 24 m |
| — | Router de DIGI → router 1 (WAN) | WAN | 1 m |

Las longitudes salen del plano y llevan holgura para las bajadas por la pared. Todas están muy por debajo del límite de 100 m del Ethernet. Con esto se ocupan los 4 puertos LAN, así que **no queda ningún puerto libre para la recreativa** (ver apartado 5.2).

### 3.3 Wi-Fi

- **Router 1** en el armario del despacho: cubre el despacho, los aseos, el almacén y la mitad izquierda del comedor.
- **Router 2** en la pared del comedor, cerca de la entrada y de la barra: cubre la barra, la entrada y la mitad derecha del comedor. Se une al router 1 por **WDS** (tarea 25), sin cable.
- Entre los dos debe quedar zona solapada para que los móviles pasen de uno a otro. Los círculos del plano son aproximados: la cobertura real se mide en la tarea 25 con una app tipo Wi-Fi Analyzer.

## 4. Plan de direccionamiento

### 4.1 Redes

| Red | Subred | Puerta de enlace | DHCP | Para qué |
|---|---|---|---|---|
| LAN del local | `192.168.10.0/24` | `192.168.10.1` (router 1) | Router 1 | Servidor, gerente, TPV y routers |
| Wi-Fi de invitados | `192.168.20.0/24` *(a comprobar, ver 4.4)* | Router 1 | Router 1 | Móviles de clientes y recreativa |
| WAN | La que dé el router de DIGI | Router de DIGI | Router de DIGI | Enlace entre el router 1 y DIGI |

**Por qué `192.168.10.0/24` y no `192.168.1.0/24`:** los routers de operador suelen venir con `192.168.1.0/24`. Si nuestra LAN usara la misma red que hay detrás del router de DIGI, el router 1 tendría la misma red a los dos lados y no sabría por dónde enviar el tráfico. Además, `192.168.10.x` es lo que ya proponía el diagrama de la [tarea 11](../diagramas/11-arquitectura-equipos/DIAGRAMA.md).

### 4.2 Rangos dentro de la LAN

Las IPs de los equipos fijos se dan por **reserva DHCP** (el router siempre da la misma IP a la misma MAC). Así no hay que configurar nada en cada equipo y todo queda apuntado en un solo sitio, el router.

| Rango | Uso |
|---|---|
| .1 | Router 1 (puerta de enlace, DHCP y DNS) |
| .2 | Router 2 (WDS) |
| .3–.9 | Reservado para red (por ejemplo, un switch en el futuro) |
| .10–.19 | Servidores |
| .20–.29 | Gerencia |
| .30–.39 | TPV |
| .40–.49 | Impresoras (solo si algún día van por red) |
| .50–.59 | Arcade (si la recreativa vuelve a ir por cable) |
| .100–.199 | DHCP dinámico: portátiles y móviles del personal |
| .200–.254 | Libre |

### 4.3 Equipos

| Equipo | IP | Cómo la obtiene | Conexión | MAC |
|---|---|---|---|---|
| Router 1 (Archer C6) | 192.168.10.1 | Fija en el router | — | *(apuntar al montarlo)* |
| Router 2 (Archer C6, WDS) | 192.168.10.2 | Fija en el router, con su DHCP apagado | WDS | *(apuntar)* |
| Servidor Odoo | 192.168.10.10 | Reserva DHCP | Cable, LAN 1 | *(apuntar)* |
| PC del gerente | 192.168.10.20 | Reserva DHCP | Cable, LAN 2 | *(apuntar)* |
| TPV 1 | 192.168.10.31 | Reserva DHCP | Cable, LAN 3 | *(apuntar)* |
| TPV 2 | 192.168.10.32 | Reserva DHCP | Cable, LAN 4 | *(apuntar)* |
| Impresora TPV 1 | — (USB) | — | USB al TPV 1 | — |
| Impresora TPV 2 | — (USB) | — | USB al TPV 2 | — |
| Recreativa | Rango de invitados | DHCP de invitados | Wi-Fi de invitados | *(apuntar)* |
| Móviles de clientes | Rango de invitados | DHCP de invitados | Wi-Fi de invitados | — |

- **DNS:** los equipos usan el router 1 (`192.168.10.1`) como DNS y el router reenvía a DNS públicos (por ejemplo `9.9.9.9` y `1.1.1.1`).
- **Duración de la concesión DHCP:** 24 h en la LAN y 2 h en invitados, porque los clientes entran y salen.

### 4.4 Redes Wi-Fi

| SSID | Seguridad | Red | Quién se conecta |
|---|---|---|---|
| `Restaurante-Almichain` | WPA3-Personal (o WPA2/WPA3 mixto si algún equipo no soporta WPA3) | LAN | Personal |
| `Restaurante-Almichain-Invitados` | WPA2/WPA3, contraseña distinta y que se cambia cada cierto tiempo | Invitados | Clientes y recreativa |

Se mantienen los nombres de la [tarea 24](../evidencias/Configurar-red-segura/configurar-red-segura.md).

**A comprobar en la tarea 24:** no está confirmado que la red de invitados del Archer C6 use una subred propia (`192.168.20.0/24`). Algunos routers domésticos dan a los invitados IPs del mismo rango que la LAN y los aíslan solo con reglas internas. Lo importante es el aislamiento, que se prueba igual en los dos casos (apartado 6). La subred que asigne el router de verdad se apunta en esta tabla.

## 5. Segmentación

El enunciado pide separar **TPV, gerente, clientes y arcade**.

### 5.1 Quién puede hablar con quién

| Desde ↓ / Hacia → | Servidor Odoo | TPV | PC gerente | Internet |
|---|---|---|---|---|
| **TPV** | Sí (TPV de Odoo, puerto 8069) | — | No hace falta | Sí |
| **PC gerente** | Sí (Odoo y administración) | No hace falta | — | Sí |
| **Clientes** | **No** | **No** | **No** | Sí |
| **Recreativa** | **No** | **No** | **No** | Sí (actualizaciones) |

### 5.2 Lo que se monta con el hardware actual

El Archer C6 con su firmware de fábrica **no tiene VLANs**: todos sus puertos LAN están en la misma red. Con lo que hay se consigue esto:

1. **Clientes aislados:** van a la Wi-Fi de invitados, que solo tiene salida a internet y no ve la LAN.
2. **Recreativa aislada:** también va a la **Wi-Fi de invitados**, no por cable. Tiene dos ventajas:
   - Queda separada de los TPV y del servidor, como pide el enunciado.
   - No hace falta un switch, porque los 4 puertos LAN ya están ocupados (apartado 3.2).
   
   Si el PC de la recreativa no trae Wi-Fi, hace falta un adaptador USB Wi-Fi (unos 10 €), que se añadiría al presupuesto de la tarea 10.
3. **TPV y gerente separados por rangos:** están en la misma red, pero en rangos distintos (.30 y .20). Eso ordena la red y facilita el firewall y los registros, aunque **no impide** que un TPV vea el PC del gerente. Para compensarlo:
   - Los TPV usan un usuario estándar en modo quiosco (tarea 13).
   - El PC del gerente tiene activado el firewall de Windows, que bloquea las conexiones entrantes.

**Contrapartida:** desde la LAN no se llega a la recreativa por SSH, que es lo que usan los scripts de monitorización de la [tarea 18](../arcade/18-monitorizacion-recreativa.md). Para las pruebas, se conecta un portátil a la Wi-Fi de invitados o se trabaja directamente en la recreativa.

### 5.3 Diseño ideal (mejora)

Con un router que admita VLANs (por ejemplo, uno compatible con OpenWrt) o un switch gestionable, cada grupo tendría su propia red, y el firewall del router solo dejaría pasar lo que marca la tabla 5.1:

| VLAN | Nombre | Subred | Equipos |
|---|---|---|---|
| 10 | Servidores | 192.168.10.0/24 | Servidor Odoo |
| 20 | TPV | 192.168.20.0/24 | TPV 1 y 2 (e impresoras si van por red) |
| 30 | Gerencia | 192.168.30.0/24 | PC del gerente |
| 40 | Arcade | 192.168.40.0/24 | Recreativa |
| 50 | Invitados | 192.168.50.0/24 | Móviles de clientes |
| 99 | Gestión | 192.168.99.0/24 | Panel de administración de routers y switch |

Haría falta un switch gestionable de 8 puertos o cambiar de router. Con el Archer C6 de fábrica no se puede montar, así que se ha comprobado en Packet Tracer (apartado 5.4).

### 5.4 Simulación en Packet Tracer

Fichero: [23-segmentacion-vlan.pkt](23-segmentacion-vlan.pkt) (Packet Tracer 9.0.1).

![Topología en Packet Tracer](23-segmentacion-vlan.png)

**Montaje:**
- Router **R1** (Cisco 2911) y switch **SW1** (2960-24TT) unidos por un *trunk* (`R1 Gi0/0` ↔ `SW1 Gi0/1`).
- R1 tiene una subinterfaz por VLAN (`Gi0/0.10` … `Gi0/0.99`), que hace de puerta de enlace `.1` de cada red. Este montaje se llama *router-on-a-stick*.
- R1 reparte las IPs por DHCP, con un pool por VLAN que empieza en `.10`. El servidor tiene IP fija: `192.168.10.10`.
- SW1 se administra desde la VLAN 99 (`192.168.99.2`).

| Puerto de SW1 | VLAN | Equipo | IP obtenida |
|---|---|---|---|
| Fa0/1 | 10 Servidores | SRV-ODOO | 192.168.10.10 (fija) |
| Fa0/2 | 20 TPV | TPV1 | 192.168.20.10 |
| Fa0/3 | 20 TPV | TPV2 | 192.168.20.11 |
| Fa0/4 | 30 Gerencia | GERENTE | 192.168.30.10 |
| Fa0/5 | 40 Arcade | RECREATIVA | 192.168.40.10 |
| Fa0/6 | 50 Invitados | CLIENTE | 192.168.50.10 |

**ACLs en R1** (de entrada en cada subinterfaz; aplican la tabla 5.1):

| ACL | Subinterfaz | Qué deja pasar |
|---|---|---|
| `TPV-IN` | Gi0/0.20 | DHCP; HTTP (80) y ping al servidor; nada más hacia redes internas; resto (internet) sí |
| `GERENCIA-IN` | Gi0/0.30 | DHCP; todo hacia el servidor y hacia la VLAN de gestión; nada más hacia redes internas; resto sí |
| `AISLADA-IN` | Gi0/0.40 y Gi0/0.50 | DHCP; ninguna red interna (`192.168.0.0/16`); resto sí |

En Packet Tracer no existe Odoo. El servidor responde por HTTP en el puerto 80 en lugar del 8069 del local real.

**Pruebas** (ping desde cada equipo, 23/10/2026):

| # | Desde → hasta | Esperado | Resultado |
|---|---|---|---|
| 1 | TPV1 → servidor (192.168.10.10) | Llega | 4/4 ✔ |
| 2 | GERENTE → servidor | Llega | 4/4 ✔ |
| 3 | GERENTE → SW1, gestión (192.168.99.2) | Llega | 4/4 ✔ |
| 4 | TPV1 → GERENTE (192.168.30.10) | Bloqueado | 0/4 ✔ |
| 5 | GERENTE → TPV1 (192.168.20.10) | Bloqueado | 0/4 ✔ |
| 6 | CLIENTE → servidor | Bloqueado | 0/4 ✔ |
| 7 | CLIENTE → RECREATIVA (192.168.40.10) | Bloqueado | 0/4 ✔ |
| 8 | RECREATIVA → TPV1 | Bloqueado | 0/4 ✔ |

El primer ping de cada pareja pierde 1 o 2 paquetes mientras se resuelve la dirección MAC (ARP). En las tablas se pone el resultado de la repetición.

`show access-lists` en R1 confirma que los bloqueos los hacen las ACLs y no un fallo de red: suben los contadores de las líneas `deny ip any 192.168.0.0 0.0.255.255` de `TPV-IN`, `GERENCIA-IN` y `AISLADA-IN`.

**Acceso web del TPV al servidor:** desde TPV1, *Desktop → Web Browser* con `http://192.168.10.10`, se abre la página del servidor. En `show access-lists TPV-IN`, la línea `permit tcp … host 192.168.10.10 eq www` registra 5 coincidencias, así que el tráfico pasa por la regla prevista.

![Navegador del TPV1 abriendo el servidor](23-prueba-http-tpv1.png)

## 6. Cómo se comprueba

Estas pruebas se hacen en las tareas 24 y 25, con el router montado. Se dejan apuntadas aquí para que cuadren con el plan:

| # | Prueba | Resultado esperado |
|---|---|---|
| 1 | `ipconfig` en el TPV 1 / `ip addr` en el servidor | 192.168.10.31 / 192.168.10.10, puerta de enlace .1 |
| 2 | Desde el TPV 1, abrir `http://192.168.10.10:8069` | Abre Odoo |
| 3 | Móvil en la Wi-Fi de invitados: abrir una web | Funciona |
| 4 | Móvil en la Wi-Fi de invitados: `ping 192.168.10.10` y abrir `http://192.168.10.10:8069` | No responde |
| 5 | Recreativa: `ping 192.168.10.31` | No responde |
| 6 | Ver la lista de clientes DHCP en el router | Cada equipo fijo tiene su IP reservada |
| 7 | Móvil en el comedor junto al router 2 | Conectado al router 2 con buena señal |

## 7. Cambios que provoca en otras tareas

| Tarea | Qué hay que cambiar |
|---|---|
| 24 · Red segura (Peio) | Las capturas son de un TL-WR841N con la LAN en `192.168.1.0/24`. Al montar los Archer C6 hay que poner la LAN en `192.168.10.0/24`, configurar las reservas de la tabla 4.3 y documentar la red de invitados |
| 25 · WDS | Router 2 en 192.168.10.2, DHCP apagado y colocado donde marca el plano |
| 11 · Diagrama de arquitectura (Iker) | Pasar el direccionamiento de "propuesta" a definitivo. La recreativa va por la Wi-Fi de invitados, no por cable |
| 10 · Presupuesto | Las IPs de ejemplo de las impresoras (.21 y .22) pasan al rango .40–.49 si algún día van por red. Añadir el adaptador USB Wi-Fi de la recreativa si hace falta |
| 18 · Monitorización de la recreativa | Las pruebas por SSH se hacen desde la Wi-Fi de invitados (apartado 5.2) |

## 8. Pendiente

- [ ] Revisión de Iker.
- [ ] Apuntar las MAC de los equipos cuando estén montados.
- [ ] Confirmar en la tarea 24 qué subred da el Archer C6 a la red de invitados.
- [ ] Confirmar si el PC de la recreativa tiene Wi-Fi.
- [x] Simular el diseño con VLANs en Packet Tracer (apartado 5.4).
- [x] Probar en Packet Tracer el acceso HTTP del TPV al servidor desde el navegador.
