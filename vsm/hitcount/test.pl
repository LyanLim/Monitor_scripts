#!/usr/bin/perl

use Data::Dumper;
my %hitcount;

while(<DATA>){


	if ( m/AddHitcountList/ ){
		my ( $date, $hour, $min, $tmp_hostname, $tmp_filename, $hit ) = (split /[,:=]/ , $_)[2,3,4,10,11,13];
		#my @test = split /[,:=]/ , $_;
		my ( $hostname, $hostip ) = (split /[()\[\]]/ , $tmp_hostname)[1,2];
		my $filename = (split /\// , $tmp_filename)[-1];
		my $time = "$hour:$min:00";
		
	#	print "$date\n";
	#	print "$time\n";
	#	print "$hostname\n";
	#	print "$hostip\n";
	#	print "$filename\n";
	#	print "$hit\n";
		$hitcount{$filename}{date} = $date;
		#$hitcount{$filename}{$time} += $hit;
		$hitcount{$filename}{time}{$time} += $hit;
		$hitcount{$filename}{hostname} = $hostname;
		$hitcount{$filename}{hostip} = $hostip;

		print Dumper \%hitcount;
	}


}

foreach my $filename ( keys %hitcount ) {
	foreach my $time ( keys %{ $hitcount{$filename}{time} } ){
		print "$filename, $hitcount{$filename}{date},$time, $hitcount{$filename}{time}{$time},$hitcount{$filename}{hostname}, $hitcount{$filename}{hostip} \n";
	}
}


#print Dumper \%ptime_data;

__DATA__
CiGFMServer,2.0.0,2016-05-04,00:01:32.666,Debug,HitcountFileContainer.cpp:AddHitcountList(283),,"Add HitCount(CDN2_SBK-CDN2_3[1.255.94.71]). FileName=/data/ftp/pub/hanaro/movie/32050/M320274_1_R160420.ts.pac, HitCount=1, TotalHitCount=4732"         
CiGFMServer,2.0.0,2016-05-04,00:01:33.666,Debug,HitcountFileContainer.cpp:AddHitcountList(283),,"Add HitCount(CDN2_SBK-CDN2_3[1.255.94.71]). FileName=/data/ftp/pub/hanaro/movie/32050/M320274_1_R160420.ts.pac, HitCount=1, TotalHitCount=4732"         
CiGFMServer,2.0.0,2016-05-04,00:01:34.666,Debug,HitcountFileContainer.cpp:AddHitcountList(283),,"Add HitCount(CDN2_SBK-CDN2_3[1.255.94.71]). FileName=/data/ftp/pub/hanaro/movie/32050/M320274_1_R160420.ts.pac, HitCount=1, TotalHitCount=4732"         
CiGFMServer,2.0.0,2016-05-04,00:01:35.666,Debug,HitcountFileContainer.cpp:AddHitcountList(283),,"Add HitCount(CDN2_SBK-CDN2_3[1.255.94.71]). FileName=/data/ftp/pub/hanaro/movie/32050/M320274_1_R160420.ts.pac, HitCount=1, TotalHitCount=4732"         
CiGFMServer,2.0.0,2016-05-04,00:01:35.666,Debug,HitcountFileContainer.cpp:AddHitcountList(283),,"Add HitCount(CDN2_SBK-CDN2_3[1.255.94.71]). FileName=/data/ftp/pub/hanaro/movie/32050/M320274_1_R160420.ts.pac, HitCount=1, TotalHitCount=4732"         
CiGFMServer,2.0.0,2016-05-04,00:02:35.666,Debug,HitcountFileContainer.cpp:AddHitcountList(283),,"Add HitCount(CDN2_SBK-CDN2_3[1.255.94.71]). FileName=/data/ftp/pub/hanaro/movie/32050/M320274_1_R160420.ts.pac, HitCount=1, TotalHitCount=4732"         
CiGFMServer,2.0.0,2016-05-04,00:03:35.666,Debug,HitcountFileContainer.cpp:AddHitcountList(283),,"Add HitCount(CDN2_SBK-CDN2_3[1.255.94.71]). FileName=/data/ftp/pub/hanaro/movie/32050/M320274_1_R160420.ts.pac, HitCount=1, TotalHitCount=4732"         

