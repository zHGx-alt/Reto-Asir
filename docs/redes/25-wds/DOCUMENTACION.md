# Tarea 25: WDS con segundo router y pruebas de cobertura

- **Bloque:** 5 Redes
- **Responsable:** Peio
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado (27/10/2026):** 🟡 Prueba de laboratorio hecha por Peio (sección 1.2): el enlace WDS funciona. Falta repetirlo con la red del proyecto, con la red de invitados, y hacer las pruebas W3 a W10 y las medidas de la sección 8
- **Fechas:** 02/11 – 03/11/2026
- **Depende de:** tarea 24 (router 1 configurado) y tarea 23 (plano y plan de IP)
- **La necesita:** tarea 26 (Wireshark y nmap)

## 1. Qué pide el enunciado y qué hay que demostrar

> «Para ampliar la cobertura Wi-Fi para los clientes del local se dispondrá de otro router Wi-Fi conectado mediante WDS al router principal, comprobando que la solución funciona correctamente.»

**WDS** (*Wireless Distribution System*) une dos routers **por radio, sin cable**. El router 2 se conecta por Wi-Fi al router 1 y repite su red: un móvil junto al router 2 se conecta a él, pero recibe la IP y sale a internet por el router 1. El router 2 funciona como un **puente**: no hace NAT ni reparte IP.

Hay que demostrar cuatro cosas, con evidencia:

| # | Qué | Dónde |
|---|---|---|
| 1 | El enlace WDS está activo | Sección 6 |
| 2 | Un cliente junto al router 2 se conecta a él y navega | Sección 7, pruebas W2 a W4 |
| 3 | **Los clientes que entran por el router 2 siguen aislados de la LAN** (la red de la caja) | Sección 7, pruebas W5 a W7 |
| 4 | La cobertura y la velocidad mejoran con el router 2 (antes y después) | Sección 8 |

El punto 3 es el más importante para este proyecto: la red es plana con la Wi-Fi de invitados aislada ([tarea 23, 5.2](../23-plano-direccionamiento.md#52-decisión-red-plana-con-red-de-invitados-aislada-24102026)). Si el router 2 deja a los clientes en la LAN, se rompe la seguridad de todo el diseño.

También demuestra el **RA.2 de PAR** («evaluando su funcionamiento y prestaciones»): las medidas de la sección 8.

### 1.2 Prueba de laboratorio del 27/10/2026

Peio montó el WDS con dos TL-WR841N antes de tener la red del proyecto. El informe completo, con los problemas que encontró y cómo los resolvió, está en [prueba-laboratorio-2026-10-27.md](prueba-laboratorio-2026-10-27.md).

| Qué se hizo | Resultado | Evidencia |
|---|---|---|
| Router 2 enlazado por WDS (*Connect to Network*) al router 1, en WPA2-PSK/AES | ✅ El enlace funciona: un PC enchufado al router 2 recibe por DHCP una IP del router 1 (`192.168.1.102`, puerta de enlace `192.168.1.1`) y le hace `ping` con 0 % de pérdida | [01](evidencias/01-seleccion-red-wds.png), [02](evidencias/02-configuracion-wds.png) (contraseña tapada), [04](evidencias/04-ping-router-principal.png) |
| DHCP del router 2 | ✅ Apagado: las IP las da solo el router 1 | [03](evidencias/03-dhcp-desactivado.png) |
| Móvil en la Wi-Fi | ✅ Se conecta, recibe IP del router 1 (`192.168.1.100`), señal excelente y enlace de 72 Mbit/s cerca de los routers. Lejos, sigue conectado cuando ya no ve ninguna otra red ([07](evidencias/07-limite-cobertura.png)); más allá se desconecta (sin captura) | [05](evidencias/05-cobertura-cerca.png), [06](evidencias/06-detalles-conexion-wifi.png) |

**En qué se queda corta** (por eso la tarea sigue en curso):

1. **No es la red del proyecto.** El router 1 era uno de pruebas con el nombre de fábrica (`TP-Link_AF60`) en `192.168.1.0/24`, y el router 2 quedó en `192.168.1.101`. El plan es `192.168.10.1` y `192.168.10.2` con `Restaurante-Almichain` (sección 3).
2. **Sin red de invitados**, así que no se pudo comprobar lo más importante: que los clientes del router 2 siguen aislados de la LAN (W3 a W7). Depende de la tarea 24 (hallazgo S-06 de la [tarea 46](../../seguridad/46-revision-seguridad/DOCUMENTACION.md)).
3. **La cobertura no demuestra que el router 2 la amplíe.** No se miró el BSSID, así que no se sabe a qué router estaba conectado el móvil, y no hay medidas de antes y después (sección 8).
4. **Sin salida a internet:** el móvil marcaba «Sin acceso a Internet».
5. El router 2 fue un TL-WR841N y no el Archer C6 de la sección 6: en el TL-WR841N el WDS está en *Wireless → Connect to Network*. Vale igual, pero el WR841N no tiene WPA3 (S-07).

## 2. Material

| Qué | Para qué |
|---|---|
| Router 1 configurado según la tarea 24 (LAN `192.168.10.1`, Wi-Fi del personal y de invitados) | Router principal |
| Router 2: TP-Link Archer C6 V3, el mismo modelo que el router 1 | WDS no está estandarizado: con dos aparatos de modelos distintos puede no funcionar, y TP-Link lo avisa |
| Un portátil con cable | Configurar el router 2 y hacer de servidor de `iperf3` |
| Un móvil Android con **WiFi Analyzer** (u otra app que dé la señal en dBm y el BSSID) | Medir la cobertura |
| Un portátil con Wi-Fi e `iperf3` instalado | Medir la velocidad dentro del local |
| El plano de la [tarea 23](../23-plano-direccionamiento.md#3-plano-del-local) | Puntos de medida |

> [!NOTE]
> **Si no hay Archer C6:** el procedimiento se puede hacer con dos TL-WR841N (como la tarea 24). Su panel es el antiguo: el WDS está en *Wireless → Wireless Settings → Enable WDS Bridging*. En la documentación se dice con qué aparatos se hizo.

## 3. Valores del plan

| Dato | Router 1 | Router 2 |
|---|---|---|
| IP LAN | `192.168.10.1` | `192.168.10.2` ([tarea 23, 4.3](../23-plano-direccionamiento.md#43-equipos)) |
| DHCP | Encendido | **Apagado** |
| Banda del enlace WDS | 2,4 GHz | 2,4 GHz |
| Canal de 2,4 GHz | **Fijo** (1, 6 u 11, el menos ocupado según WiFi Analyzer) | El mismo, lo toma del router 1 |
| SSID del personal | `Restaurante-Almichain` | `Restaurante-Almichain` (mismo nombre y misma contraseña) |
| SSID de invitados | `Restaurante-Almichain-Invitados` | `Restaurante-Almichain-Invitados` (mismo nombre y misma contraseña) |
| Lugar | Armario del despacho | Pared del comedor, cerca de la barra (plano de la tarea 23) |

**Por qué el canal fijo:** el router 2 se engancha al canal del router 1. Si el router 1 está en *Auto* y cambia de canal, el enlace WDS se cae.

**Por qué los mismos SSID y contraseñas:** así el móvil pasa de un router a otro sin hacer nada.

Las contraseñas son las de la tarea 24, las que guarda el equipo. **No se escriben aquí ni salen en las capturas.**

## 4. Antes de empezar: router 1

1. Entrar en el router 1 (`http://192.168.10.1` o `tplinkwifi.net`) desde el PC del gerente, con cable.
2. *Wireless* (2,4 GHz): cambiar el canal de *Auto* al elegido en la sección 3. Guardar y apuntar el canal.
3. Comprobar que la red de invitados está encendida y que **no** está marcada la opción de dejar a los invitados ver la red local (tarea 24).
4. Captura de la página de Wi-Fi (canal) y de la red de invitados, **con las contraseñas tapadas**.

## 5. Medidas «antes» (solo el router 1)

Con el router 2 **apagado**, hacer las medidas de la sección 8 en los cinco puntos y rellenar las columnas *Antes*. Así se puede comparar.

## 6. Configurar el router 2

Pasos de la guía oficial de TP-Link para WDS ([FAQ 1555](https://www.tp-link.com/us/support/faq/1555/)), con los valores de este proyecto. Los menús pueden cambiar un poco según la versión de hardware y firmware: si no aparece una opción, buscarla en *Advanced* y apuntar dónde estaba.

1. **Firmware y modo.** Actualizar el router 2 al último firmware de la web de TP-Link. Comprobar que el modo de funcionamiento es **Router**: en modo *Access Point* el WDS no aparece.
2. **Conectar** el portátil por cable a un puerto LAN del router 2 (todavía no a la red del local) y entrar en `http://192.168.0.1` o `tplinkwifi.net`. Cambiar la contraseña de administración por una robusta (tarea 24).
3. **IP LAN:** *Advanced → Network → LAN* → `192.168.10.2`, máscara `255.255.255.0`. Guardar. El router cambia de IP: poner en el portátil una IP fija `192.168.10.50/24` y volver a entrar en `http://192.168.10.2`.
4. **DHCP apagado:** *Advanced → Network → DHCP Server* → desmarcar *Enable DHCP Server*. Guardar. Las IP las da solo el router 1.
5. **WDS:** *Advanced → System Tools → System Parameters* → apartado **2.4GHz Wireless** → marcar **Enable WDS Bridging** → **Survey** → elegir `Restaurante-Almichain` (el SSID del personal del router 1) → **Choose** → poner su contraseña → **Save**. En algunos firmware está en *Advanced → Wireless → Wireless Settings*.
6. **Wi-Fi del router 2:** poner los mismos SSID y contraseñas que el router 1 (sección 3), con WPA2/WPA3 y AES, sin WPS (tarea 24).
7. **Red de invitados del router 2:** encenderla con el SSID de invitados y **sin** acceso a la red local, igual que en el router 1.
8. **Administración:** dejarla solo para la MAC del PC del gerente y cerrar la administración remota (tarea 24).
9. **Comprobar el enlace:** *Advanced → Status → Wireless* → **WDS Status: Run**. Captura.
10. Colocar el router 2 en el comedor, quitar el cable del portátil y volver a poner el portátil en DHCP.

**Si el WDS no pasa a *Run*:** comprobar el canal (sección 4) y la contraseña. Algunos usuarios del Archer C6 cuentan que el modo *Auto* del WDS no engancha y funciona al forzar otro tipo. Apuntar lo que pasó y lo que se probó, aunque no salga.

## 7. Pruebas de funcionamiento

Cada prueba con su captura o su salida (sección 9). El **BSSID** es la MAC del punto de acceso al que está conectado el móvil: WiFi Analyzer lo enseña. Apuntar antes el BSSID de cada router (pegatina o *Status → Wireless*), para saber a cuál está conectado.

| # | Prueba | Esperado | Resultado |
|---|---|---|---|
| W1 | Router 2: *Status → Wireless* | WDS Status **Run** | |
| W2 | Desde el PC del gerente: `ping 192.168.10.2` | Responde: el router 2 está en la LAN por el enlace WDS | |
| W3 | Móvil en la Wi-Fi de **invitados**, junto al router 2 | El BSSID es el del **router 2** | |
| W4 | Ese móvil: abrir una web y mirar su IP (*Ajustes → Wi-Fi → detalles*) | Navega. Apuntar la IP: tiene que ser de la red de invitados (la misma que da el router 1 a los invitados, tarea 24), **no** `192.168.10.x` | |
| W5 | Ese móvil: abrir `https://192.168.10.10` (Odoo) y hacer ping con una app (por ejemplo *Fing* o *PingTools*) a `192.168.10.10` y `192.168.10.31` | **No** llega a ninguno | |
| W6 | Ese móvil: abrir `http://192.168.10.2` y `http://192.168.10.1` | **No** abre el panel de ningún router | |
| W7 | Dos móviles en la Wi-Fi de invitados del router 2: uno hace ping al otro | **No** responde (aislamiento de clientes) | |
| W8 | Portátil en la Wi-Fi del **personal** junto al router 2 → `https://192.168.10.10` | Abre Odoo: el personal también tiene cobertura en la barra | |
| W9 | Ir andando del despacho a la barra con el móvil en la Wi-Fi de invitados y un vídeo puesto | Cambia de router (cambia el BSSID) y el vídeo, como mucho, se corta un momento | |
| W10 | Apagar el router 2 con el móvil conectado a él | El móvil pasa al router 1 si tiene señal; en la barra, la señal baja (se ve en la sección 8) | |

### Si W4, W5 o W6 fallan (el cliente llega a la LAN)

Puede pasar: el enlace WDS une el router 2 con la **LAN** del router 1, y depende del firmware que la red de invitados del router 2 aísle de verdad. Si un móvil del router 2 recibe una IP `192.168.10.x`, llega a Odoo, a un TPV o al panel de un router:

1. **No dejar el router 2 así:** apagar su red de invitados hasta resolverlo.
2. Apuntar en la sección 9 qué IP recibió y a qué llegó, con capturas. **Es un resultado de la prueba, no un fallo de la tarea:** el enunciado pide comprobar que funciona, y esto es lo que se comprueba.
3. Probar con el último firmware y repetir W4 a W6.
4. Si sigue igual, avisar a Adrian para decidir. La alternativa es que el router 2 emita **solo** la Wi-Fi del personal y que la cobertura de clientes en la barra dependa del router 1. Hay que corregir el plano, el diagrama de la tarea 11 y la tarea 23 con lo que se decida.

## 8. Cobertura y velocidad

### 8.1 Puntos de medida

Cinco puntos del plano de la tarea 23, siempre los mismos y a la misma altura (a la altura de una mesa, con el móvil en la mano):

| Punto | Dónde |
|---|---|
| P1 | Despacho, junto al armario (referencia: al lado del router 1) |
| P2 | Comedor, mitad izquierda |
| P3 | Barra, junto al TPV 2 |
| P4 | Comedor, mitad derecha |
| P5 | Entrada |

### 8.2 Cómo se mide

- **Señal (dBm):** WiFi Analyzer, la red de invitados. Esperar 10 segundos y apuntar el valor que más se repite. Apuntar también el BSSID (router 1 o 2).
- **Velocidad a internet:** desde el móvil en la Wi-Fi de invitados, `https://fast.com` o la app de Speedtest. Tres medidas y apuntar la del medio (la mediana).
- **Velocidad dentro del local:** el portátil del servidor de pruebas, con cable en el router 1, ejecuta `iperf3 -s`. El portátil con Wi-Fi, en la red del **personal** (la de invitados no llega a la LAN, a propósito), ejecuta `iperf3 -c <IP del portátil con cable> -t 10`. Apuntar el *receiver*, en Mbit/s. Así se mide el Wi-Fi y el enlace WDS sin que influya la línea a internet.

**Cómo leer la señal:**

| Señal | Calidad |
|---|---|
| -30 a -67 dBm | Buena: vídeo y llamadas sin problemas |
| -67 a -75 dBm | Aceptable: navegar |
| Peor que -75 dBm | Mala: cortes |

**Qué esperar:** con el router 2, la señal en P3, P4 y P5 tiene que mejorar. La velocidad por el router 2 suele ser **menor** que la del router 1 a la misma distancia: el router 2 recibe y reenvía por la misma radio, así que la velocidad se queda más o menos en la mitad. Es normal en WDS y se explica en la conclusión.

### 8.3 Resultados

| Punto | Antes · señal (dBm) | Antes · internet (Mbit/s) | Antes · iperf3 (Mbit/s) | Después · router (1 o 2) | Después · señal (dBm) | Después · internet (Mbit/s) | Después · iperf3 (Mbit/s) |
|---|---|---|---|---|---|---|---|
| P1 | | | | | | | |
| P2 | | | | | | | |
| P3 | | | | | | | |
| P4 | | | | | | | |
| P5 | | | | | | | |

**Datos de la medida:** fecha y hora, canal, modelo del móvil y del portátil, y si el local estaba vacío o con gente.

## 9. Evidencias

En [`evidencias/`](evidencias/), con nombres que digan qué demuestran:

| Fichero | Qué demuestra |
|---|---|
| `01` a `07` | Prueba de laboratorio del 27/10 (sección 1.2). Revisadas: no se lee ninguna contraseña |
| `10-router1-canal-fijo.png` | Canal fijo en el router 1 |
| `11-router2-lan-y-dhcp.png` | Router 2 en `192.168.10.2` y DHCP apagado |
| `12-router2-wds-run.png` | WDS Status: Run (W1) |
| `13-ping-gerente-router2.txt` | W2 |
| `14-movil-bssid-router2.png` | El móvil está en el router 2 (W3) |
| `15-movil-ip-invitados.png` | IP del móvil por el router 2 (W4) |
| `16-movil-sin-acceso-lan.png` | W5 y W6 |
| `17-cobertura-antes.png` y `18-cobertura-despues.png` | Pantallas de WiFi Analyzer en P3 |
| `19-iperf3-p3-antes.txt` y `20-iperf3-p3-despues.txt` | Velocidad en la barra |

> [!WARNING]
> Antes de subir cada captura, ábrela **ampliada** y comprueba que no se lee ninguna contraseña (Wi-Fi, administración, WDS). gitleaks no mira dentro de las imágenes: es lo que pasó en la tarea 24.

## 10. Conclusión

*(Rellenar al terminar: si el WDS funciona, cuánto mejora la cobertura en la barra y la entrada, qué pasa con la velocidad y si los clientes del router 2 siguen aislados.)*

## 11. Pendiente

- [x] Prueba de laboratorio del enlace WDS y del DHCP del router 2 (27/10, Peio; sección 1.2).
- [ ] Red de invitados en el router 1 (tarea 24): sin ella no se pueden hacer W3 a W7.
- [ ] Router 1 con el canal fijo (sección 4).
- [ ] Medidas «antes» (sección 5).
- [ ] Router 2 configurado y WDS en *Run* (sección 6).
- [ ] Pruebas W1 a W10 con sus evidencias (sección 7).
- [ ] Medidas «después» y tabla 8.3.
- [ ] Conclusión, y si cambia algo, corregir el plano (tarea 23) y el diagrama (tarea 11).
- [ ] CSV: tarea 25 en **Hecho** con la evidencia, y `python3 scripts/gantt.py`.
