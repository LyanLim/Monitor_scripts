#!/bin/sh

VSM_HOME=/home/vt_admin/yang/vsm
SCRIPT_HOME=$VSM_HOME/vod_service

start_datetime=`date +%F.%H_%M_%S`
temp_file=$SCRIPT_HOME/temp

time=`date +%F-%H-%M-%S`

echo "Checked Time|`date \"+%F %T\"`" > $temp_file
for line in `sqlite3 $VSM_HOME/ip.db "select host,dcnip from ip where systemname='LSM' and servernumber=1"`
#for line in PDL_CV1_LSM_01,10.59.54.4 NTH_CV5_LSM_01,10.41.16.4
do
	host=`echo $line | cut -d'|' -f1`
	ip=`echo $line | cut -d'|' -f2`
	#host=`echo $line | cut -d',' -f1`
	#ip=`echo $line | cut -d',' -f2`
	/home/vt_admin/bin/LBAdmin_64 $ip 18888 all status >> $temp_file
done

grep -v Status $temp_file | grep -v LoadBala | grep -v ^$ > $temp_file.1
$SCRIPT_HOME/insert_mysql_db.pl $temp_file.1
