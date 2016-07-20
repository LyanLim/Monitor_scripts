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
my $table_name	= "gsdm_ptime";


my $date = shift;

exit 1 if not $date =~ m/^\d\d\d\d-\d\d-\d\d$/;

my %ptime_data;


# connect to the database
my $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $username, $password) or die $DBI::errstr;

$dbh->do("
		CREATE TABLE if not exists $table_name (
			`processingTime` INT(8) UNSIGNED NOT NULL,
			`count` INT(11) UNSIGNED NOT NULL,
			`date` DATE NOT NULL,
			UNIQUE INDEX `Unique` (`processingTime`, `date`)
		)
	");


while(<ARGV>){

	 #processed time =>19(ms)
	if ( m/Response sended:.* SpendTime:([0-9]+)ms$/ ){
		$ptime_data{$1}++;
	}
}

$dbh->begin_work;
foreach my $ptime ( keys %ptime_data ){

	$dbh->do("INSERT IGNORE INTO $table_name ( processingTime, count, date )
			values ( \'$ptime\', $ptime_data{$ptime}, \'$date\' )");
}
$dbh->commit;
