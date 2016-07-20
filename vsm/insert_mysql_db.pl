#!/usr/bin/perl

use strict;
use warnings;

use Time::Local;
use DBI;

my $username	= "root";
my $password	= "castis";
my $db		= "cdnm";
my $host	= "10.60.67.200";
my $port	= "3306";
my $table_name	= "trung_test";


my $date = shift;

# connect to the database
my $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $username, $password) or die $DBI::errstr;

$dbh->do("
		CREATE TABLE if not exists $table_name (
			`fileName` VARCHAR(50) NOT NULL,
			`requestCount` INT(10) UNSIGNED NOT NULL,
			`date` DATE NOT NULL
		)
	");



$dbh->begin_work;

$dbh->do("insert into $table_name ( fileName, requestCount, date ) values ( \'$filename\', $hitcount{$filename}, \'$date\' )");
$dbh->do("insert into $table_name ( fileName, requestCount, date ) values ( \'$filename\', $hitcount{$filename}, \'$date\' )");
$dbh->do("insert into $table_name ( fileName, requestCount, date ) values ( \'$filename\', $hitcount{$filename}, \'$date\' )");
$dbh->do("insert into $table_name ( fileName, requestCount, date ) values ( \'$filename\', $hitcount{$filename}, \'$date\' )");
$dbh->do("insert into $table_name ( fileName, requestCount, date ) values ( \'$filename\', $hitcount{$filename}, \'$date\' )");
$dbh->do("insert into $table_name ( fileName, requestCount, date ) values ( \'$filename\', $hitcount{$filename}, \'$date\' )");

$dbh->commit;
