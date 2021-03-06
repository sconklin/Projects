 # http://wiki.tcl.tk/447
 # simple serial port example to send AT to modem and
 # wait for OK response in a fixed amount of time.  At the
 # bottom is a simple loop to do this 20x to check serial
 # handler reliability...
 #
 # Works well on Tcl 8.0 and up on Unix (Solaris/NT), poorly on
 # the tclsh included with Tcl 8.1.1 on NT, but pretty well on
 # the wish included with same.
 #
 # NOTE may need to set comPort appropriately for your
 # platform.  Must have a modem configured to respond
 # with "OK" to "AT" commands.
 #
 switch $tcl_platform(os) {
     {Linux}            {set comPort /dev/ttyUSB0}
     {SunOS}            {set comPort /dev/cua/a}
     {Windows NT}       {set comPort COM2:}
     default            {error "Must configure comPort"}
 }
 set waitSecs 2
 set nTries   20
 set guardDly 3

 #
 # A cheap version of expect.
 #
 # Set up a event-driven I/O reader on the channel, output the
 # string, and wait some number of seconds for the result.
 #
 # @param fh
 #        a channel opened in non-blocking mode for I/O
 #        with buffering turned off.
 #
 # @param outstr
 #        a string to send to the output channel -- note: end-
 #        of-line characters must be included in this string,
 #        if desired.
 #
 # @param regexp
 #        regular expression to match in the incoming data.
 #
 # @param seconds
 #        number of seconds to wait for above match
 #
 # @throws error
 #        if eof is detected on the channel while waiting
 #
 # @returns int
 #        1 if a match is found, 0 otherwise.
 #
 proc send_expect {fh outstr regexp seconds} {
     global send_exp

     # make sure global vars are initialized properly
     set send_exp($fh.matched)        0
     if {![info exists send_exp($fh.buffer)]} {
         set send_exp($fh.buffer) {}
     }

     # set up our Read handler before outputting the string.
     if {![info exists send_exp($fh.setReader)]} {
         fileevent $fh readable [list private_send_exp_reader \
                 $fh $regexp]
         set send_exp($fh.setReader) 1
     }

     # output the string to send
     puts -nonewline $fh $outstr
     flush $fh

     # set up a timer so that we wait a limited amt of seconds
     set afterId [after [expr {$seconds*1000}] \
             [list set send_exp($fh.matched) 0]]
     vwait send_exp($fh.matched)
     set matched $send_exp($fh.matched)
     unset send_exp($fh.matched)
     catch [list after cancel $afterId]

     # If we got an eof, then throw an error
     if {$matched < 0} {
         error "Channel EOF while waiting for data"
         return 0
     }
     return $matched
 }

 #
 # PRIVATE channel read event handler for send_expect.  Should
 # not be called by user.
 #
 proc private_send_exp_reader {fh regexp} {
     global send_exp

     if {[eof $fh]} {
         close $fh
         set send_exp($fh.matched) -1
         return
     }
     append send_exp($fh.buffer) [read $fh]
     if {[regexp $regexp $send_exp($fh.buffer)]} {
         set send_exp($fh.matched) 1
     }
 }

 #
 # Return the current contents of the send_expect buffer
 #
 # @param fh
 #        channel identifier that was used with send_expect
 #
 # @returns string
 #        the current contents of the buffer for the channel
 #
 proc send_exp_getbuf {fh} {
     global send_exp
     return $send_exp($fh.buffer)
 }

 #
 # Reset the send_expect buffer, returning its contents
 #
 # @param fh
 #        channel identifier that was used with send_expect
 #
 # @returns string
 #        the current contents of the buffer for the channel
 #
 proc send_exp_resetbuf {fh} {
     global send_exp

     set buf $send_exp($fh.buffer)
     set send_exp($fh.buffer) {}
     return $buf
 }

 #
 # Close out a send_expect session, closing I/O event handler
 #
 # @param fh
 #        channel identifier that was used with send_expect
 #
 # @returns
 #        the channel identifier passed as the fh parameter
 #
 proc send_exp_end {fh} {
     global send_exp

     fileevent $fh readable {}
     foreach v [array names send_exp $fh.*] {
         catch [list unset send_exp($v)]
     }
     return $fh
 }

 ##
 ## MAIN
 ##
 set fh [open $comPort RDWR]
 fconfigure $fh -blocking 0 -buffering none \
         -mode 9600,n,8,1 -translation binary -eofchar {}

 # Loop nTries times, sending AT to modem and expecting OK.
 set nMatches 0
 puts "Entering Command Mode"
 for {set i 0} {$i < $nTries} {incr i} {
     # Enter Command Mode
     puts "Delaying $guardDly seconds"
     after [expr {$guardDly*1000}]
     if {[send_expect $fh "+++" "OK" $waitSecs]} {
         incr nMatches
         regsub -all "\r" [send_exp_getbuf $fh] {\r} buf
         regsub -all "\n" $buf {\n} buf
         #puts "Entered Command Mode: <$buf>"
         puts "Entered Command Mode"
	 break
     } else {
         puts "Command Mode not entered in $waitSecs Seconds"
     }
 }
send_exp_resetbuf $fh

#after 12000
# Print the firmware version
if {[send_expect $fh "E6" "\r10E6\r" $waitSecs]} {
    regsub -all "\r" [send_exp_getbuf $fh] {\r} buf
    regsub -all "\n" $buf {\n} buf
    puts "Firmware Version = <$buf>"
} else {
    puts "No response in $waitSecs Seconds"
}
puts [send_exp_resetbuf $fh]
puts "done"


 send_exp_end $fh
 close $fh
# puts "Matched $nMatches/$nTries\
#         ([expr 100.0*$nMatches/$nTries]%)"