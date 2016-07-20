#!/usr/bin/perl

use strict;
use warnings;

use Time::Local;
use DBI;

my $db_file = "/home/vt_admin/yang/vsm/vod_service/vod.db";
my $table_name = "vod_service";

my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file", "", "",
		{ RaiseError => 1, AutoCommit => 1 });

$dbh->do("create table if not exists $table_name (
		serviceip text,
		servernumber integer,
		status integer,
		curbw integer,
		maxbw integer,
		cursession integer,
		maxsession integer,
		datetime text,
		unique(serviceip,datetime)
	)");


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

	#print "$service_ip,$server_num,$status,$cur_bw,$max_bw,$cur_session,$max_session,$datetime\n";
	$dbh->do("insert into $table_name ( serviceip, servernumber, status, curbw, maxbw, cursession, maxsession, datetime )
		values ( \'$service_ip\', $server_num, \'$status\', $cur_bw, $max_bw, $cur_session, $max_session, \'$datetime\' )");

}
$dbh->commit;

__DATA__
18(172.23.56.149)    Running         238M/238M/16G[100%/100%]       35/5333[0%]     4.040T/5.267T[76%]  ,cpu=[2%]
