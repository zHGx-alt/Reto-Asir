#include <Arduino.h>
#include <EEPROM.h>
#include <Joystick.h>

const int PIN_X = A0;
const int PIN_Y = A1;
const int PINES_BOTON[] = {2, 3};
const uint8_t NUM_FISICOS = sizeof(PINES_BOTON) / sizeof(PINES_BOTON[0]);
const uint8_t NUM_HID = 8;

const uint16_t MAGIA = 0xA5C1;
const uint8_t VERSION_CONFIG = 1;
const int DIR_EEPROM = 0;

// Lo que se guarda en EEPROM. Si cambia la estructura, subir VERSION_CONFIG.
struct Config {
  uint16_t magia;
  uint8_t version;
  uint8_t mapa[NUM_FISICOS];  // boton fisico -> boton HID (0..NUM_HID-1)
  uint8_t invertirX;
  uint8_t invertirY;
  uint8_t zonaMuerta;         // unidades ADC alrededor del centro (512)
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
}

void mostrarAyuda() {
  Serial.println(F("Comandos:"));
  Serial.println(F("  VER                 muestra la configuracion"));
  Serial.println(F("  MAP <fisico> <hid>  asigna boton fisico a boton HID (1-8)"));
  Serial.println(F("  INV X|Y             invierte un eje"));
  Serial.println(F("  ZM <0-200>          zona muerta del stick"));
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

int leerEje(int pin, bool invertir) {
  int v = analogRead(pin);
  if (abs(v - 512) < cfg.zonaMuerta) v = 512;
  return invertir ? 1023 - v : v;
}

void setup() {
  for (uint8_t i = 0; i < NUM_FISICOS; i++) pinMode(PINES_BOTON[i], INPUT_PULLUP);
  if (!cargarConfig()) configPorDefecto();

  Serial.begin(9600);
  Joystick.setXAxisRange(0, 1023);
  Joystick.setYAxisRange(0, 1023);
  Joystick.begin(false);  // el estado se envia a mano una vez por vuelta
}

void loop() {
  leerSerie();

  Joystick.setXAxis(leerEje(PIN_X, cfg.invertirX));
  Joystick.setYAxis(leerEje(PIN_Y, cfg.invertirY));

  // Se recalculan todos los botones HID para que ninguno se quede pulsado al remapear
  bool pulsado[NUM_HID] = {false};
  for (uint8_t i = 0; i < NUM_FISICOS; i++) {
    if (digitalRead(PINES_BOTON[i]) == LOW) pulsado[cfg.mapa[i]] = true;
  }
  for (uint8_t b = 0; b < NUM_HID; b++) Joystick.setButton(b, pulsado[b]);

  Joystick.sendState();
  delay(10);
}
