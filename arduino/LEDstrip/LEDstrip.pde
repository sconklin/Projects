// Adafruit Motor shield library
// copyright Adafruit Industries LLC, 2009
// this code is public domain, enjoy!

// LED strip controller

#include <AFMotor.h>

AF_DCMotor red(1);
AF_DCMotor green(2);
AF_DCMotor blue(3);

void setup() {

  // turn on motor
  red.setSpeed(0);
  green.setSpeed(0);
  blue.setSpeed(0);
  red.run(RELEASE);
  green.run(RELEASE);
  blue.run(RELEASE);
  
}

uint8_t firsttime = 1;

void loop() {
  uint8_t i;
  
  red.run(FORWARD);
  green.run(FORWARD);
  blue.run(FORWARD);

  // red up
  for (i=0; i<255; i++) {
    red.setSpeed(i);
    delay(10);
 }

  if (firsttime == 1) {
    firsttime = 0;
  } else {
    // blue down
    for (i=255; i!=0; i--) {
      blue.setSpeed(i);
      delay(10);
   }
  }  

  // green up
  for (i=0; i<255; i++) {
    green.setSpeed(i);
    delay(10);
 }
 
  // red down
  for (i=255; i!=0; i--) {
    red.setSpeed(i);
    delay(10);
 }

  // blue up
  for (i=0; i<255; i++) {
    blue.setSpeed(i);
    delay(10);
 }

  // green down
  for (i=255; i!=0; i--) {
    green.setSpeed(i);
    delay(10);
 }

  //red.run(RELEASE);
  //green.run(RELEASE);
  //blue.run(RELEASE);
}
