#!/usr/bin/python

import mysql.connector


db_config = {
        'user'  : 'root',
        'password'  : 'castis',
        'host'  : '1.255.85.210',
        'port'  : '8081',
        'database'  : 'skb'
}

cnx = mysql.connector.connect(**db_con)

db_config
