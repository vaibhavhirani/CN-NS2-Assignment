# time of simulation end
set val(stop)   60.0                         


#Define tracefile o/p
set f [open out.tr w]

#Create a ns simulator
set ns [new Simulator]


$ns trace-all $f
set namfile [open out.nam w]
$ns namtrace-all $namfile


#Create 4 nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

#links between nodes
$ns duplex-link $n3 $n0 10Mb 10ms DropTail
$ns queue-limit $n3 $n0 50
$ns duplex-link $n2 $n3 10Mb 10ms DropTail
$ns queue-limit $n2 $n3 50
$ns duplex-link $n3 $n1 10Mb 10ms DropTail
$ns queue-limit $n3 $n1 50

#node positioning
$ns duplex-link-op $n3 $n0 orient left-up
$ns duplex-link-op $n2 $n3 orient right-up
$ns duplex-link-op $n3 $n1 orient right


#Setup a TCP connection
set tcp0 [new Agent/TCP]
$ns attach-agent $n0 $tcp0
set sink0 [new Agent/TCPSink]
$ns attach-agent $n1 $sink0
$tcp0 set packetSize_ 512
#$tcp0 set window_ 1000
#$tcp0 tracevar cwnd_
$ns connect $tcp0 $sink0

set tcp1 [new Agent/TCP]
$ns attach-agent $n2 $tcp1
set sink1 [new Agent/TCPSink]
$ns attach-agent $n1 $sink1
$tcp1 set packetSize_ 512
#$tcp1 set window_ 1000
#$tcp1 tracevar cwnd_  
$ns connect $tcp1 $sink1

#Setup a FTP Application over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns at 2.0 "$ftp0 start"
$ns at 60.0 "$ftp0 stop"

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns at 1.5 "$ftp1 start"
$ns at 60.0 "$ftp1 stop"


#Runs at End
proc finish {} {
    global ns namfile f
    $ns flush-trace
    close $namfile
    close $f
    exec nam out.nam &
    #exec xgraph __out0.tr __out1.tr -geometry 800x400 &
    	exit 0
}

#Setting Congestion and Advertised window
set cwnd0 [$tcp0 set cwnd_ 1000]
set cwnd1 [$tcp1 set cwnd_ 1000]
set awnd0 [$tcp0 set awnd_ 1000]
set awnd1 [$tcp1 set awnd_ 1000]


$ns at 60.0 "finish"


puts "Congestion Window Size = $cwnd0"
puts "Advertised Window Size = $awnd0"

$ns run
