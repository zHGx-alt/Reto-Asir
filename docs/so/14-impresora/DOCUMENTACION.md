# Tareas 14 y 37: Impresora de tickets en el TPV y ticket desde Odoo

- **Bloque:** 2 SO (14) y 7 ERP (37)
- **Responsables:** Adrian (14) · Peio (37)
- **Requisitos que cubre:** RI-01 a RI-07 y RT-02 de la [tarea 7](../../hardware/07-necesidades-equipos.md)
- **Estado:** guía preparada el 24/10/2026. **La impresora la da el centro**: hasta entonces solo se puede hacer la parte de la VM (sección 3, pasos 1-3 con la impresora en modo «Microsoft Print to PDF»).

## 1. Cómo va conectada

La impresora va **por USB a su TPV** (decisión de la tarea 8): no tiene IP, ni panel de administración ni reglas de firewall. Odoo genera el ticket en el navegador del TPV y Windows lo imprime con el driver de la impresora.

```
TPV (Edge en quiosco, TPV de Odoo) ── ticket ──► cola de Windows ──USB──► impresora térmica 80 mm
```

## 2. Antes de empezar

- Apuntar **marca, modelo y conexiones** de la impresora que dé el centro. Si no es la Epson TM-T20IV del presupuesto, buscar su driver de Windows en la web del fabricante (para Epson TM: *Advanced Printer Driver*, APD).
- Descargar el driver **desde la web del fabricante** con la cuenta de administración, **antes** de ejecutar `configurar-tpv.ps1` (después, Edge solo abre Odoo y los USB de almacenamiento están bloqueados). Si el TPV ya está bastionado, se descarga en otro equipo y se instala desde una carpeta compartida o se desactiva temporalmente el bloqueo USB.

## 3. Procedimiento

1. **Instalar el driver** (cuenta de administración). Conectar la impresora por USB cuando lo pida el instalador.
2. **Comprobar en PowerShell** que aparece y apuntar su nombre y el del driver (van a la [tarea 9](../../hardware/09-tabla-software-licencias.md)):
   ```powershell
   Get-Printer | Format-Table Name, DriverName, PortName, PrinterStatus
   ```
   ```powershell
   Get-PrinterDriver | Format-Table Name, MajorVersion, Manufacturer
   ```
3. **Ajustes de la impresora** (*Preferencias de impresión*): papel de 80 mm (ancho del rollo), corte automático al final del documento y, si hay cajón, apertura del cajón tras el ticket.
4. **Que sea la predeterminada del cajero.** Con la sesión de `cajero` (antes de activar el quiosco, o saliendo de él): *Configuración → Dispositivos → Impresoras* → desmarcar «Permitir que Windows administre la impresora predeterminada» → elegir la térmica como predeterminada.
5. **Página de prueba** desde *Propiedades de impresora → Imprimir página de prueba*. Foto del ticket como evidencia (tarea 14).
6. **Ticket desde Odoo (tarea 37):** en Odoo, *Punto de venta → Configuración → Ajustes* del TPV: activar **«Impresión automática del recibo»** si se quiere que salga el diálogo nada más cobrar. Hacer una venta como en la [tarea 34, sección 8.2](../../erp/34-configurar-odoo/DOCUMENTACION.md) y pulsar *Imprimir recibo*: sale el diálogo de Edge con la térmica seleccionada → *Imprimir*. Foto del ticket impreso.
7. **Repetir en el TPV 2** con su impresora.

## 4. Pruebas

| # | Prueba | Resultado esperado | Requisito |
|---|---|---|---|
| 1 | `Get-Printer` | La térmica aparece con puerto `USB00x` y estado `Normal` | RI-02 |
| 2 | Página de prueba de Windows | Sale en 80 mm y se corta sola | RI-01, RI-03 |
| 3 | Ticket de una venta de Odoo | Sale con el detalle de la venta y el IVA, en pocos segundos | RT-02, RI-07 |
| 4 | Desde la Wi-Fi de invitados, buscar la impresora en la red | No aparece (va por USB, sin IP) | RI-06 |
| 5 | Como `cajero`, intentar cambiar el driver o borrar la impresora | Se pide administrador y se deniega | RT-04 |

## 5. Limitaciones

- **Impresora de las pruebas (decisión del 27/10/2026).** Las térmicas del centro no llegan para todos los grupos, así que las pruebas se hacen con una **Samsung ML-1660** láser (A4, sin corte ni cajón). Pasada por USB a una VM, Windows instala el driver pero no crea el puerto `USB001`. Por IPP a la cola CUPS del equipo que la tiene enchufada sí imprime el ticket de Odoo: así se hizo la tarea 37 ([tarea 52, sección 4.2](../../erp/52-https-odoo/DOCUMENTACION.md#42-pruebas-5-y-6-con-un-tpv-provisional-26102026)). Las pruebas 1, 2 y 4 de la sección 4 son de la térmica y no se pueden hacer con ella.

- **Diálogo de impresión.** Con Edge en el modo quiosco de Windows 10 Pro, cada ticket muestra el diálogo de impresión (un toque en *Imprimir*). Imprimir sin diálogo necesita lanzar Edge con `--kiosk-printing`, que se puede en Windows 10 IoT Enterprise con Shell Launcher, o una IoT Box de Odoo (de pago). Se deja así y se documenta.
- **ESC/POS directo** (comandos de corte y cajón desde Odoo) solo funciona con la IoT Box. Con el driver de Windows, el corte y el cajón los hace el driver (paso 3).
