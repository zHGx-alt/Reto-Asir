// Prueba del antirrebote del firmware en el PC (sin la placa): compila el .ino real
// con sustitutos de Arduino, simula rebotes en los pines y comprueba lo que llega por HID.
#include "../mando_joystick/mando_joystick.ino"

unsigned long sim_millis = 0;
int sim_pin[32];
SerialSim Serial;
EEPROMSim EEPROM;

static int fallos = 0;
static void comprobar(bool ok, const char *que) {
  printf("%s  %s\n", ok ? "OK   " : "FALLO", que);
  if (!ok) fallos++;
}

// Avanza el tiempo de 1 en 1 ms ejecutando loop() (el bucle real va mucho mas rapido).
static void esperar(unsigned long ms) {
  for (unsigned long i = 0; i < ms; i++) { loop(); sim_millis++; }
}

// Cuenta cuantas veces pasa el boton HID b de suelto a pulsado mientras pasa el tiempo.
static int pulsacionesHID(int b, const char *patron) {
  int n = 0; bool antes = Joystick.boton[b];
  for (const char *c = patron; *c; c++) {
    sim_pin[2] = (*c == '1') ? LOW : HIGH;  // '1' = contacto cerrado en ese ms
    loop(); sim_millis++;
    if (Joystick.boton[b] && !antes) n++;
    antes = Joystick.boton[b];
  }
  return n;
}

int main() {
  for (int &p : sim_pin) p = HIGH;  // INPUT_PULLUP: sin pulsar
  setup();
  esperar(20);
  comprobar(Joystick.x == 512 && Joystick.y == 512 && !Joystick.boton[0], "en reposo: palanca al centro y botones sueltos");

  // Pulsacion con rebote tipico de un microinterruptor: 3 ms vibrando al cerrar y al abrir
  const char *conRebote = "1010110111111111111111111111110101001000000000000000";
  comprobar(pulsacionesHID(0, conRebote) == 1, "pulsacion con rebotes de 3 ms al cerrar y al abrir: cuenta 1, no 5");
  comprobar(!Joystick.boton[0], "al soltar con rebote, el boton queda suelto");

  // Ruido aislado de 1-2 ms (interferencia): no debe llegar al PC
  comprobar(pulsacionesHID(0, "0001000000110000000000") == 0, "picos de ruido de 1 y 2 ms: no generan pulsacion");

  // Retardo: el cambio llega a los ANTIRREBOTE_MS de quedar estable
  sim_pin[2] = LOW;
  int ms = 0;
  while (!Joystick.boton[0] && ms < 50) { loop(); sim_millis++; ms++; }
  printf("       retardo medido de una pulsacion limpia: %d ms (antes, con delay(10): hasta 10 ms)\n", ms);
  comprobar(ms >= ANTIRREBOTE_MS && ms <= ANTIRREBOTE_MS + 1, "la pulsacion limpia llega en 5-6 ms");
  sim_pin[2] = HIGH; esperar(20);

  // Palanca: rebote en arriba
  const char *palanca = "10110111111111";
  int vecesArriba = 0; int yAntes = Joystick.y;
  for (const char *c = palanca; *c; c++) {
    sim_pin[A5] = (*c == '1') ? LOW : HIGH; loop(); sim_millis++;
    if (Joystick.y == 0 && yAntes != 0) vecesArriba++;
    yAntes = Joystick.y;
  }
  comprobar(vecesArriba == 1 && Joystick.y == 0, "palanca arriba con rebote: Y = 0 una sola vez");
  sim_pin[A5] = HIGH; esperar(20);
  comprobar(Joystick.y == 512, "al soltar la palanca vuelve al centro");

  // Remapeo: MAP 1 2 con el boton 1 pulsado mueve la pulsacion al HID 2 sin dejar el 1 colgado
  sim_pin[2] = LOW; esperar(20);
  cfg.mapa[0] = 1; esperar(2);
  comprobar(!Joystick.boton[0] && Joystick.boton[1], "remapeo con el boton pulsado: HID 1 suelto y HID 2 pulsado");
  cfg.mapa[0] = 0; sim_pin[2] = HIGH; esperar(20);

  // Sin cambios solo se envia un informe cada 100 ms
  int antes = Joystick.informes; esperar(1000);
  int informes = Joystick.informes - antes;
  printf("       informes USB en 1 s sin tocar nada: %d (antes, con delay(10): unos 100)\n", informes);
  comprobar(informes >= 9 && informes <= 11, "en reposo, un informe cada 100 ms");

  printf("\n%s: %d fallos\n", fallos ? "HAY FALLOS" : "Todo correcto", fallos);
  return fallos ? 1 : 0;
}
