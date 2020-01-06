/*********************************************************************
*	File:		NetIO.h
*	
*	Description:	NetIO interface.
*
*	Author:	Devid
*
*	Copyright: 	?Copyright 2009 Liteon, Inc. All rights reserved.
*
**********************************************************************/

#ifndef __NETIO_H__
#define __NETIO_H__
#pragma once

#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

#include <stdio.h>
#include <stdlib.h>

#include <arpa/inet.h>
#include <ifaddrs.h>

#include <string.h>
#include <net/if.h>
#include <net/if_dl.h>

#include "Socket.h"
#include "GrandeCmd.h"


#ifndef BYTE
typedef UInt8 BYTE;
#endif  // BYTE

#ifndef DWORD
typedef UInt32 DWORD;
#endif  // DWORD

#define LOWORD(l)           ((WORD)(((DWORD)(l)) & 0xffff))
#define HIWORD(l)           ((WORD)((((DWORD)(l)) >> 16) & 0xffff))
#define LOBYTE(w)           ((BYTE)(((DWORD)(w)) & 0xff))
#define HIBYTE(w)           ((BYTE)((((DWORD)(w)) >> 8) & 0xff))

#define FLIPWORD_(X)		(((X>>8)&0x00ff) | ((X<<8)&0xff00))
#define FLIPDWORD_(X)	((((X)>>24)&0x000000ff) | (((X)>>8)&0x0000ff00) | (((X)<<8)&0x00ff0000) | (((X)<<24)&0xff000000))

typedef bool (*LPFNFINDCALLBACK)(char* ip, char* hostname, void* param);
typedef bool (*FNOUTPUTRESPONSEVALUE)(BYTE* oid, int oidLen, BYTE valueType, BYTE* valueData, int valueLen);

struct ifs_info
{
	char name[IFNAMSIZ];	
	int scope_id;	
	struct ifs_info *ifs_next;
};

#define SYSOBJECTID_OID		"1.3.6.1.2.1.1.2.0"
#define SYSNAME_OID			"1.3.6.1.2.1.1.5.0"
#define PVT_DEVICEID_OID	"1.3.6.1.4.1.26266.886.300.369.8531.1.1.0"
#define PVT_FWVER_OID		"1.3.6.1.4.1.26266.886.300.369.8531.1.2.1.0"
#define PVT_MCUVER_OID		"1.3.6.1.4.1.26266.886.300.369.8531.1.2.3.0"

#define MSGUSERNAME "Xdrivers"
#define PASSWDAUTH "3tamAvUMEfeR84erar6z"
#define PASSWDPRIV "TRUDU27qumAspuswe4he"

#define MAX_SNMP_LEN	2048
#define MAX_USERNAME	36
#define MAX_PASSWORD	36

#if (PERRY_CP115W || PERRY_CP116W || PERRY_CP225W || PERRY_CM115W || PERRY_CM225FW)
#define EngineEnterpriseId 0x29010080
//#define EngineEnterpriseId 0xfd000080

#elif (PERRY_6020 || PERRY_6022 || PERRY_6025 || PERRY_6027)
#define EngineEnterpriseId 0xfd000080

#else
#define EngineEnterpriseId 0xA2020080

#endif

typedef struct _SNMP_PARAM_V3 {
	int	nObjects;
	const char**	raw_oid;
	BYTE**	value;
	char*	valueLen;
	BYTE*	typeID;

	BYTE	engineID[32];
	int		engineIDLen;
	int		msgAuthoritativeEngineBoots;
    int		msgAuthoritativeEngineTime;
	char	msgUserName[MAX_USERNAME];
	char	passwdAuth[MAX_PASSWORD];
	char	passwdPriv[MAX_PASSWORD];
	BYTE	privacyKey[16];
	BYTE	authKey[16];

	int	socket;
	struct sockaddr*	ai_addr;
	size_t              ai_addrlen;

	FNOUTPUTRESPONSEVALUE	responseFunc;
	BOOL	done;
} SNMP_PARAM_V3;

class CNetIO
{
public:
	CNetIO();
	~CNetIO();
	
	bool FindSnmpAgent(const char* community, const char* ip, const char* oid, LPFNFINDCALLBACK FindCallback, void* param, bool bBroadcast = true);
	bool FindSnmpV3Agent(const char* community, const char* ip, const char* oid, LPFNFINDCALLBACK FindCallback, void* param, bool bBroadcast = true);
	bool FindSnmpAgentV6(const char* community, const char* ip, const char* oid, LPFNFINDCALLBACK FindCallback, void* param, bool bBroadcast = true);
	bool FindSnmpAgentV6_(const char* community, const char* ip, const char* oid, LPFNFINDCALLBACK FindCallback, void* param, bool bBroadcast = true);
	bool FindSnmpV3AgentV6_(const char* community, const char* ip, const char* oid, LPFNFINDCALLBACK FindCallback, void* param, bool bBroadcast = true);
	bool FindSnmpAgent3Times(const char* community, const char* oid, LPFNFINDCALLBACK FindCallback, void* param);
	int NetworkConnect(char *server, int port);
	int NetworkConnectV6(char *server, int port);
	int NetworkRead(int sd, void* buff, DWORD len); 
	int NetworkWrite(int sd, void* buff, DWORD len); 
	void NetworkClose(int sd);
	int GrandeNetworkGetPrinterName(const char* ip, BYTE ipversion, char* name, int buffsize);
	int GrandeNetworkGetFwVersion(const char* ip, BYTE ipversion, char* version, int buffsize);
	int GrandeNetworkGetFwMCUVersion(const char* ip, BYTE ipversion, char* version, int buffsize);
	int GrandeNetworkGetNameAndFwAndMCUVersion(const char* ip, char* name, char* fwVersion, char* MCUVersion, int buffsize);

	bool NetworkReadStatus(const char* community, const char* ip, PRINTER_STATUS *status);
	bool NetworkReadStatusV6(const char* community, const char* ip, PRINTER_STATUS *status);

	bool NetworkReadStatusSNMPv3(const char* community, const char* ip, PRINTER_STATUS *status);
	bool NetworkReadStatusV6SNMPv3(const char* community, const char* ip, PRINTER_STATUS *status);

	int BuildSnmpV3GetRequestPDU(WORD requestId, int nObjects, const char* raw_oid[], BYTE* request);
	int BuildSnmpV3PDU(WORD requestId, int nObjects, const char* raw_oid[], const BYTE* value[], const char valueLen[], const BYTE typeID[], BYTE* request);
	int BuildSnmpV3msgData(const BYTE *contextEngineID, int contextEngineIdLen, const char* contextName, WORD requestId, int nObjects, const char* oid[], const BYTE* value[], const char valueLen[], const BYTE typeID[], BYTE* msgData);
	int BuildSnmpV3msgSecurityParameters(const BYTE *contextEngineID, int contextEngineIdLen, int msgAuthoritativeEngineBoots, int msgAuthoritativeEngineTime, const char* msgUserName, const char* authPassword, const BYTE* msgPrivacyParameters, int msgPrivacyParametersLen, BYTE* msgSecurityParameters, DWORD* piAuthParamOffset);
	int BuildSnmpV3msgGlobalDataUSM(int msgID, int msgMaxSize, BOOL bReportable, BOOL bEncrypted, BOOL bAuthenticated, BYTE* msgGlobalData);
	int BuildSnmpV3Packet(BYTE* msgGlobalData, int msgGlobalDataLen, BYTE* msgSecurityParameters, int msgSecurityParametersLen, BYTE* msgData, int msgDataLen, DWORD* piAuthParamOffset, BYTE* snmpV3Packet);
	int BuildSnmpV3GetEngineIdPacket(WORD requestID, WORD msgID, BYTE* snmpv3Packet, int snmpv3PacketSize);
	void InitTargetOID(const char* oid, const char* oid1);
	BYTE* berEncodeLength(BYTE* pValue, DWORD len);
	BOOL parseSnmpV3Response(BYTE* udpdata, int len, int *version,	BYTE* requestId, BYTE* errorStatus, BYTE* errorIndex, SNMP_PARAM_V3* param);
	int BuildSnmpV3RequestPacket(const BYTE* engineID, int engineIDLen, DWORD msgAuthoritativeEngineBoots, DWORD msgAuthoritativeEngineTime, int nObjects, const char* raw_oid[], const BYTE* value[], const char valueLen[], const BYTE typeID[], const char* msgUserName, const char* passwdAuth, const char* passwdPriv, BYTE* authKey, BYTE* encryptKey, BYTE* snmpv3Packet);

	
private:
	BYTE* parseLength(BYTE* data, int *length);	
	BOOL parseGetResponse(BYTE* udpdata, int len, int *version, char* community, BYTE* requestId, BYTE* errorStatus, BYTE* errorIndex, FNOUTPUTRESPONSEVALUE outputResponseValue);
	int oidEncode (const char* src, BYTE* dst);
	bool parseForOID(BYTE* udpdata, int len, BYTE* oidExpected, int oidlen);
	bool parseForDeviceId(BYTE* udpdata, int len, PRINTER_STATUS* status);
	bool parseForRecvBuf(BYTE* udpdata, int len, char* pBuf)	;
	bool NetSnmpGetV4(const char* ip, char* community, char* oid, char* buf, int buffsize);
	bool NetSnmpGetV6(const char* ip, char* community, char* oid, char* buf, int buffsize);

	bool NetSnmpGetV4SNMPv3(const char* ip, char* name, char* fwVersion, char* MCUVersion, int buffsize);
	bool NetSnmpGetV6SNMPv3(const char* ip, char* name, char* fwVersion, char* MCUVersion, int buffsize);

	int BuildGetRequestFor(int nObjects, char* raw_oid, char* community, BYTE* request);
	
private:
	CSocket m_socket;

	BYTE	m_targetOID[32];	
	BYTE	m_targetOID1[32];	


};

//extern Boolean StartBrowsingForServices(CFStringRef type, CFStringRef domain, LPFNFINDCALLBACK FindCallback, void* param);

extern "C" {
	int DecodStatusFromDeviceID(char* device_id, PRINTER_STATUS* status);
	
	bool NetworkReadStatus(const char* community, const char* ip, PRINTER_STATUS *status);
	bool NetworkReadStatusV6(const char* community, const char* ip, PRINTER_STATUS *status);
	
	bool NetworkReadStatusSNMPv3(const char* community, const char* ip, PRINTER_STATUS *status);
	bool NetworkReadStatusV6SNMPv3(const char* community, const char* ip, PRINTER_STATUS *status);
	
}

#endif //__NETIO_H__
