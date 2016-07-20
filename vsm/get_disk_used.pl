#!/usr/bin/perl

use 5.010;

use strict;
use warnings;
use Data::Dumper;

my $oid = '.1.3.6.1.2.1.25.2.3';
my $host = shift;
my $ip = shift;
my @snmp_result=`snmpwalk -v 2c -c ViettelMS1NMS $ip $oid`;

my %data;
my %disk;


foreach ( @snmp_result ){

	chomp; 
	if ( m/^HOST-RESOURCES-MIB::(\w+)\.(\d+) = \w+: (.*)/ ){

		$data{$2}{$1} = $3;

	}elsif ( m/^HOST-RESOURCES-MIB::(\w+)\.(\d+) = \w+: (.*)/ ){

		$data{$2}{$1} = $3;

	}elsif ( m/^HOST-RESOURCES-MIB::(\w+)\.(\d+) = \w+: (.*)/ ){

		$data{$2}{$1} = $3;

	}elsif ( m/^HOST-RESOURCES-MIB::(\w+)\.(\d+) = \w+: (.*)/ ){

		$data{$2}{$1} = $3;

	}elsif ( m/^HOST-RESOURCES-MIB::(\w+)\.(\d+) = \w+: (.*)/ ){

		$data{$2}{$1} = $3;

	}else{
	}
}

foreach my $index ( keys %data ){
	
	if ( $data{$index}{'hrStorageDescr'} eq '/' ||
		$data{$index}{'hrStorageDescr'} eq '/var' ||
		$data{$index}{'hrStorageDescr'} eq '/castis' ||
		$data{$index}{'hrStorageDescr'} eq '/data1' ||
		$data{$index}{'hrStorageDescr'} eq '/RAM_DISK'
	){
		my $unit = (split / /, $data{$index}{'hrStorageAllocationUnits'})[0];	
		my $total_size = $data{$index}{'hrStorageSize'} * $unit;
		my $used_size = $data{$index}{'hrStorageUsed'} * $unit;
		print "$host,$ip,$data{$index}{'hrStorageDescr'},$total_size,$used_size\n";
	}else{
	}
}
