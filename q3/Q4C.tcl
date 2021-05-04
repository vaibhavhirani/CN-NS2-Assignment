
#  This is a simple demonstration of how to use the TcpApp application
#  to send data over a TCP connection.


set namfile	out.nam
set tracefile	out.tr

set ns [new Simulator]

proc monitor {interval} {
    global tcp0 tcp1 ns sink0 sink1
    set nowtime [$ns now]

    set win0 [open result a]
    set win1 [open result a]
    set bw0 [$sink0 set bytes_]
    set bw1 [$sink1 set bytes_]
    set tput0 [expr $bw0/$interval*8/1000000]
    set tput1 [expr $bw1/$interval*8/1000000]
    set cwnd0 [$tcp0 set cwnd_ 1000]
    set cwnd1 [$tcp set awnd_ 1000]
    puts $win0 "$nowtime $tput0 $cwnd0]"
    puts $win1 "$nowtime $tput1 $cwnd1]"
    $sink0 set bytes_ 0
    $sink1 set bytes_ 0
    close $win0
    close $win1

    $ns after $interval "monitor $interval"
}


# open trace files and enable tracing
set nf [open $namfile w]
$ns namtrace-all $nf
set f [open $tracefile w]
$ns trace-all $f


# create two nodes
set sender1 [$ns node]
set sender2 [$ns node]
set router [$ns node]
set receiver [$ns node]

$ns duplex-link $sender1 $router 10Mb 10ms DropTail
$ns duplex-link $sender2 $router 10Mb 10ms DropTail
$ns duplex-link $router $receiver 10Mb 10ms DropTail

$ns duplex-link-op $sender1 $router orient right-down
$ns duplex-link-op $sender2 $router orient right-up
$ns duplex-link-op $router $receiver orient right

# create FullTcp agents for the nodes
# TcpApp needs a two-way implementation of TCP
set tcp0 [new Agent/TCP]
$ns attach-agent $sender1 $tcp0
set tcp1 [new Agent/TCP]
$ns attach-agent $sender2 $tcp1

set sink0 [new Agent/TCPSink]
$ns attach-agent $sender1 $sink0
set sink1 [new Agent/TCPSink]
$ns attach-agent $sender2 $sink1

$ns connect $tcp0 $sink0
$ns connect $tcp1 $sink1


#Setup a FTP over TCP connection
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0

set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1

$ns at 0 "$ftp0 start"
$ns at 0 "$ftp1 start"
$ns at 60 "$ftp0 stop"
$ns at 60 "$ftp1 stop"

proc finish {} {
	global ns nf f namfile
	$ns flush-trace
	close $nf
	close $f

	puts "running nam..."
	exec nam $namfile &
	exit 0
}

#call the monitor at the end
$ns at 0 "monitor 0.5"

$ns at 60.0 "finish"

$ns run
