#!/usr/bin/perl

use strict;
use warnings;

use Time::Local;
use Data::Dumper;

my %hitcount;

while(<ARGV>){

	if ( m/SDP Request/ ){

		my ($string, $json) = (split /[{}]/)[0,1];

		#my $time = substr (  ((split / /, $string)[1]), 0, 8 );
		$json =~ s/"//g;
		$json =~ s/ : /:/g;
		chomp $json;
		my @arr = split /,/ , $json;
		my %hash;

		foreach my $data ( @arr ){
			my ($key, $value) = split /:/ , $data;
			$hash{$key} = $value;
		}

		$hitcount{  $hash{filename}   }{   $hash{regionId}   }++;
	}
}

foreach my $filename ( keys %hitcount ){
	
	foreach my $region ( keys %{ $hitcount{$filename} } ){
		print "$filename , $region, $hitcount{$filename}{$region}\n";
	}
}
