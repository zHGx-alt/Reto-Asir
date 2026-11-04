// Sustituto del Joystick de MHeironimus: guarda el ultimo estado y cuenta los informes enviados.
#pragma once
#define JOYSTICK_DEFAULT_REPORT_ID 3
#define JOYSTICK_TYPE_JOYSTICK 4
struct Joystick_ {
  int x = 512, y = 512;
  bool boton[32] = {};
  int informes = 0;
  Joystick_(int, int, int, int, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool, bool) {}
  void setXAxisRange(int, int) {}
  void setYAxisRange(int, int) {}
  void begin(bool) {}
  void setXAxis(int v) { x = v; }
  void setYAxis(int v) { y = v; }
  void setButton(int b, bool v) { boton[b] = v; }
  void sendState() { informes++; }
};
