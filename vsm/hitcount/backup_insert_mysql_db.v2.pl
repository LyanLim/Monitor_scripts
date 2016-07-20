#!/usr/bin/perl
use strict;
use warnings;

use Time::Local;
use DBI;
use Data::Dumper;

my $username	= "root";
my $password	= "castis";
my $db		= "skb";
my $host	= "127.0.0.1";
my $port	= "8081";
my $table_name	= "hitcount_sum";
my %hitcount;
#grant all privileges on *.* to "root"@"175.223.14.112";

# connect to the database
my $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $username, $password) or die $DBI::errstr;

$dbh->do("
		CREATE TABLE if not exists $table_name (
			`fileName` VARCHAR(50) NOT NULL,
			`date` DATE NOT NULL,
			`time` TIME NOT NULL,
			`hitCount` INT(10) UNSIGNED NOT NULL,
			`hostname` VARCHAR(50) NOT NULL,
			`hostip` VARCHAR(50) NOT NULL
		)
	");

# parser
sub parser {
	open FD, $_[0];
	$period = $_[1];

	while(<FD>){
		        if ( m/AddHitcountList/ ){
	                my ( $date, $hour, $min, $tmp_hostname, $tmp_filename, $hit ) = (split /[,:=]/ , $_)[2,3,4,10,11,13];
	                my ( $hostname, $hostip ) = (split /[()\[\]]/ , $tmp_hostname)[1,2];
	                my $filename = (split /\// , $tmp_filename)[-1];
	                my $time = "$hour:$min:00";
	
	                $hitcount{$filename}{date} = $date;
	                $hitcount{$filename}{time}{$time} += $hit;
	                $hitcount{$filename}{hostname} = $hostname;
	                $hitcount{$filename}{hostip} = $hostip;
	        }
	
	}
}

#batch db
sub insert_db {
	$dbh->begin_work;
	
	foreach my $filename ( keys %hitcount ) {
	        foreach my $time ( keys %{ $hitcount{$filename}{time} } ){
			$dbh->do("insert into $table_name ( fileName, date, time, hitCount, hostname, hostip )
	                	values ( \'$filename\', \'$hitcount{$filename}{date}\', \'$time\', \'$hitcount{$filename}{time}{$time}\', \'$hitcount{$filename}{hostname}\', \'$hitcount{$filename}{hostip}\')");
	        }
	}
	$dbh->commit;
}


parser($ARGV[0], $ARGV[1]);
insert_db();
