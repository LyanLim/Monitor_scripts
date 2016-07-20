#!/bin/sh -x

VSM_HOME=/home/vt_admin/yang/vsm
SCRIPT_HOME=$VSM_HOME/hitcount
DAY_AGO=$1
INSERT_DB_SCRIPT=$SCRIPT_HOME/insert_mysql_db.v2.pl
#PTIME_SCRIPT=$SCRIPT_HOME/parse_and_insert_ptime.v2.pl

TEMP=$SCRIPT_HOME/.temp
LOG_DIR=$SCRIPT_HOME/log

if [ $# -ne 1 ];then
	echo "Usage:$0 [days ago]  ex) $0 1"
	echo "$0 1 means collect 1 day ago log files"
	exit 1
fi

rm -rf $LOG_DIR 2> /dev/null
mkdir -p $LOG_DIR

#for line in `sqlite3 $VSM_HOME/ip.db "select host,dcnip from ip where host like '%GSDM%'"`
#do
#        host=`echo $line | cut -d'|' -f1`
#	ip=`echo $line | cut -d'|' -f2`

for ip in 10.60.67.105 10.60.67.106 10.60.67.198
do

	$SCRIPT_HOME/run_command.sh $ip "find /castis/log/gsdm_log/ -name '*.log' -daystart -mtime $DAY_AGO > /home/vt_admin/gsdm_log.list"
	$SCRIPT_HOME/download_log.sh $ip /home/vt_admin/gsdm_log.list $TEMP

	for file in `cat $TEMP`
	do
		$SCRIPT_HOME/download_log.sh $ip $file $LOG_DIR/`basename $file`.$ip
	done
done

cat $LOG_DIR/* | sed -e "s/^\s*//" | perl -pe 's/,\r?\n/,/' | perl -pe 's/\{\r?\n/\{/' > $TEMP
$INSERT_DB_SCRIPT `date -d"$DAY_AGO day ago" +%F` $TEMP
#$PTIME_SCRIPT `date -d"$DAY_AGO day ago" +%F` $LOG_DIR/*
