/*
 * AntiLED - Arduino interface for HL1606-based LED strips
 * Copyright (c) 2009, Steve Conklin
 * This code is public domain
*/

//?#include "WConstants.h"
#include "AntiLED.h"

AntiLED::AntiLED(uint8_t nLEDs, uint8_t dPin, uint8_t sPin, uint8_t latchPin, uint8_t clkPin) 
{
  if (nLEDs > MAXLEDS)
    nLEDs = MAXLEDS;
  _nLEDs = nLEDs;
  _strip = LEDStrip(dPin, sPin, latchPin, clkPin);
  for (i=0;i<MAXLEDS;i++)
    Ld[i] = 0;
  // other init here
}

void LEDStrip::lightOne(uint8_t ledNum, uint8_t RedVal, uint8_t GrnVal, uint8_t BluVal)
{
  // light the nth LED in the specified color
  
  // todo
}

unsigned uint8_t LEDStrip::setEveryNth(uint8_t offset, uint8_t RedVal,
				       uint8_t GrnVal, uint8_t BluVal, uint8_t skip)
{
  // - set every nth LED starting at offset, until end
  // - if skip is set, leave other LEDs as is (no latch bit)

}

