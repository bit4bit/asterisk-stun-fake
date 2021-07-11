=pod

=head1 Description

This script start a fake stun server, for Asterisk chan_sip.

Asterisk for Webrtc clients requires configure a stun server for getting
public ip for ice candidates, when asterisk server run in a nat one-to-one like AWS,
 we not need a stun server, this scripts workaround this issue with a fake stun server.

Run this script on your asterisk server, edit **rtp.conf** and set "stunaddr=localhost".

Tested with Asterisk chan_sip on:
 - 14.x
 - 13.x

=head1 Usage

perl patun.pl <my public ip>

=cut

use strict;
use warnings;

use IO::Socket;


my ($ip, $port) = @ARGV;

if (not defined $ip) {
    die "Usage $0: <advertised ip> [local port]\n";
}

if (not defined $port) {
    $port = 3478;
}


my $sock = IO::Socket::INET->new(LocalAddr => 'localhost',
                                 LocalPort => $port,
                                 Proto => 'udp')
    or die "couldn't start server on localhost:$port: $@\n";

print "Listening at localhost:$port\n";

while ($sock->recv(my $pdu, 20)) {
    my($port, $ipaddr) = sockaddr_in($sock->peername);
    my $host = gethostbyaddr($ipaddr, AF_INET);

    my $header = substr $pdu, 0, 20;

    my($omit, $message_length, @transaction) = unpack('nnC16', $header);

    # asterisk 13.x and 14.x using chan_sip
    # only use mapped-address
    my $sockip = unpack('N', inet_aton($ip));
    my $mapped_address = pack('nnCCnN', 0x0001, 0x0008, 0x00, 0x01, $port, $sockip);

    my $bindres = pack('nnC16', 0x0101, length($mapped_address), @transaction);

    $sock->send($bindres . $mapped_address);
}

