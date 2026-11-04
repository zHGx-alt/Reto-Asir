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

// Antirrebote. Al pulsar o soltar, el contacto metalico vibra unos milisegundos y el pin
// lee LOW y HIGH alternados; sin filtrar, una pulsacion podria contar como varias.
// Cada entrada (4 botones y 4 direcciones) solo cambia de estado cuando la lectura cruda
// lleva ANTIRREBOTE_MS seguidos sin cambiar. No hay delay(): el bucle lee continuamente.
const uint8_t ANTIRREBOTE_MS = 5;
const uint8_t NUM_ENTRADAS = NUM_BOTONES + 4;
enum { E_ARRIBA = NUM_BOTONES, E_ABAJO, E_IZQUIERDA, E_DERECHA };
int pinesEntrada[NUM_ENTRADAS];
bool estable[NUM_ENTRADAS];         // estado ya filtrado (true = pulsado)
bool crudoAnterior[NUM_ENTRADAS];   // ultima lectura sin filtrar
unsigned long desde[NUM_ENTRADAS];  // millis() del ultimo cambio de la lectura cruda

void iniciarEntradas() {
  for (uint8_t i = 0; i < NUM_BOTONES; i++) pinesEntrada[i] = PINES_BOTON[i];
  pinesEntrada[E_ARRIBA] = PIN_ARRIBA;
  pinesEntrada[E_ABAJO] = PIN_ABAJO;
  pinesEntrada[E_IZQUIERDA] = PIN_IZQUIERDA;
  pinesEntrada[E_DERECHA] = PIN_DERECHA;
  unsigned long ahora = millis();
  for (uint8_t i = 0; i < NUM_ENTRADAS; i++) {
    pinMode(pinesEntrada[i], INPUT_PULLUP);
    crudoAnterior[i] = estable[i] = false;
    desde[i] = ahora;
  }
}

// Devuelve true si alguna entrada filtrada ha cambiado en esta vuelta.
bool actualizarEntradas() {
  bool hayCambio = false;
  unsigned long ahora = millis();
  for (uint8_t i = 0; i < NUM_ENTRADAS; i++) {
    bool crudo = digitalRead(pinesEntrada[i]) == LOW;  // microinterruptor: pulsado = LOW
    if (crudo != crudoAnterior[i]) {
      crudoAnterior[i] = crudo;  // sigue rebotando: se vuelve a contar desde ahora
      desde[i] = ahora;
    } else if (crudo != estable[i] && ahora - desde[i] >= ANTIRREBOTE_MS) {
      estable[i] = crudo;
      hayCambio = true;
    }
  }
  return hayCambio;
}

// Si se pulsan los dos sentidos a la vez (no deberia pasar), centro.
// En HID, X = 0 es izquierda e Y = 0 es arriba.
int leerEje(uint8_t entradaMenos, uint8_t entradaMas, bool invertir) {
  bool menos = estable[entradaMenos];
  bool mas = estable[entradaMas];
  if (invertir) {
    bool t = menos;
    menos = mas;
    mas = t;
  }
  if (menos && !mas) return 0;
  if (mas && !menos) return 1023;
  return 512;
}

// Calcula el estado HID completo y lo envia. Se recalculan todos los botones HID
// para que ninguno se quede pulsado al remapear.
void enviarEstado() {
  Joystick.setXAxis(leerEje(E_IZQUIERDA, E_DERECHA, cfg.invertirX));
  Joystick.setYAxis(leerEje(E_ARRIBA, E_ABAJO, cfg.invertirY));
  bool pulsado[NUM_BOTONES] = {false};
  for (uint8_t i = 0; i < NUM_BOTONES; i++) {
    if (estable[i]) pulsado[cfg.mapa[i]] = true;
  }
  for (uint8_t b = 0; b < NUM_BOTONES; b++) Joystick.setButton(b, pulsado[b]);
  Joystick.sendState();
}

void setup() {
  iniciarEntradas();
  if (!cargarConfig()) configPorDefecto();

  Serial.begin(9600);
  Joystick.setXAxisRange(0, 1023);
  Joystick.setYAxisRange(0, 1023);
  Joystick.begin(false);  // el estado se envia a mano una vez por vuelta
}

void loop() {
  leerSerie();

  // Solo se envia por USB cuando cambia algo (o cada 100 ms, por si el PC se perdio un informe).
  // Asi no hace falta el delay(10) de antes, que retrasaba cada pulsacion hasta 10 ms.
  static unsigned long ultimoEnvio = 0;
  static uint8_t mapaAnterior[NUM_BOTONES];
  static uint8_t invXAnterior = 255, invYAnterior = 255;
  bool cambio = actualizarEntradas();
  if (memcmp(mapaAnterior, cfg.mapa, NUM_BOTONES) != 0 ||
      invXAnterior != cfg.invertirX || invYAnterior != cfg.invertirY) {
    memcpy(mapaAnterior, cfg.mapa, NUM_BOTONES);  // MAP, INV, CARGAR o RESET por el puerto serie
    invXAnterior = cfg.invertirX;
    invYAnterior = cfg.invertirY;
    cambio = true;
  }
  if (cambio || millis() - ultimoEnvio >= 100) {
    enviarEstado();
    ultimoEnvio = millis();
  }
}
