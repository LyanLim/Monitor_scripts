#!/usr/bin/python

import mysql.connector
from mysql.connector import errorcode
from datetime import datetime

dbConfig = {
	'user'		:'vsmuser',
	'password'	:'castis!vsm!@#',
	'host'		:'10.60.70.199',
	'port'		:'3307',
	'database'	:'cdnm'
}

try:
	cnx = mysql.connector.connect(**dbConfig)

except mysql.connector.Error as err:

	print(err)
	exit(1)
else:
	cursor = cnx.cursor()

	dbTable = {}
	dbTable['vod_service'] = (
	"CREATE TABLE IF NOT EXISTS `vod_service` ("
	"`dcnIP` VARCHAR(15) NULL DEFAULT NULL,"
	"`curbw` INT(11) NULL DEFAULT NULL,"
	"`cursession` SMALLINT(6) NULL DEFAULT NULL,"
	"`datetime` DATETIME NULL DEFAULT NULL,"
	"`region` VARCHAR(15) NULL DEFAULT NULL,"
	"UNIQUE INDEX `data` (`dcnIP`, `datetime`))"
	)

try:
	cursor.execute(dbTable['vod_service'])
	cursor.commit()

except mysql.connector.Error as err:

	print(err)
	exit(1)

qrInsertVODService = (
"INSERT IGNORE INTO vod_service"
"(dcnIP, curbw, cursession, datetime, region)"
"VALUES (%(dcnIP)s, %(curbw)s, %(cursession)s, %(datetime)s, %(region)s)"
)

data = (
	{
		"dcnIP"		: "10.60.67.104",
		"curbw"		: 1405,
		"cursession"	: 330,
		"datetime"	: "2015-10-22 11:36:00",
		"region"	: "A076"
	},
	{
		"dcnIP"		: "10.60.67.105",
		"curbw"		: 405,
		"cursession"	: 126,
		"datetime"	: "2015-10-22 11:36:00",
		"region"	: "B076"
	},
	{
		"dcnIP"		: "10.60.67.106",
		"curbw"		: 705,
		"cursession"	: 257,
		"datetime"	: "2015-10-22 11:36:00",
		"region"	: "C076"
	}
)

for row in data:
	cursor.execute(qrInsertVODService, row)

cnx.commit()
cnx.close()
