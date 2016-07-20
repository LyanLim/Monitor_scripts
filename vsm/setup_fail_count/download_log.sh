#!/usr/bin/expect -f

set ip [ lindex $argv 0 ]
set src_file [ lindex $argv 1 ]
set dst_dir [ lindex $argv 2 ]

spawn /usr/bin/scp -o ConnectTimeout=3 vt_admin@$ip:"$src_file" "$dst_dir"

expect {
-re "Are you sure you want to continue.*\? $" {
exp_send "yes\n"
exp_continue
}
"password:" {
#exp_send "L2d&tvV5\n"
#exp_send "n0p#sswD\n"
exp_send "qaz@123WER\n"
}
}
expect eof
exit
