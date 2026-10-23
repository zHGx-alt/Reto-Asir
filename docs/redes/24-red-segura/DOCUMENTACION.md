# Configurar red segura (WPA3; invitados; firewall)

## 1. Objetivo

Configurar y comprobar la seguridad de la red inalámbrica del restaurante, proteger el acceso de administración y revisar las funciones de firewall del router.

> [!IMPORTANT]
> El equipo utilizado es un **TP-Link TL-WR841N v14**. En las capturas solamente aparecen WPA/WPA2 y WPA2-PSK. Por tanto, este equipo no permite demostrar WPA3. La opción más segura mostrada es **WPA2-PSK con AES**. Para cumplir el requisito WPA3 hace falta un router o punto de acceso compatible con WPA3-SAE.

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

El panel recomienda WPA2-PSK con cifrado AES. Las contraseñas visibles en las capturas originales se han ocultado antes de preparar las imágenes para GitHub.

![Primera configuración de seguridad Wi-Fi](imagenes/07-wifi-seguridad-primera.png)

*Figura 7. Primera comprobación de la seguridad inalámbrica.*

En la configuración final se mantiene WPA2-PSK con AES. No se utiliza WEP ni TKIP porque son alternativas antiguas y menos seguras.

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

## 11. Conclusión

Se ha verificado la conectividad, se ha revisado la administración local y remota, se ha configurado la opción Wi-Fi más segura disponible en el equipo y se han comprobado las funciones de firewall. Para terminar completamente la tarea faltan dos acciones: utilizar un equipo compatible con WPA3-SAE y documentar la configuración y el aislamiento de la red de invitados.

> [!WARNING]
> No deben subirse al repositorio las capturas originales sin censurar, ya que contienen contraseñas Wi-Fi y credenciales RADIUS visibles.
