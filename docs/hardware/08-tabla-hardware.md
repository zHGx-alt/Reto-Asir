# Tarea 8: Tabla de hardware con justificación

- **Bloque:** 1 Hardware
- **Depende de:** tarea 7 (necesidades de equipos)
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Fecha de consulta de precios y disponibilidad:** 22/10/2026 (impresora actualizada el 23/10/2026)
- **Estado:** pendiente de revisión

## 1. Alcance y criterios

Este documento elige el hardware de los puestos definidos en la tarea 7: equipo del gerente, 2 TPV de barra y 2 impresoras de tickets, más el monitor del gerente. Cada elección se compara con alternativas y se justifica con los requisitos de la tarea 7 (identificadores RG, RT y RI).

Criterios de selección, por orden:

1. Cumplir los mínimos de la tarea 7 (sección 4 de ese documento).
2. Incluir lo necesario para aplicar mínimos privilegios: Windows Pro y firmware UEFI en el equipo del gerente, y puertos suficientes en el TPV.
3. Precio razonable con disponibilidad real en tiendas españolas.
4. Riesgos conocidos y documentados.

El hardware de otros bloques (router, repetidor Wi-Fi, switch, equipo de la máquina recreativa y placa Arduino) se consolida en el presupuesto final (ver sección 7).

## 2. Resumen de la selección

| Puesto | Uds. | Modelo elegido | Especificaciones principales | Precio unidad | Total |
|---|---|---|---|---|---|
| Gerente: equipo | 1 | Lenovo ThinkCentre Neo 50q Gen 4 (Mini PC) | Core i5-13420H (8 núcleos), 16 GB DDR4 ampliable a 32 GB, SSD NVMe de 512 GB, Windows 11 Pro, Gigabit Ethernet, HDMI y DisplayPort | 792,67 € | 792,67 € |
| Gerente: monitor | 1 | Xiaomi A24i 24" | 23,8", Full HD 1920x1080, IPS, 100 Hz, DisplayPort y HDMI | 90,99 € | 90,99 € |
| TPV de barra | 2 | Iggual AIO B156.88.N100 | Todo en uno de 15,6" Full HD táctil capacitivo, Intel N100 (4 núcleos), 8 GB, SSD de 256 GB, Windows 11 Pro, Gigabit Ethernet, 6 USB 2.0, 2 USB 3.2, RS-232 | 538,99 € | 1.077,98 € |
| Impresora de tickets | 2 | Epson TM-T20IV (C31CL47102) | Térmica de 80 mm, 250 mm/s, cortador automático, USB, Ethernet 10/100 y RS-232 | 199,86 € | 399,72 € |
| | | | **Total verificado** | | **2.361,36 €** |

Los precios proceden de tiendas online españolas consultadas el 22/10/2026 (la impresora, el 23/10/2026). Las páginas no indican si el precio incluye IVA. En tiendas minoristas el precio mostrado suele incluirlo, pero hay que confirmarlo antes de preparar el presupuesto final (sección 6).

## 3. Justificación por puesto

### 3.1 Equipo del gerente

| | A: Lenovo ThinkCentre Neo 50q Gen 4 (elegido) | B: HP ProDesk 400 G5 Mini reacondicionado |
|---|---|---|
| Procesador | Core i5-13420H, 8 núcleos | Core i5-9500, 6 núcleos |
| RAM | 16 GB (ampliable a 32 GB) | 16 GB |
| Disco | SSD NVMe de 512 GB | SSD de 512 GB |
| Sistema | Windows 11 Pro | Windows 11 Pro |
| Garantía | No consta en la página | 2 años (garantía comercial) |
| Precio | 792,67 € | No consta en la página |
| Disponibilidad | Sin fecha de entrada en PcComponentes | No disponible en Back Market |

**Elección: A.** Cumple RG-06 con margen (8 núcleos, 16 GB, ampliable) y deja sitio para el arranque dual (RG-01): 512 GB permiten unos 100 GB para Windows, unos 100 GB para Linux y el resto para datos. Es un mini PC de 1 litro, que ocupa muy poco en un despacho. Tiene Ethernet gigabit para la red de oficina (RG-07).

**Por qué no B:** es más antiguo y la oferta consultada no tiene precio ni stock. Sería una buena opción si se busca ahorro, pero no se puede presupuestar con datos verificados.

**Riesgos:**
- A fecha de consulta, la tienda no tiene fecha de entrada. Hay que buscar el mismo modelo en otras tiendas o una versión posterior (Neo 50q Gen 5).
- El equipo trae Windows 11 Pro, pero el enunciado exige Windows 10 (sección 6).

### 3.2 TPV de barra (2 unidades)

| | A: Approx APPTPV05+ G8-256 | B: Iggual AIO B156.88.N100 (elegido) | C: 10POS J6412 |
|---|---|---|---|
| Procesador | Celeron J4125 | Intel N100, 4 núcleos | Celeron J6412, 4 núcleos |
| RAM y disco | 8 GB, SSD de 256 GB | 8 GB, SSD de 256 GB | 8 GB, SSD de 128 GB |
| Pantalla | 15,6" 1920x1080, capacitiva | 15,6" 1920x1080 IPS, capacitiva | 15" 1024x768, capacitiva |
| Puertos | 5 USB, Gigabit, sin serie ni RJ11 | 8 USB, Gigabit, RS-232 | USB 3.2, 2 RS-232, Gigabit |
| Sistema | Sin sistema incluido* | Windows 11 Pro incluido | Windows 11 IoT Enterprise LTSC |
| Precio | 529,00 € | 538,99 € | No consta en la página |

\* Una opinión de un comprador indica que viene sin Windows. Habría que sumar una licencia.

**Elección: B.** Por 9,99 € más que A (19,98 € por los dos), incluye Windows 11 Pro, tiene un procesador más moderno y más puertos, entre ellos un RS-232. Cumple los requisitos de la tarea 7:

- RT-03: pantalla táctil capacitiva de 15,6".
- RT-07: 4 núcleos y 8 GB de RAM, con SSD de 256 GB.
- RT-08: Ethernet gigabit para IP fija.
- Mínimos de puertos: 8 USB de sobra. Se bloquearán por directiva (RT-05).
- Sistema: Windows Pro permite el modo quiosco y las directivas de seguridad local (RT-01, RT-04, RT-06).

**Por qué no C:** el modelo está bien equipado, pero la página no muestra precio, y su pantalla es de 1024x768.

**Riesgos:**
- RT-09 (equipo para hostelería, sin ventilador y con frontal resistente a salpicaduras) **no está confirmado**: las páginas consultadas no indican refrigeración ni protección IP. Es un equipo todo en uno de gama general. Mitigación: colocarlo fuera de la zona de salpicaduras y limpiarlo con paño. Si el cliente lo exige, habría que pasar a un TPV de hostelería con protección IP, de mayor precio.
- No es un TPV de hostelería especializado.

### 3.3 Impresoras de tickets (2 unidades)

| | A: Epson TM-T20IV (C31CL47102) (elegida) | B: Epson TM-T20III (011) USB + serie |
|---|---|---|
| Interfaces | USB, Ethernet 10/100 y RS-232 | USB y RS-232 |
| Velocidad | 250 mm/s | 250 mm/s |
| Papel y corte | 80 mm, cortador automático | 80 mm, cortador automático |
| Cajón portamonedas | No consta en la página | Salida para cajón (ficha de Epson) |
| Precio | 199,86 € | 241,20 € |
| Estado del modelo | Vigente (sucesor de la serie T20III) | Descatalogado por Epson |

**Elección: A, conectada por USB al TPV (una por TPV).** Se cambia la T20III de la primera versión por la T20IV por tres razones: cuesta menos (41,34 € menos por unidad), sigue en catálogo del fabricante y trae USB y Ethernet, lo que cumple RI-05 por completo. La propuesta de Peio en el presupuesto (tarea 10) ya incluía este modelo.

La conexión recomendada sigue siendo **USB** directamente al TPV: evita un dispositivo más en la red, sin IP ni reglas de cortafuegos ni panel de administración expuesto (RI-06), en coherencia con los mínimos privilegios. La interfaz Ethernet queda disponible si más adelante se decide imprimir por red o compartir una impresora entre dos puestos; en ese caso habría que añadir IP fija y reglas entre redes (ver tarea 10, sección 4.3). Cumple RI-01 (80 mm térmica), RI-03 (cortador automático) y RI-07 (250 mm/s). La compatibilidad con ESC/POS y con el controlador de Windows (RI-02) debe comprobarse en la tarea de instalación de impresora.

**Riesgos:**
- La página de la tienda no menciona la salida para cajón (RI-04). Epson lista la serie TM-T20 como compatible con apertura de cajón, pero hay que confirmarlo en la hoja técnica del modelo antes de comprar si el cliente quiere cajón.
- La tienda no indica si el precio incluye IVA (H-02) ni stock; muestra entrega estimada para el 26/10/2026.
- El enunciado no dice cuántas impresoras hay. Se ha supuesto una por TPV (S-01 de la tarea 7).

### 3.4 Monitor del gerente

| | A: Xiaomi A24i 24" (elegido) | B: LG 24MP400-B 24" |
|---|---|---|
| Panel | IPS, 1920x1080, 100 Hz | IPS, 1920x1080, 75 Hz |
| Entradas | DisplayPort y HDMI | HDMI y VGA |
| VESA | No consta | 75 x 75 mm |
| Precio | 90,99 € | 149,99 € |
| Disponibilidad | Disponible | Sin fecha de entrada |

**Elección: A.** Cumple lo pedido (22-24", Full HD) por casi 60 € menos, con DisplayPort y HDMI, que enlazan con el mini PC elegido (HDMI y DisplayPort). Limitación: el soporte no es regulable en altura y no consta compatibilidad VESA.

## 4. Cumplimiento de los requisitos de la tarea 7

| Requisito | Cumple | Cómo |
|---|---|---|
| RG-01 Arranque dual | Sí | 512 GB de SSD para dos sistemas. El equipo es moderno y lleva UEFI, a confirmar en su ficha. Se simula en VMware Workstation (tarea 12). |
| RG-06 Rendimiento | Sí | 8 núcleos y 16 GB de RAM. |
| RG-07 Conexión | Sí | Ethernet gigabit. |
| RT-01, RT-04, RT-06 Quiosco y restricciones | Sí | Windows Pro (modo quiosco, directivas de seguridad local, cortafuegos). Hay que aplicar los derechos de licencia (sección 6). |
| RT-03 Táctil | Sí | Capacitiva de 15,6". |
| RT-05 USB bloqueado | Sí | 8 USB, que se bloquean por directiva. |
| RT-07 Rendimiento | Sí | 4 núcleos, 8 GB de RAM y SSD. |
| RT-08 Ethernet | Sí | Gigabit. |
| RT-09 Apto hostelería | **No confirmado** | Sin datos de refrigeración ni protección IP. |
| RI-01, RI-03, RI-07 Térmica, corte y velocidad | Sí | 80 mm, cortador automático, 250 mm/s. |
| RI-02 ESC/POS y controlador Windows | A verificar | Comprobar en la tarea de instalación de la impresora. |
| RI-04 Cajón | A verificar | La página de la tienda no lo menciona; hay que confirmarlo en la hoja técnica de Epson. |
| RI-05 USB y Ethernet | Sí | La TM-T20IV trae USB, Ethernet y RS-232. |
| RI-06 Seguridad de la impresora | Sí | Al ir por USB no expone ningún servicio de red. Si se usa Ethernet, IP fija y reglas de cortafuegos. |

## 5. Coste

| Concepto | Importe |
|---|---|
| Equipo del gerente | 792,67 € |
| Monitor del gerente | 90,99 € |
| 2 TPV | 1.077,98 € |
| 2 impresoras | 399,72 € |
| **Total verificado (precios de tienda)** | **2.361,36 €** |
| Si los precios incluyen IVA del 21 %: base imponible | 1.951,54 € |
| Si los precios incluyen IVA del 21 %: IVA | 409,82 € |

Elementos sin precio verificado, para añadir al presupuesto con el valor que se confirme: teclado y ratón del gerente (estimación propia de 20 €, sin verificar), rollos de papel térmico de 80 mm (estimación propia de 25 € por el primer pack, sin verificar) y SAI opcional. Con esas dos estimaciones, el total sería de unos 2.406,36 €.

## 6. Incidencias y supuestos

| Id | Asunto | Cómo se resuelve |
|---|---|---|
| H-01 | **Windows 10 frente a Windows 11 Pro.** Los equipos elegidos traen Windows 11 Pro y el enunciado exige Windows 10. Windows 11 Pro suele incluir derechos para instalar Windows 10 Pro, pero hay que confirmarlo en las condiciones de licencia de Microsoft y del vendedor. | Confirmar la licencia. Windows 10 Pro no tiene soporte gratuito desde el 14/10/2025 y el ESU para particulares terminó el 13/10/2026. Para los TPV se propone **Windows 10 IoT Enterprise LTSC 2021** (soporte hasta 2032) o el ESU de pago para empresas ([tarea 10](10-presupuesto-hardware.md), apartado 4.1). |
| H-02 | Los precios no indican si incluyen IVA. | Confirmar con la tienda o en el carrito antes del presupuesto final. |
| H-03 | Stock: a fecha de consulta no hay stock del Lenovo Neo 50q Gen 4. | Buscar el mismo modelo en otras tiendas o el sucesor. |
| H-04 | Resuelta: se sustituye la impresora descatalogada TM-T20III por la TM-T20IV (vigente). | Comprobar precio y stock antes de comprar. |
| H-05 | RT-09 (hostelería) no confirmado. | Decidir con el equipo si se acepta el riesgo o se sube de gama. |
| H-06 | En las pruebas del reto estos equipos se simulan en máquinas virtuales (VirtualBox o VMware Workstation). | Ver S-07 de la tarea 7. |
| H-07 | Precios sujetos a cambio. | Actualizar antes de la entrega final. |

## 7. Hardware de otros bloques pendiente de consolidar

Ya están en el presupuesto ([tarea 10](10-presupuesto-hardware.md#12-elementos-que-faltaban-en-el-presupuesto), secciones 4.4 y 12): routers, switch, servidor, discos del RAID, disco USB de copias, SAI, cable, adaptador Wi-Fi de la recreativa y palanca del stick. Lista original:

- Router, repetidor Wi-Fi y switch (bloque de redes).
- Equipo de la máquina recreativa y placa Arduino con el joystick (bloque de arcade; el centro presta algunos).
- Servidor de Odoo y discos del RAID (bloque de datos y ERP).

## 8. Referencias (consultadas el 22/10/2026)

- [Lenovo ThinkCentre Neo 50q Gen 4, PcComponentes](https://www.pccomponentes.com/lenovo-thinkcentre-neo-50q-gen-4-intel-core-i5-13420h-16gb-512gb-ssd)
- [HP ProDesk 400 G5 Mini reacondicionado, Back Market](https://www.backmarket.es/es-es/p/hp-prodesk-400-g5-mini-core-i5-3-ghz-ssd-512-gb-ram-16-gb/d867ff6a-a720-43db-890e-9f03f00b22d8)
- [Iggual AIO B156.88.N100, PcComponentes](https://www.pccomponentes.com/ordenador-todo-en-uno-iggual-aio-b15688n100-intel-n100-8gb-256gb-ssd-uhd-156-windows-11-pro-tactil)
- [Approx APPTPV05+ G8-256, PcComponentes](https://www.pccomponentes.com/approx-apptpv05-plus-g8-256-ordenador-tpv-intel-celeron-j4125-8gb-256gb-ssd-15-6-tactil)
- [10POS TPV J6412, Beep](https://www2.beep.es/es/product/10t-15j648128w1-10pos-tpv-15-intel-j6412-8gb-128gb-w11-iot)
- [Epson TM-T20IV Ethernet/USB/RS-232, PcComponentes (consultada el 23/10/2026)](https://www.pccomponentes.com/impresora-termica-ethernet-usb-rs-232-epson-tm-t20iv-con-cortador-automatico-y-codigos-de-barras)
- [Epson TM-T20III USB + serie, PcComponentes](https://www.pccomponentes.com/epson-tm-t20iii-impresora-tickets-usb-serial-negra)
- [Epson TM-T20III Ethernet, PcComponentes](https://www.pccomponentes.com/epson-tm-t20iii-impresora-tickets-ethernet-negra)
- [Epson TM-T20III Ethernet, Beep](https://www.beep.es/c31ch51012-epson-impresora-tickets-tm-t20iii-ethernet/p)
- [Epson TM-T20III (011), ficha de Epson Europa](https://epson.eu/en_EU/products/printers/pos-printers/pos-printers/pc-pos-printers/epson-tm-t20iii-(011):-usb-+-serial,-ps,-blk,-eu/p/28149)
- [Xiaomi A24i 24", PcComponentes](https://www.pccomponentes.com/monitor-xiaomi-a24i-monitor-24-fhd-ips-100-hz)
- [LG 24MP400-B, PcComponentes](https://www.pccomponentes.com/lg-24mp400-b-24-led-ips-fullhd-75hz-freesync)
- [Requisitos de sistema de Windows 10, Microsoft](https://support.microsoft.com/en-us/windows/windows-10-system-requirements-6d4e9a79-66bf-7950-467c-795cf0386715)
