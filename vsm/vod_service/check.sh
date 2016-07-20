#!/bin/sh

for ip in `cat hyb_vod_ip`
do

	echo -n "$ip : "
	snmpwalk -v 2c $ip -c ViettelMS1NMS .1.3.6.1.4.1.8072.1.3.2.3.1.1.13.118.111.100.95.98.97.110.100.119.105.100.116.104
	echo -n "$ip : "
	snmpwalk -v 2c $ip -c ViettelMS1NMS .1.3.6.1.4.1.8072.1.3.2.3.1.1.11.118.111.100.95.115.101.115.115.105.111.110
done
