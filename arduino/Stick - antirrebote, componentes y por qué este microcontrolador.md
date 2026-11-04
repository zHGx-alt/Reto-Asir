# Mando joystick con Arduino

**Autor:** Markel · **Tarea #59:** 04/11/2026–06/11/2026 · **Tarea #48 (documentación final):** 09/11/2026–11/11/2026 · **Archivo destino:** `arduino/mando-joystick/README.md`

> **Hipótesis de partida.** Se supone un **Arduino Uno R3 (ATmega328P)** y un **módulo joystick analógico tipo KY-023** (2 ejes + pulsador). Todo lo marcado con **[ ]** es un dato que debes confirmar o cambiar; el resto funciona tal cual.

## 1. Introducción y objetivo

Este proyecto construye un mando de control basado en un joystick analógico. El Arduino lee la posición de los dos ejes (X, Y) y el estado del pulsador integrado, filtra el ruido y los rebotes, y envía los datos por el puerto serie para que los use un PC, un robot, un juego u otro dispositivo.

**Qué hace:**
- Lee los ejes X e Y con el ADC de 10 bits (valores 0–1023).
- Aplica una zona muerta alrededor del centro para evitar lecturas fantasma.
- Lee el pulsador con **antirrebote por software** y detecta pulsaciones válidas.
- Envía los datos por serie a 115200 baudios.

**Qué no hace:**
- No se presenta como un gamepad USB nativo (para eso haría falta un Arduino Leonardo o Pro Micro, ver sección 5).

## 2. Lista de componentes

| Cantidad | Componente | Valor / modelo | Función |
|---|---|---|---|
| 1 | Microcontrolador | Arduino Uno R3 **[confirmar]** | Lectura y procesado |
| 1 | Módulo joystick | KY-023 (2 potenciómetros de 10 kΩ + pulsador) **[confirmar]** | Entrada del usuario |
| 1 | Cable USB A-B | — | Alimentación, carga del código y comunicación serie |
| 1 | Protoboard | 400 puntos | Montaje sin soldar |
| 5 | Cables dupont | M-M | Conexiones |
| 1 | LED (opcional) | 5 mm, color **[ ]** | Indicador de pulsación |
| 1 | Resistencia (opcional) | 220 Ω | Limita la corriente del LED |
| 1 | Condensador (opcional) | 100 nF | Antirrebote por hardware (ver sección 4) |

El módulo ya trae sus potenciómetros, así que no necesita resistencias externas para los ejes. El pulsador se conecta con la **resistencia pull-up interna** del Arduino, por lo que tampoco hace falta una externa.

## 3. Montaje paso a paso

**Conexiones:**

| Pin del joystick | Pin del Arduino | Descripción |
|---|---|---|
| GND | GND | Masa |
| +5V | 5V | Alimentación |
| VRx | A0 | Eje X (analógico) |
| VRy | A1 | Eje Y (analógico) |
| SW | D2 | Pulsador (entrada digital con pull-up) |
| (LED, opcional) | D13 vía 220 Ω a GND | Indicador |

**Pasos:**
1. Con el Arduino **desconectado** del USB, coloca el módulo joystick en un extremo de la protoboard.
2. Conecta GND del joystick al carril de masa y 5V al carril positivo; lleva ambos al Arduino.
3. Conecta VRx a A0 y VRy a A1.
4. Conecta SW a D2.
5. (Opcional) Monta el LED con su resistencia de 220 Ω entre D13 y GND (pata larga hacia D13).
6. Revisa todas las conexiones antes de enchufar el USB.
7. Conecta el USB y carga el firmware (sección 6).
8. Abre el Monitor Serie a 115200 baudios y comprueba que los valores cambian al mover la palanca.

**[ ] Añade aquí una foto del montaje y un esquema (puedes hacerlo con Fritzing o a mano).**

## 4. Antirrebote

### El problema
Un pulsador mecánico no pasa limpiamente de abierto a cerrado: los contactos rebotan durante **1 a 20 ms** y generan varios flancos. Si el Arduino lee cada flanco, una sola pulsación se cuenta varias veces.

### Solución elegida: software (sin componentes extra)
Se exige que la lectura permanezca **estable durante 20 ms** antes de aceptar el cambio de estado. Se usa `millis()` en lugar de `delay()`, de modo que el programa sigue leyendo los ejes mientras vigila el botón.

### Alternativa por hardware (para la documentación)
Filtro RC: resistencia pull-up de 10 kΩ y condensador de 1 µF entre la entrada y GND. La constante de tiempo es τ = R·C = 10 kΩ · 1 µF = 10 ms, suficiente para absorber el rebote. Opcionalmente se añade un inversor Schmitt (74HC14) para obtener un flanco limpio. Se descarta como solución principal porque el software resuelve el problema sin coste ni espacio adicional.

### Cómo validarlo
1. Carga una versión **sin** antirrebote que cuente cada flanco y pulsa 20 veces: verás más de 20 cuentas.
2. Carga la versión **con** antirrebote y repite: debe contar exactamente 20.
3. Anota ambos resultados en la tabla de pruebas (sección 7). Si tienes osciloscopio o analizador lógico, añade una captura del rebote.

## 5. Por qué este microcontrolador

Se elige el **Arduino Uno R3 (ATmega328P)** **[confirmar si usas otro modelo]** por estas razones:

- **Entradas analógicas suficientes:** tiene 6 canales ADC de 10 bits y el proyecto necesita solo 2 (X e Y).
- **Tensión compatible:** trabaja a 5 V, igual que el módulo joystick, sin adaptadores de nivel.
- **Pines sobrados:** 14 E/S digitales, de los que se usan solo 1 o 2, lo que deja margen para ampliar con más botones.
- **Memoria suficiente:** 32 KB de Flash y 2 KB de RAM, muy por encima de lo que ocupa este firmware (menos de 3 KB de Flash).
- **Facilidad de uso:** se programa con el IDE de Arduino, tiene USB integrado para cargar el código y abundante documentación y librerías.
- **Coste y disponibilidad:** es barato y fácil de conseguir.

**Alternativas descartadas:**
- **Arduino Nano:** mismo chip y mismas prestaciones, más pequeño. Sería la mejor opción para una versión final compacta.
- **Arduino Leonardo / Pro Micro (ATmega32U4):** tienen USB nativo y pueden presentarse como un gamepad real (HID). Es la mejora natural si se quiere que el PC lo reconozca como mando sin software intermedio.
- **ESP32 / Raspberry Pi Pico:** más potentes y con Bluetooth o Wi-Fi (ESP32), pero trabajan a 3,3 V y son excesivos para esta aplicación.

## 6. Firmware

```cpp
// Mando joystick con Arduino: lectura de ejes y pulsador con antirrebote
// Autor: Markel

const int PIN_X   = A0;   // Eje X
const int PIN_Y   = A1;   // Eje Y
const int PIN_SW  = 2;    // Pulsador del joystick
const int PIN_LED = 13;   // LED indicador (opcional)

const int CENTRO      = 512;  // Valor en reposo aproximado
const int ZONA_MUERTA = 30;   // Tolerancia alrededor del centro
const unsigned long T_REBOTE = 20;  // ms de estabilidad exigidos

int estadoEstable = HIGH;         // HIGH = suelto (pull-up)
int ultimaLectura = HIGH;
unsigned long tUltimoCambio = 0;
unsigned long contador = 0;

// Aplica zona muerta: si está cerca del centro devuelve 0, si no, el desvío
int aplicarZonaMuerta(int valor) {
  int desvio = valor - CENTRO;
  if (abs(desvio) < ZONA_MUERTA) return 0;
  return desvio;
}

void setup() {
  pinMode(PIN_SW, INPUT_PULLUP);
  pinMode(PIN_LED, OUTPUT);
  Serial.begin(115200);
}

void loop() {
  // --- Ejes ---
  int x = aplicarZonaMuerta(analogRead(PIN_X));
  int y = aplicarZonaMuerta(analogRead(PIN_Y));

  // --- Pulsador con antirrebote ---
  int lectura = digitalRead(PIN_SW);

  if (lectura != ultimaLectura) {
    tUltimoCambio = millis();          // hubo cambio: reinicia el temporizador
  }

  if ((millis() - tUltimoCambio) > T_REBOTE && lectura != estadoEstable) {
    estadoEstable = lectura;           // lleva 20 ms estable: se acepta
    if (estadoEstable == LOW) {
      contador++;                      // pulsación válida
    }
  }
  ultimaLectura = lectura;

  digitalWrite(PIN_LED, estadoEstable == LOW ? HIGH : LOW);

  // --- Salida por serie cada 20 ms ---
  static unsigned long tEnvio = 0;
  if (millis() - tEnvio >= 20) {
    tEnvio = millis();
    Serial.print("X=");   Serial.print(x);
    Serial.print(" Y=");  Serial.print(y);
    Serial.print(" BTN="); Serial.print(estadoEstable == LOW ? 1 : 0);
    Serial.print(" N=");  Serial.println(contador);
  }
}
```

**Cómo compilarlo y cargarlo:**
1. Instala el IDE de Arduino.
2. Abre un sketch nuevo y pega el código.
3. En *Herramientas → Placa* elige **Arduino Uno** y en *Puerto* el que aparezca.
4. Pulsa *Subir*.
5. Abre *Monitor Serie* a **115200 baudios**.

**Calibración:** con la palanca en reposo, anota los valores de X e Y. Si no rondan 512, ajusta `CENTRO`. Si hay lecturas fantasma, aumenta `ZONA_MUERTA`.

## 7. Pruebas y resultados

| Nº | Acción | Resultado esperado | Resultado obtenido |
|---|---|---|---|
| 1 | Palanca en reposo | X=0, Y=0 | **[ ]** |
| 2 | Palanca a la derecha | X positivo, hasta ~+511 | **[ ]** |
| 3 | Palanca a la izquierda | X negativo, hasta ~−512 | **[ ]** |
| 4 | Palanca arriba / abajo | Y cambia de signo según el sentido | **[ ]** |
| 5 | Pulsar el joystick 20 veces **sin** antirrebote | Más de 20 cuentas | **[ ]** |
| 6 | Pulsar el joystick 20 veces **con** antirrebote | Exactamente 20 cuentas | **[ ]** |
| 7 | Mantener pulsado | BTN=1 constante, sin cuentas extra | **[ ]** |
| 8 | LED al pulsar | Se enciende mientras se pulsa | **[ ]** |

## 8. Problemas frecuentes y soluciones

| Problema | Causa probable | Solución |
|---|---|---|
| Los ejes no marcan 0 en reposo | Centro real distinto de 512 | Ajustar `CENTRO` |
| Valores que oscilan en reposo | Ruido del ADC | Aumentar `ZONA_MUERTA` |
| El botón cuenta varias veces | Rebote no filtrado | Subir `T_REBOTE` a 30–50 ms |
| El botón siempre aparece pulsado | Falta `INPUT_PULLUP` o cable suelto en SW | Revisar `pinMode` y conexión |
| Ejes invertidos | Módulo girado | Intercambiar A0/A1 o invertir el signo en código |
| No aparece el puerto | Driver o cable de solo carga | Probar otro cable USB |

## 9. Conclusiones y mejoras futuras

El proyecto cumple el objetivo: lectura estable de los dos ejes y detección fiable del pulsador gracias al antirrebote por software. **[ ] Añade tus conclusiones personales: qué aprendiste, qué fue lo más difícil.**

Mejoras posibles:
- Cambiar a Arduino Leonardo o Pro Micro para que el PC lo detecte como gamepad HID.
- Añadir más botones y un segundo joystick.
- Comunicación inalámbrica con Bluetooth (HC-05) o un ESP32.
- Caja impresa en 3D.

## 10. Anexos

- Hoja de datos del ATmega328P.
- Esquema de conexión **[ ]**.
- Fotos y capturas de pruebas **[ ]**.
