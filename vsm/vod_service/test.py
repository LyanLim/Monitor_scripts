#!/usr/bin/python

import asyncio
from pysnmp.hlapi.asynio import *

session_oid='.1.3.6.1.4.1.8072.1.3.2.3.1.1.11.118.111.100.95.115.101.115.115.105.111.110'
bandwidth_oid='.1.3.6.1.4.1.8072.1.3.2.3.1.1.13.118.111.100.95.98.97.110.100.119.105.100.116.104'

snmp_community='ViettelMS1NMS'

def snmpGet(host,oid):

	errIndication, errStatus, errIndex, varBinds = yield from getCmd(
		SnmpEngine(),
		CommunityData(snmp_community),
		UdpTransportTarget((host,161)),
		ContextData(),
		ObjectType(ObjectIdentity(oid))
	)

	print(errIndication,errStatus,errIndex,varBinds)


asyncio.get_event_loop().run_until_complete(snmpGet('10.61.77.239',session_oid))
asyncio.get_event_loop().run_until_complete(snmpGet('10.61.77.240',session_oid))
asyncio.get_event_loop().run_until_complete(snmpGet('10.61.77.241',session_oid))
asyncio.get_event_loop().run_until_complete(snmpGet('10.61.77.242',session_oid))

