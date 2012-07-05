/*
 * AntiLED - Arduino interface for HL1606-based LED strips
 * Copyright (c) 2009, Steve Conklin
 * This code is public domain
*/

#ifndef AntiLED_h
#define AntiLED_h

#include <LEDStrip.h>

#define MAXLEDS 160

class AntiLED
{
  private:
    LEDStrip _strip;
    uint8_t _nLEDs;
    uint8_t Ld[MAXLEDS];
  public:
    AntiLED(uint8_t, uint8_t, uint8_t, uint8_t, uint8_t);
    lightOne(uint8_t, uint8_t, uint8_t, uint8_t);
    setEveryNth(uint8_t, uint8_t, uint8_t, uint8_t, uint8_t)
};

#endif
