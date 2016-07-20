#!/usr/bin/perl

use Data::Dumper;


while(<DATA>){


	if ( m/AddHitcountList/ ){
		#my ( $filename, $hit ) = (split /[,=]/ , $_)[8,10];
		my @test = split /[,=]/ , $_;
		
		#print "$filename,            $hit\n";
		print Dumper \@test;
	}
}

#print Dumper \%ptime_data;

__DATA__
CiGFMServer,2.0.0,2016-05-04,00:01:32.666,Debug,HitcountFileContainer.cpp:AddHitcountList(283),,"Add HitCount(CDN2_SBK-CDN2_3[1.255.94.71]). FileName=/data/ftp/pub/hanaro/movie/32050/M320274_1_R160420.ts.pac, HitCount=1, TotalHitCount=4732"         

