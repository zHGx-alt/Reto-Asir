# Presupuesto de hardware y conectividad

## 1. Información del documento

| Campo | Valor |
|---|---|
| Proyecto | Reto 1: Almi-Chain |
| Empresa | Cadena de restaurantes Almi-Chain |
| Responsable | Peio Amenabar |
| Fecha de elaboración | 22/10/2026 |
| Moneda | Euros |
| Impuestos | IVA incluido, salvo que se indique lo contrario |
| Validez del presupuesto | 15 días |
| Revisión | Eneko.S, 23/10/2026: ajustado a la tabla de hardware (tarea 8) |

> Los precios y la disponibilidad pueden cambiar. Antes de realizar una compra hay que comprobar el precio final, los gastos de envío, el vendedor y la versión exacta del producto.

---

## 2. Objetivo

El objetivo de este presupuesto es reunir el hardware y los servicios de los puestos definidos en la tarea 7 y elegidos en la tarea 8:

- Un equipo para el despacho del gerente, con su monitor.
- Dos puestos de barra que funcionarán como terminales punto de venta o TPV en Windows, con pantalla táctil.
- Dos impresoras térmicas de tickets.
- Un router principal.
- Un segundo router Wi-Fi para ampliar la cobertura mediante WDS.
- Una conexión WAN de fibra óptica.

La selección busca un equilibrio entre coste, rendimiento, seguridad, compatibilidad y facilidad de mantenimiento. Los equipos, monitor e impresoras son los de la tabla de hardware (tarea 8); los routers y la WAN se añaden aquí.

---

## 3. Necesidades identificadas

Los dos puestos de barra deberán ejecutar Windows y el software TPV o ERP seleccionado para el restaurante. No necesitan una tarjeta gráfica dedicada ni un procesador de gama alta, pero sí necesitan suficiente memoria y almacenamiento para trabajar de forma fluida.

### Requisitos mínimos recomendados para cada TPV

- Procesador de cuatro núcleos.
- 8 GB de memoria RAM como mínimo.
- Unidad SSD de 128 GB o más (la tarea 7 fija este mínimo).
- Pantalla táctil de 15" (RT-03 de la tarea 7).
- Windows Pro (modo quiosco y directivas de seguridad). El enunciado exige Windows 10; ver la nota de la sección 4.1.
- Puerto Ethernet Gigabit.
- Cuatro o más puertos USB.
- Bajo consumo eléctrico.

### Requisitos de las impresoras

- Impresión térmica directa.
- Papel térmico de 80 mm.
- Cortador automático.
- Conexión USB y Ethernet.
- Compatibilidad con Windows.
- Velocidad adecuada para un entorno de hostelería.
- Disponibilidad de controladores y soporte del fabricante.

### Requisitos de red

- Conexión WAN de fibra simétrica.
- Router principal con puertos Gigabit.
- Red Wi-Fi de doble banda.
- Cifrado WPA3 para las redes que lo permitan.
- Red de invitados independiente.
- Segundo router compatible con WDS.
- DHCP activado únicamente en el router principal.
- TPV e impresoras conectados preferentemente mediante Ethernet.

---

## 4. Productos seleccionados

### 4.1. Equipos TPV

Se seleccionan dos unidades del **Iggual AIO B156.88.N100**, un todo en uno de 15,6" Full HD con pantalla táctil capacitiva, procesador Intel N100 de cuatro núcleos, 8 GB de RAM, SSD de 256 GB, Windows 11 Pro, Ethernet Gigabit, 8 puertos USB y un RS-232.

Es la elección de la tabla de hardware (tarea 8, sección 3.2). Incluye la pantalla táctil que pide la tarea 7 (RT-03), por lo que no hace falta monitor aparte, y tiene puertos suficientes para bloquear los USB por directiva (RT-05).

**Producto:** Iggual AIO B156.88.N100  
**Cantidad:** 2  
**Precio unitario:** 538,99 €  
**Subtotal:** 1.077,98 €  
**Fuente:** [PcComponentes - Iggual AIO B156.88.N100](https://www.pccomponentes.com/ordenador-todo-en-uno-iggual-aio-b15688n100-intel-n100-8gb-256gb-ssd-uhd-156-windows-11-pro-tactil)

#### Motivos de la elección

- Pantalla táctil integrada (RT-03).
- Windows 11 Pro incluido, que permite el modo quiosco y las directivas de seguridad local.
- 4 núcleos, 8 GB de RAM y SSD de 256 GB, suficientes para el punto de venta de Odoo en el navegador.
- Un solo equipo por puesto: menos cables y menos dispositivos en la barra.

#### Limitaciones y riesgos

- No es un TPV de hostelería especializado: no consta refrigeración sin ventilador ni protección contra salpicaduras (RT-09, incidencia H-05 de la tarea 8).
- **Windows 10 frente a Windows 11:** el enunciado exige Windows 10 y los equipos traen Windows 11 Pro. Windows 11 Pro suele incluir derechos para instalar Windows 10 Pro, pero hay que confirmarlo en la licencia. La tarea 9 contempla tres licencias de Windows 10 Pro; si finalmente hubiera que comprarlas, su coste no está incluido en este presupuesto.
- El equipo no se usará como servidor.

---

### 4.2. Equipo y monitor del gerente

Para el despacho del gerente, con arranque dual Windows 10 y Linux (tarea 12), se seleccionan el **Lenovo ThinkCentre Neo 50q Gen 4** y el monitor **Xiaomi A24i de 24"**, según la tarea 8 (secciones 3.1 y 3.4).

| Producto | Cantidad | Precio unitario | Subtotal |
|---|---:|---:|---:|
| Lenovo ThinkCentre Neo 50q Gen 4 (Core i5-13420H, 16 GB, SSD de 512 GB, Windows 11 Pro) | 1 | 792,67 € | 792,67 € |
| Xiaomi A24i 24", Full HD IPS | 1 | 90,99 € | 90,99 € |

**Fuentes:** [PcComponentes - Lenovo ThinkCentre Neo 50q Gen 4](https://www.pccomponentes.com/lenovo-thinkcentre-neo-50q-gen-4-intel-core-i5-13420h-16gb-512gb-ssd) y las referencias de la tarea 8.

#### Motivos de la elección

- 16 GB de RAM y 512 GB de SSD: espacio para dos sistemas y datos (RG-01, RG-06).
- Mini PC de 1 litro, que ocupa poco en el despacho.
- Ethernet Gigabit para la red de oficina (RG-07).

> A fecha de la tarea 8, la tienda no tenía fecha de entrada del Neo 50q Gen 4 (incidencia H-03). Hay que buscar el mismo modelo en otra tienda o el sucesor antes de comprar.

---

### 4.3. Impresoras térmicas de tickets

Se seleccionan dos impresoras **Epson TM-T20IV**, referencia `C31CL47102`.

La Epson TM-T20IV es una impresora térmica profesional para puntos de venta. Imprime a una velocidad de hasta 250 mm/s, utiliza papel térmico de 80 mm, incorpora cortador automático y permite conexión USB, Ethernet y RS-232. Es el modelo vigente que sustituye a la TM-T20III, descatalogada por Epson, de la primera versión de la tarea 8.

**Producto:** Epson TM-T20IV Ethernet/USB/RS-232  
**Referencia:** C31CL47102  
**Cantidad:** 2  
**Precio unitario:** 199,86 € (consultado el 23/10/2026; el 22/10/2026 se consultó a 203,59 €)  
**Subtotal:** 399,72 €  
**Fuente:** [PcComponentes - Epson TM-T20IV](https://www.pccomponentes.com/impresora-termica-ethernet-usb-rs-232-epson-tm-t20iv-con-cortador-automatico-y-codigos-de-barras)

#### Motivos de la elección

- Es una impresora diseñada específicamente para TPV.
- Utiliza papel térmico, por lo que no necesita tinta ni tóner.
- Alcanza una velocidad de impresión de 250 mm/s.
- Incorpora cortador automático.
- Permite conexión mediante Ethernet y USB (RI-05).
- Ofrece compatibilidad con Windows.

#### Conexión

La recomendación de la tarea 8 es conectar cada impresora **por USB** directamente a su TPV: no necesita IP, ni reglas de cortafuegos, ni deja un panel de administración expuesto en la red (RI-06). La interfaz Ethernet queda disponible. Si el plano de red (tarea 23) decide imprimir por red, se configurará una reserva DHCP o una dirección IP fija fuera del rango DHCP, por ejemplo:

| Dispositivo | Dirección prevista |
|---|---|
| Impresora TPV 1 | 192.168.10.21 |
| Impresora TPV 2 | 192.168.10.22 |

Las direcciones definitivas se establecerán durante la configuración de red.

> La página de la tienda no indica si el precio incluye IVA ni menciona la salida para cajón (RI-04). Hay que confirmarlo antes de comprar.

---

### 4.4. Router principal y router WDS

Se seleccionan dos unidades del **TP-Link Archer C6 V3 AC1200**.

Una unidad funcionará como router principal de la red y la segunda como router Wi-Fi adicional conectado mediante WDS. Utilizar dos dispositivos del mismo fabricante y versión reduce los posibles problemas de compatibilidad.

El Archer C6 ofrece doble banda, cuatro puertos LAN Gigabit, un puerto WAN Gigabit, red de invitados, WPA3, MU-MIMO y Beamforming.

**Producto:** TP-Link Archer C6 V3 AC1200  
**Cantidad:** 2  
**Precio unitario:** 42,99 €  
**Subtotal:** 85,98 €  
**Fuente:** [MediaMarkt - TP-Link Archer C6](https://www.mediamarkt.es/es/product/_router-tp-link-archer-c6-wifi-doble-banda-5xpuertos-gigabit-mu-mimo-wpa3-tecnologia-onemesh-negro-1524001.html)

#### Distribución de los routers

| Equipo | Función |
|---|---|
| Archer C6 número 1 | Router principal conectado al equipo de la operadora |
| Archer C6 número 2 | Router secundario para ampliar la cobertura mediante WDS |

#### Motivos de la elección

- Puertos Ethernet Gigabit.
- Wi-Fi de doble banda.
- Compatibilidad con WPA3.
- Posibilidad de crear una red de invitados.
- Precio reducido.
- Configuración mediante interfaz web.
- El fabricante dispone de documentación para configurar WDS.
- Utilizar el mismo modelo en ambos extremos mejora las posibilidades de compatibilidad.

#### Comprobación obligatoria antes de la compra

La compatibilidad con WDS puede variar según la versión de hardware y el firmware. Antes de comprar se deberá confirmar que la unidad entregada dispone de la opción:

`Advanced > System Tools > System Parameters > Enable WDS Bridging`

Si la opción WDS no aparece, se actualizará el firmware utilizando exclusivamente el archivo correspondiente a la versión de hardware y a la región europea.

No se debe instalar firmware de otra versión porque puede dejar el router inutilizable.

---

### 4.5. Conexión WAN

Para la conexión WAN se propone contratar **fibra simétrica de 600 Mbps para empresas**.

Esta velocidad es suficiente para:

- Funcionamiento de los dos TPV.
- Acceso al ERP.
- Navegación y correo electrónico.
- Actualizaciones de los equipos.
- Acceso a servicios en la nube.
- Conexión Wi-Fi de clientes.
- Copias de seguridad remotas.
- Administración remota mediante VPN.

**Servicio:** Fibra 600 Mb Empresas  
**Cantidad:** 1 línea  
**Precio ordinario sin IVA:** 40,50 €/mes  
**IVA del 21 %:** 8,51 €/mes  
**Precio aproximado con IVA:** 49,01 €/mes  
**Coste anual con IVA:** 588,12 €  
**Fuente:** [Telefónica Empresas - Fibra para empresas](https://www.telefonicaempresas.es/internet-empresas)

#### Motivos de la elección

- Conexión simétrica de 600 Mbps.
- Capacidad suficiente para los servicios del restaurante.
- Tarifa orientada a empresas.
- No es necesario contratar 1, 2 o 10 Gbps para solo dos TPV y una red de clientes.
- Permite mantener una separación clara entre el coste inicial del hardware y el coste recurrente de Internet.

#### Aspectos que se deben confirmar con la operadora

Antes de contratar la línea se deberá comprobar:

- Cobertura real en la dirección del restaurante.
- Permanencia.
- Coste de instalación.
- Router y ONT incluidos.
- Posibilidad de configurar el equipo de la operadora en modo puente.
- Posibilidad de utilizar un router propio.
- Disponibilidad de IPv4 pública.
- Existencia de CG-NAT.
- Precio después de las promociones.
- Soporte técnico para empresas.

> El presupuesto utiliza el precio ordinario y no una promoción temporal para evitar que el coste anual quede infravalorado.

---

## 5. Resumen económico

### 5.1. Inversión inicial

| Concepto | Cantidad | Precio unitario | Subtotal |
|---|---:|---:|---:|
| Lenovo ThinkCentre Neo 50q Gen 4 (gerente) | 1 | 792,67 € | 792,67 € |
| Monitor Xiaomi A24i 24" (gerente) | 1 | 90,99 € | 90,99 € |
| Iggual AIO B156.88.N100 táctil, Windows 11 Pro (TPV) | 2 | 538,99 € | 1.077,98 € |
| Impresora Epson TM-T20IV Ethernet/USB/RS-232 | 2 | 199,86 € | 399,72 € |
| Router TP-Link Archer C6 V3 AC1200 | 2 | 42,99 € | 85,98 € |
| **Total de inversión inicial** |  |  | **2.447,34 €** |

De ellos, **2.361,36 €** son los equipos de la tarea 8 (gerente, TPV e impresoras) y 85,98 € los routers. Los importes se toman de los precios publicados por las tiendas consultadas; las páginas no indican siempre si incluyen IVA (incidencia H-02 de la tarea 8), así que hay que confirmarlo antes de la compra.

### 5.2. Costes recurrentes

| Servicio | Coste mensual con IVA | Coste anual con IVA |
|---|---:|---:|
| Fibra simétrica de 600 Mbps para empresas | 49,01 € | 588,12 € |

### 5.3. Coste total del primer año

| Tipo de coste | Total |
|---|---:|
| Inversión inicial | 2.447,34 € |
| Conexión WAN durante 12 meses | 588,12 € |
| **Coste total estimado del primer año** | **3.035,46 €** |

> No se incluyen posibles gastos de envío, instalación del operador, cableado estructurado, canaletas, rollos de papel, teclado y ratón del gerente, SAI, licencias de Windows 10 (si fueran necesarias) ni licencias del ERP. Estos elementos dependerán de las existencias del centro y de las características físicas definitivas del local.

---

## 6. Fuentes de los productos

| Elemento | Proveedor o fabricante | Enlace |
|---|---|---|
| Equipos TPV | PcComponentes | [Iggual AIO B156.88.N100](https://www.pccomponentes.com/ordenador-todo-en-uno-iggual-aio-b15688n100-intel-n100-8gb-256gb-ssd-uhd-156-windows-11-pro-tactil) |
| Equipo del gerente | PcComponentes | [Lenovo ThinkCentre Neo 50q Gen 4](https://www.pccomponentes.com/lenovo-thinkcentre-neo-50q-gen-4-intel-core-i5-13420h-16gb-512gb-ssd) |
| Monitor del gerente | Tarea 8 | Xiaomi A24i, referencias en `08-tabla-hardware.md` |
| Impresoras | PcComponentes | [Epson TM-T20IV](https://www.pccomponentes.com/impresora-termica-ethernet-usb-rs-232-epson-tm-t20iv-con-cortador-automatico-y-codigos-de-barras) |
| Especificaciones de impresora | Epson | [Soporte Epson TM-T20](https://www.epson.es/es_ES/support/sc/tm-t20/s/s2405) |
| Routers | MediaMarkt | [TP-Link Archer C6](https://www.mediamarkt.es/es/product/_router-tp-link-archer-c6-wifi-doble-banda-5xpuertos-gigabit-mu-mimo-wpa3-tecnologia-onemesh-negro-1524001.html) |
| Firmware y documentación del router | TP-Link | [Soporte del Archer C6](https://www.tp-link.com/es/support/download/archer-c6/) |
| Guía de WDS | TP-Link | [Configuración de WDS](https://www.tp-link.com/us/support/faq/1555/) |
| Línea WAN | Telefónica Empresas | [Fibra para empresas](https://www.telefonicaempresas.es/internet-empresas) |

---

## 7. Arquitectura prevista

```text
                         INTERNET
                            |
                     Fibra óptica WAN
                            |
               Router/ONT de la operadora
                            |
                  Router principal Archer C6
                     192.168.10.1/24
                            |
        +---------------+---+-----------+
        |               |               |
      TPV 1           TPV 2     Gerente (despacho)
        |               |
  Impresora 1      Impresora 2          Red Wi-Fi interna
 (USB al TPV;     (USB al TPV;
  Ethernet:        Ethernet:
  192.168.10.21)   192.168.10.22)

                            |
                         Enlace WDS
                            |
                  Router secundario Archer C6
                      192.168.10.2/24
                            |
                 Wi-Fi ampliada para clientes
```

El router principal será el único servidor DHCP. El router secundario tendrá una dirección IP fija dentro de la misma subred y su servidor DHCP permanecerá desactivado.

---

## 8. Decisiones de seguridad previstas

Aunque la seguridad se configurará y documentará con más detalle en las tareas posteriores, el hardware seleccionado permite aplicar las siguientes medidas:

1. Utilizar WPA3 en las redes que lo permitan.
2. Utilizar una contraseña Wi-Fi larga y no reutilizada.
3. Cambiar las credenciales administrativas predeterminadas.
4. Desactivar WPS.
5. Desactivar UPnP si no es necesario.
6. Mantener actualizado el firmware de los routers.
7. Crear una red de invitados independiente.
8. Impedir que los clientes accedan a los TPV y a las impresoras.
9. Conectar los TPV mediante Ethernet.
10. Asignar direcciones conocidas a las impresoras.
11. Desactivar DHCP en el router secundario.
12. Crear cuentas de usuario sin privilegios administrativos en los TPV y en el equipo del gerente.
13. Aplicar actualizaciones de seguridad de Windows.
14. Instalar únicamente el software necesario.
15. Realizar pruebas de aislamiento y conectividad después de la instalación.

---

## 9. Riesgos y consideraciones técnicas

### 9.1. Compatibilidad WDS

WDS no está completamente normalizado entre fabricantes y puede presentar incompatibilidades entre modelos, revisiones de hardware o versiones de firmware.

Para reducir este riesgo se han seleccionado dos routers del mismo modelo. Aun así, se deberá verificar la presencia de WDS antes de finalizar la compra.

### 9.2. WPA3 y WDS

La red principal puede utilizar WPA3, pero algunos modos WDS solo funcionan correctamente con WPA2-PSK y AES.

Durante las pruebas se comprobará la combinación de seguridad admitida. No se permitirá el uso de WEP, WPA antiguo ni cifrado TKIP.

Si WDS no funciona con WPA3, se utilizará WPA2-PSK con AES exclusivamente para el enlace WDS y se documentará la limitación. La solución preferible para una instalación real sería utilizar un punto de acceso cableado o un sistema de malla moderno, pero el reto solicita expresamente comprobar una solución WDS.

### 9.3. Pérdida de rendimiento

Un enlace WDS inalámbrico puede reducir el rendimiento disponible porque el router secundario debe recibir y retransmitir los datos utilizando el medio inalámbrico.

Por este motivo:

- El router secundario se instalará en una zona donde todavía reciba una señal estable.
- Se evitará colocarlo directamente en una zona sin cobertura.
- Se probarán las bandas de 2,4 GHz y 5 GHz.
- Se medirá la cobertura antes y después de activar WDS.
- Se comprobarán latencia, pérdida de paquetes y velocidad.

### 9.4. Red de clientes

La red de clientes no deberá tener acceso a:

- TPV.
- Impresoras.
- Interfaz de administración de los routers.
- Equipos del personal.
- Servidores o bases de datos.
- Otros dispositivos conectados a la red interna.

Si el Archer C6 no permite mantener correctamente el aislamiento de invitados a través de WDS, la limitación se documentará y se propondrá una separación mediante VLAN y puntos de acceso profesionales como mejora futura.

### 9.5. Equipo del operador

El Archer C6 no incorpora módem de fibra. Será necesario conservar la ONT o el router proporcionado por la operadora.

Si el equipo de la operadora no puede configurarse en modo puente, el Archer C6 puede quedar detrás de él y producir doble NAT. Esta situación puede afectar a VPN, apertura de puertos y algunos servicios remotos.

---

## 10. Pruebas que se realizarán posteriormente

### Pruebas de los TPV

- Inicio correcto de Windows.
- Creación de cuenta de usuario restringida.
- Conexión Ethernet.
- Acceso al ERP o software TPV.
- Impresión de un ticket de prueba.
- Reinicio y recuperación del servicio.
- Comprobación de actualizaciones y antivirus.

### Pruebas de red segura

- Comprobación del cifrado Wi-Fi.
- Verificación de la red de invitados.
- Comprobación del aislamiento entre clientes y red interna.
- Intento de acceso desde invitados a los TPV.
- Desactivación de WPS.
- Revisión de credenciales administrativas.
- Comprobación de actualización del firmware.

### Pruebas WDS

- Estado conectado del enlace WDS.
- Ping al router principal.
- Ping a Internet.
- Obtención de dirección IP desde el router principal.
- Comprobación de que el DHCP secundario está desactivado.
- Medición de cobertura antes y después.
- Medición de latencia.
- Medición de velocidad.
- Prueba de pérdida de paquetes.
- Prueba desde distintos puntos del local.

---

## 11. Conclusión

La solución propuesta cubre las necesidades principales del restaurante con una inversión inicial estimada de **2.447,34 €** (2.361,36 € de equipos de la tarea 8 más 85,98 € de routers) y un coste total aproximado durante el primer año de **3.035,46 €**, con la conexión WAN incluida.

Los TPV táctiles incluyen Windows Pro para aplicar el modo quiosco y mínimos privilegios. Las impresoras Epson TM-T20IV ofrecen USB y Ethernet, velocidad adecuada y cortador automático. La utilización de dos routers TP-Link Archer C6 del mismo modelo permite diseñar una red Gigabit, utilizar WPA3 en las redes compatibles y realizar la práctica de ampliación de cobertura mediante WDS.

Antes de efectuar cualquier compra se deberán confirmar los precios, la disponibilidad (sobre todo del Lenovo Neo 50q), si los precios incluyen IVA, las condiciones de garantía, la licencia de Windows 10 y, especialmente, la versión de hardware y el soporte WDS de los routers.
