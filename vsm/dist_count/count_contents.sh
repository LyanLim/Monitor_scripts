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
_report=$_SCRIPT_HOME/report/report_dist_count_$begin.csv

echo "DATE,IP,HOST,TSTV,TVOD New,TVOD Total,RVOD New,RVOD Total" > $_report

###########################################################
# OTT
###########################################################

# TSTV
# tstv_count_command="echo -n TSTV:;find /RAM_DISK/ -maxdepth 1 -name '*.m3u8' | egrep ^\/RAM_DISK\/[0-9]*.m3u8 -c"

# TVOD
# tvod_count_command="echo -n TVOD:;find /data1 -maxdepth 1 -name '*.m3u8' -newermt $begin ! -newermt $end | egrep ^/data1/[0-9]{14}_[0-9]*_[0-9]*.m3u8 -c | tr -d '\n';echo -n /;find /data1 -maxdepth 1 -name '*.m3u8' | egrep ^/data1/[0-9]{14}_[0-9]*_[0-9]*.m3u8 -c"

# RVOD
# rvod_count_command="echo -n RVOD:;find /data1 -maxdepth 1 -name '*.m3u8' -newermt $begin ! -newermt $end | egrep ^\/data1\/[0-9]*_[1-5].m3u8 -c | tr -d '\n';echo -n /;find /data1 -maxdepth 1 -name '*.m3u8' | egrep ^\/data1\/[0-9]*_[1-5].m3u8 -c"

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

###########################################################
# Hybrid
###########################################################

# TSTV
tstv_count_command="echo -n TSTV:;find /RAM_DISK/ -maxdepth 1 -name '*.mpg' | egrep ^\/RAM_DISK\/[0-9]*.mpg -c"

# TVOD
tvod_count_command="echo -n TVOD:;find /data1 -maxdepth 1 -name '*.mpg' -newermt $begin ! -newermt $end | egrep ^/data1/[0-9]{14}_[0-9]*_[0-9]*.mpg -c | tr -d '\n' ;echo -n /;find /data1 -maxdepth 1 -name '*.mpg' | egrep ^/data1/[0-9]{14}_[0-9]*_[0-9]*.mpg -c"

# RVOD
rvod_count_command="echo -n RVOD:;find /data1 -maxdepth 1 -type f -newermt $begin ! -newermt $end | egrep ^\/data1\/[0-9]*_[1-5].[mt] -c | tr -d '\n' ;echo -n /;find /data1 -maxdepth 1 -type f | egrep ^\/data1\/[0-9]*_[1-5].[mt] -c"

for line in `cat $_VSM_HOME/ip_list/hybrid_vod`
#for line in 10.73.226.68
do
	host=`echo $line | cut -d, -f1`
	ip=`echo $line | cut -d, -f2`
	$_SCRIPT_HOME/run_command.sh $ip "$tstv_count_command;$tvod_count_command;$rvod_count_command" > $_temp
	dos2unix $_temp
	TSTV=`grep ^TSTV $_temp | cut -d: -f2`
	TVOD_NEW=`grep ^TVOD $_temp | cut -d: -f2 | cut -d'/' -f1`
	TVOD_TOTAL=`grep ^TVOD $_temp | cut -d: -f2 | cut -d'/' -f2`
	RVOD_NEW=`grep ^RVOD $_temp | cut -d: -f2 | cut -d'/' -f1`
	RVOD_TOTAL=`grep ^RVOD $_temp | cut -d: -f2 | cut -d'/' -f2`
	echo "$begin,$ip,$host,$TSTV,$TVOD_NEW,$TVOD_TOTAL,$RVOD_NEW,$RVOD_TOTAL" >> $_report
done 

###########################################################
# Hybrid nPVR
###########################################################

for line in `cat $_VSM_HOME/ip_list/low_vod`
do
	host=`echo $line | cut -d, -f1`
	ip=`echo $line | cut -d, -f2`

	TVOD_NEW=0
	TVOD_TOTAL=0
	RVOD_NEW=0
	RVOD_TOTAL=0

	for data_dir in /DATA01 /DATA02 /DATA03 /DATA04 /DATA05
	do
		# TVOD
		tvod_count_command="echo -n TVOD:;find $data_dir -maxdepth 1 -name '*.mpg' -newermt $begin ! -newermt $end | egrep ^$data_dir/[0-9]{14}_[0-9]*_[0-9]*.mpg -c | tr -d '\n' ;echo -n /;find $data_dir -maxdepth 1 -name '*.mpg' | egrep ^$data_dir/[0-9]{14}_[0-9]*_[0-9]*.mpg -c"

		# RVOD
		rvod_count_command="echo -n RVOD:;find $data_dir -maxdepth 1 -type f -newermt $begin ! -newermt $end | egrep ^$data_dir/[0-9]*_[1-5].[mt] -c | tr -d '\n' ;echo -n /;find $data_dir -maxdepth 1 -type f | egrep ^$data_dir/[0-9]*_[1-5].[mt] -c"
		$_SCRIPT_HOME/run_command.sh $ip "$tvod_count_command;$rvod_count_command" > $_temp
		dos2unix $_temp
		tvod_new=`grep ^TVOD $_temp | cut -d: -f2 | cut -d'/' -f1`
		tvod_total=`grep ^TVOD $_temp | cut -d: -f2 | cut -d'/' -f2`
		rvod_new=`grep ^RVOD $_temp | cut -d: -f2 | cut -d'/' -f1`
		rvod_total=`grep ^RVOD $_temp | cut -d: -f2 | cut -d'/' -f2`

		let "TVOD_NEW=$tvod_new+$TVOD_NEW"
		let "TVOD_TOTAL=$tvod_total+$TVOD_TOTAL"
		let "RVOD_NEW=$rvod_new+$RVOD_NEW"
		let "RVOD_TOTAL=$rvod_total+$RVOD_TOTAL"
	done

	echo "$begin,$ip,$host,0,$TVOD_NEW,$TVOD_TOTAL,$RVOD_NEW,$RVOD_TOTAL" >> $_report
done 


chmod 755 /home/vt_admin/yang/vsm/dist_count/report/*
