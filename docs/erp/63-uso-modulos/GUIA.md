# Tarea 63: Usar CRM, empleados, marketing e inventario con datos

- **Bloque:** 7 ERP
- **Responsable:** Eneko.P
- **Depende de:** tareas 34 (módulos instalados) y 36 (carta importada)
- **Criterio de la rúbrica:** [7. Implementación de un ERP](../../gestion/rubrica-anexo-VI.md#7-implementación-de-un-erp). Nivel 4: «se usan de forma correcta el resto de módulos del ERP». Como la rúbrica es acumulativa, sin el 4 tampoco cuenta el 5 (la factura automática de la tarea 35, que ya está hecha).
- **Estado (12/11/2026):** ✅ Hecha en la VM `ServidorERP` con el usuario `gerente`: los cinco casos de abajo con su captura (sección 7). Primera prueba de Eneko.P en su Odoo local (sección 8) y cierre en el servidor con [`caso-63.py`](caso-63.py) (sección 9).

## 1. Qué hay que demostrar

Los módulos están instalados desde la tarea 34, pero solo se han usado Facturación y TPV. Hay que usar **cada uno de los otros cuatro** con un caso del restaurante, y dejar una captura de cada paso:

| Módulo | Caso del restaurante | Qué tiene que verse al final |
|---|---|---|
| **CRM** | Una empresa pide presupuesto para una comida de 20 personas | Una oportunidad que pasa por las etapas y acaba **ganada**, con su presupuesto |
| **Ventas** | El presupuesto de esa comida | Un presupuesto con productos de la carta, enviado y confirmado |
| **Empleados** | La plantilla del local | Los empleados dados de alta, con su puesto y departamento |
| **Marketing por correo** | Avisar a los clientes del menú de temporada | Una lista de correo y una campaña preparada (o enviada a una dirección de prueba) |
| **Inventario** | Llega un pedido de bebida | Un producto almacenable con su stock y un ajuste de inventario |

## 2. Antes de empezar

- Entrar en Odoo (`https://<servidor>/web`) con **`gerente`** (contraseña en KeePassXC).
- `gerente` tiene ventas (y por tanto CRM), TPV e inventario, pero **no** Empleados ni Marketing por correo (tarea 34, sección 3). Para esas dos partes hay dos opciones:
  1. **Recomendada:** con `admin`, en *Ajustes → Usuarios → gerente*, darle **Empleados: Administrador** y **Marketing por correo: Usuario**. Captura del cambio (`63-00-permisos-gerente.png`). Es coherente: el gerente lleva la plantilla y la publicidad.
  2. Hacer esas dos partes con `admin` y decirlo en la sección 7.
- No poner datos personales reales: nombres inventados y correos `@example.com`.
- Las capturas van a `docs/erp/63-uso-modulos/evidencias/` con los nombres que se indican.

## 3. CRM y Ventas: de oportunidad a presupuesto

1. **CRM → Ventas → Mi pipeline → Nuevo.**
   - Oportunidad: `Comida de empresa 20 personas`
   - Cliente: crear `Talleres Ejemplo S.L.` (correo `compras@example.com`)
   - Ingreso esperado: `600 €` · Fecha de cierre: una semana
2. Arrastrar la tarjeta de **Nuevo** a **Cualificado** y después a **Propuesta**. Captura del tablero (`63-01-crm-pipeline.png`).
3. Abrir la oportunidad → botón **Nuevo presupuesto**. Añadir líneas de la carta (las importó la tarea 36):
   - `Menú del día` × 20
   - `Txakoli (copa)` × 20
   - `Tarta de queso` × 20
   
   Captura (`63-02-presupuesto.png`).
4. **Enviar por correo electrónico** (Odoo lo deja en la cola; no hace falta que salga) y **Confirmar**: pasa a *Pedido de venta*.
5. Volver a la oportunidad → **Ganada**. Captura con la cinta «Ganada» y el presupuesto enlazado (`63-03-oportunidad-ganada.png`).

**Para la defensa:** el CRM guarda el historial con el cliente (llamadas, correos, etapas) y el presupuesto sale de la misma ficha, sin volver a escribir los datos. Es justo lo que da un ERP frente a programas sueltos (tarea 58, sección 4).

## 4. Empleados

1. **Empleados → Departamentos → Nuevo:** `Sala` y `Cocina`.
2. **Empleados → Nuevo**, uno por puesto (los mismos puestos que la tabla `empleado` de `almi_chain`: gerente, camarero, cocina y barra). Por ejemplo:

   | Nombre | Puesto de trabajo | Departamento | Correo de trabajo |
   |---|---|---|---|
   | Ane Gerente | Gerente | Sala | `gerente@example.com` |
   | Jon Camarero | Camarero | Sala | `jon@example.com` |
   | Miren Cocina | Cocinera | Cocina | `miren@example.com` |
   | Iñigo Barra | Barra | Sala | `inigo@example.com` |

3. En la ficha de Ane, campo **Usuario relacionado** → `gerente`, y **Responsable** de Jon e Iñigo → Ane.
4. Captura de la vista de lista o de organigrama (`63-04-empleados.png`).

**Para la defensa:** en el TPV se puede exigir que cada camarero se identifique como empleado, y así cada venta queda a su nombre.

## 5. Marketing por correo

1. **Marketing por correo → Listas de correo → Nuevo:** `Clientes que aceptan publicidad`.
2. Añadir 3 contactos inventados (`cliente1@example.com`…). Captura (`63-05-lista-correo.png`).
3. **Marketing por correo → Nuevo:**
   - Asunto: `Menú de temporada de otoño`
   - Destinatarios: la lista anterior
   - Plantilla sencilla con un título, un texto y el botón *Reservar*
4. **Probar** (botón *Prueba*) enviándolo solo a una dirección `@example.com`. Sin servidor de correo configurado queda en la cola, y vale igual. Si hay correo, se puede mandar a una dirección propia.
5. Captura de la campaña (`63-06-campana.png`).

**Protección de datos:** solo se escribe a quien ha aceptado publicidad. Es la misma regla que tiene `almi_chain` (`cliente.acepta_publicidad`, con un CHECK que obliga a tener correo), y cada correo de Odoo lleva el enlace para darse de baja.

## 6. Inventario

1. **Inventario → Productos → Agua 50 cl** (o `Caña`): en *Información general*, marcar **Rastrear inventario**. Si no aparece, comprobar que el tipo es **Bienes**.
2. Botón **Actualizar cantidad** → `48` unidades en el almacén del restaurante. Captura (`63-07-stock-inicial.png`).
3. Vender 2 aguas desde el TPV como `cajero1` (o un pedido de venta) y volver al producto: tiene que marcar **46**. Captura (`63-08-stock-tras-venta.png`).
4. **Inventario → Operaciones → Ajustes físicos:** contar 45 (se ha roto una botella) y **Aplicar**. Captura del movimiento en *Informes → Historial de movimientos* (`63-09-ajuste-inventario.png`).

**Para la defensa:** la venta del TPV descuenta el stock sola. Es la integración entre módulos que da un ERP.

## 7. Resultados

Hecho el 12/11/2026 en `ServidorERP` (Odoo 19, base `tienda`) con el usuario `gerente`. Salida completa: [`evidencias/63-caso-2026-11-12.txt`](evidencias/63-caso-2026-11-12.txt).

| # | Módulo | Prueba | Resultado | Captura |
|---|---|---|---|---|
| 0 | Permisos | `gerente` con Empleados (Administrador) y Marketing por correo (Usuario) | ✅ Lo hace `admin` al principio del script; todo lo demás, `gerente` | — |
| 1 | CRM | Oportunidad de Nuevo a Ganada | ✅ «Comida de empresa 20 personas», Talleres Ejemplo S.L., 600 €. Pasa por Nuevo → Cualificado → Propuesta → Ganado y cada cambio queda en el historial | [`63-01`](evidencias/63-01-crm-pipeline.png), [`63-03`](evidencias/63-03-oportunidad-ganada.png) |
| 2 | Ventas | Presupuesto desde la oportunidad, enviado y confirmado | ✅ `S00001`: 20 menús del día, 20 txakolis y 20 tartas de queso; 445,45 € + 10 % de IVA = **490,00 €**. Presupuesto → Presupuesto enviado → Pedido de venta, enlazado a la oportunidad | [`63-02`](evidencias/63-02-pedido-venta.png) |
| 3 | Empleados | 4 empleados en 2 departamentos, gerente enlazada a su usuario | ✅ Ane Gerente, Jon Camarero e Iñigo Barra (Sala) y Miren Cocina (Cocina). Ane está enlazada al usuario `gerente`, es responsable de Jon e Iñigo y jefa de Sala | [`63-04`](evidencias/63-04-empleados.png) |
| 4 | Marketing | Lista y campaña de prueba | ✅ Lista «Clientes que aceptan publicidad» con 3 contactos `@example.com` y campaña «Menú de temporada de otoño» en borrador. La prueba a `prueba@example.com` queda registrada como «Connection refused», porque el servidor no tiene correo saliente (lo esperado) | [`63-05`](evidencias/63-05-lista-correo.png), [`63-06`](evidencias/63-06-campana.png) |
| 5 | Inventario | 48 → venta de 2 → 46 → ajuste a 45 | ✅ Agua 50 cl pasa a rastrear inventario. Recuento de 48; pedido `S00002` de 2 aguas con el albarán `WH/OUT/00002` validado → 46; ajuste físico a 45 (una rota) | [`63-07`](evidencias/63-07-producto-agua.png), [`63-08`](evidencias/63-08-albaran-venta.png), [`63-09`](evidencias/63-09-historial-movimientos.png) |

La venta de las 2 aguas se hizo con un pedido de venta, que la sección 6 da como alternativa al TPV. En el historial de movimientos (`63-09`) también se ven las ventas del TPV de octubre (`WH/POS/…`), que descuentan stock de la misma forma.

## 8. Primera prueba de Eneko.P (12/11, en su Odoo local)

Eneko.P probó los módulos en su propio Odoo (`localhost:8069`, compañía «My Company», usuario `admin`). Usó el caso de Almi-Chain como empresa de informática, no el del restaurante. Sus capturas están en [`evidencias/eneko-p-local/`](evidencias/eneko-p-local/). Las subió primero en un Word (`docs/evidencias/CRM,INVENTARIO.ETC.docx`, commit `ab8d5bb`) y aquí se han pasado a PNG.

| Captura | Qué enseña |
|---|---|
| `01`, `02`, `06` | Importar empleados, clientes y productos desde CSV con la pantalla de importación de Odoo, asociando columnas a campos (sirve también para la [tarea 36](../36-importar-exportar/DOCUMENTACION.md)). En la `06` todavía no están asociadas las columnas |
| `03`, `04` | 7 empleados en 5 departamentos y 39 contactos con etiquetas (VIP, habitual, empresa…) |
| `05` | Embudo del CRM con 7 oportunidades en Cualificado, Propuesta y Ganado |
| `07` | Recuentos de inventario de 10 productos, todavía sin aplicar |
| `08` | Campaña de correo «Digitaliza tu restaurante…» |
| `09`, `10`, `11` | Factura `INV/2026/00001`, ticket del TPV y factura proforma en PDF |

Lo que faltaba para el nivel 4 se hizo en el servidor (sección 7): el presupuesto que sale de la oportunidad, el stock aplicado y descontado por una venta, la plantilla del restaurante enlazada a `gerente` y la lista de correo. Todo con el caso del restaurante y con `gerente`.

## 9. Cómo repetirlo

[`caso-63.py`](caso-63.py) hace los cinco casos por la API de Odoo (XML-RPC). Busca cada registro por nombre antes de crearlo, así que se puede lanzar otra vez sin duplicar nada. Las contraseñas las lee en el servidor y no las muestra:

```bash
sudo bash -c 'set -a; . /opt/odoo/.env; python3 caso-63.py' | tee 63-caso-$(date +%F).txt
```

Antes de lanzarlo se hizo la instantánea `antes-tarea-63-2026-11-12` de la VM. Al escribirlo salieron dos cosas de Odoo 19:
- los botones que no devuelven nada (`action_quotation_sent`, `action_set_won`) dan un error de XML-RPC aunque Odoo ya los ha ejecutado. El script lo ignora;
- una campaña de correo necesita remitente (`email_from`) y, con «responder a» en modo `new`, también `reply_to`. Si no, la pestaña Ajustes sale en rojo.

Para la defensa basta con abrir Odoo como `gerente` y recorrer las capturas en este orden: CRM → presupuesto → empleados → marketing → inventario.
