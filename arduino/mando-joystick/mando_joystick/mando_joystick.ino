// Arcade stick para Keyestudio Leonardo (KS0248, ATmega32U4).
// Se conecta por USB como joystick HID estandar y el mapeo se cambia por el puerto serie.
//
// Conexiones (esquema en ../esquema-conexiones.svg):
//   Botones 1-6: cable rojo -> pines 2..7, cable negro -> GND comun (fila - de la protoboard)
//   Botones 7-8 (opcionales): pines 8 y 9, igual que los demas
//   Palanca digital de arcade (Sanwa, Zippy...: 4 microinterruptores, modo por defecto):
//     arriba -> A2, abajo -> A3, izquierda -> A4, derecha -> A5, comun -> GND
//   Palanca analogica (potenciometros): VRx -> A0, VRy -> A1, +5V -> 5V, GND -> GND
//
// Necesita la libreria Joystick de MHeironimus:
// https://github.com/MHeironimus/ArduinoJoystickLibrary

#include <Arduino.h>
#include <EEPROM.h>
#include <Joystick.h>

// Tipo de palanca (se cambia con el comando PALANCA y se guarda en EEPROM):
//   NINGUNA:   ejes fijos en el centro
//   DIGITAL:   palanca de arcade de 4 microinterruptores. Con INPUT_PULLUP, si no hay palanca
//              los pines leen HIGH (sin pulsar) y los ejes se quedan en el centro: es el modo seguro
//   ANALOGICA: palanca de potenciometros. Sin ella, A0 y A1 quedan al aire y los ejes se moverian solos
enum ModoPalanca : uint8_t { PALANCA_NINGUNA = 0, PALANCA_DIGITAL = 1, PALANCA_ANALOGICA = 2 };

const int PIN_X = A0;
const int PIN_Y = A1;
const int PIN_ARRIBA = A2;
const int PIN_ABAJO = A3;
const int PIN_IZQUIERDA = A4;
const int PIN_DERECHA = A5;

// Botones 1-6 en el orden del esquema: rojo, azul, rojo, azul, azul, azul. 7 y 8, opcionales.
// No usar los pines 0 y 1 (RX/TX).
const int PINES_BOTON[] = {2, 3, 4, 5, 6, 7, 8, 9};
const uint8_t NUM_FISICOS = sizeof(PINES_BOTON) / sizeof(PINES_BOTON[0]);
const uint8_t NUM_HID = 8;

const uint16_t MAGIA = 0xA5C1;
const uint8_t VERSION_CONFIG = 3;  // 2: pasa de 2 a 6 botones; 3: 8 botones y tipo de palanca
const int DIR_EEPROM = 0;

// Lo que se guarda en EEPROM. Si cambia la estructura, subir VERSION_CONFIG.
struct Config {
  uint16_t magia;
  uint8_t version;
  uint8_t mapa[NUM_FISICOS];  // boton fisico -> boton HID (0..NUM_HID-1)
  uint8_t invertirX;
  uint8_t invertirY;
  uint8_t zonaMuerta;         // unidades ADC alrededor del centro (512), solo palanca analogica
  uint8_t modoPalanca;        // ModoPalanca
  uint8_t checksum;
};

Config cfg;

// 8 botones, sin crucetas, solo ejes X e Y
Joystick_ Joystick(JOYSTICK_DEFAULT_REPORT_ID, JOYSTICK_TYPE_JOYSTICK, NUM_HID, 0,
                   true, true, false, false, false, false, false, false, false, false, false);

char linea[32];
uint8_t largo = 0;

uint8_t calcularChecksum(const Config &c) {
  const uint8_t *p = (const uint8_t *)&c;
  uint8_t suma = 0;
  for (size_t i = 0; i < sizeof(Config) - 1; i++) suma += p[i];
  return suma;
}

void configPorDefecto() {
  cfg.magia = MAGIA;
  cfg.version = VERSION_CONFIG;
  for (uint8_t i = 0; i < NUM_FISICOS; i++) cfg.mapa[i] = i;
  cfg.invertirX = 0;
  cfg.invertirY = 0;
  cfg.zonaMuerta = 20;
  cfg.modoPalanca = PALANCA_DIGITAL;
}

bool cargarConfig() {
  Config leida;
  EEPROM.get(DIR_EEPROM, leida);
  if (leida.magia != MAGIA || leida.version != VERSION_CONFIG ||
      leida.checksum != calcularChecksum(leida)) {
    return false;
  }
  for (uint8_t i = 0; i < NUM_FISICOS; i++) {
    if (leida.mapa[i] >= NUM_HID) return false;
  }
  if (leida.modoPalanca > PALANCA_ANALOGICA) return false;
  cfg = leida;
  return true;
}

void guardarConfig() {
  cfg.checksum = calcularChecksum(cfg);
  EEPROM.put(DIR_EEPROM, cfg);  // put solo escribe los bytes que cambian
}

void mostrarConfig() {
  Serial.println(F("--- Configuracion (numeracion desde 1) ---"));
  for (uint8_t i = 0; i < NUM_FISICOS; i++) {
    Serial.print(F("Boton fisico "));
    Serial.print(i + 1);
    Serial.print(F(" (pin "));
    Serial.print(PINES_BOTON[i]);
    Serial.print(F(") -> HID "));
    Serial.println(cfg.mapa[i] + 1);
  }
  Serial.print(F("Invertir X: "));
  Serial.println(cfg.invertirX ? F("si") : F("no"));
  Serial.print(F("Invertir Y: "));
  Serial.println(cfg.invertirY ? F("si") : F("no"));
  Serial.print(F("Zona muerta: "));
  Serial.println(cfg.zonaMuerta);
  Serial.print(F("Palanca: "));
  if (cfg.modoPalanca == PALANCA_DIGITAL) Serial.println(F("digital (A2-A5)"));
  else if (cfg.modoPalanca == PALANCA_ANALOGICA) Serial.println(F("analogica (A0, A1)"));
  else Serial.println(F("ninguna"));
}

void mostrarAyuda() {
  Serial.println(F("Comandos:"));
  Serial.println(F("  VER                 muestra la configuracion"));
  Serial.println(F("  MAP <fisico> <hid>  asigna boton fisico a boton HID (1-8)"));
  Serial.println(F("  INV X|Y             invierte un eje"));
  Serial.println(F("  ZM <0-200>          zona muerta de la palanca analogica"));
  Serial.println(F("  PALANCA DIGITAL|ANALOGICA|NINGUNA"));
  Serial.println(F("  GUARDAR             guarda en EEPROM"));
  Serial.println(F("  CARGAR              descarta cambios y recarga de EEPROM"));
  Serial.println(F("  RESET               valores por defecto (sin guardar)"));
}

void procesarComando(char *cmd) {
  for (char *c = cmd; *c; c++) *c = toupper(*c);
  char *orden = strtok(cmd, " ");
  char *arg1 = strtok(NULL, " ");
  char *arg2 = strtok(NULL, " ");
  if (!orden) return;

  if (!strcmp(orden, "VER")) {
    mostrarConfig();
  } else if (!strcmp(orden, "MAP") && arg1 && arg2) {
    int fisico = atoi(arg1);
    int hid = atoi(arg2);
    if (fisico < 1 || fisico > NUM_FISICOS || hid < 1 || hid > NUM_HID) {
      Serial.println(F("ERROR: fuera de rango"));
      return;
    }
    cfg.mapa[fisico - 1] = hid - 1;
    Serial.println(F("OK"));
  } else if (!strcmp(orden, "INV") && arg1 && (!strcmp(arg1, "X") || !strcmp(arg1, "Y"))) {
    uint8_t &eje = (arg1[0] == 'X') ? cfg.invertirX : cfg.invertirY;
    eje = !eje;
    Serial.println(eje ? F("OK: invertido") : F("OK: normal"));
  } else if (!strcmp(orden, "ZM") && arg1) {
    int zm = atoi(arg1);
    if (zm < 0 || zm > 200) {
      Serial.println(F("ERROR: fuera de rango"));
      return;
    }
    cfg.zonaMuerta = zm;
    Serial.println(F("OK"));
  } else if (!strcmp(orden, "PALANCA") && arg1) {
    if (!strcmp(arg1, "DIGITAL")) cfg.modoPalanca = PALANCA_DIGITAL;
    else if (!strcmp(arg1, "ANALOGICA")) cfg.modoPalanca = PALANCA_ANALOGICA;
    else if (!strcmp(arg1, "NINGUNA")) cfg.modoPalanca = PALANCA_NINGUNA;
    else {
      Serial.println(F("ERROR: DIGITAL, ANALOGICA o NINGUNA"));
      return;
    }
    Serial.println(F("OK"));
  } else if (!strcmp(orden, "GUARDAR")) {
    guardarConfig();
    Serial.println(F("OK: guardado"));
  } else if (!strcmp(orden, "CARGAR")) {
    if (!cargarConfig()) configPorDefecto();
    Serial.println(F("OK: recargado"));
  } else if (!strcmp(orden, "RESET")) {
    configPorDefecto();
    Serial.println(F("OK: por defecto (usa GUARDAR para mantenerlo)"));
  } else {
    mostrarAyuda();
  }
}

void leerSerie() {
  while (Serial.available()) {
    char c = Serial.read();
    if (c == '\n' || c == '\r') {
      if (largo > 0) {
        linea[largo] = '\0';
        procesarComando(linea);
        largo = 0;
      }
    } else if (largo < sizeof(linea) - 1) {
      linea[largo++] = c;
    }
  }
}

int invertirEje(int v, bool invertir) {
  if (!invertir || v == 512) return v;
  return 1023 - v;
}

int leerEjeAnalogico(int pin, bool invertir) {
  int v = analogRead(pin);
  if (abs(v - 512) < cfg.zonaMuerta) v = 512;
  return invertirEje(v, invertir);
}

// Microinterruptores: pulsado = LOW. Si se pulsan los dos a la vez (no deberia pasar), centro.
int leerEjeDigital(int pinMenos, int pinMas, bool invertir) {
  bool menos = digitalRead(pinMenos) == LOW;
  bool mas = digitalRead(pinMas) == LOW;
  int v = 512;
  if (menos && !mas) v = 0;
  else if (mas && !menos) v = 1023;
  return invertirEje(v, invertir);
}

void leerPalanca(int &x, int &y) {
  x = 512;
  y = 512;
  if (cfg.modoPalanca == PALANCA_ANALOGICA) {
    x = leerEjeAnalogico(PIN_X, cfg.invertirX);
    y = leerEjeAnalogico(PIN_Y, cfg.invertirY);
  } else if (cfg.modoPalanca == PALANCA_DIGITAL) {
    // En HID, Y = 0 es arriba y X = 0 es izquierda
    x = leerEjeDigital(PIN_IZQUIERDA, PIN_DERECHA, cfg.invertirX);
    y = leerEjeDigital(PIN_ARRIBA, PIN_ABAJO, cfg.invertirY);
  }
}

void setup() {
  for (uint8_t i = 0; i < NUM_FISICOS; i++) pinMode(PINES_BOTON[i], INPUT_PULLUP);
  const int pinesPalanca[] = {PIN_ARRIBA, PIN_ABAJO, PIN_IZQUIERDA, PIN_DERECHA};
  for (int pin : pinesPalanca) pinMode(pin, INPUT_PULLUP);
  if (!cargarConfig()) configPorDefecto();

  Serial.begin(9600);
  Joystick.setXAxisRange(0, 1023);
  Joystick.setYAxisRange(0, 1023);
  Joystick.begin(false);  // el estado se envia a mano una vez por vuelta
}

void loop() {
  leerSerie();

  int x, y;
  leerPalanca(x, y);
  Joystick.setXAxis(x);
  Joystick.setYAxis(y);

  // Se recalculan todos los botones HID para que ninguno se quede pulsado al remapear
  bool pulsado[NUM_HID] = {false};
  for (uint8_t i = 0; i < NUM_FISICOS; i++) {
    if (digitalRead(PINES_BOTON[i]) == LOW) pulsado[cfg.mapa[i]] = true;
  }
  for (uint8_t b = 0; b < NUM_HID; b++) Joystick.setButton(b, pulsado[b]);

  Joystick.sendState();
  delay(10);
}
