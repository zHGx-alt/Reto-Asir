# Tarea 32: Comparativa y elección de ERP

- **Bloque:** 7 ERP
- **Reto:** Almi-Chain (ASIR1 2026-27)
- **Estado:** pendiente de revisión (revisa: Markel)
- **Fecha:** 22/10/2026

## 1. Qué tiene que hacer el ERP

El enunciado pide un ERP con TPV para los restaurantes, con estas funciones: facturas, CRM, personal, marketing e inventario. Además, un caso de uso automatizado de principio a fin (la factura) y una base de datos por establecimiento con disco redundante. El ERP se instala en una máquina virtual (VirtualBox) y debe poder configurarse con mínimos privilegios.

## 2. Candidatos

Comparamos tres ERP de código abierto con edición gratuita:

| ERP | Qué es | Licencia de la edición gratuita |
|---|---|---|
| **Odoo Community** | ERP modular. Edición gratuita y edición Enterprise de pago | LGPL-3 (Enterprise es propietaria) |
| **ERPNext** | ERP del proyecto Frappe, completo y sin edición de pago | Código abierto (GPL) |
| **Dolibarr** | ERP/CRM ligero en PHP | Código abierto (GPL) |

## 3. Comparativa por criterios

| Criterio | Odoo Community | ERPNext | Dolibarr |
|---|---|---|---|
| Facturas, CRM, personal, marketing, inventario | Todas disponibles. Community trae facturación y la contabilidad básica (asientos, diarios, plan contable, impuestos); Enterprise añade los informes contables completos y la gestión avanzada (ver E-01) | Todas, en una sola edición | Todas mediante módulos; interfaz más básica |
| TPV | Aplicación de TPV integrada con interfaz táctil | TPV incluido, menos orientado a hostelería | Módulo TakePOS |
| API | API externa (XML-RPC/JSON-RPC; JSON-2 en Odoo 19) | API REST muy cómoda | API REST, menos completa |
| España (IVA, plan contable) | Localización española oficial | Hay que configurar impuestos a mano | Soporte parcial por módulos |
| Verifactu (ver 4) | Módulos de terceros; oficial pendiente de comprobar | Solo desarrollo a medida de terceros | Anunciado para 2026, sin confirmar |
| Instalación en VM | Docker Compose + PostgreSQL | Más pesado (MariaDB, Redis, varios servicios) | Sencilla (PHP + MariaDB/PostgreSQL) |
| Base de datos | PostgreSQL | MariaDB | MariaDB o PostgreSQL |
| Seguridad / roles | Grupos de acceso y reglas por registro | Roles y permisos por documento | Permisos por módulo |
| Documentación y comunidad | Muy amplia, mucho material en español | Buena | Menor |

## 4. Verifactu (factura electrónica en España)

Es un riesgo a vigilar, no un impedimento para el reto, porque el calendario cambia.

- Una fuente (qamarero.com) indica obligación para sociedades desde el **1/1/2027** y para autónomos desde el **1/7/2027**, tras el aplazamiento del Real Decreto-ley 15/2025.
- Una fuente más reciente (wwwhatsnew.com, 6/10/2026) dice que Hacienda **aplazará hasta octubre de 2028** las obligaciones pendientes del Real Decreto 1007/2023, aunque el nuevo plazo **todavía no consta en una norma formal**.
- Conclusión: no podemos fijar una fecha con seguridad. Lo documentaremos como riesgo y comprobaremos el BOE antes de entregar.

Sobre el soporte en cada ERP:

- **Odoo:** existen módulos de terceros de pago (por ejemplo, el de Mr Rubik, con licencia propietaria OPL-1). En el foro de Odoo, una respuesta sin fecha indica que el módulo de la comunidad (OCA/l10n-spain) aún no estaba publicado. La documentación oficial de Odoo no pudimos leerla desde aquí, así que hay que comprobarla.
- **ERPNext:** solo hemos encontrado un desarrollo a medida de un tercero (ECOSIRE), con licencia sin confirmar.
- **Dolibarr:** DoliCloud dice que los módulos de Facturae y Verifactu «deberían estar disponibles de serie a partir de principios de 2026». No hemos podido confirmar que lo estén.

## 5. Matriz de puntuación

Puntuación de 1 (peor) a 5 (mejor). Los pesos suman 100. Total = suma de peso × puntuación, dividido entre 100 (calculado con un script).

| Criterio | Peso | Odoo | ERPNext | Dolibarr |
|---|---|---|---|---|
| Funciones pedidas | 25 | 5 | 4 | 4 |
| TPV integrado | 15 | 5 | 3 | 3 |
| API para automatizar el caso de uso | 15 | 4 | 5 | 3 |
| Localización España (IVA, plan contable, Verifactu) | 15 | 4 | 2 | 3 |
| Instalación en VM (Docker, PostgreSQL) | 10 | 5 | 3 | 4 |
| Seguridad y mínimos privilegios | 10 | 4 | 4 | 3 |
| Documentación y comunidad | 5 | 5 | 4 | 3 |
| Coste y licencia | 5 | 4 | 5 | 5 |
| **Total (sobre 5)** | **100** | **4,55** | **3,65** | **3,45** |

Los pesos y las puntuaciones son juicio nuestro, basado en las fuentes de la sección 8 y en el enunciado. Si se cambian los pesos, hay que recalcular los totales.

## 6. Elección: Odoo Community

Elegimos **Odoo Community**. Razones:

1. Es el que mejor cubre las funciones del enunciado, incluido un TPV táctil integrado que sirve para el caso de uso de los restaurantes.
2. Usa PostgreSQL, que ya es la base de datos común del proyecto, y se instala en una VM con Docker Compose.
3. Es el de mayor documentación y comunidad, con mucho material en español.
4. Es gratuito (LGPL-3), compatible con el presupuesto del reto.

**Versión.** Proponemos **Odoo 19.0**. Según una fuente secundaria (ecosire.com), Odoo 20 salió en septiembre de 2026, pero la 19.0 tiene soporte estándar previsto hasta septiembre de 2028 y la 20 es demasiado reciente para tener módulos y guías. Hay que confirmar con el profesor si impone versión.

## 7. Riesgos y límites

| Id | Riesgo | Mitigación |
|---|---|---|
| E-01 | Community **sí** genera asientos con el plan PYMES (se comprobó en la tarea 34: asiento `POSS/2026/10/0001`), pero le faltan funciones de Enterprise: informes contables completos (balance, pérdidas y ganancias, libros), conciliación bancaria avanzada, activos, presupuestos y el módulo de contabilidad completo para el asesor | El caso de uso es la factura, que entra en Community. Los informes legales los puede sacar la gestoría con los datos exportados (tarea 36). Documentarlo como límite |
| E-02 | Verifactu: calendario incierto y sin módulo oficial confirmado | Documentar como riesgo y revisar el BOE antes de entregar |
| E-03 | La API cambia entre versiones (JSON-2 en Odoo 19) | Fijar la versión y escribir el automatismo contra ella |
| E-04 | Pasar de Community a Enterprise no es trivial | Fuera del alcance del reto |
| E-05 | No hemos podido leer la página oficial de ediciones de Odoo | Comprobar el primer día que Facturación, TPV, CRM, Empleados, Inventario y Email Marketing aparecen en Community 19.0 |

## 8. Referencias (consultadas el 22/10/2026)

- [Odoo Community vs Enterprise, Glorium Tech](https://gloriumtech.com/odoo-community-vs-enterprise/)
- [Latest Odoo version, ECOSIRE](https://ecosire.com/de/blog/latest-odoo-version)
- [Veri*Factu POS, Mr Rubik (Odoo Apps)](https://apps.odoo.com/apps/modules/16.0/l10n_es_verifactu_POS)
- [Verifactu module in OCA for Spain, foro de Odoo](https://odoo.com/forum/help-1/verifactu-module-in-oca-for-spain-281166)
- [ERPNext Spain Verifactu, ECOSIRE](https://ecosire.com/es/apps/erpnext/erpnext-spain-verifactu)
- [Dolibarr y facturación electrónica, DoliCloud](https://www.dolicloud.com/are-dolicloud-and-dolibarr-ready-for-electronic-invoicing.php)
- [Versiones de Dolibarr (24.0.2, 2/10/2026)](https://wiki.dolibarr.org/index.php/Versionen)
- [Verifactu para restaurantes, Qamarero](https://www.qamarero.com/en/blog/spain-verifactu-restaurant/)
- [Hacienda retrasa Verifactu hasta octubre de 2028, WWWhatsNew](https://wwwhatsnew.com/2026/10/06/hacienda-verifactu-octubre-2028-aplazamiento-factura-electronica-2026)

## 9. Dudas para el profesor

1. ¿Hay que usar una versión concreta de Odoo?
2. ¿Hay que cumplir Verifactu en el reto o basta con documentarlo?
3. ¿Se admite instalar módulos de terceros (OCA o de pago)?
