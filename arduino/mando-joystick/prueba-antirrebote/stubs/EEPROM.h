#pragma once
struct EEPROMSim {
  template <class T> void get(int, T &t) { memset(&t, 0, sizeof t); }
  template <class T> void put(int, const T &) {}
};
extern EEPROMSim EEPROM;
