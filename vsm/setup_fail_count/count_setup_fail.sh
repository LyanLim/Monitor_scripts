#!/bin/sh

_VSM_HOME=/home/vt_admin/yang/vsm
_SCRIPT_HOME=$_VSM_HOME/setup_fail_count

check_time=`date +%F`
$_SCRIPT_HOME/collect_log.sh $check_time
$_SCRIPT_HOME/check_failed_file_in_db.sh $check_time
$_SCRIPT_HOME/generate_html.pl $_SCRIPT_HOME/db_list $_SCRIPT_HOME/file_list

chown vt_admin:security -R $_SCRIPT_HOME/*
