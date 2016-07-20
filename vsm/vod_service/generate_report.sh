#!/bin/sh

if [ $# -ne 1];then
	echo "Usage:$0 [date] ( ex. $0 2015-06-25 )"
	exit 1
fi

_date=$1

for region in HLC HKH HHT CV1 CV2 CV3 CV5 CV6 CV7 CV8 CV9
do
	for file in `ls $_date`
	do
		#2015-06-11.04_10_01.raw
		_tmp=`echo ${file%.raw} | sed -e 's/\./ /'`
		time=`echo $_tmp | sed -e 's/_/:/g'`
		echo $region,$time,`grep $region $_date/$file | awk -F, '{s+=$2;bw+=$3}END{print s","bw}'`
	done
done
