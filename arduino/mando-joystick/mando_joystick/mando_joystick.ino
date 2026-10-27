// Arcade stick para Keyestudio Leonardo (KS0248, ATmega32U4).
// Se conecta por USB como joystick HID estandar y el mapeo se cambia por el puerto serie.
//
// Conexiones (esquema en ../esquema-conexiones.svg):
//   Botones 1-4: cable rojo -> pines 2..5, cable negro -> GND comun (fila - de la protoboard)
//   Palanca de arcade (Sanwa, Zippy...: 4 microinterruptores):
//     izquierda -> A2, derecha -> A3, abajo -> A4, arriba -> A5, comun (cable blanco) -> GND
//
// Necesita la libreria Joystick de MHeironimus:
// https://github.com/MHeironimus/ArduinoJoystickLibrary

#include <Arduino.h>
#include <EEPROM.h>
#include <Joystick.h>

// Con INPUT_PULLUP, si no hay palanca los pines leen HIGH (sin pulsar) y los ejes se quedan en el centro
// Pines según el cableado real de la palanca (prueba del 27/10/2026 con probar-stick.py): en este conector
// los colores no siguen el orden arriba/abajo/izquierda/derecha, así que se ajusta aquí en vez de recablear.
const int PIN_ARRIBA = A5;
const int PIN_ABAJO = A4;
const int PIN_IZQUIERDA = A2;
const int PIN_DERECHA = A3;

// Botones 1-4 en el orden del esquema: rojo, azul, rojo, azul.
// No usar los pines 0 y 1 (RX/TX).
const int PINES_BOTON[] = {2, 3, 4, 5};
const uint8_t NUM_BOTONES = sizeof(PINES_BOTON) / sizeof(PINES_BOTON[0]);

const uint16_t MAGIA = 0xA5C1;
const uint8_t VERSION_CONFIG = 4;  // 3: 8 botones y tipo de palanca; 4: 4 botones y solo palanca digital
const int DIR_EEPROM = 0;

// Lo que se guarda en EEPROM. Si cambia la estructura, subir VERSION_CONFIG.
struct Config {
  uint16_t magia;
  uint8_t version;
  uint8_t mapa[NUM_BOTONES];  // boton fisico -> boton HID (0..NUM_BOTONES-1)
  uint8_t invertirX;
  uint8_t invertirY;
  uint8_t checksum;
};

Config cfg;

// 4 botones, sin crucetas, solo ejes X e Y
Joystick_ Joystick(JOYSTICK_DEFAULT_REPORT_ID, JOYSTICK_TYPE_JOYSTICK, NUM_BOTONES, 0,
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
  for (uint8_t i = 0; i < NUM_BOTONES; i++) cfg.mapa[i] = i;
  cfg.invertirX = 0;
  cfg.invertirY = 0;
}

bool cargarConfig() {
  Config leida;
  EEPROM.get(DIR_EEPROM, leida);
  if (leida.magia != MAGIA || leida.version != VERSION_CONFIG ||
      leida.checksum != calcularChecksum(leida)) {
    return false;
  }
  for (uint8_t i = 0; i < NUM_BOTONES; i++) {
    if (leida.mapa[i] >= NUM_BOTONES) return false;
  }
  cfg = leida;
  return true;
}

void guardarConfig() {
  cfg.checksum = calcularChecksum(cfg);
  EEPROM.put(DIR_EEPROM, cfg);  // put solo escribe los bytes que cambian
}

void mostrarConfig() {
  Serial.println(F("--- Configuracion (numeracion desde 1) ---"));
  for (uint8_t i = 0; i < NUM_BOTONES; i++) {
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
}

void mostrarAyuda() {
  Serial.println(F("Comandos:"));
  Serial.println(F("  VER                 muestra la configuracion"));
  Serial.println(F("  MAP <fisico> <hid>  asigna boton fisico a boton HID (1-4)"));
  Serial.println(F("  INV X|Y             invierte un eje"));
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
    if (fisico < 1 || fisico > NUM_BOTONES || hid < 1 || hid > NUM_BOTONES) {
      Serial.println(F("ERROR: fuera de rango"));
      return;
    }
    cfg.mapa[fisico - 1] = hid - 1;
    Serial.println(F("OK"));
  } else if (!strcmp(orden, "INV") && arg1 && (!strcmp(arg1, "X") || !strcmp(arg1, "Y"))) {
    uint8_t &eje = (arg1[0] == 'X') ? cfg.invertirX : cfg.invertirY;
    eje = !eje;
    Serial.println(eje ? F("OK: invertido") : F("OK: normal"));
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

// Microinterruptores: pulsado = LOW. Si se pulsan los dos a la vez (no deberia pasar), centro.
// En HID, X = 0 es izquierda e Y = 0 es arriba.
int leerEje(int pinMenos, int pinMas, bool invertir) {
  bool menos = digitalRead(pinMenos) == LOW;
  bool mas = digitalRead(pinMas) == LOW;
  if (invertir) {
    bool t = menos;
    menos = mas;
    mas = t;
  }
  if (menos && !mas) return 0;
  if (mas && !menos) return 1023;
  return 512;
}

void setup() {
  for (uint8_t i = 0; i < NUM_BOTONES; i++) pinMode(PINES_BOTON[i], INPUT_PULLUP);
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

  Joystick.setXAxis(leerEje(PIN_IZQUIERDA, PIN_DERECHA, cfg.invertirX));
  Joystick.setYAxis(leerEje(PIN_ARRIBA, PIN_ABAJO, cfg.invertirY));

  // Se recalculan todos los botones HID para que ninguno se quede pulsado al remapear
  bool pulsado[NUM_BOTONES] = {false};
  for (uint8_t i = 0; i < NUM_BOTONES; i++) {
    if (digitalRead(PINES_BOTON[i]) == LOW) pulsado[cfg.mapa[i]] = true;
  }
  for (uint8_t b = 0; b < NUM_BOTONES; b++) Joystick.setButton(b, pulsado[b]);

  Joystick.sendState();
  delay(10);
}
