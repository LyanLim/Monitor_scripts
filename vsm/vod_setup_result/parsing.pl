#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

my %hash;


while (<ARGV>){

	next unless m/OnDescribeResponse/;

	my ($lsm_ip, $file_name, $result) = (split /[,\[\]]/)[9,13,16];

	if ( $result =~ m/success/ ){
		$hash{$lsm_ip}{$file_name}{success}++;
	}elsif ( $result =~ m/file not found/ ){
		$hash{$lsm_ip}{$file_name}{fail}++;
	}elsif ( $result =~ m/max/ ){
		$hash{$lsm_ip}{$file_name}{fail}++;
	}else{
		print "Unknown result : $result\n";
	}
}

foreach my $lsm_ip ( keys %hash ){
	foreach my $file_name ( keys %{$hash{$lsm_ip}} ){

		foreach my $result ( keys %{ $hash{$lsm_ip}{$file_name} } ){
			print "$lsm_ip   $file_name   $result   $hash{$lsm_ip}{$file_name}{$result}\n";
		}

	}
}
