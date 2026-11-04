// Sustitutos minimos del nucleo de Arduino para compilar el firmware en el PC.
#pragma once
#include <cstdint>
#include <cstring>
#include <cstdlib>
#include <cctype>
#include <cstdio>
typedef bool boolean;
#define LOW 0
#define HIGH 1
#define INPUT_PULLUP 2
#define F(s) (s)
enum { A2 = 20, A3 = 21, A4 = 22, A5 = 23 };
extern unsigned long sim_millis;
extern int sim_pin[32];
inline unsigned long millis() { return sim_millis; }
inline int digitalRead(int p) { return sim_pin[p]; }
inline void pinMode(int, int) {}
struct SerialSim {
  void begin(long) {}
  int available() { return 0; }
  int read() { return -1; }
  template <class T> void print(T) {}
  template <class T> void println(T) {}
};
extern SerialSim Serial;
