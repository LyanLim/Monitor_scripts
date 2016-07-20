#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

my %file_list;
my $html_file = "/castis/bin/CiVSMAdmin/vod_mon/VOD.html";

# DB
open FD, shift;
<FD>;
while(<FD>){
	#channelid	eventid	filename	begindatetime	enddatetime	expiredatetime	tvodtransactionid	tvodfilesize	tvodstatus
	#80	7428	20150728130000_80_7428.mpg	2015-07-28 13:00:00	2015-07-28 13:30:00	2015-08-05 13:00:00	20150728125013270780	-1	PROCESSING
	chomp;
	my ($channelid, $eventid, $filename, $begin, $end, $expire, $trID, $filesize, $status) = split /\t/;
	$file_list{$filename}{channelid} = $channelid;
	$file_list{$filename}{eventid} = $eventid;
	$file_list{$filename}{begin} = $begin;
	$file_list{$filename}{end} = $end;
	$file_list{$filename}{expire} = $expire;
	$file_list{$filename}{trID} = $trID;
	$file_list{$filename}{filesize} = $filesize;
	$file_list{$filename}{status} = $status;

}
close FD;

# Fail Count
open FD, shift;
while(<FD>){
	# 20150728130000_80_7428.mpg 1
	chomp;
	my ($filename, $failcount) = split / /;

	if ( exists $file_list{$filename} ){
		$file_list{$filename}{failcount} = $failcount;
	}else{
		$file_list{$filename}{failcount} = $failcount;
		$file_list{$filename}{channelid} = 'NULL';
		$file_list{$filename}{eventid} = 'NULL';
		$file_list{$filename}{begin} = 'NULL';
		$file_list{$filename}{end} = 'NULL';
		$file_list{$filename}{expire} = 'NULL';
		$file_list{$filename}{trID} = 'NULL';
		$file_list{$filename}{filesize} = 'NULL';
		$file_list{$filename}{status} = 'NULL';
	}

}
close FD;

open FD, ">$html_file";
while(<DATA>){
	last if m/^DATA/;
	if ( m/^HEAD/ ){
		my $time = scalar(localtime);
		print FD "<h1>The Number of VOD Setup Fail : $time </h1>\n";
		next;
	}
	print FD;
}


foreach my $filename ( sort { $file_list{$b}{failcount} <=> $file_list{$a}{failcount} } keys %file_list ){

	print FD "<tr>\n";
	my $string = 
	"<td>$filename</td>" .
	"<td>$file_list{$filename}{failcount}</td>" .
	"<td>$file_list{$filename}{begin}</td>" .
	"<td>$file_list{$filename}{end}</td>" .
	"<td>$file_list{$filename}{status}</td>" .
	"<td>$file_list{$filename}{filesize}</td>" .
	"<td>$file_list{$filename}{trID}</td>";
	#"<td>$file_list{$filename}{channelid}</td>" .
	#"<td>$file_list{$filename}{eventid}</td>" .
	#"<td>$file_list{$filename}{expire}</td>";
	print FD "$string\n";
	print FD "</tr>\n";

}

while(<DATA>){
	print FD;
}
close FD;
__DATA__
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- The above 3 meta tags *must* come first in the head; any other head content must come *after* these tags -->
    <title>Bootstrap 101 Template</title>
    <!-- Bootstrap -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
      <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
      <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
    <![endif]-->
  </head>
  <body>
HEAD    <h1>VOD Setup Fail File Information</h1>
      <table class="table">
          <thead>
              <tr>
                  <th>FileName</th>
                  <th>FailCount</th>
                  <th>StartTime</th>
                  <th>EndTime</th>
                  <th>Status</th>
                  <th>FileSize</th>
                  <th>TRID</th>
              </tr>
DATA
    <!-- jQuery (necessary for Bootstrap's JavaScript plugins) -->
    <!-- <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.3/jquery.min.js"></script> -->
    <script src="js/jquery.min.js"></script>
    <!-- Include all compiled plugins (below), or include individual files as needed -->
    <script src="js/bootstrap.min.js"></script>
  </body>
</html>
