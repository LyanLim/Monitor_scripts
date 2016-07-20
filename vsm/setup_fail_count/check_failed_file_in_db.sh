#!/bin/sh

_VSM_HOME=/home/vt_admin/yang/vsm
_SCRIPT_HOME=$_VSM_HOME/setup_fail_count

FILE_LIST=$_SCRIPT_HOME/file_list
SQL_FILE=$_SCRIPT_HOME/sql
DB_RESULT=$_SCRIPT_HOME/db_list

if [ $# -ne 1 ];then
	echo "Usage:$0 [2015-08-02]"
	exit 1
fi

sort $_SCRIPT_HOME/`echo $1 | cut -d'-' -f1-2`/$1/* | uniq -c | awk '{print $2,$1}' > $FILE_LIST

echo "select channelid,eventid,filename,begindatetime,enddatetime,expiredatetime,tvodtransactionid,tvodfilesize,tvodstatus" > $SQL_FILE
echo "from assetinstaller_hybrid_tvod" >> $SQL_FILE
echo "where filename in (" >> $SQL_FILE
awk '{print $1}' $FILE_LIST | sed -e "s/\(.*\)/'\1',/" | sed -e '$s/,//' >> $SQL_FILE
echo ")" >> $SQL_FILE

mysql -uroot -pcastis -h 10.60.67.143 -D cdn_tvod_hybrid -e "`cat $SQL_FILE`" > $DB_RESULT
