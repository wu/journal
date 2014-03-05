#!/usr/bin/env perl

use Net::OpenSSH;
use Sys::Hostname;

my $localhost = hostname();

my $host = shift @ARGV;
unless ( $host ) {
    die "ERROR: no hostname specified";
}

my $ssh = Net::OpenSSH->new( $host );
$ssh->error and
    die "Couldn't establish SSH connection: ". $ssh->error;

print "Killing any remote raspivid processes that may be running...\n";
$ssh->system("sudo pkill raspivid && sleep 1");


print "Starting local mplayer process\n";
my $command = "nc -l 5001 | mplayer -fps 31 -cache 1024 -";
open my $run, "-|", "$command 2>&1 >/dev/null" or die "Unable to execute $command: $!";

print "Starting remote raspivid process\n";
$ssh->system("sudo raspivid -t 999999 -br 60 -ex auto -mm matrix -fps 10 -ISO 100 -t 0 -o - | nc $localhost 5001") or
    die "remote command failed: " . $ssh->error;
