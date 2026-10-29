# Configurar una red segura con TP-Link TL-WR841N

## 1. Objetivo

Configurar y comprobar la seguridad de la red del restaurante mediante:

- Una red LAN separada en `192.168.10.0/24`.
- DHCP con una reserva para el PC de administración.
- Wi-Fi del personal protegido con WPA2-PSK y AES.
- WPS desactivado.
- Una red de invitados aislada de la LAN.
- Acceso al panel limitado al PC de administración.

El equipo utilizado es un **TP-Link TL-WR841N**. Este modelo y su firmware no muestran compatibilidad con WPA3-SAE, por lo que se utiliza la opción más segura disponible: **WPA2-PSK con AES**.

> **Limitación:** para utilizar WPA3 sería necesario sustituir el router o añadir un punto de acceso compatible con WPA3-SAE.

## 2. Configuración de la red LAN

En `Network > LAN` se configuraron los siguientes valores:

| Parámetro | Valor |
|---|---|
| Dirección del router | `192.168.10.1` |
| Máscara de subred | `255.255.255.0` |

![Configuración LAN](imagenes/12-lan-192-168-10-1.png)

*Figura 1. Dirección LAN del router y máscara de subred.*

## 3. DHCP y reserva del PC de administración

En `DHCP > DHCP Settings` se habilitó el servidor DHCP con esta configuración:

| Parámetro | Valor |
|---|---|
| Rango DHCP | `192.168.10.100` - `192.168.10.199` |
| Tiempo de concesión | `1440` minutos |
| Puerta de enlace | `192.168.10.1` |

En `DHCP > Address Reservation` se reservó `192.168.10.20` para la interfaz Ethernet del PC de administración. Después de renovar la conexión, Linux confirmó que `enp2s0` estaba activa con `192.168.10.20/24`.

![DHCP y reserva](imagenes/13-dhcp-y-reserva-gerente.png)

*Figura 2. Servidor DHCP, reserva de dirección y comprobación en Linux.*

## 4. Wi-Fi del personal

En `Wireless > Basic Settings` se configuró:

| Parámetro | Valor |
|---|---|
| SSID | `Restaurante-Almichain` |
| Modo | `11bgn mixed` |
| Canal | `6` fijo |
| Ancho de canal | `20 MHz` |
| Difusión del SSID | Activada |

El firmware no ofrece `11gn mixed`, por lo que se mantuvo `11bgn mixed`, que es la opción disponible con compatibilidad 802.11n. El canal se dejó fijo para evitar cambios automáticos que puedan afectar al WDS.

En `Wireless > Wireless Security` se seleccionó:

- `WPA/WPA2 - Personal`.
- Versión `WPA2-PSK`.
- Cifrado `AES`.
- Renovación periódica de la clave de grupo.

![Wi-Fi del personal](imagenes/14-wifi-personal.png)

*Figura 3. Parámetros básicos y seguridad de la red del personal. La contraseña está censurada.*

## 5. WPS desactivado

En `Wireless > WPS` se desactivó WPS. El panel muestra el estado `Disabled`.

![WPS desactivado](imagenes/15-wps-desactivado.png)

*Figura 4. WPS desactivado. El PIN se ha censurado.*

## 6. Red de invitados

En `Guest Network` se configuró una red independiente:

| Parámetro | Valor |
|---|---|
| Estado | Activada |
| SSID | `Restaurante-Almichain-Invitados` |
| Seguridad | `WPA2-PSK` con `AES` |
| Acceso a la red local | Desactivado |
| Aislamiento entre invitados | Activado |
| Renovación de clave de grupo | `3600` segundos |

La contraseña de invitados es diferente de la contraseña del personal y no se publica en el repositorio.

![Red de invitados](imagenes/16-red-invitados.png)

*Figura 5. Red de invitados habilitada y aislada. La contraseña está censurada.*

## 7. Administración limitada al PC autorizado

En `Security > Local Management` se seleccionó la opción que permite administrar el router únicamente desde los equipos incluidos en la lista. Se añadió la interfaz Ethernet del PC de administración.

La comprobación dio el resultado esperado:

- El PC autorizado por Ethernet puede entrar en `http://192.168.10.1`.
- Un móvil conectado por Wi-Fi recibe `ERR_CONNECTION_REFUSED` al intentar abrir el panel.

![Administración solo desde el PC](imagenes/17-administracion-solo-gerente.png)

*Figura 6. Restricción por MAC y prueba de acceso denegado desde un móvil.*

## 8. Comprobación de la dirección reservada

El comando utilizado en Linux fue:

```bash
ip -4 addr show enp2s0
```

El resultado confirmó `192.168.10.20/24` en la interfaz Ethernet.

![IP reservada](imagenes/18-ip-reservada-pc-gerente.png)

*Figura 7. Dirección reservada aplicada al PC de administración.*

## 9. Pruebas de la red de invitados

| Prueba | Resultado esperado | Evidencia disponible |
|---|---|---|
| P1. Abrir una web desde invitados | La web abre | Comprobado durante la práctica, sin captura específica en el PDF |
| P2. Consultar IP y puerta de enlace del invitado | Registrar ambos valores | No hay captura específica de la red de invitados |
| P3a. Abrir `192.168.10.1` desde invitados | El panel no abre | Sí |
| P3b. Ping a `192.168.10.20` desde invitados | Sin respuesta | No hay captura de ping en el PDF |
| P4. Ping entre dos móviles invitados | Sin respuesta | No hay captura en el PDF |
| P5. Conectar con la contraseña antigua | No conecta | Sin captura requerida |

![Invitado sin acceso al router](imagenes/20-invitados-sin-acceso-router.png)

*Figura 8. El dispositivo Wi-Fi no puede abrir el panel del router.*

> La captura anterior demuestra el bloqueo del panel, pero no sustituye las capturas de ping exigidas para P3b y P4.

## 10. Resultado de las comprobaciones

| Comprobación | Resultado |
|---|---|
| Dirección LAN | `192.168.10.1/24` |
| DHCP | Activado, rango `192.168.10.100-199` |
| Reserva del PC | `192.168.10.20/24` aplicada |
| Seguridad Wi-Fi | WPA2-PSK con AES |
| Canal | `6`, fijo |
| WPS | Desactivado |
| Red de invitados | Activada y con aislamiento configurado |
| Acceso al panel desde móvil | Bloqueado |
| Acceso al panel desde PC autorizado | Permitido |
| WPA3 | No disponible en el TL-WR841N |

## 11. Conclusión

La red se ha migrado a `192.168.10.0/24`, se ha configurado DHCP con una reserva para el PC de administración, se ha protegido el Wi-Fi con WPA2-PSK y AES, se ha desactivado WPS, se ha creado una red de invitados aislada y se ha limitado el panel a un único equipo autorizado.

La principal limitación es la ausencia de WPA3-SAE en el TP-Link TL-WR841N. Para cerrar todas las evidencias solicitadas por la guía todavía deben añadirse, si el profesor las exige, las capturas de P1, P2, el ping de P3 y el ping entre invitados de P4.

## 12. Lista de comprobación

- [x] Dirección LAN `192.168.10.1/24`.
- [x] DHCP `192.168.10.100-199` y concesión de 1440 minutos.
- [x] Reserva `192.168.10.20` para el PC de administración.
- [x] Canal Wi-Fi fijo.
- [x] WPA2-PSK con AES.
- [x] WPS desactivado.
- [x] Red de invitados habilitada.
- [x] Acceso de invitados a la LAN desactivado.
- [x] Aislamiento entre invitados habilitado en la configuración.
- [x] Administración limitada al PC autorizado.
- [x] Prueba de bloqueo del panel desde un móvil.
- [ ] Captura de navegación web desde la red de invitados.
- [ ] Captura de IP y puerta de enlace de un invitado.
- [ ] Captura del ping fallido desde invitados a `192.168.10.20`.
- [ ] Captura del ping fallido entre dos invitados.

## 13. Seguridad de las evidencias

Las imágenes preparadas para GitHub ocultan contraseñas y el PIN WPS. El PDF original no debe subirse al repositorio porque contiene credenciales visibles. Como esas credenciales aparecieron en las capturas originales, se recomienda rotarlas antes de dar la tarea por finalizada.
