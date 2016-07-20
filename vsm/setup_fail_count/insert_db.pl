#!/usr/bin/perl

use strict;
use warnings;

use DBI;

my ($parsing_log_type, $region);
my %log_type = ( "OTT" => 1, "HYB" => 1 );

my $username	= "root";
my $password	= "castis";
my $db		= "cdnm";
my $host	= "10.60.67.200";
my $port	= "3306";
my $raw_table	= "setup_fail";
my $note_table	= "setup_fail_detail";

my $dbh;

$parsing_log_type = shift;
$region = shift;

die "Usage:$0 [Log Type] [RegionID] [File to parse]" if not exists $log_type{$parsing_log_type};

sub parse_and_insert_ott_log {

	# OTT Log
	# CiGLBServer,2.4.0,2015-07-31,08:41:02.627,Information,SLPClientThread.cpp:OnRetrieveBandwidthResponse(860),,"OnRetrieveBandwidthResponse : 6f9e7bd9-3df4-46bc-a04c-cbb9981a7a87, c6330e26-f62f-455a-acc9-2e8825bf0993, 0, 17.m3u8, 0, result is file not found, LB[172.23.57.6, 172.23.57.6], ClientIP[58.140.91.9]"

	open FD, shift;
	while(<FD>){
		my ($day,$time,$filename) = (split /,/)[2,3,10];
		m/ClientIP\[([0-9\.]+)\]/;
		my $clientIP = $1;
		my $serviceType;

		if ( $filename =~ m/^\s([0-9]+\.m3u8)$/ ){
			$serviceType='TSTV';
			$filename = $1;

		}elsif ( $filename =~ m/^\s([0-9]{14}_[0-9]+_[0-9]+\.m3u8$)/ ){
			$serviceType='TVOD';
			$filename = $1;

		}elsif ( $filename =~ m/^\s([0-9]+_[0-9]\.m3u8)$/ ){
			$serviceType='RVOD';
			$filename = $1;

		}else{
			next;
		}
		$dbh->do("insert ignore into $raw_table ( fileName, occuredTime, serviceType, deviceType, clientIP, region )
			values ( \'$filename\', \'$day $time\', \'$serviceType\', 'OTT', \'$clientIP\', \'$region\' )");
		$dbh->do("insert ignore into $note_table ( fileName ) values ( \'$filename\' )");
	}
	close FD;
}

sub parse_and_insert_hyb_log {

	# Hybrid Log
	# CiGLBServer,2.4.0,2015-08-04,00:03:10.012,Information,SLPClientThread.cpp:OnDescribeResponse(734),,"OnDescribeResponse, LB[172.23.58.6, 172.23.58.6], AssetID[20150803220000_152_2844.mpg], result[result is file not found], Client[10.15.68.6]"

	open FD, shift;
	while(my $line = <FD>){

		my ($day,$time) = (split /,/, $line)[2,3];

		$line =~ m/AssetID\[([0-9\._a-zA-Z]+)\]/;
		my $filename = $1;

		$line =~ m/Client\[([0-9\.]+)\]/;
		my $clientIP = $1;
		my $serviceType;

		if ( $filename =~ m/^([0-9]+\.[a-zA-Z]+)$/ ){
			$serviceType='TSTV';

		}elsif ( $filename =~ m/^([0-9]{14}_[0-9]+_[0-9]+\.[a-zA-Z]+$)/ ){
			$serviceType='TVOD';

		}elsif ( $filename =~ m/^([0-9]+_[0-9]\.[a-zA-Z]+)$/ ){
			$serviceType='RVOD';

		}else{
			next;
		}
		$dbh->do("insert ignore into $raw_table ( fileName, occuredTime, serviceType, deviceType, clientIP, region )
			values ( \'$filename\', \'$day $time\', \'$serviceType\', 'STB', \'$clientIP\', \'$region\' )");
		$dbh->do("insert ignore into $note_table ( fileName ) values ( \'$filename\' )");
	}
	close FD;
}


# connect to the database
$dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $username, $password) or die $DBI::errstr;

$dbh->do("
		CREATE TABLE if not exists $raw_table (
			`fileName` CHAR(40) NULL DEFAULT NULL,
			`occuredTime` DATETIME(3) NULL DEFAULT NULL,
			`serviceType` CHAR(5) NULL DEFAULT NULL,
			`deviceType` CHAR(5) NULL DEFAULT NULL,
			`clientIP` VARCHAR(15) NULL DEFAULT NULL,
			`region` CHAR(5) NULL DEFAULT NULL,
			UNIQUE INDEX `PreventDuplicateInsert` (`fileName`, `occuredTime`, `clientIP`)
			)
	");





$dbh->begin_work;
if ( $parsing_log_type eq "OTT" ){
	parse_and_insert_ott_log(shift);
}elsif ( $parsing_log_type eq "HYB" ){
	parse_and_insert_hyb_log(shift);
}else{
}
$dbh->commit;
