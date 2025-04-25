#!/usr/bin/perl
use strict;
use warnings;

my $log_file = '/opt/loxberry/log/plugins/ozw672_plugin/test_output.log';
open(my $fh, '>>', $log_file) or die "Unable to open $log_file: $!";
print $fh "Schrijf hier je testtekst.\n";
close($fh);

print "Tekst weggeschreven naar $log_file.\n";