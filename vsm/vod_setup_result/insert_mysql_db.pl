#!/usr/bin/perl

use strict;
use warnings;

use Time::Local;
use DBI;
use Data::Dumper;

my $username	= "root";
my $password	= "castis";
my $db		= "cdnm";
my $host	= "10.60.67.200";
my $port	= "3306";
my $table_name	= "vod_setup_result";
my %hitcount;
my %service_type;
my %device_type;


my $date = shift;

# connect to the database
my $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $username, $password) or die $DBI::errstr;

$dbh->do("
		CREATE TABLE if not exists $table_name (
			`lsmIP` VARCHAR(15) NOT NULL,
			`fileName` VARCHAR(50) NOT NULL,
			`setupResult` TINYINT(3) UNSIGNED NOT NULL,
			`setupCount` MEDIUMINT(8) UNSIGNED NOT NULL,
			`deviceType` VARCHAR(10) NOT NULL,
			`date` VARCHAR(10) NOT NULL
		)
	");

my %vod_setup;

while(<ARGV>){

	if ( m/OnDescribeResponse/ ){

		my ($lsm_ip, $file_name, $result) = (split /[,\[\]]/)[9,13,16];

		if ( $result =~ m/success/ ){
			$vod_setup{$lsm_ip}{$file_name}{1}++;
		}elsif ( $result =~ m/file not found/ ){
			$vod_setup{$lsm_ip}{$file_name}{0}++;
		}elsif ( $result =~ m/max/ ){
			$vod_setup{$lsm_ip}{$file_name}{0}++;
		}else{
			print "Unknown result : $result\n";
		}
	}
}

$dbh->begin_work;
foreach my $lsm_ip ( keys %vod_setup ){
	foreach my $file_name ( keys %{$vod_setup{$lsm_ip}} ){

		foreach my $result ( keys %{ $vod_setup{$lsm_ip}{$file_name} } ){

			#print "$lsm_ip   $file_name   $result   $vod_setup{$lsm_ip}{$file_name}{$result}\n";

			$dbh->do("insert into $table_name ( lsmIP, fileName, setupResult, setupCount, deviceType, date )
					values ( \'$lsm_ip\', \'$file_name\', $result, \'$vod_setup{$lsm_ip}{$file_name}{$result}\', \'HYB\', \'$date\' )");
		}

	}
}
$dbh->commit;
