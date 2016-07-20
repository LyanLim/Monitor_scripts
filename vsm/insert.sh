#!/bin/sh

for line in `cat ip_list/all`
do
	host=`echo $line | cut -d, -f1`
	ip=`echo $line | cut -d, -f2`

	echo $host,$ip
	sqlite3 ip.db "INSERT INTO ip (host,dcn_ip) VALUES ( \"$host\",\"$ip\");"

done
