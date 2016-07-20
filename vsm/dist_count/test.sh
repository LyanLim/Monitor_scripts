#!/bin/sh

_VSM_HOME=/home/vt_admin/yang/vsm
_SCRIPT_HOME=$_VSM_HOME/dist_count

_temp=$_SCRIPT_HOME/.temp

if [ $# -eq 0 ];then
        begin=`date +%F -d"1 day ago"`
elif [ $# -eq 1 ];then
        begin=$1
else
        echo "Usage:$0 [YYYY-MM-DD]    ex) $0 2015-06-30"
        exit 1
fi

end=`date -d"$begin 1day" +%Y-%m-%d`
_report=$_SCRIPT_HOME/test.report_$begin.csv

for line in `cat $_VSM_HOME/ip_list/ott_vod`
do
	host=`echo $line | cut -d, -f1`
	ip=`echo $line | cut -d, -f2`
	rm $_temp
	log_file_name=/home/vt_admin/log/`echo $begin | cut -d'-' -f1-2`/${begin}_CC.log
	$_SCRIPT_HOME/download_log.sh $ip "$log_file_name" $_temp
	TSTV=`grep ^TSTV $_temp | cut -d: -f2`
	TVOD_NEW=`grep ^TVOD $_temp | cut -d: -f2 | cut -d'/' -f1`
	TVOD_TOTAL=`grep ^TVOD $_temp | cut -d: -f2 | cut -d'/' -f2`
	RVOD_NEW=`grep ^RVOD $_temp | cut -d: -f2 | cut -d'/' -f1`
	RVOD_TOTAL=`grep ^RVOD $_temp | cut -d: -f2 | cut -d'/' -f2`
	echo "$begin,$ip,$host,$TSTV,$TVOD_NEW,$TVOD_TOTAL,$RVOD_NEW,$RVOD_TOTAL" >> $_report
done 
