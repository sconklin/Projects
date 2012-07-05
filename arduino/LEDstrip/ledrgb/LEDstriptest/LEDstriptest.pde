// Addressable LED strip test program
// copyright Steve Conklin 2009
// http://www.antitronics.com/
// this code is public domain, enjoy!

#include "LEDStrip.h"
//#define NUMLEDS 160
#define NUMLEDS 32

LEDStrip strip(3, 2, 5, 4);

//#define SPIN 2
//#define DPIN 3
//#define CLKPIN 4
//#define LPIN 5

// 160 LEDs in 5m strip

uint8_t redcmd;
uint8_t greencmd;
uint8_t bluecmd;
uint8_t tmpcmd;
uint8_t i;

uint8_t current;
int8_t delta;

//LEDStrip strip(DPIN, SPIN, LPIN, CLKPIN);
void clearStrip() {
  // Clear the strip
  for(i=0; i<NUMLEDS; i++) {
    strip.rgbPush(0, 0, 0);
  }
  strip.latch();
}

void setup() {

  clearStrip();
  
  redcmd = 1;
  greencmd = 0;
  bluecmd = 0;

  current=2;
  delta = 1;

  Serial.begin(9600);           // set up Serial library at 9600 bps
  Serial.println("Setup!");
/*
  strip.rgbPush(redcmd, bluecmd, greencmd);
  strip.latch();
  for(i=0; i<(NUMLEDS); i++)
  {
    strip.rgbPush(0, 0, 0);
    delay(10);
    strip.latch();
  }
  //strip.latch();
  //strip.faderSpeedSet(50);
*/
}

uint8_t firsttime = 1;

//
// Set every LED in the strip to the same RGB value, max value 128
//

//
// NOTE - this doesn't work when RGB are each different. LEDs cannot go from being in "up" mode to just staying at the
// value, so they must be left OFF until it's time to increment them. Start with all OFF then turn each color on so that
// all colors reach desired value on the same clock
//

void setAllRGB(uint8_t red, uint8_t green, uint8_t blue) {
  
  uint8_t redon, greenon, blueon;
  uint8_t numsteps, stepno, sendcmd;
  uint8_t redstart, greenstart, bluestart;
  
  char buffer[40];
  
  // what's the highest value we have to step to (max 127)
  numsteps = max(red, green);
  numsteps = max(numsteps, blue);

  redstart = numsteps - red;
  greenstart = numsteps - green;
  bluestart = numsteps - blue;
  
  redcmd = greencmd = bluecmd = 0; // all off

  sprintf(buffer, "## %03d %03d %03d %03d %03d %03d %03d\n", numsteps, red, green, blue, redstart, greenstart, bluestart);
  Serial.print(buffer);
/*
  Serial.print("#");
  Serial.print(red, HEX);
  Serial.print(green, HEX);
  Serial.print(blue, HEX);
  Serial.print(numsteps, HEX);
  Serial.print(redstart, HEX);
  Serial.print(greenstart, HEX);
  Serial.print(bluestart, HEX);
*/  
  // Clear the strip
  clearStrip();

  sendcmd = 0;

  for (stepno = 0; stepno < numsteps; stepno++) {

    //Serial.println(stepno, HEX);

    if (stepno == redstart) {
      redcmd = 2;
      sendcmd = 1;
    }
    if (stepno == greenstart) {
      greencmd = 2;
      sendcmd = 1;
    }
    if (bluecmd == bluestart) {
      bluecmd = 2;
      sendcmd = 1;
    }
      
    // Send the command if needed
    if (sendcmd) {
      for(i=0; i<(NUMLEDS-1); i++) {
        strip.rgbPush(redcmd, bluecmd, greencmd);
      }
      strip.latch();
      sendcmd = 0;
    }
    
    // send the fade up signal
    strip.sPulse();
  }
}

//
// loop on increasing brightness
//
void fadeUpLoop() {
  delay(1000);
  //current = 0;
  setAllRGB(current, current, current);
  if (current++ == 128)
    current = 0;
  }

//These colors don't work.

void colorTestLoop() {
  delay(1000);
  setAllRGB(127, 0, 0); // red
  delay(1000);
  setAllRGB(127, 82, 0); // orange
  delay(1000);
  setAllRGB(127, 127, 0); // yellow
  delay(1000);
  setAllRGB(0, 127, 0); // green
  delay(1000);
  setAllRGB(0, 0, 127); // blue
  delay(1000);
  setAllRGB(38, 0, 65); // indigo
  delay(1000);
  setAllRGB(119, 65, 119); // violet
}

//
// Simple white chase, far end to near end and repeat
//
void whiteChaseLoop() {
  delay(10);

  for(i=0; i<(NUMLEDS-1); i++) {
    if (current == (i+1))
      strip.rgbPush(1, 1, 1);
    else
      strip.rgbPush(0, 0, 0);
    }

  strip.latch();
  if (current == NUMLEDS) {
    current = 1;
  }
  //if ((current == (NUMLEDS-1)) || (current == 1)){
  //  delta = -delta;
//  }
  current = current + delta;
  //strip.sPulse();
  //strip.faderCrank();
}

//
// Do nothing, leaves strip blank
//
void doNothingLoop() {
}

void variableLoop() {
  int ra, ga, ba;
  uint8_t rv, gv, bv;

  ra = analogRead(0);
  ga = analogRead(1);
  ba = analogRead(2);
  rv = map(ra, 0, 1023, 0, 127);
  gv = map(ga, 0, 1023, 0, 127);
  bv = map(ba, 0, 1023, 0, 127);

  setAllRGB(rv, gv, bv);
  //delay(1000);
}

//
// Main loop, call the loop function we want
//
void loop() {
  variableLoop();
//  colorTestLoop();
}
