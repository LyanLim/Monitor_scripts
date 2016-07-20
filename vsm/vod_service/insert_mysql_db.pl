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
my $table_name	= "vod_service";

my %region_code = (
	"172.23.56" => "HYB-HLC",
	"172.23.64" => "HYB-HKH",
	"172.23.72" => "HYB-HHT",
	"172.23.58" => "HYB-HLC-NPVR",
	"172.23.66" => "HYB-HLC-NPVR",
	"172.23.74" => "HYB-HLC-NPVR",
	"172.23.80" => "HYB-CV1",
	"172.23.84" => "HYB-CV2",
	"172.23.86" => "HYB-CV3",
	"172.23.90" => "HYB-CV5",
	"172.23.92" => "HYB-CV6",
	"172.23.94" => "HYB-CV7",
	"172.23.96" => "HYB-CV8",
	"172.23.98" => "HYB-CV9",
	"27.67.50" => "OTT-HLC",
	"27.67.64" => "OTT-HKH",
	"27.67.80" => "OTT-HHT"
);


# connect to the database
my $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $username, $password) or die $DBI::errstr;

$dbh->do("
		CREATE TABLE if not exists $table_name (
			`serviceip` VARCHAR(15) NULL DEFAULT NULL,
			`servernumber` TINYINT(4) NULL DEFAULT NULL,
			`status` TINYTEXT NULL,
			`curbw` INT(11) NULL DEFAULT NULL,
			`maxbw` INT(11) NULL DEFAULT NULL,
			`cursession` SMALLINT(6) NULL DEFAULT NULL,
			`maxsession` SMALLINT(6) NULL DEFAULT NULL,
			`datetime` DATETIME NULL DEFAULT NULL,
			`region` VARCHAR(15) NULL DEFAULT NULL,
			UNIQUE INDEX `data` (`serviceip`, `datetime`)
			)
	");


open FD , shift;

my $datetime = (split /\|/, <FD>)[1];
chomp $datetime;

$dbh->begin_work;
while(<FD>){
	m/^(\d+)\((\d+\.\d+.\d+.\d+)\)\s+(\w+)\s+([a-zA-Z0-9]+)\/([a-zA-Z0-9]+)\/([a-zA-Z0-9]+)\[\d+\%\/\d+\%\]\s+ (\d+)\/(\d+)\[\d+\%\]\s+/;

	my $server_num	= $1;
	my $service_ip	= $2;
	my $status	= $3;
	my $cur_bw	= $4;
	my $max_bw	= $6;
	my $cur_session	= $7;
	my $max_session	= $8;

	$cur_bw =~ m/(\d+)([a-zA-Z])/;
	if ( $2 eq "M" ){
		$cur_bw = $1;
	}elsif ( $2 eq "G" ){
		$cur_bw = $1 * 1000;
	}else{
	}

	$max_bw =~ m/(\d+)([a-zA-Z])/;
	if ( $2 eq "M" ){
		$max_bw = $1;
	}elsif ( $2 eq "G" ){
		$max_bw = $1 * 1000;
	}else{
	}

	my $ip_class = join "." , (split /\./ , $service_ip)[0,1,2];
	my $region = $region_code{$ip_class};
	#print "$service_ip,$server_num,$status,$cur_bw,$max_bw,$cur_session,$max_session,$datetime\n";
	$dbh->do("insert ignore into $table_name ( serviceip, servernumber, status, curbw, maxbw, cursession, maxsession, datetime, region )
		values ( \'$service_ip\', $server_num, \'$status\', $cur_bw, $max_bw, $cur_session, $max_session, \'$datetime\', \'$region\' )");

}
$dbh->commit;

__DATA__
18(172.23.56.149)    Running         238M/238M/16G[100%/100%]       35/5333[0%]     4.040T/5.267T[76%]  ,cpu=[2%]
