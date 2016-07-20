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
my $table_name	= "hitcount";
my %hitcount;
my %service_type;
my %device_type;


my $date = shift;

# connect to the database
my $dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $username, $password) or die $DBI::errstr;

$dbh->do("
		CREATE TABLE if not exists $table_name (
			`fileName` VARCHAR(50) NOT NULL,
			`hitCount` INT(10) UNSIGNED NOT NULL,
			`date` DATE NOT NULL,
			`regionID` VARCHAR(10) NOT NULL,
			`serviceType` CHAR(10) NOT NULL,
			`deviceType` VARCHAR(8) NOT NULL
		)
	");


while(<ARGV>){

	if ( m/SDP Request/ ){

		if ( m/\&/ ){
			print "$_ matched \$\n";
			next;
		}

		my ($string, $json) = (split /[{}]/)[0,1];

		#my $time = substr (  ((split / /, $string)[1]), 0, 8 );
		$json =~ s/"//g;
		$json =~ s/ : /:/g;

		chomp $json;
		my @arr = split /,/ , $json;
		my %hash;


		foreach my $data ( @arr ){
			my ($key, $value) = split /:/ , $data;
			$hash{$key} = $value;
		}

		$hitcount{  $hash{filename}   }{   $hash{regionId}   }++;
		
		if ( $hash{filename} =~ m/^[0-9]+\./ ){
			$service_type{ $hash{filename} } = 'TSTV';

			if ( $hash{filename} =~ m/mpg$/ ){
				$device_type{ $hash{filename} } = 'STB';

			}elsif( $hash{filename} =~ m/m3u8$/ ){
				$device_type{ $hash{filename} } = 'OTT';
			}else{
				$device_type{ $hash{filename} } = 'Invalid';
			}

		}elsif ( $hash{filename} =~ m/^[0-9]{14}_[0-9]+_[0-9]+\./ ){
			$service_type{ $hash{filename} } = 'TVOD';
			
			if ( $hash{filename} =~ m/mpg$/ ){
				$device_type{ $hash{filename} } = 'STB';

			}elsif( $hash{filename} =~ m/m3u8$/ ){
				$device_type{ $hash{filename} } = 'OTT';
			}else{
				$device_type{ $hash{filename} } = 'Invalid';
			}

		}elsif ( $hash{filename} =~ m/^[0-9]+_[0-9]\./ ){
			$service_type{ $hash{filename} } = 'RVOD';

			if ( $hash{filename} =~ m/[tT][sS]$/ or $hash{filename} =~ m/[mM][pP][gG]/ ){
				$device_type{ $hash{filename} } = 'STB';

			}elsif( $hash{filename} =~ m/m3u8$/ ){
				$device_type{ $hash{filename} } = 'OTT';
			}else{
				$device_type{ $hash{filename} } = 'Invalid';
			}

		}else{
			$service_type{ $hash{filename} } = 'Invalid';

			if ( $hash{filename} =~ m/mpg$/ ){
				$device_type{ $hash{filename} } = 'STB';

			}elsif( $hash{filename} =~ m/m3u8$/ ){
				$device_type{ $hash{filename} } = 'OTT';
			}else{
				$device_type{ $hash{filename} } = 'Invalid';
			}
		}
	}
}

$dbh->begin_work;
foreach my $filename ( keys %hitcount ){

	foreach my $regionID ( keys %{ $hitcount{$filename} } ){

		$dbh->do("insert into $table_name ( fileName, hitCount, date, regionID, serviceType, deviceType )
				values ( \'$filename\', $hitcount{$filename}{$regionID}, \'$date\', \'$regionID\', \'$service_type{$filename}\', \'$device_type{$filename}\' )");
	}
}
$dbh->commit;
