#!/usr/bin/python

from pysnmp.hlapi.asyncore import *

session_oid='.1.3.6.1.4.1.8072.1.3.2.3.1.1.11.118.111.100.95.115.101.115.115.105.111.110'
bandwidth_oid='.1.3.6.1.4.1.8072.1.3.2.3.1.1.13.118.111.100.95.98.97.110.100.119.105.100.116.104'
dictReqID = dict()
dictVODSessionCount = dict()
dictVODBandwidth = dict()


def cbFun(snmpEngine, sendReqHandle, errorIndication, errorStatus, errorIndex, varBinds, cbCtx):
	if errorIndication:
		print(errorIndication)
		return
	elif errorStatus:
		transportDomain, transportAddress = snmpEngine.msgAndPduDsp.getTransportInfo(stateReference)
		print('%s at %s' % (errorStatus.prettyPrint(), errorIndex and varBindTable[-1][int(errorIndex)-1][0] or '?'))
		print('peer domain %s , peer ip %s' % ( transportDomain, transportAddress ))
		return
	else:
		for oid, value in varBinds:
			oidStr = '.' + str(oid)
			if oidStr == session_oid:
				dictVODSessionCount[sendReqHandle] = value
			elif oidStr == bandwidth_oid:
				dictVODBandwidth[sendReqHandle] = value
			else:
				print("ID(%s) %s = %s" % (sendReqHandle, oid, value))

data = (
)

dictVODServer = {
		'HLC_HYB_VOD_N_01':'10.60.69.68',
		'HLC_HYB_VOD_N_02':'10.60.69.69',
		'HLC_HYB_VOD_N_03':'10.60.69.70',
		'HLC_HYB_VOD_N_04':'10.60.69.71',
		'HLC_HYB_VOD_N_05':'10.60.69.72',
		'HLC_HYB_VOD_N_06':'10.60.69.73',
		'HLC_HYB_VOD_N_07':'10.60.69.74',
		'HLC_HYB_VOD_N_08':'10.60.69.75',
		'HLC_HYB_VOD_N_09':'10.60.69.76',
		'HLC_HYB_VOD_N_10':'10.60.69.77',
		'HLC_HYB_VOD_N_11':'10.60.69.78',
		'HLC_HYB_VOD_N_12':'10.60.69.79',
		'HLC_HYB_VOD_H_13':'10.60.69.80',
		'HLC_HYB_VOD_H_14':'10.60.69.81',
		'HLC_HYB_VOD_H_15':'10.60.69.82',
		'HLC_HYB_VOD_H_16':'10.60.69.83',
		'HLC_HYB_VOD_H_17':'10.60.69.84',
		'HLC_HYB_VOD_H_18':'10.60.69.85',
		'HKH_HYB_VOD_N_01':'10.42.9.68',
		'HKH_HYB_VOD_N_02':'10.42.9.69',
		'HKH_HYB_VOD_N_03':'10.42.9.70',
		'HKH_HYB_VOD_N_04':'10.42.9.71',
		'HKH_HYB_VOD_N_05':'10.42.9.72',
		'HKH_HYB_VOD_N_06':'10.42.9.73',
		'HKH_HYB_VOD_N_07':'10.42.9.74',
		'HKH_HYB_VOD_N_08':'10.42.9.75',
		'HKH_HYB_VOD_N_09':'10.42.9.76',
		'HKH_HYB_VOD_N_10':'10.42.9.77',
		'HKH_HYB_VOD_N_11':'10.42.9.78',
		'HKH_HYB_VOD_N_12':'10.42.9.79',
		'HKH_HYB_VOD_H_13':'10.42.9.80',
		'HHT_HYB_VOD_N_01':'10.73.226.68',
		'HHT_HYB_VOD_N_02':'10.73.226.69',
		'HHT_HYB_VOD_N_03':'10.73.226.70',
		'HHT_HYB_VOD_N_04':'10.73.226.71',
		'HHT_HYB_VOD_N_05':'10.73.226.72',
		'HHT_HYB_VOD_N_06':'10.73.226.73',
		'HHT_HYB_VOD_N_07':'10.73.226.74',
		'HHT_HYB_VOD_N_08':'10.73.226.75',
		'HHT_HYB_VOD_N_09':'10.73.226.76',
		'HHT_HYB_VOD_N_10':'10.73.226.77',
		'HHT_HYB_VOD_N_11':'10.73.226.78',
		'HHT_HYB_VOD_N_12':'10.73.226.79',
		'HHT_HYB_VOD_H_13':'10.73.226.80',
		'HHT_HYB_VOD_H_14':'10.73.226.81',
		'HHT_HYB_VOD_H_15':'10.73.226.82',
		'HHT_HYB_VOD_H_16':'10.73.226.83',
		'HLC_HYB_PVR_L_01':'10.60.69.6',
		'HLC_HYB_PVR_L_02':'10.60.69.7',
		'HKH_HYB_PVR_L_01':'10.42.9.6',
		'HKH_HYB_PVR_L_02':'10.42.9.7',
		'HHT_HYB_PVR_L_01':'10.73.226.6',
		'HHT_HYB_PVR_L_02':'10.73.226.7',
		'PDL_CV1_VOD_H_01':'10.59.54.6',
		'PDL_CV1_VOD_H_02':'10.59.54.7',
		'PDL_CV1_VOD_H_03':'10.59.54.8',
		'PDL_CV1_VOD_H_04':'10.59.54.9',
		'PDL_CV3_VOD_H_01':'10.59.54.134',
		'PDL_CV3_VOD_H_02':'10.59.54.135',
		'PDL_CV3_VOD_H_03':'10.59.54.136',
		'PDL_CV3_VOD_H_04':'10.59.54.137',
		'PDL_CV3_VOD_H_05':'10.59.54.138',
		'PDL_CV3_VOD_H_06':'10.59.54.139',
		'PDL_CV3_VOD_H_07':'10.59.54.140',
		'PVN_CV2_VOD_H_01':'10.58.54.6',
		'PVN_CV2_VOD_H_02':'10.58.54.7',
		'PVN_CV2_VOD_H_03':'10.58.54.8',
		'PVN_CV2_VOD_H_04':'10.58.54.9',
		'PVN_CV2_VOD_H_05':'10.58.54.10',
		'PVN_CV2_VOD_H_06':'10.58.54.11',
		'NTH_CV5_VOD_H_01':'10.41.16.6',
		'NTH_CV5_VOD_H_02':'10.41.16.7',
		'NTH_CV5_VOD_H_03':'10.41.16.8',
		'NTH_CV5_VOD_H_04':'10.41.16.9',
		'NTH_CV6_VOD_H_01':'10.41.16.134',
		'NTH_CV6_VOD_H_02':'10.41.16.135',
		'NTH_CV6_VOD_H_03':'10.41.16.136',
		'HHT_CV7_VOD_H_01':'10.73.227.6',
		'HHT_CV7_VOD_H_02':'10.73.227.7',
		'HHT_CV7_VOD_H_03':'10.73.227.8',
		'HHT_CV7_VOD_H_04':'10.73.227.9',
		'HHT_CV7_VOD_H_05':'10.73.227.10',
		'HHT_CV8_VOD_H_01':'10.73.227.134',
		'HHT_CV8_VOD_H_02':'10.73.227.135',
		'HHT_CV8_VOD_H_03':'10.73.227.136',
		'HHT_CV9_VOD_H_01':'10.73.227.196',
		'HHT_CV9_VOD_H_02':'10.73.227.197',
		'HHT_CV9_VOD_H_03':'10.73.227.198',
		'HHT_CV9_VOD_H_04':'10.73.227.199',
		'HHT_CV9_VOD_H_05':'10.73.227.200',
		'HHT_CV9_VOD_H_06':'10.73.227.201'
}



snmpEngine = SnmpEngine()

for hostname in dictVODServer.keys():

	g = getCmd(snmpEngine, CommunityData('ViettelMS1NMS'), UdpTransportTarget((dictVODServer[hostname], 161)), ContextData(), ObjectType(ObjectIdentity(session_oid)), cbFun=cbFun)
	dictVODSessionCount[g] = ''
	dictReqID[g] = hostname

	g = getCmd(snmpEngine, CommunityData('ViettelMS1NMS'), UdpTransportTarget((dictVODServer[hostname], 161)), ContextData(), ObjectType(ObjectIdentity(bandwidth_oid)), cbFun=cbFun)
	dictVODBandwidth[g] = ''
	dictReqID[g] = hostname


#getCmd(snmpEngine, CommunityData('ViettelMS1NMS'), UdpTransportTarget(('10.59.54.6', 161)), ContextData(), ObjectType(ObjectIdentity(bandwidth_oid)), cbFun=cbFun)

snmpEngine.transportDispatcher.runDispatcher()

for reqID in dictVODSessionCount.keys():
	print("%s = %s" % (dictReqID[reqID], dictVODSessionCount[reqID]))

for reqID in dictVODBandwidth.keys():
	print("%s = %s" % (dictReqID[reqID], dictVODBandwidth[reqID]))

