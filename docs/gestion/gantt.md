# Planificación · Diagrama de Gantt

Del 21/10/2026 al 10/11/2026 (15 días laborables).

> Fichero generado con `python3 scripts/gantt.py` a partir de [backlog-kanban.csv](backlog-kanban.csv). Para cambiar fechas o responsables, edita el CSV y vuelve a generarlo.

```mermaid
gantt
    dateFormat YYYY-MM-DD
    axisFormat %d/%m
    excludes weekends
    section 0 Gestión
    Firmar Anexo I (contrato de equipo) · Adrian :t1, 2026-10-21, 2026-10-22
    Mantener Anexo II (11 pasos) · Adrian :active, t2, 2026-10-21, 2026-11-11
    Repartir tareas y responsables · Adrian :done, t3, 2026-10-21, 2026-10-22
    Crear tablero Kanban en GitHub Projects · Iker :t4, 2026-10-21, 2026-10-23
    Repo con estructura y gitleaks, commits de todos · Adrian :active, t5, 2026-10-21, 2026-10-23
    Resolver dudas pendientes con el profesor · Peio :t6, 2026-10-21, 2026-10-23
    section 1 Hardware
    Definir necesidades de equipos (gerente, 2 TPV, impresoras) · Eneko.S :t7, 2026-10-22, 2026-10-24
    Tabla de hardware con justificación · Eneko.S :t8, 2026-10-23, 2026-10-27
    Tabla de software y licencias · Markel :t9, 2026-10-23, 2026-10-27
    Presupuesto con enlaces (incl. WAN y router extra) · Peio :t10, 2026-10-26, 2026-10-28
    Diagrama de arquitectura de equipos · Iker :t11, 2026-10-27, 2026-10-29
    section 2 SO
    Dual boot Win10 + Linux en el equipo del gerente · Eneko.P :t12, 2026-10-28, 2026-10-31
    Bastionado de los 2 TPV Windows (usuario estándar, kiosko, USB) · Markel :t13, 2026-10-28, 2026-11-03
    Instalar impresora de tickets y prueba · Peio :t14, 2026-10-29, 2026-10-31
    Scripts de configuración reproducibles · Adrian :t15, 2026-10-30, 2026-11-04
    section 3 Arcade
    Instalar SO ligero y MAME con arranque directo · Iker :t16, 2026-10-26, 2026-10-29
    Pruebas de rendimiento MAME antes/después · Iker :t17, 2026-10-29, 2026-10-31
    Monitorización de recursos de la recreativa · Eneko.S :t18, 2026-10-30, 2026-11-03
    section 4 Arduino
    Montaje del arcade stick (ATmega32U4) · Eneko.P :t19, 2026-10-22, 2026-10-28
    Firmware HID y mapeo configurable (EEPROM) · Adrian :t20, 2026-10-27, 2026-10-31
    Pruebas del stick con MAME y otro emulador · Eneko.P :t21, 2026-11-02, 2026-11-04
    section 5 Redes
    Comparativa de operadores WAN · Markel :t22, 2026-10-22, 2026-10-24
    Plano del local y plan de direccionamiento IP · Eneko.P :t23, 2026-10-22, 2026-10-27
    Configurar red segura (WPA3, invitados, firewall) · Peio :t24, 2026-10-28, 2026-10-31
    WDS con segundo router y pruebas de cobertura · Peio :t25, 2026-11-02, 2026-11-05
    Análisis de conectividad (Wireshark, nmap) · Eneko.S :t26, 2026-11-04, 2026-11-06
    section 6 Web
    Wireframes y diseño conceptual web · Peio :t27, 2026-10-22, 2026-10-24
    Implementar web (mapa, formulario, slideshow) · Markel :t28, 2026-10-26, 2026-10-31
    Validación W3C, Lighthouse y accesibilidad · Eneko.P :t29, 2026-11-02, 2026-11-04
    Hosting AWS con dominio y HTTPS · Adrian :t30, 2026-11-02, 2026-11-05
    IaC y despliegue automatizado (Terraform + Actions) · Iker :t31, 2026-11-02, 2026-11-06
    section 7 ERP
    Comparativa y elección de ERP · Eneko.S :t32, 2026-10-22, 2026-10-24
    Instalar Odoo + PostgreSQL con Docker · Iker :t33, 2026-10-26, 2026-10-29
    Configurar módulos de Odoo · Markel :t34, 2026-10-29, 2026-11-03
    Caso de uso end-to-end automatizado · Adrian :t35, 2026-11-03, 2026-11-06
    Importar y exportar datos en Odoo · Peio :t36, 2026-11-04, 2026-11-06
    Imprimir ticket desde el TPV de Odoo · Eneko.P :t37, 2026-11-04, 2026-11-06
    section 8 BD
    Modelo E/R · Adrian :t38, 2026-10-22, 2026-10-24
    Modelo lógico normalizado (3FN) · Eneko.S :t39, 2026-10-26, 2026-10-28
    Scripts DDL · Eneko.S :t40, 2026-10-28, 2026-10-30
    Datos de prueba y consultas · Iker :t41, 2026-10-30, 2026-11-03
    Usuarios de BD con mínimos privilegios · Markel :t42, 2026-11-02, 2026-11-04
    section 9 Backup
    RAID 1 y simulación de fallo · Eneko.P :t43, 2026-10-29, 2026-11-03
    Plan de backup 3-2-1 cifrado y automatizado · Markel :t44, 2026-11-03, 2026-11-06
    Prueba de restauración con evidencias · Iker :t45, 2026-11-05, 2026-11-07
    section 10 Seguridad
    Revisión de seguridad transversal · Eneko.S :t46, 2026-11-05, 2026-11-07
    section 11 Entrega
    Tabla de pruebas por bloque · Eneko.P :t47, 2026-11-05, 2026-11-10
    Documentación final paso a paso · Markel :t48, 2026-11-06, 2026-11-11
    Presentación y ensayo · Peio :t49, 2026-11-09, 2026-11-11
```

## Carga por persona

| Persona | Tareas | Días-tarea | Revisiones | Bloques que toca |
|---|---|---|---|---|
| Adrian | 9 | 34 | 7 | 0, 2, 4, 6, 7, 8 |
| Eneko.P | 8 | 22 | 7 | 2, 4, 5, 6, 7, 9, 11 |
| Eneko.S | 8 | 16 | 8 | 1, 3, 5, 7, 8, 10 |
| Iker | 8 | 20 | 8 | 0, 1, 3, 6, 7, 8, 9 |
| Markel | 8 | 24 | 8 | 1, 2, 5, 6, 7, 8, 9, 11 |
| Peio | 8 | 18 | 8 | 0, 1, 2, 5, 6, 7, 11 |

## Tareas por persona

### Adrian

| # | Tarea | Bloque | Fechas | Revisa | Estado |
|---|---|---|---|---|---|
| 1 | Firmar Anexo I (contrato de equipo) | 0 Gestión | 21/10–21/10 | Equipo | Pendiente |
| 2 | Mantener Anexo II (11 pasos) | 0 Gestión | 21/10–10/11 | Iker | En curso |
| 3 | Repartir tareas y responsables | 0 Gestión | 21/10–21/10 | Equipo | Hecho |
| 5 | Repo con estructura y gitleaks; commits de todos | 0 Gestión | 21/10–22/10 | Eneko.P | En curso |
| 15 | Scripts de configuración reproducibles | 2 SO | 30/10–03/11 | Markel | Pendiente |
| 20 | Firmware HID y mapeo configurable (EEPROM) | 4 Arduino | 27/10–30/10 | Eneko.P | Pendiente |
| 30 | Hosting AWS con dominio y HTTPS | 6 Web | 02/11–04/11 | Eneko.P | Pendiente |
| 35 | Caso de uso end-to-end automatizado | 7 ERP | 03/11–05/11 | Iker | Pendiente |
| 38 | Modelo E/R | 8 BD | 22/10–23/10 | Peio | Pendiente |

### Eneko.P

| # | Tarea | Bloque | Fechas | Revisa | Estado |
|---|---|---|---|---|---|
| 12 | Dual boot Win10 + Linux en el equipo del gerente | 2 SO | 28/10–30/10 | Eneko.S | Pendiente |
| 19 | Montaje del arcade stick (ATmega32U4) | 4 Arduino | 22/10–27/10 | Peio | Pendiente |
| 21 | Pruebas del stick con MAME y otro emulador | 4 Arduino | 02/11–03/11 | Markel | Pendiente |
| 23 | Plano del local y plan de direccionamiento IP | 5 Redes | 22/10–26/10 | Iker | Pendiente |
| 29 | Validación W3C; Lighthouse y accesibilidad | 6 Web | 02/11–03/11 | Peio | Pendiente |
| 37 | Imprimir ticket desde el TPV de Odoo | 7 ERP | 04/11–05/11 | Peio | Pendiente |
| 43 | RAID 1 y simulación de fallo | 9 Backup | 29/10–02/11 | Iker | Pendiente |
| 47 | Tabla de pruebas por bloque | 11 Entrega | 05/11–09/11 | Markel | Pendiente |

### Eneko.S

| # | Tarea | Bloque | Fechas | Revisa | Estado |
|---|---|---|---|---|---|
| 7 | Definir necesidades de equipos (gerente; 2 TPV; impresoras) | 1 Hardware | 22/10–23/10 | Iker | Pendiente |
| 8 | Tabla de hardware con justificación | 1 Hardware | 23/10–26/10 | Peio | Pendiente |
| 18 | Monitorización de recursos de la recreativa | 3 Arcade | 30/10–02/11 | Markel | Pendiente |
| 26 | Análisis de conectividad (Wireshark; nmap) | 5 Redes | 04/11–05/11 | Markel | Pendiente |
| 32 | Comparativa y elección de ERP | 7 ERP | 22/10–23/10 | Markel | Pendiente |
| 39 | Modelo lógico normalizado (3FN) | 8 BD | 26/10–27/10 | Peio | Pendiente |
| 40 | Scripts DDL | 8 BD | 28/10–29/10 | Adrian | Pendiente |
| 46 | Revisión de seguridad transversal | 10 Seguridad | 05/11–06/11 | Eneko.P | Pendiente |

### Iker

| # | Tarea | Bloque | Fechas | Revisa | Estado |
|---|---|---|---|---|---|
| 4 | Crear tablero Kanban en GitHub Projects | 0 Gestión | 21/10–22/10 | Adrian | Pendiente |
| 11 | Diagrama de arquitectura de equipos | 1 Hardware | 27/10–28/10 | Adrian | Pendiente |
| 16 | Instalar SO ligero y MAME con arranque directo | 3 Arcade | 26/10–28/10 | Markel | Pendiente |
| 17 | Pruebas de rendimiento MAME antes/después | 3 Arcade | 29/10–30/10 | Eneko.P | Pendiente |
| 31 | IaC y despliegue automatizado (Terraform + Actions) | 6 Web | 02/11–05/11 | Adrian | Pendiente |
| 33 | Instalar Odoo + PostgreSQL con Docker | 7 ERP | 26/10–28/10 | Peio | Pendiente |
| 41 | Datos de prueba y consultas | 8 BD | 30/10–02/11 | Eneko.S | Pendiente |
| 45 | Prueba de restauración con evidencias | 9 Backup | 05/11–06/11 | Markel | Pendiente |

### Markel

| # | Tarea | Bloque | Fechas | Revisa | Estado |
|---|---|---|---|---|---|
| 9 | Tabla de software y licencias | 1 Hardware | 23/10–26/10 | Eneko.P | Pendiente |
| 13 | Bastionado de los 2 TPV Windows (usuario estándar; kiosko; USB) | 2 SO | 28/10–02/11 | Iker | Pendiente |
| 22 | Comparativa de operadores WAN | 5 Redes | 22/10–23/10 | Eneko.S | Pendiente |
| 28 | Implementar web (mapa; formulario; slideshow) | 6 Web | 26/10–30/10 | Eneko.S | Pendiente |
| 34 | Configurar módulos de Odoo | 7 ERP | 29/10–02/11 | Adrian | Pendiente |
| 42 | Usuarios de BD con mínimos privilegios | 8 BD | 02/11–03/11 | Iker | Pendiente |
| 44 | Plan de backup 3-2-1 cifrado y automatizado | 9 Backup | 03/11–05/11 | Eneko.S | Pendiente |
| 48 | Documentación final paso a paso | 11 Entrega | 06/11–10/11 | Peio | Pendiente |

### Peio

| # | Tarea | Bloque | Fechas | Revisa | Estado |
|---|---|---|---|---|---|
| 6 | Resolver dudas pendientes con el profesor | 0 Gestión | 21/10–22/10 | Adrian | Pendiente |
| 10 | Presupuesto con enlaces (incl. WAN y router extra) | 1 Hardware | 26/10–27/10 | Eneko.S | Pendiente |
| 14 | Instalar impresora de tickets y prueba | 2 SO | 29/10–30/10 | Eneko.S | Pendiente |
| 24 | Configurar red segura (WPA3; invitados; firewall) | 5 Redes | 28/10–30/10 | Adrian | Pendiente |
| 25 | WDS con segundo router y pruebas de cobertura | 5 Redes | 02/11–04/11 | Iker | Pendiente |
| 27 | Wireframes y diseño conceptual web | 6 Web | 22/10–23/10 | Eneko.S | Pendiente |
| 36 | Importar y exportar datos en Odoo | 7 ERP | 04/11–05/11 | Eneko.P | Pendiente |
| 49 | Presentación y ensayo | 11 Entrega | 09/11–10/11 | Equipo | Pendiente |
