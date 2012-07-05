// Copyright 2009 by Steve Conklin http://www.antitronics.com
// released to the public domain
//
// derived from some code and ideas by Maurice Ribble:
// http://www.glacialwanderer.com/hobbyrobotics
// http://www.glacialwanderer.com/hobbyrobotics/?cat=5&paged=2

// This sketch sends the values from the first three analog inputs to a web server
// for logging. It uses the adafruit ethernet shield with an XPort module installed.
// The XPORT connections and configuration are *almost* the same as documented on the adafruit
// web site: http://www.ladyada.net/make/eshield/index.html
//
// XPort connections on the eshield:
//
// XPort RX pin -> Arduino digital pin 2
// XPort TX pin -> Arduino digital pin 3
// XPort Reset pin -> Arduino digital pin 4
// XPort DTR pin -> Arduino digital pin 5 (not used)
// XPort CTS pin -> Arduino digital pin 6
// XPort RTS pin -> Arduino digital pin 7 (not used)
//
// XPort configuration:
//
// *** Channel 1
// Baudrate 57600, I/F Mode 4C, Flow 02
// Port 10001
// Connect Mode : D4
// Send '+++' in Modem Mode enabled
// Show IP addr after 'RING' enabled
// Auto increment source port disabled
// Remote IP Adr: --- none ---, Port 00000
// Disconn Mode : 80  Disconn Time: 00:03 <=== Different than adafruit example, she uses Disconn Mode = 0
// Flush   Mode : 77

// These are web server specific values
#define PHP_PAGE_LOCATION "/monkey/power.php"
#define WEB_HOST "HOST: antitronics.com\n\n"
//#define CONN_IP "172.31.0.106" // test server
#define CONN_IP "69.163.135.165" // antitronics
#define CONN_PORT 80

#include "AF_XPort.h"
#include "NewSoftSerial.h"

// the xport!
#define XPORT_RX        2
#define XPORT_TX        3
#define XPORT_RESET     4
#define XPORT_CTS       6
#define XPORT_RTS       0 // not used
#define XPORT_DTR       0 // not used
AF_XPort xport = AF_XPort(XPORT_RX, XPORT_TX, XPORT_RESET, XPORT_DTR, XPORT_RTS, XPORT_CTS);

char linebuffer[128];
int retstat;

void printstatus(int)
{
  // no output for success
  if (retstat == ERROR_TIMEDOUT)
    Serial.println("ERROR: Timeout");
  else if (retstat == ERROR_BADRESP)
    Serial.println("ERROR: Bad Response");
  else if (retstat == ERROR_DISCONN)
    Serial.println("ERROR: Disconnect");

  return;
}

void setup()
{
  Serial.begin(57600);
  Serial.println("serial port ready");
  xport.begin(57600);
  retstat = xport.reset();
  printstatus(retstat);
  Serial.println("XPort ready");
}

void loop()
{
  int value0, value1, value2;
  uint8_t read;
  char cbuffer[128];

  //Serial.println("Connecting");
  retstat = xport.connect(CONN_IP, CONN_PORT);
  printstatus(retstat);
  //Serial.println("Sending GET");

  //Serial.println("Request");
  value0 = analogRead(0);
  value1 = analogRead(1);
  value2 = analogRead(2);

  sprintf(cbuffer, "GET %s?value0=%d&value1=%d&value2=%d HTTP/1.1\n%s", PHP_PAGE_LOCATION,value0,value1,value2,WEB_HOST);
  Serial.println(cbuffer);
  xport.print(cbuffer);

  // read back the status from the web host
  read = xport.readline_timeout(linebuffer, 128, 1000);
  //Serial.println(read, DEC);   // debugging output
  //Serial.print(linebuffer); // debugging output

  //Serial.println("sent - sleeping");
  // Delay for 1 minute to aviod triggering my host's firewall
  delay(60000);
  // The disconnect notification 'D' character probably arrived during this interval
  // so fluch it so we don't read it after our next connect attempt
  xport.flush(255);
}


