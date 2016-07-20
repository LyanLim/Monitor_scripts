#!/usr/bin/perl



$hash{'a.mpg'}{region} = A;
$hash{'a.mpg'}{hitcount} = 30;
$hash{'a.mpg'}{time} = '2016-06-10';

$hash{'b.mpg'}{region} = A;
$hash{'b.mpg'}{hitcount} = 30;
$hash{'b.mpg'}{time} = '2016-06-10';


use Data::Dumper;

#print Dumper \%hash;

foreach my $filename ( keys %hash ){
	foreach my $region ( keys %{ $hash{$filename} } ){
			print "$region :: $hash{$filename}{$region}\n";
	}
}
