#!/bin/sh

VSM_HOME=/home/vt_admin/yang/vsm
SCRIPT_HOME=$VSM_HOME/setup_fail_count
INSERT_DB_SCRIPT=$SCRIPT_HOME/insert_db.pl


TEMP=$SCRIPT_HOME/.temp
LOG_DIR=$SCRIPT_HOME/downloaded_log

[ -d $LOG_DIR ] || mkdir -p $LOG_DIR


###########################################################
# OTT
###########################################################
for line in `cat $VSM_HOME/ip_list/lsm_ott_active`
do
	host=`echo $line | cut -d, -f1`
	ip=`echo $line | cut -d, -f2`
	region=`echo $host | cut -d'_' -f1`

	$SCRIPT_HOME/run_command.sh $ip 'find /castis/log/glb_log/ -name "*_CiGLBServer.log" -mmin -20' | egrep ^/castis | tr '\r\n' ' ' > $TEMP

	rm $LOG_DIR/*
	for file in `cat $TEMP`
	do
		$SCRIPT_HOME/download_log.sh $ip $file $LOG_DIR
	done

	grep -h OnRetrieveBandwidthResponse $LOG_DIR/* | grep -v 'result is success' > $TEMP
	$INSERT_DB_SCRIPT OTT $region $TEMP
done



###########################################################
# Hybrid
###########################################################

#HLC nPVR 172.23.58.6
#HKH nPVR 172.23.66.6
#HHT nPVR 172.23.74.6

for line in `cat $VSM_HOME/ip_list/lsm_cv_active`
do
	host=`echo $line | cut -d, -f1`
	ip=`echo $line | cut -d, -f2`
	region=`echo $host | cut -d'_' -f2`

	if [ `echo $host | grep CV[1-3] -c` -eq 1 ];then
		nPVR_LSM_IP=172.23.58.6

	elif [ `echo $host | grep CV[56] -c` -eq 1 ];then
		nPVR_LSM_IP=172.23.66.6

	elif [ `echo $host | grep CV[7-9] -c` -eq 1 ];then
		nPVR_LSM_IP=172.23.74.6
	else
		continue
	fi

	$SCRIPT_HOME/run_command.sh $ip 'find /castis/log/glb_log/ -name "*_CiGLBServer.log" -mmin -20' | egrep ^/castis | tr '\r\n' ' ' > $TEMP

	rm $LOG_DIR/*
	for file in `cat $TEMP`
	do
		$SCRIPT_HOME/download_log.sh $ip $file $LOG_DIR
	done

	grep -h OnDescribeResponse $LOG_DIR/* | grep -v 'result is success' | grep $nPVR_LSM_IP > $TEMP
	$INSERT_DB_SCRIPT HYB $region $TEMP
done 
