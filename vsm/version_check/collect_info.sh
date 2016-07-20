#!/bin/sh

_VSM_HOME=/home/vt_admin/yang/vsm
_SCRIPT_HOME=$_VSM_HOME/version_check

_temp=$_SCRIPT_HOME/.temp
_result=$_SCRIPT_HOME/result

rm $_result 2>/dev/null


for row in `sqlite3 $_VSM_HOME/ip.db "select host,dcnip from ip where systemName='LSM';"`
do
	host=`echo $row | cut -d'|' -f1`
	ip=`echo $row | cut -d'|' -f2`
	$_SCRIPT_HOME/run_command.sh $ip "ls -l /castis/bin/CiLFMServer/CiLFMServer" > $_temp
	dos2unix $_temp
	echo "$host $ip `grep ^l $_temp`" >> $_result
done
