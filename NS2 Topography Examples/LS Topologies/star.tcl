#create simulator object
set ns [new Simulator]

#$ns rtproto LS
$ns rtproto DV

#opens the NAM trace file
set nf [open out.nam w]
$ns namtrace-all $nf

#opens window trace file
set winfile [open WinFile w]

#defines a finish procedure
proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out.nam &
	exit 0
}

#creates the nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]

#creates the links
$ns duplex-link $n0 $n1 2Mb 30ms DropTail
$ns duplex-link $n0 $n2 2Mb 30ms DropTail
$ns duplex-link $n0 $n3 2Mb 30ms DropTail
$ns duplex-link $n0 $n4 2Mb 30ms DropTail
$ns duplex-link $n0 $n5 2Mb 30ms DropTail

#sets node position
$ns duplex-link-op $n0 $n1 orient right-up
$ns duplex-link-op $n0 $n2 orient left-up
$ns duplex-link-op $n0 $n3 orient right-down
$ns duplex-link-op $n0 $n4 orient left-down
$ns duplex-link-op $n0 $n5 orient up

#monitors the queue between links n0-n5 for NAM
$ns duplex-link-op $n0 $n5 queuePos 0.5

#setup a TCP connection
set tcp [new Agent/TCP/Reno]
$ns attach-agent $n3 $tcp

set sink [new Agent/TCPSink/DelAck]
set sink [new Agent/TCPSink]
$ns attach-agent $n5 $sink

$ns connect $tcp $sink
$tcp set fid_ 1
$tcp set window_ 8000
$tcp set packetSize_ 552

#sets FTP over TCP connection
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

#schedules start/stop times
$ns at 0.1 "$ftp start"
$ns at 100.0 "$ftp stop"

#plot window stuff
proc plotWindow {tcpSource file} {
    global ns

    set time 0.1
    set now [$ns now]
    set cwnd [$tcpSource set cwnd_]
    set wnd [$tcpSource set window_]
    puts $file "$now $cwnd"
    $ns at [expr $now + $time] "plotWindow $tcpSource $file"
}

#starts plotWindow
$ns at 0.1 "plotWindow $tcp $winfile"

#sets sim. end time
$ns at 125.0 "finish"

$ns run
