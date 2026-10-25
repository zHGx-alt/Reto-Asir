# Tarea 24: Configurar red segura (WPA3; invitados; firewall)

- **Bloque:** 5 Redes
- **Responsable:** Peio
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** en curso (faltan la red de invitados, WPA3, WPS y la contraseña de administración, sección 12)
- **Fecha:** 23/10/2026 · **Revisión:** 24/10/2026
- **Depende de:** tarea 23 (plano y direccionamiento)

## 1. Objetivo

Configurar y comprobar la seguridad de la red inalámbrica del restaurante, proteger el acceso de administración y revisar las funciones de firewall del router.

> [!IMPORTANT]
> El equipo utilizado es un **TP-Link TL-WR841N v14**. En las capturas solamente aparecen WPA/WPA2 y WPA2-PSK. Por tanto, este equipo no permite demostrar WPA3. La opción más segura mostrada es **WPA2-PSK con AES**. Para cumplir el requisito WPA3 hace falta un router o punto de acceso compatible con WPA3-SAE.

> [!NOTE]
> **Por qué un TL-WR841N y no el Archer C6.** Los Archer C6 del presupuesto (tarea 10) no se han comprado; el TL-WR841N es el router que había disponible para practicar. Sirve para demostrar el procedimiento (administración, cifrado, firewall), pero **no es el router del diseño**: su LAN está en `192.168.1.0/24` y no en `192.168.10.0/24` (tarea 23), y no tiene WPA3. La configuración definitiva se repite en el Archer C6 (sección 12).

## 2. Comprobación de conectividad

Se comprobó la comunicación con la puerta de enlace `192.168.1.1` mediante cuatro paquetes ICMP. Se recibieron los cuatro paquetes, con un 0 % de pérdida.

![Ping al router](imagenes/01-ping-router.png)

*Figura 1. Prueba de conectividad con el router.*

También se consultó la dirección del equipo con `ip addr`. La interfaz de red recibió la dirección `192.168.1.110/24`.

![Dirección IP del equipo](imagenes/02-direccion-ip.png)

*Figura 2. Dirección IPv4 asignada al equipo de administración.*

## 3. Administración remota y local

La administración remota aparece desactivada mediante el valor `0.0.0.0`. Esta configuración impide administrar el router directamente desde Internet.

![Administración remota](imagenes/03-administracion-remota.png)

*Figura 3. Administración remota desactivada.*

El panel también permite restringir la administración local a equipos concretos mediante su dirección MAC. Esta medida reduce el número de dispositivos que pueden acceder a la configuración.

![Administración local](imagenes/04-administracion-local.png)

*Figura 4. Opciones de control para la administración local.*

## 4. Seguridad avanzada

El router ofrece protección frente a ataques DoS y filtros para tráfico ICMP-FLOOD, UDP-FLOOD y TCP-SYN-FLOOD. También permite impedir respuestas a ping desde el puerto WAN.

![Seguridad avanzada](imagenes/05-seguridad-avanzada.png)

*Figura 5. Opciones de protección avanzada y filtrado de inundaciones.*

## 5. Firewall

En **Security > Basic Security** se revisó el firewall SPI. La inspección con estado ayuda a bloquear tráfico entrante que no corresponda a conexiones iniciadas desde la red interna.

![Firewall SPI](imagenes/06-firewall-spi.png)

*Figura 6. Configuración del firewall SPI y servicios relacionados.*

## 6. Seguridad Wi-Fi

El panel recomienda WPA2-PSK con cifrado AES.

> [!CAUTION]
> **Contraseñas expuestas (corregido el 24/10/2026).** En la primera versión de las figuras 7 y 8 el recuadro negro tapaba otra zona y **se leían la contraseña Wi-Fi y la contraseña RADIUS**. Ahora están tapadas encima del campo correcto, pero las imágenes antiguas **siguen en el historial de Git**, así que:
> 1. Hay que **cambiar la contraseña Wi-Fi** de ese router si sigue en uso. Además era débil (8 cifras), contra la norma del proyecto. La nueva, una frase de 20 caracteres o más generada con KeePassXC.
> 2. gitleaks no analiza imágenes: cada captura se revisa a ojo, ampliada, antes de subirla.

![Primera configuración de seguridad Wi-Fi](imagenes/07-wifi-seguridad-primera.png)

*Figura 7. Primera comprobación de la seguridad inalámbrica.*

En la configuración final se mantiene WPA2-PSK con AES. No se utiliza WEP ni TKIP porque son alternativas antiguas y menos seguras.

Dos ajustes que quedan mal en las capturas y hay que corregir en el router definitivo:

- **Periodo de renovación de la clave de grupo a `0`**: no se renueva nunca. Poner un valor, por ejemplo 3600 s.
- **Modo `11bgn mixed`** (figura 9): admite clientes 802.11b, antiguos y lentos. Usar `11gn` o `11n` si no hay equipos antiguos.

![Configuración final de seguridad Wi-Fi](imagenes/08-wifi-seguridad-final.png)

*Figura 8. Configuración final de WPA2-PSK y AES con las credenciales ocultas.*

### Limitación de WPA3

El TP-Link TL-WR841N v14 no muestra WPA3-SAE en el panel. Por ello, esta documentación no afirma que WPA3 esté habilitado. Para completar ese requisito debe incorporarse un punto de acceso o router compatible con WPA3.

## 7. Nombre y estado de la red

En la configuración básica aparece el SSID `Restaurante-Almichain`, con modo `11bgn mixed`, canal automático y difusión del SSID.

![Configuración del SSID](imagenes/09-configuracion-ssid.png)

*Figura 9. Nombre y parámetros básicos de la red inalámbrica.*

La página de estado identifica el equipo como **TP-Link TL-WR841N v14**, muestra la dirección LAN `192.168.1.1` y la máscara `255.255.255.0`.

![Estado del router](imagenes/10-estado-router.png)

*Figura 10. Estado general, versión de hardware y parámetros LAN.*

## 8. Acceso al panel

El panel solicita credenciales de administración. La contraseña administrativa debe ser robusta, diferente de la contraseña Wi-Fi y no debe conservar el valor predeterminado.

**Problemas que se ven en las capturas:**

- Se entra como `Admin` con una contraseña de 5 caracteres, que parece la de fábrica (`admin`). No hay evidencia de que se haya cambiado.
- El panel va por **HTTP** (el navegador marca «No es seguro»): la contraseña viaja sin cifrar.
- La administración local está abierta a **todos** los equipos de la LAN (figura 4).

**Qué hay que hacer y documentar:** cambiar la contraseña de administración por una de KeePassXC (distinta de la Wi-Fi), limitar la administración local a la MAC del PC del gerente (figura 4) y administrar solo por cable, nunca desde la Wi-Fi.

![Acceso al panel del router](imagenes/11-acceso-administracion.png)

*Figura 11. Pantalla de acceso al panel de administración.*

## 9. Red de invitados

El menú incluye **Guest Network**, pero las once capturas no muestran la página de configuración final de esa red. Para completar esta parte hay que añadir una captura donde aparezcan:

1. Un SSID independiente, por ejemplo `Restaurante-Almichain-Invitados`.
2. Una contraseña diferente de la red principal.
3. El acceso a la red local desactivado.
4. El aislamiento entre clientes activado, si el firmware lo permite.
5. Una prueba de acceso a Internet y otra que demuestre que no se puede acceder a `192.168.1.0/24`.

## 10. Resultado de las comprobaciones

| Comprobación | Resultado |
|---|---|
| Dirección del equipo | `192.168.1.110/24` |
| Comunicación con el router | Correcta, 0 % de pérdida |
| Dirección LAN del router | `192.168.1.1/24` |
| Administración remota | Desactivada |
| Seguridad principal | WPA2-PSK con AES |
| WPA3 | No disponible en las capturas ni en el panel mostrado |
| Firewall SPI | Revisado en el panel |
| Protección DoS | Disponible y revisada |
| Red de invitados aislada | Pendiente de configuración y evidencia |
| WPS | Sin evidencia de que esté desactivado |
| Contraseña de administración | Parece la de fábrica; pendiente de cambiar y de limitar a la MAC del gerente |
| Contraseña Wi-Fi | Expuesta en las capturas antiguas y débil: **pendiente de cambiar** |

## 11. Conclusión

Se ha verificado la conectividad, se ha revisado la administración local y remota, se ha configurado la opción Wi-Fi más segura disponible en el equipo y se han comprobado las funciones de firewall. Para terminar completamente la tarea faltan dos acciones: utilizar un equipo compatible con WPA3-SAE y documentar la configuración y el aislamiento de la red de invitados.

> [!WARNING]
> No deben subirse al repositorio las capturas originales sin censurar, ya que contienen contraseñas Wi-Fi y credenciales RADIUS visibles.

## 12. Pendiente

- [ ] Cambiar la contraseña Wi-Fi expuesta del TL-WR841N (frase de KeePassXC de 20 caracteres o más).
- [ ] Cambiar la contraseña de administración y limitar la administración a la MAC del PC del gerente; captura.
- [ ] Desactivar WPS; captura.
- [ ] Repetir la configuración en el Archer C6: LAN `192.168.10.0/24`, reservas de la tarea 23, WPA3 (o WPA2/WPA3), clave de grupo con renovación y modo sin 802.11b.
- [ ] Configurar la red de invitados (`192.168.50.0/24` si el router lo permite) con aislamiento entre clientes y hacer las pruebas 3 a 5 de la [tarea 23, sección 6](../23-plano-direccionamiento.md#6-cómo-se-comprueba).
- [ ] Comprobar en la tarea 25 si la red de invitados pasa por el enlace WDS al router 2. Si no pasa, documentarlo y corregir los diagramas (tarea 11 y LOGICA_RETO).
