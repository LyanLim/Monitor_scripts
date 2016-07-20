#!/usr/bin/perl

use strict;
use warnings;

use DBI;

my $username	= "root";
my $password	= "castis";
my $db		= "cdnm";
my $host	= "10.60.67.200";
my $port	= "3306";
my $raw_table	= "disk";

my $dbh;

sub parse_and_insert_disk_log {

	# Disk Log
	# HHT-OTT-VOD-05,10.73.226.140,/RAM_DISK,223338299392,6533144576
	# HHT-OTT-VOD-05,10.73.226.140,/var,21146652672,1388240896
	# HHT-OTT-VOD-05,10.73.226.140,/data1,23977850306560,13494651715584
	# HHT-OTT-VOD-05,10.73.226.140,/castis,167461437440,13765689344
	# HHT-OTT-VOD-05,10.73.226.140,/,105694126080,4914073600

	open FD, shift;
	while(<FD>){
		chomp;
		my ($host,$ip,$partition_name,$total_size,$used_size) = split /,/;

		$dbh->do("insert ignore into $raw_table ( host, ip, partitionName, totalSize, usedSize )
			values ( \'$host\', \'$ip\', \'$partition_name\', $total_size, $used_size )");
	}
	close FD;
}


# connect to the database
$dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $username, $password) or die $DBI::errstr;

$dbh->do("
		CREATE TABLE if not exists $raw_table (
			`host` VARCHAR(64) NULL DEFAULT NULL,
			`ip` VARCHAR(15) NULL DEFAULT NULL,
			`partitionName` VARCHAR(50) NULL DEFAULT NULL,
			`totalSize` BIGINT(20) NULL DEFAULT NULL,
			`usedSize` BIGINT(20) NULL DEFAULT NULL,
			`checkedTime` DATETIME NULL DEFAULT CURRENT_TIMESTAMP
			)
	");


$dbh->begin_work;
parse_and_insert_disk_log(shift);
$dbh->commit;
