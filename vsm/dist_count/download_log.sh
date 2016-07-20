#!/usr/bin/expect -f

set ip [ lindex $argv 0 ]
set src_file [ lindex $argv 1 ]
set dst_file [ lindex $argv 2 ]

spawn /usr/bin/scp -o ConnectTimeout=3 vt_admin@$ip:$src_file $dst_file

expect {
-re "Are you sure you want to continue.*\? $" {
exp_send "yes\n"
exp_continue
}
"password:" {
#exp_send "L2d&tvV5\n"
exp_send "n0p#sswD\n"
}
}
expect eof
exit
