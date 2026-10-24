# Tarea 23 · Simulación en Packet Tracer de la red del local

- **Responsable:** Adrian · **Revisa:** Iker
- **Qué se construye:** `23-red-local.pkt`, la simulación de **la red que se monta de verdad** (decisión del [apartado 5.2 de la tarea 23](23-plano-direccionamiento.md#52-decisión-red-plana-con-red-de-invitados-aislada-24102026)): Internet y el router del operador, el router 1 con NAT, la LAN del personal, la Wi-Fi del personal, la Wi-Fi de invitados aislada y el router 2 que la amplía.
- **De dónde se parte:** del [`23-anexo-vlan.pkt`](23-anexo-vlan.pkt) (se reutilizan R1, SW1 y los equipos). El anexo no se toca: se guarda con otro nombre.
- **Tiempo estimado:** 1 h 30 min, con las pruebas y las capturas.
- **Resultado de aprendizaje que demuestra:** RA.7 de PAR («conecta redes privadas a redes públicas»): NAT, red pública y red privada. Además, RA.2 de PAR (equipos cableados e inalámbricos) y la red configurada de forma segura del enunciado.

> Las contraseñas de los comandos (`<CLAVE-...>`) se generan en KeePassXC y **no se escriben en el repositorio**. Con `service password-encryption` y `secret` quedan cifradas dentro del `.pkt`.

## 0. Cómo queda

```
INTERNET (Server-PT 198.51.100.10: web y DNS)
   │ Gi0/1
ISP (2911) ── Gi0/0 203.0.113.1/30 ══ red pública ══ 203.0.113.2/30 Gi0/1 ── R1
                                                                                │ Gi0/0 (trunk: VLAN 10 y 50)
R1 = router 1 (Archer C6): NAT, DHCP, red de invitados aislada, SSH solo desde el gerente
   │
SW1 (2960) · gestión 192.168.10.3
   ├─ Fa0/1 SRV-ODOO .10   Fa0/2 TPV1 .31   Fa0/3 TPV2 .32   Fa0/4 GERENTE .20      ─┐ VLAN 10
   ├─ Fa0/5 AP-PERSONAL  ·  Wi-Fi «Restaurante-Almichain» (personal)                ─┘ LAN 192.168.10.0/24
   ├─ Fa0/6 AP-INVITADOS ·  Wi-Fi «Restaurante-Almichain-Invitados»                 ─┐ VLAN 50
   └─ Fa0/7 ROUTER2-WDS  ·  mismo SSID: amplía la Wi-Fi de clientes                 ─┘ invitados 192.168.50.0/24
                ─ ─ ─ Wi-Fi ─ ─ ─ CLIENTE (portátil) · RECREATIVA
```

**Lo que es igual y lo que cambia respecto al local** (para explicarlo en la defensa):

| En el local | En Packet Tracer | Por qué |
|---|---|---|
| Archer C6 con LAN y red de invitados | R1 con dos subinterfaces (VLAN 10 y 50) y la ACL `INVITADOS-IN` | Es lo que el Archer hace por dentro: dos redes y la de invitados sin acceso a la LAN |
| Router 2 en modo WDS | AccessPoint-PT `ROUTER2-WDS` con el mismo SSID | En WDS el router 2 es un **puente**, no enruta ni reparte IP; Packet Tracer no tiene WDS y el punto de acceso es el aparato que se comporta igual. El cable representa el enlace por radio |
| IP fijas por reserva DHCP | IP fijas configuradas en cada equipo | Las reservas por MAC en IOS son engorrosas; el resultado (siempre la misma IP) es el mismo |
| DNS: el router 1 | DNS: el servidor INTERNET | R1 no hace de DNS en Packet Tracer |
| Windows Firewall con entrada **y salida** limitadas (TPV) | Cortafuegos de los PC de Packet Tracer (solo entrada) | Packet Tracer no filtra la salida en los PC; la entrada basta para probar que TPV y gerente no se ven |
| Odoo por HTTPS (tarea 52) | Servicio HTTPS del Server-PT | Mismo puerto y mismo resultado |

## 1. Preparar el fichero

1. Abrir `23-anexo-vlan.pkt` y **guardarlo como** `docs/redes/23-red-local.pkt` (*File → Save As*). Desde aquí se trabaja solo en el nuevo.
2. En R1, apuntar los pools de DHCP y las exclusiones del diseño anterior (hacen falta en el paso 3.1):
   ```
   enable
   show running-config | include ip dhcp
   ```
3. Borrar los cables de **RECREATIVA** (a `SW1 Fa0/5`) y de **CLIENTE** (a `SW1 Fa0/6`): los dos pasan a ir por Wi-Fi.

## 2. Red pública: ISP e Internet

Añadir:

| Equipo | Modelo | Conexión |
|---|---|---|
| `ISP` | Router 2911 | `ISP Gi0/0` ↔ `R1 Gi0/1` (cobre directo) |
| `INTERNET` | Server-PT | `INTERNET Fa0` ↔ `ISP Gi0/1` |

**INTERNET** (*Desktop → IP Configuration*): IP `198.51.100.10`, máscara `255.255.255.0`, puerta de enlace `198.51.100.1`, DNS `198.51.100.10`. En *Services*: **HTTP** encendido (cambiar `index.html` por «Internet de prueba · ISP») y **DNS** encendido, con un registro `A`: `internet.test` → `198.51.100.10`.

**ISP** (CLI):

```
enable
configure terminal
hostname ISP
interface GigabitEthernet0/0
 description Enlace con el cliente Almi-Chain (R1)
 ip address 203.0.113.1 255.255.255.252
 no shutdown
interface GigabitEthernet0/1
 description Red de Internet de prueba
 ip address 198.51.100.1 255.255.255.0
 no shutdown
end
write memory
```

El ISP **no tiene ninguna ruta** hacia `192.168.0.0/16`: desde Internet no se llega a la red privada, como en la realidad.

## 3. R1 (router 1)

### 3.1 Quitar el diseño con VLAN por grupo

```
configure terminal
no interface GigabitEthernet0/0.20
no interface GigabitEthernet0/0.30
no interface GigabitEthernet0/0.40
no interface GigabitEthernet0/0.99
no ip access-list extended TPV-IN
no ip access-list extended GERENCIA-IN
no ip access-list extended AISLADA-IN
```

Y, con lo apuntado en el paso 1.2, cada pool y cada exclusión: `no ip dhcp pool <nombre>` y `no ip dhcp excluded-address <inicio> <fin>`. Si Packet Tracer no deja borrar una subinterfaz, basta con `interface GigabitEthernet0/0.20` → `shutdown` → `no ip address`.

### 3.2 LAN del personal, red de invitados y DHCP

```
ip access-list extended INVITADOS-IN
 remark Invitados y recreativa: DHCP e Internet; nada de la red privada, ni el propio router
 permit udp any eq bootpc any eq bootps
 deny ip any 192.168.0.0 0.0.255.255
 permit ip any any
interface GigabitEthernet0/0.10
 description LAN del personal
 encapsulation dot1Q 10
 ip address 192.168.10.1 255.255.255.0
interface GigabitEthernet0/0.50
 description Wi-Fi de invitados (clientes y recreativa)
 encapsulation dot1Q 50
 ip address 192.168.50.1 255.255.255.0
 ip access-group INVITADOS-IN in
exit
ip dhcp excluded-address 192.168.10.1 192.168.10.99
ip dhcp excluded-address 192.168.10.200 192.168.10.254
ip dhcp excluded-address 192.168.50.1 192.168.50.9
ip dhcp pool LAN-PERSONAL
 network 192.168.10.0 255.255.255.0
 default-router 192.168.10.1
 dns-server 198.51.100.10
ip dhcp pool INVITADOS
 network 192.168.50.0 255.255.255.0
 default-router 192.168.50.1
 dns-server 198.51.100.10
```

Los rangos son los del [plan de direccionamiento](23-plano-direccionamiento.md#42-rangos-dentro-de-la-lan): `.1-.99` para equipos fijos y red, `.100-.199` dinámico para el personal.

### 3.3 WAN y NAT con sobrecarga (PAT)

```
interface GigabitEthernet0/1
 description WAN hacia el ISP (DIGI)
 ip address 203.0.113.2 255.255.255.252
 ip nat outside
 no shutdown
interface GigabitEthernet0/0.10
 ip nat inside
interface GigabitEthernet0/0.50
 ip nat inside
exit
ip route 0.0.0.0 0.0.0.0 203.0.113.1
access-list 1 remark Redes del local que salen a Internet
access-list 1 permit 192.168.10.0 0.0.0.255
access-list 1 permit 192.168.50.0 0.0.0.255
ip nat inside source list 1 interface GigabitEthernet0/1 overload
```

### 3.4 Seguridad: solo SSH y solo desde el PC del gerente

Es lo mismo que la tarea 24 pide en el router real («administración limitada al PC del gerente»):

```
hostname R1
service password-encryption
enable secret <CLAVE-ENABLE-R1>
username admin privilege 15 secret <CLAVE-ADMIN-R1>
ip domain-name almichain.local
crypto key generate rsa general-keys modulus 2048
ip ssh version 2
ip access-list standard ADMIN-GERENTE
 permit host 192.168.10.20
line console 0
 login local
line vty 0 4
 login local
 transport input ssh
 access-class ADMIN-GERENTE in
banner motd # Acceso solo para personal autorizado de Almi-Chain #
end
write memory
```

## 4. SW1

```
enable
configure terminal
hostname SW1
vlan 10
 name LAN-PERSONAL
vlan 50
 name INVITADOS
vlan 999
 name SIN-USO
exit
no vlan 20
no vlan 30
no vlan 40
no vlan 99
interface range FastEthernet0/1 - 5
 description LAN del personal: servidor, TPV, gerente y AP del personal
 switchport mode access
 switchport access vlan 10
 no shutdown
interface range FastEthernet0/6 - 7
 description Invitados: AP de invitados y router 2 (WDS)
 switchport mode access
 switchport access vlan 50
 no shutdown
interface range FastEthernet0/8 - 24
 description Libre: apagado
 switchport mode access
 switchport access vlan 999
 shutdown
interface GigabitEthernet0/2
 shutdown
interface GigabitEthernet0/1
 description Trunk hacia R1
 switchport mode trunk
 switchport trunk allowed vlan 10,50
no interface Vlan99
interface Vlan10
 ip address 192.168.10.3 255.255.255.0
 no shutdown
ip default-gateway 192.168.10.1
service password-encryption
enable secret <CLAVE-ENABLE-SW1>
username admin privilege 15 secret <CLAVE-ADMIN-SW1>
ip domain-name almichain.local
crypto key generate rsa general-keys modulus 2048
ip ssh version 2
ip access-list standard ADMIN-GERENTE
 permit host 192.168.10.20
line console 0
 login local
line vty 0 15
 login local
 transport input ssh
 access-class ADMIN-GERENTE in
banner motd # Acceso solo para personal autorizado de Almi-Chain #
end
write memory
```

`192.168.10.3` está en el rango reservado a equipos de red del plan (`.3-.9`).

## 5. Equipos con cable

*Desktop → IP Configuration → Static* en cada uno (máscara `255.255.255.0`, puerta de enlace `192.168.10.1`, DNS `198.51.100.10`):

| Equipo | IP | Notas |
|---|---|---|
| SRV-ODOO | `192.168.10.10` | En *Services*: **HTTP** apagado y **HTTPS** encendido (representa Odoo detrás del proxy, tarea 52) |
| GERENTE | `192.168.10.20` | — |
| TPV1 | `192.168.10.31` | — |
| TPV2 | `192.168.10.32` | — |

## 6. Wi-Fi

1. Añadir tres **AccessPoint-PT** y conectarlos con cable recto a SW1:

   | Nombre | Puerto de SW1 | SSID (*Config → Port 1*) | Seguridad |
   |---|---|---|---|
   | `AP-PERSONAL` | Fa0/5 | `Restaurante-Almichain` | WPA2-PSK, AES, `<CLAVE-WIFI-PERSONAL>` |
   | `AP-INVITADOS` | Fa0/6 | `Restaurante-Almichain-Invitados` | WPA2-PSK, AES, `<CLAVE-WIFI-INVITADOS>` |
   | `ROUTER2-WDS` | Fa0/7 | `Restaurante-Almichain-Invitados` (el mismo) | La misma que `AP-INVITADOS` |

   Packet Tracer no tiene WPA3: en el local, WPA3 o WPA2/WPA3 (tarea 24).
2. Poner una **nota** junto a `ROUTER2-WDS`: «Router 2 · Archer C6 en modo WDS (puente). El cable representa el enlace por radio con el router 1 (tarea 25)».
3. **CLIENTE** (Laptop-PT): apagarlo (botón del equipo, pestaña *Physical*), quitar el módulo de cable y poner el **WPC300N**; encenderlo. En *Desktop → PC Wireless → Connect*, elegir la red de invitados y poner la clave. *IP Configuration* en **DHCP**.
4. **RECREATIVA** (PC-PT): igual, con el módulo **WMP300N**, en la red de invitados y por DHCP.
5. (Opcional) Un **SMARTPHONE-PT** `MOVIL-PERSONAL` en la Wi-Fi del personal: tiene que recibir una IP `192.168.10.1xx`.

## 7. Cortafuegos de los equipos

En la red plana, TPV, gerente y servidor comparten red: lo que los separa es el cortafuegos de cada uno, como en el local. En *Desktop → Firewall* (IPv4), ponerlo en **On** y añadir las reglas **en este orden** (la última, «Allow IP» o «Deny IP», deja claro qué pasa con el resto):

| Equipo | Reglas (Action · Protocol · Remote IP · Remote Wildcard) |
|---|---|
| **TPV1** y **TPV2** | `Deny · ICMP · 192.168.10.20 · 0.0.0.0` · `Deny · TCP · 192.168.10.20 · 0.0.0.0` · `Allow · IP · 0.0.0.0 · 255.255.255.255` |
| **GERENTE** | `Deny · ICMP · 192.168.10.31 · 0.0.0.0` · `Deny · ICMP · 192.168.10.32 · 0.0.0.0` · `Deny · TCP · 192.168.10.31 · 0.0.0.0` · `Deny · TCP · 192.168.10.32 · 0.0.0.0` · `Allow · IP · 0.0.0.0 · 255.255.255.255` |
| **SRV-ODOO** | `Allow · TCP · 192.168.10.0 · 0.0.0.255` (HTTPS desde la LAN) · `Allow · ICMP · 192.168.10.0 · 0.0.0.255` · `Deny · IP · 0.0.0.0 · 255.255.255.255` |

En el local, esto lo hacen `configurar-tpv.ps1` (tareas 13 y 15), el Firewall de Windows y `ufw` del gerente (tarea 12) y [`cortafuegos-servidor.sh`](../erp/33-odoo-docker/cortafuegos-servidor.sh).

## 8. Pruebas

Hacer cada una y apuntar el resultado en la tabla de pruebas de la [tarea 23](23-plano-direccionamiento.md#6-cómo-se-comprueba). Las marcadas con 📷 llevan captura. El primer ping de cada pareja puede perder 1 o 2 paquetes por ARP: se apunta el de la repetición.

| # | Desde → hasta | Esperado | Qué demuestra |
|---|---|---|---|
| 1 | TPV1 → `ipconfig` | `192.168.10.31`, puerta de enlace `.1` | Plan de direccionamiento |
| 2 | TPV1 → navegador `https://192.168.10.10` 📷 | Abre la página del servidor | El TPV llega a Odoo cifrado |
| 3 | TPV1 → `ping 192.168.10.20` (gerente) | Falla | Cortafuegos del gerente |
| 4 | GERENTE → `ping 192.168.10.31` (TPV1) | Falla | Cortafuegos del TPV |
| 5 | GERENTE → `ping 192.168.10.10` | Llega | El gerente sí llega al servidor |
| 6 | CLIENTE (Wi-Fi) → `ipconfig` | `192.168.50.x`, puerta de enlace `192.168.50.1` | DHCP de invitados |
| 7 | CLIENTE → navegador `http://internet.test` 📷 | Abre la página del ISP | DNS y NAT: red privada → pública (RA.7) |
| 8 | CLIENTE → `ping 192.168.10.10` | Falla | Invitados aislados de la LAN (`INVITADOS-IN`) |
| 9 | RECREATIVA → `ping 192.168.10.31` | Falla | La recreativa no ve la caja |
| 10 | CLIENTE → `ping 192.168.50.1` | Falla | Los invitados no llegan ni al router |
| 11 | R1 → `show ip nat translations` 📷 | Traducciones de `192.168.x.x` a `203.0.113.2` | NAT con sobrecarga |
| 12 | INTERNET → `ping 192.168.10.10` | Falla | Desde Internet no se llega a la red privada |
| 13 | GERENTE → *Command Prompt* `ssh -l admin 192.168.10.1` y `ssh -l admin 192.168.10.3` 📷 | Pide la contraseña y entra | Administración solo por SSH |
| 14 | TPV1 → `ssh -l admin 192.168.10.1` | Rechazado | Administración solo desde el gerente (`ADMIN-GERENTE`) |
| 15 | Apagar `AP-INVITADOS` (*Config → Port 1 → Port Status: Off*) 📷 | CLIENTE pasa a `ROUTER2-WDS` y sigue navegando (si no se asocia solo, *PC Wireless → Connect*) | El router 2 amplía la Wi-Fi de clientes |
| 16 | R1 → `show access-lists INVITADOS-IN` | Suben los contadores de la línea `deny ip any 192.168.0.0 0.0.255.255` | Los bloqueos los hace la ACL, no un fallo de red |

**No se puede probar en Packet Tracer:** el aislamiento entre clientes de la Wi-Fi de invitados (un móvil no ve a otro). Se prueba en el Archer C6 (tarea 24).

## 9. Al terminar

- [ ] Guardar `23-red-local.pkt` y la captura de la topología como `23-red-local.png` en `docs/redes/`.
- [ ] Pasar la tabla de pruebas al apartado 5.4 de la [tarea 23](23-plano-direccionamiento.md#54-simulación-en-packet-tracer-de-la-red-real) y enlazar el `.pkt` y la captura (sustituyen al «Pendiente» de la tabla de ficheros).
- [ ] Guardar en KeePassXC las contraseñas de R1, SW1 y las Wi-Fi de prueba.
- [ ] Marcar el punto en [CORRECIONES.md](../../CORRECIONES.md#42-packet-tracer-tarea-23) y en el CSV (tarea 23).
