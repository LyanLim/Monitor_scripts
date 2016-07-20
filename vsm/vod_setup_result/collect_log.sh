#!/bin/sh -x

VSM_HOME=/home/vt_admin/yang/vsm
SCRIPT_HOME=$VSM_HOME/vod_setup_result
INSERT_DB_SCRIPT=$SCRIPT_HOME/insert_mysql_db.pl
DAY_AGO=$1

TEMP=$SCRIPT_HOME/.temp
LOG_DIR=$SCRIPT_HOME/log

if [ $# -ne 1 ];then
	echo "Usage:$0 [days ago]  ex) $0 1"
	echo "$0 1 means collect 1 day ago log files"
	exit 1
fi

rm -rf $LOG_DIR 2> /dev/null
mkdir -p $LOG_DIR

for line in `sqlite3 $VSM_HOME/ip.db "select host,dcnip from ip where systemName = 'LSM' and serviceType = 'Hybrid' and serverNumber = 1"`
#for line in `sqlite3 $VSM_HOME/ip.db "select host,dcnip from ip where systemName = 'LSM' and serviceType = 'OTT' and serverNumber = 1"`
do
        host=`echo $line | cut -d'|' -f1`
	ip=`echo $line | cut -d'|' -f2`

	$SCRIPT_HOME/run_command.sh $ip "find /castis/log/glb_log/ -mindepth 2 -name '*.log' -daystart -mtime $DAY_AGO > /home/vt_admin/glb_log.list"
	$SCRIPT_HOME/download_log.sh $ip /home/vt_admin/glb_log.list $TEMP

	for file in `cat $TEMP`
	do
		$SCRIPT_HOME/download_log.sh $ip $file $LOG_DIR/`basename $file`.$ip
	done
done

$INSERT_DB_SCRIPT `date -d"$DAY_AGO day ago" +%F` $LOG_DIR/*
