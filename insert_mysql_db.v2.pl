#!/usr/bin/perl
#Modify by hellolcs
use strict;
use warnings;

use Time::Local;
use DBI;
use Data::Dumper;

my $log_dir = "/root/hit_analysis/log_hit/20160710";
my $username	= "root";
my $password	= "castis";
my $db		= "skb";
my $host	= "127.0.0.1";
my $port	= "8081";
my $table_name	= "hitcount_sum_0710";
my %hitcount;
my $dbh;
#grant all privileges on *.* to "root"@"175.223.14.112";



# connect to the database
sub create_table {

	$dbh = DBI->connect("DBI:mysql:database=$db;host=$host;port=$port", $username, $password) or die $DBI::errstr;

	$dbh->do("
			CREATE TABLE if not exists $table_name (
				`fileName` VARCHAR(50) NOT NULL,
				`date` DATE NOT NULL,
				`time` TIME NOT NULL,
				`hitCount` INT(10) UNSIGNED NOT NULL
			)
		");
}

# parser
sub parser_with_server {
	open FD, $_[0];
	my $period = $_[1];
	
	my $current_hour = "00";
	my $current_min = "00";
	while(<FD>){
		        if ( m/AddHitcountList/ ){
	                my ( $date, $hour, $min, $tmp_hostname, $tmp_filename, $hit ) = (split /[,:=]/ , $_)[2,3,4,10,11,13];
	                my ( $hostname, $hostip ) = (split /[()\[\]]/ , $tmp_hostname)[1,2];
	                my $filename = (split /\// , $tmp_filename)[-1];
		
			#check hour	
			if ( $current_hour < $hour ){
				if ( $hour > 10 ){
					$current_hour = $hour;
				}else{

					$current_hour = substr $hour, -1;
					if ( $current_hour < 10  ){
						$current_hour = "0".$current_hour;
					}
				}
			}	
			
			#check minute
			if ( $current_min+$period <= $min ){
				if ( $current_min+$period < 60 ){

					$current_min +=$period;
					if ( $current_min < 10  ){
						$current_min = "0".$current_min;
					}
				}else{

					$current_hour += 1;
					if ( $current_hour < 10  ){
						$current_hour = "0".$current_hour;
					}

					$current_min = $current_min+$period-60;
					if ( $current_min < 10  ){
						$current_min = "0".$current_min;
					}
					
				}
			}



	                my $time = "$current_hour:$current_min:00";
				
	                $hitcount{$filename}{date} = $date;
	                $hitcount{$filename}{time}{$time} += $hit;
	                $hitcount{$filename}{hostname} = $hostname;
	                $hitcount{$filename}{hostip} = $hostip;
	        }
	
	}
}

sub parser_no_server {
	open FD, $_[0];
	my $period = $_[1];
	
	my $current_hour = "00";
	my $current_min = "00";
	while(<FD>){
		        if ( m/AddHitcountList/ ){
	                my ( $date, $hour, $min, $tmp_hostname, $tmp_filename, $hit ) = (split /[,:=]/ , $_)[2,3,4,10,11,13];
	                my ( $hostname, $hostip ) = (split /[()\[\]]/ , $tmp_hostname)[1,2];
	                my $filename = (split /\// , $tmp_filename)[-1];
		
			#check hour	
			if ( $current_hour < $hour ){
				if ( $hour > 10 ){
					$current_hour = $hour;
				}else{

					$current_hour = substr $hour, -1;
					if ( $current_hour < 10  ){
						$current_hour = "0".$current_hour;
					}
				}
			}	
			
			#check minute
			if ( $current_min+$period <= $min ){
				if ( $current_min+$period < 60 ){

					$current_min +=$period;
					if ( $current_min < 10  ){
						$current_min = "0".$current_min;
					}
				}else{

					$current_hour += 1;
					if ( $current_hour < 10  ){
						$current_hour = "0".$current_hour;
					}

					$current_min = $current_min+$period-60;
					if ( $current_min < 10  ){
						$current_min = "0".$current_min;
					}
					
				}
			}



	                my $time = "$current_hour:$current_min:00";
				
	                $hitcount{$filename}{date} = $date;
	                $hitcount{$filename}{time}{$time} += $hit;
	        }
	
	}
}

sub insert_db {
	$dbh->begin_work;
	
	foreach my $filename ( keys %hitcount ) {
	        foreach my $time ( keys %{ $hitcount{$filename}{time} } ){
			$dbh->do("insert into $table_name ( fileName, date, time, hitCount )
	                	values ( \'$filename\', \'$hitcount{$filename}{date}\', \'$time\', \'$hitcount{$filename}{time}{$time}\')");
	        }
	}
	$dbh->commit;
}

my $cnt = 0;
opendir(DIR, $log_dir) or die $!;

while (my $file = readdir(DIR)) {

	next if ($file =~ m/^\./);
	
	$cnt++;
	parser_no_server($log_dir."/".$file, $ARGV[0]);
	print "$cnt :: fihished $log_dir\"/$file\n";
	#print "\n".$hitcount{"T321175_18_160710.ts.pac"}{time}."\n";
#	print Dumper \%$hitcount{"T321175_18_160710.ts.pac"}{time};



}

closedir(DIR);

print Dumper \%hitcount;


#create_table();
insert_db();
