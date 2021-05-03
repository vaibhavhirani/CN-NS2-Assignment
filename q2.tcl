

#===================================
#     Simulation parameters setup
#===================================
set val(stop)   60.0                         ;# time of simulation end


set f0 [open __out0.tr w]
set f1 [open __out1.tr w]

#===================================
#        Initialization        
#===================================
#Create a ns simulator
set ns [new Simulator]

#Open the NS trace file
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Open the NAM trace file
set namfile [open out.nam w]
$ns namtrace-all $namfile

#===================================
#        Nodes Definition        
#===================================
#Create 4 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#===================================
#        Links Definition        
#===================================
#Createlinks between nodes
$ns duplex-link $n3 $n0 100.0Mb 10ms DropTail
$ns queue-limit $n3 $n0 50
$ns duplex-link $n2 $n3 100.0Mb 10ms DropTail
$ns queue-limit $n2 $n3 50
$ns duplex-link $n3 $n1 100.0Mb 10ms DropTail
$ns queue-limit $n3 $n1 50

#Give node position (for NAM)
$ns duplex-link-op $n3 $n0 orient left-up
$ns duplex-link-op $n2 $n3 orient right-up
$ns duplex-link-op $n3 $n1 orient right

#===================================
#        Agents Definition        
#===================================
#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink5 [new Agent/TCPSink]
$ns attach-agent $n1 $sink5
$ns connect $tcp0 $sink5
$tcp0 set packetSize_ 1500

#Setup a TCP/FullTcp/Tahoe connection
set tcp1 [new Agent/TCP]
$ns attach-agent $n2 $tcp1
set sink3 [new Agent/TCPSink]
$ns attach-agent $n1 $sink3
$ns connect $tcp1 $sink3
$tcp1 set packetSize_ 1500


#===================================
#        Applications Definition        
#===================================
#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 2.0 "$ftp0 start"
$ns at 60.0 "$ftp0 stop"

#Setup a FTP Application over TCP/FullTcp/Tahoe connection
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 1.5 "$ftp1 start"
$ns at 60.0 "$ftp1 stop"


#===================================
#        Termination        
#===================================
#Define a 'finish' procedure
proc finish {} {
    global ns tracefile namfile f0 f1
    $ns flush-trace
    close $tracefile
    close $namfile
    close $f0
    close $f1
    exec nam out.nam &
    exit 0
}

proc record {} {
        global sink3 sink5 f0 f1 
	#Get an instance of the simulator
	set ns [Simulator instance]
	#Set the time after which the procedure should be called again
        set time 0.5
	#How many bytes have been received by the traffic sinks?
        set bw0 [$sink3 set bytes_]
        set bw1 [$sink5 set bytes_]

	#Get the current time
        set now [$ns now]

	#Calculate the bandwidth (in MBit/s) and write it to the files
        puts $f0 "$now [expr $bw0/$time*8/1000000]"
        puts $f1 "$now [expr $bw1/$time*8/1000000]"

	#Reset the bytes_ values on the traffic sinks
        $sink3 set bytes_ 0
        $sink5 set bytes_ 0

	#Re-schedule the procedure
        $ns at [expr $now+$time] "record"
}

$ns at 0.0 "record"
$ns at 60.0 "finish"

$ns run
#$ns at $val(stop) "$ns nam-end-wireless $val(stop)"
#$ns at $val(stop) "finish"
#$ns at $val(stop) "puts \"done\" ; $ns halt"
#$ns run
