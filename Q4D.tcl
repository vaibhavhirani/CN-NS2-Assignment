#Create a simulator object
set ns [new Simulator]

$ns color 1 Red
$ns color 2 Blue

#Open the output files
set f [open udp.tr w]
$ns trace-all $f
set nf [open out.nam w]
$ns namtrace-all $nf

#Create 4 nodes
set sender1 [$ns node]
set sender2 [$ns node]
set router [$ns node]
set receiver [$ns node]

#Connect the nodes
$ns duplex-link $sender1 $router 10Mb 10ms DropTail
$ns duplex-link $sender2 $router 10Mb 10ms DropTail
$ns duplex-link $router $receiver 10Mb 10ms DropTail

$ns duplex-link-op $sender1 $router orient right-down
$ns duplex-link-op $sender2 $router orient right-up
$ns duplex-link-op $router $receiver orient right

$ns duplex-link-op $router $receiver queuePos 0.5

set udp0 [new Agent/UDP]
$udp0 set class_ 1
$ns attach-agent $sender1 $udp0

set cbr0 [new Application/Traffic/CBR]
$cbr0 set packetSize_ 512
$cbr0 set interval_ 0.005
$cbr0 attach-agent $udp0

set udp1 [new Agent/UDP]
$udp1 set class_ 2
$ns attach-agent $sender2 $udp1

set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 512
$cbr1 set interval_ 0.005
$cbr1 attach-agent $udp1

set sink0 [new Agent/LossMonitor]
$ns attach-agent $receiver $sink0

$ns connect $udp0 $sink0
$ns connect $udp1 $sink0

proc finish {} {
	global f nf ns
	#Close the output files
	$ns flush-trace
	close $nf
	close $f
	puts "running nam..."
	exec nam out.nam &
        exit 0
}


$ns at 10.0 "$cbr0 start"
$ns at 10.0 "$cbr1 start"
$ns at 50.0 "$cbr0 stop"
$ns at 50.0 "$cbr1 stop"
$ns at 60.0 "finish"

$ns run
