# Tarea 23 · Completar la simulación de Packet Tracer (WAN, NAT, Wi-Fi y seguridad)

- **Responsable:** Adrian · **Revisa:** Iker
- **Para qué:** el [`.pkt`](23-segmentacion-vlan.pkt) solo tiene la red interna. Falta la red pública (RA.7 de PAR: «conecta redes privadas a redes públicas»), la Wi-Fi y la seguridad de R1 y SW1 ([tarea 23, apartado 5.4](23-plano-direccionamiento.md#54-simulación-en-packet-tracer)). Esta guía tiene **los comandos listos para pegar** en la CLI de cada equipo.
- **Tiempo estimado:** 1 h, más las capturas.
- **Si el equipo elige la red plana** (opción (b) del [apartado 5.5](23-plano-direccionamiento.md#55-decisión-pendiente-red-real-plana-o-con-vlan)), las secciones 1, 2 y 4 sirven igual; solo cambia la red interna.

> Las contraseñas de los comandos (`<CLAVE-...>`) se generan en KeePassXC y **no se escriben en el repositorio**. Packet Tracer guarda la configuración dentro del `.pkt`: con `service password-encryption` y `secret` quedan cifradas.

## 0. Antes de empezar

En R1, apuntar cómo se llaman los pools de DHCP (hacen falta en el paso 2.3):

```
show running-config | include ip dhcp pool
```

## 1. Red pública: ISP e Internet

Añadir al lienzo:

| Equipo | Modelo | Conexión |
|---|---|---|
| `ISP` | Router 2911 | `ISP Gi0/0` ↔ `R1 Gi0/1` (cobre directo) |
| `INTERNET` | Server-PT | `INTERNET Fa0` ↔ `ISP Gi0/1` |

**INTERNET** (*Desktop → IP Configuration*): IP `198.51.100.10`, máscara `255.255.255.0`, puerta de enlace `198.51.100.1`, DNS `198.51.100.10`.
En *Services*: **HTTP** encendido (cambiar el `index.html` por «Internet de prueba (ISP)») y **DNS** encendido con el registro `A` `internet.test` → `198.51.100.10`.

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

## 2. R1: WAN, NAT y DNS

### 2.1 WAN y ruta por defecto

```
enable
configure terminal
interface GigabitEthernet0/1
 description WAN hacia el ISP (DIGI)
 ip address 203.0.113.2 255.255.255.252
 ip nat outside
 no shutdown
ip route 0.0.0.0 0.0.0.0 203.0.113.1
```

### 2.2 NAT con sobrecarga (PAT)

```
interface GigabitEthernet0/0.10
 ip nat inside
interface GigabitEthernet0/0.20
 ip nat inside
interface GigabitEthernet0/0.30
 ip nat inside
interface GigabitEthernet0/0.40
 ip nat inside
interface GigabitEthernet0/0.50
 ip nat inside
interface GigabitEthernet0/0.99
 ip nat inside
exit
access-list 1 remark Redes internas que salen a Internet por NAT
access-list 1 permit 192.168.0.0 0.0.255.255
ip nat inside source list 1 interface GigabitEthernet0/1 overload
```

### 2.3 DNS en cada pool de DHCP

Con los nombres del paso 0 (uno por VLAN; ejemplo con un pool llamado `VLAN20`):

```
ip dhcp pool VLAN20
 dns-server 198.51.100.10
```

El servidor de la VLAN 10 tiene IP fija: ponerle a mano el DNS `198.51.100.10` en *IP Configuration*. Después, en cada PC: *IP Configuration → DHCP* otra vez para que coja el DNS.

## 3. Wi-Fi: invitados y «WDS»

Añadir:

| Equipo | Modelo | Conexión | Uso |
|---|---|---|---|
| `AP-INVITADOS` | AccessPoint-PT | `SW1 Fa0/7` | Wi-Fi de invitados (router 1) |
| `AP-WDS` | AccessPoint-PT | `SW1 Fa0/8` | Representa el router 2 del WDS |

En cada punto de acceso (*Config → Port 1*): SSID `Restaurante-Almichain-Invitados`, **WPA2-PSK**, clave `<CLAVE-WIFI-INVITADOS>` (cifrado AES). Packet Tracer no tiene WPA3 ni WDS: el segundo punto de acceso con el mismo SSID representa la ampliación de cobertura, y **la prueba real del WDS es la tarea 25** con los Archer C6.

En **SW1**:

```
enable
configure terminal
interface range FastEthernet0/7 - 8
 description Puntos de acceso de invitados
 switchport mode access
 switchport access vlan 50
 no shutdown
```

**Portátil CLIENTE:** apagarlo, quitar el módulo `PT-LAPTOP-NM-1CFE` y poner el `WPC300N` (inalámbrico); encenderlo y en *Desktop → PC Wireless* conectarse al SSID de invitados con la clave. Borrar el cable que iba a `SW1 Fa0/6`. Tiene que recibir una IP `192.168.50.x`.

## 4. Seguridad de R1 y SW1

**R1:**

```
enable
configure terminal
hostname R1
service password-encryption
enable secret <CLAVE-ENABLE-R1>
username admin privilege 15 secret <CLAVE-ADMIN-R1>
ip domain-name almichain.local
crypto key generate rsa general-keys modulus 2048
ip ssh version 2
line console 0
 login local
line vty 0 4
 login local
 transport input ssh
banner motd # Acceso solo para personal autorizado de Almi-Chain #
end
write memory
```

**SW1:**

```
enable
configure terminal
hostname SW1
service password-encryption
enable secret <CLAVE-ENABLE-SW1>
username admin privilege 15 secret <CLAVE-ADMIN-SW1>
ip domain-name almichain.local
crypto key generate rsa general-keys modulus 2048
ip ssh version 2
interface Vlan99
 ip address 192.168.99.2 255.255.255.0
 no shutdown
ip default-gateway 192.168.99.1
vlan 999
 name SIN-USO
interface range FastEthernet0/6, FastEthernet0/9 - 24
 description Libre: apagado
 switchport mode access
 switchport access vlan 999
 shutdown
line console 0
 login local
line vty 0 15
 login local
 transport input ssh
banner motd # Acceso solo para personal autorizado de Almi-Chain #
end
write memory
```

`Fa0/6` era el cable del CLIENTE, que ahora va por Wi-Fi. Si `interface Vlan99` ya tenía la IP, el comando no cambia nada.

## 5. Pruebas nuevas

Hacer cada una, apuntar el resultado en la tabla de pruebas de la [tarea 23](23-plano-direccionamiento.md) y hacer captura de las marcadas con 📷.

| # | Desde → hasta | Esperado |
|---|---|---|
| 9 | TPV1 → `ping 198.51.100.10` | Llega (sale por NAT) |
| 10 | GERENTE → navegador `http://internet.test` 📷 | Abre la página del ISP (DNS + NAT) |
| 11 | CLIENTE (Wi-Fi) → `ping 198.51.100.10` | Llega |
| 12 | CLIENTE (Wi-Fi) → `ping 192.168.10.10` | Bloqueado (ACL `AISLADA-IN`) |
| 13 | R1 → `show ip nat translations` 📷 | Traducciones de `192.168.x.x` a `203.0.113.2` |
| 14 | INTERNET → `ping 192.168.10.10` | Falla: no hay ruta a la red privada |
| 15 | GERENTE → *Command Prompt* `ssh -l admin 192.168.99.2` 📷 | Pide contraseña y entra en SW1 |
| 16 | CLIENTE → `ssh -l admin 192.168.99.2` | Falla (ACL) |
| 17 | `telnet 192.168.99.2` desde GERENTE | Rechazado (solo SSH) |

## 6. Al terminar

- [ ] Guardar el `.pkt` (mismo nombre) y rehacer la captura `23-segmentacion-vlan.png` con la topología completa.
- [ ] Añadir las pruebas 9 a 17 a la tabla del apartado 5.4 de la tarea 23 y marcar como hecho el punto de [CORRECIONES.md](../../CORRECIONES.md#42-packet-tracer-tarea-23).
- [ ] Guardar las contraseñas de R1, SW1 y la Wi-Fi de prueba en KeePassXC.
