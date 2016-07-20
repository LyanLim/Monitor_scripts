#!/usr/bin/python

import mysql.connector
from mysql.connector import errorcode
from pysnmp.hlapi.asyncore import *
from datetime import datetime
import logging

# initialize variables
dbConfig = {
	#'user'		:'vsmuser',
	#'password'	:'castis!vsm!@#',
	'user'		:'root',
	'password'	:'castis',
	'host'		:'10.60.67.200',
	'port'		:'3306',
	'database'	:'cdnm'
}

qrSelectVODServer = (
	"SELECT dcnIP,region,type FROM vodserver_info "
	"WHERE vodserver_info.`type` != 'OTT'"
)

qrInsertVODService = (
	"INSERT IGNORE INTO vod_traffic "
	"(dcnIP, curbw, cursession, datetime, region, type) "
	"VALUES (%(dcnIP)s, %(curbw)s, %(cursession)s, %(datetime)s, %(region)s, %(type)s)"
)

session_oid='.1.3.6.1.4.1.8072.1.3.2.3.1.1.11.118.111.100.95.115.101.115.115.105.111.110'
bandwidth_oid='.1.3.6.1.4.1.8072.1.3.2.3.1.1.13.118.111.100.95.98.97.110.100.119.105.100.116.104'

data = []
dicSnmpResponse = {}

curDatetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

# set logger
logging.basicConfig(
	filename='/home/vt_admin/yang/vsm/vod_service/log.log',
	format='%(asctime)s,%(levelname)s,%(filename)s,%(lineno)d,%(message)s',
	datefmt='%Y-%m-%d.%H:%M:%S',
	level=logging.DEBUG
)
logger = logging.getLogger(__name__)

# define function
def cbFun(snmpEngine, sendReqHandle, errorIndication, errorStatus, errorIndex, varBinds, cbCtx):
	if errorIndication:
		logger.error('%s', errorIndication)
		return
	elif errorStatus:
		logger.error('%s : %s', errorStatus.prettyPrint(), errorIndex and varBindTable[-1][int(errorIndex)-1][0] or '?')
		return
	else:
		for oid, value in varBinds:
			dicSnmpResponse[sendReqHandle] = value


#======== main
try:
	# connect to DB
	cnx = mysql.connector.connect(**dbConfig)

except mysql.connector.Error as err:

	print(err)
	exit(1)
else:
	cursor = cnx.cursor()

	dbTable = {}
	dbTable['vod_traffic'] = (
	"CREATE TABLE IF NOT EXISTS `vod_traffic` ("
	"`dcnIP` VARCHAR(15) NULL DEFAULT NULL,"
	"`curbw` BIGINT(11) UNSIGNED NULL DEFAULT NULL,"
	"`cursession` SMALLINT(6) UNSIGNED NULL DEFAULT NULL,"
	"`datetime` DATETIME NULL DEFAULT NULL,"
	"`region` VARCHAR(15) NULL DEFAULT NULL,"
	"`type` VARCHAR(15) NULL DEFAULT NULL,"
	"UNIQUE INDEX `data` (`dcnIP`, `datetime`))"
	)

try:
	# create table
	cursor.execute(dbTable['vod_traffic'])
	cnx.commit()

except mysql.connector.Error as err:

	print(err)
	exit(1)


# select vodserver ip in DB
cursor.execute(qrSelectVODServer)

for (dcnIP,region,type) in cursor:
	data.append({'dcnIP':dcnIP,'region':region,'type':type,'datetime':curDatetime})


# initialize snmp instance
snmpEngine = SnmpEngine()

dictVODSessionCount = {}
dictReqID = {}
dictVODBandwidth = {}

# snmp get disk usage
for idx, val in enumerate(data):

	id = getCmd(snmpEngine, CommunityData('ViettelMS1NMS'), UdpTransportTarget((data[idx]['dcnIP'], 161)), ContextData(), ObjectType(ObjectIdentity(session_oid)), cbFun=cbFun)
	logger.info('get the number of current session -> %s', data[idx]['dcnIP'])
	data[idx]['reqID'] = id


snmpEngine.transportDispatcher.runDispatcher()

for idx, val in enumerate(data):
	if data[idx]['reqID'] in dicSnmpResponse:
		data[idx]['cursession'] = int(dicSnmpResponse[data[idx]['reqID']])
		logger.info('session count of %s : %d', data[idx]['dcnIP'], data[idx]['cursession'])



for row in data:
	if 'curbw' in row and 'cursession' in row:
		cursor.execute(qrInsertVODService, row)

cnx.commit()
cnx.close()
