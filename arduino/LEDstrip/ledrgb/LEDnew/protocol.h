#ifndef Protocol_h
#define Protocol_h

/*
 *  protocol for talking with remote XBEE devices
 */

// First byte of packet is an application ID
#define APPID_NONE 00
#define APPID_LEDSTRIP 01

// Specific to the LEDSTRIP App

#define LS_CMD_ALLOFF 00 // no additional data
#define LS_CMD_SETRGB 01 // three bytes
#define LS_CMD_SETPATTERNLENGTH 02 // one additional byte
#define LS_CMD_SETPATTERN 03 // 3x pattern length bits padded
#define LS_CMD_SETRATE 04 // one byte data in tenths of a second
#define LS_CMD_SETBLINK 05 // set to blink, no data
#define LS_CMD_ALLON 06 // no additional data
#define LS_CMD_STEP // manually step if step rate is zero

struct LEDSTRIPCMD {
    unsigned char appid; // equal to APPID_LEDSTRIP in this case
    unsigned char command;
    // data follows if any
    
};

#define 


#endif
