#!/bin/sh

VSM_HOME=/home/vt_admin/yang/vsm
SCRIPT_HOME=$VSM_HOME/disk
TEMP=$SCRIPT_HOME/.temp

rm $TEMP 2> /dev/null
for line in `cat /home/vt_admin/yang/vsm/ip_list/center_hyb_vod /home/vt_admin/yang/vsm/ip_list/ott_vod`
do
	host=`echo $line | cut -d, -f1`
	ip=`echo $line | cut -d, -f2`
	$SCRIPT_HOME/get_disk_used.pl $host $ip >> $TEMP
done
$SCRIPT_HOME/insert_db.pl $TEMP
