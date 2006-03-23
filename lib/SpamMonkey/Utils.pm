package SpamMonkey::Utils;
use strict;
use Net::DNS::Resolver;
my %cache;

sub host_to_ip { # Basic method
    my ($self, $host) = @_;
    local $SIG{ALRM} = sub { return; };
    my $addr = $cache{$host} ||= eval {
        alarm 5;
        (gethostbyname $host)[4];
    };
    alarm 0;
    return unless $addr;
    my @bits = unpack("C4",$addr);
    return wantarray ? @bits : join ".", @bits;
}

sub rbl_check { # Complex method
    my ($self, $host, $type, $timeout) = @_;
    my $resolver = Net::DNS::Resolver->new();
    #$resolver->tcp_timeout($timeout) if $timeout;
    #$resolver->udp_timeout($timeout) if $timeout;
    return ! ! $resolver->query($host, $type);
}

# UNFINISHED; needs to be moved to its own module
sub parse_received_headers {
    my ($self, $monkey) = @_;
    for ($self->{email}->headers("Received")) {
        next if /^\(/;
    }
}

1;
