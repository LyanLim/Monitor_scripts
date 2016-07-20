#!/bin/bash

log_dir=/root/hit_analysis/log_hit/20160709


for temp_dir in `ls -tr $log_dir`
do
	./insert_mysql_db.v2.pl ${log_dir}/${temp_dir} 30
	echo "fihished $temp_dir"
done
