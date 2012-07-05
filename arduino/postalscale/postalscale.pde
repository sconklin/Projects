#include <avr/interrupt.h>
#include <avr/io.h>

#define INITIAL_DELAY 78
#define CLK_COUNT 55

int ledPin = 13;
int interruptPin = 2;
int clkoutPin = 4; // PD4
int datainPin = 5; // PD5

// used by the top end
volatile unsigned char scaleValue[3];
// Used by the ISR only
volatile unsigned char inb[3];
volatile unsigned char inbuffer;
volatile unsigned int state = 0;
volatile unsigned char clkdelay = 0;

// NOTES:
// Sometimes starts and runs fine, sometimes doesn't. Once it is in the "bad" state
// it doesn't recover by resetting, but does recover sometimes after power cycling
// When it doesn't work the main loop still executes, reads zeros

ISR(INT0_vect) {
    // the external input has a falling edge - this is what starts everything
    EIMSK &= ~_BV(INT0); // turn off this interrupt

    // set up timer2
    // we need a delay before starting to clock in the scale data
    TCNT2 = 0; // clear the timer count
    OCR2A = INITIAL_DELAY;
    TCCR2B = _BV(CS21); // Start timer 2
    state = 0;
}

// state bits:
// 0 - 0= write output low, 1=read data and write output high
// 1 - bit counter 0 -\
// 2 - bit counter 1 ---- max 7, rolls over into byte count
// 3 - bit counter 2 -/
// 4 - byte counter 0 -- max 2 (three bytes)
// 5 - byte counter 1 -/
// 6 - reserved
// 7 - reserved

ISR(TIMER2_COMPA_vect) {
  // we get here when the timer overflows
  int nbit, nbyte;

  if (state == 0) {
     // first time here, set up the timer for clocking bits
     TCCR2B = 0; // turn off the clock to this counter
     inbuffer = 0; // clear the input buffer byte
     clkdelay = 0;
     TCNT2 = 0; // clear the timer count
     OCR2A = CLK_COUNT;
     TCCR2B = _BV(CS21); // Start timer 2
  }

  if (clkdelay) {
    clkdelay--;
  } else {
    if (state & 0x01) {
      unsigned char tmp;
       // read data, set clock high, see if we're at the end of a byte
       nbit = (state >> 1) & 0x07;
       nbyte = (state >> 4) & 0x03;
       tmp = (PIND >> PIND5) & 0x01;
       inbuffer |= (tmp << nbit); // read the bit
       PORTD |= _BV(PORTD4); // clock high
       if (nbit == 7) {
       	  // we're done with this byte
	  inb[nbyte] = inbuffer;
	  inbuffer = 0;
	  if (nbyte == 2) {
	     // we're done with all three bytes
	     state = 0;
    	     EIFR |= _BV(INTF0); // clear any pending external interrupts
    	     EIMSK |= _BV(INT0); // re-enable external interrupts
       	     TCCR2B = 0; // turn off the clock to this counter
	     scaleValue[0] = inb[0];
	     scaleValue[1] = inb[1];
	     scaleValue[2] = inb[2];
	  } else {
	    // we're not done yet
            clkdelay = 4;
	    state++;
	  }
       } else {
         // within a byte
         state++;
       }
    } else {
      // state LSB is clear
       // set clock low, that's all
       PORTD &= ~_BV(PORTD4); // clock low
       state++;
    }
  }
}

void setup() {
    Serial.begin(9600);

    // We may want to write to the LED
    pinMode(ledPin, OUTPUT);

    // Set up the pins for clocking data in
    pinMode(clkoutPin, OUTPUT); // PD4
    pinMode(datainPin, INPUT); // PD5
    //digitalWrite(datainPin, HIGH); // turn on pullup

    // ***** Set up external interrupt *****
    // read mode on external interrupt pin
    pinMode(interruptPin, INPUT);
    digitalWrite(interruptPin, HIGH); // turn on pullup
    // falling edge triggers interrupt
    EICRA &= ~_BV(ISC00);
    EICRA |= _BV(ISC01);
    // Enable INT0 interrupt
    EIMSK |= _BV(INT0);

    // ***** Set up timer 2 *****
    // Use Timer 2
    // Use CTC (clear timer on compare match) mode 
    // (WGM22:0 = 2), Timer resets when it equals OCR2A
    // OCRA is used to set TOP count

    // TCCR2A
    // 7 - COM2A1  - 0  // Compare Match output A mode
    // 6 - COM2A0  - 0  // Compare Match output A mode
    // 5 - COM2B1  - 0  // Compare Match output B mode
    // 4 - COM2B0  - 0  // Compare Match output B mode
    // 3 - reserv  - 0
    // 2 - reserv  - 0
    // 1 - WGM21   - 1  // Waveform Generation Mode 
    // 0 - WGM20   - 0  // Waveform Generation Mode 
    TCCR2A = _BV(WGM21);

    // TCCR2B
    // 7 - FOC2A  - 0   // Force Output Compare A (not active in non-PWM mode)
    // 6 - FOC2B  - 0   // Force Output Compare B (not active in non-PWM mode)
    // 5 - reserv - 0
    // 4 - reserv - 0
    // 3 - WGM22  - 0  // Waveform Generation Mode 
    // 2 - CS22   - x  // Clock Select 
    // 1 - CS21   - x  // Clock Select
    // 0 - CS20   - x  // Clock Select
    // Clock Select:
    // we have a 16 MHz master clock
    //  000 - No Source, timer/counter stopped
    //  001 - CLK (no prescaling) .063 uS per tick (8 ticks per uS)
    //  010 - CLK/8    - 0.5 uS per tick
    //  011 - CLK/32   - 2 uS per tick
    //  100 - CLK/64   - 4 uS per tick
    //  101 - CLK/128
    //  110 - CLK/256
    //  111 - CLK/1024

    TCCR2B = 0; // for now leave it turned off
    
    ASSR &= ~_BV(AS2); // Use internal clock – external clock not used in Arduino
    TIMSK2 |= _BV(OCIE2A); // Timer2A match Interrupt Enable

    sei(); // enable interrupts
}

void loop()                     
{
  unsigned int sv0;
  unsigned int sv1;
  unsigned int sv2;
  unsigned int flags;
  unsigned int f1; // flags?
  unsigned int f2;
  unsigned int f3;
  unsigned int f4;
  unsigned int f5;
  unsigned int f6;
 
  char cbuffer[40];

  delay(100);
  
  PORTB |= _BV(PORTB5); // LED high
  cli();
  sv0 = scaleValue[0];
  sv1 = scaleValue[1];
  sv2 = scaleValue[2];
  sei();
  PORTB &= ~_BV(PORTB5); // clock low
 
 // Notes about the data format
 // sv0 is least significant, sv2 is most
 // sv0 and sv1 have values that range from 0-153 (base 154 wtf?)
 // sv2 has been seen to go as high as 6 with 200+ lbs on the scale
 // The high bits of sv2 seem to have some other information in them
 // maybe a sign bit somewhere?
 
  flags = sv2 & 0xFC;
  f1 = sv2 & 0x80;
  f2 = sv2 & 0x40;
  f3 = sv2 & 0x20;
  f4 = sv2 & 0x10; // overflow?
  f5 = sv2 & 0x08;
 
  sv2 &= 0x07;
  
  sprintf(cbuffer, "%3d %3d %3d", sv2, sv1, sv0);
  Serial.println(cbuffer);
}
