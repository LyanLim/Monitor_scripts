#!/usr/bin/expect -f

set ip [ lindex $argv 0 ]
set command [ lindex $argv 1 ]

spawn /usr/bin/ssh -o ConnectTimeout=3 $ip "$command"

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
