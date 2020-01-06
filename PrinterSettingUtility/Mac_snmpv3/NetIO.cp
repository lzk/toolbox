/*********************************************************************
*	File:		NetIO.cp
*	
*	Description:	NetIO interface.
*
*	Author:	Devid
*
*	Copyright: 	?Copyright 2009 Liteon, Inc. All rights reserved.
*
**********************************************************************/

#include <Carbon/Carbon.h>
#include <sys/ioctl.h>

#include "NetIO.h"
//#include "Md5.h"
#include "cMD5.h"
#include "Des.h"

int scope_id = 0;
char g_ifsName[256] = "%en0";

WORD FLIPWORD(WORD x)
{
//	fprintf(stderr,"FLIPWORD x=%d\n", x);

	int test=1;
	if(*(char *) &test == 1)
		return FLIPWORD_(x);	

//	fprintf(stderr,"FLIPWORD_ x=%d\n", x);
	return x;
}

WORD FLIPDWORD(DWORD x)
{
//	fprintf(stderr,"FLIPDWORD x=%d\n", x);
	
	int test=1;
	if(*(char *) &test == 1)
		return FLIPDWORD_(x);	

//	fprintf(stderr,"FLIPWORD_ x=%d\n", x);
	return x;
}

// for length=1, 2, 3, 4 only
int readIntValue(BYTE* data, int length)
{
	int	ret = 0;
	for (int i=0;i<length;i++) 
		ret = (ret<<8)|data[i];
	return ret;
}

void Password_to_Key_md5(
	const u_char *password,    /* IN */
	u_int   passwordlen, /* IN */
	const u_char *engineID,    /* IN  - pointer to snmpEngineID  */
	u_int   engineLength,/* IN  - length of snmpEngineID */
	u_char *key)         /* OUT - pointer to caller 16-octet buffer */
{

	u_char     *cp, password_buf[64];
	u_long      password_index = 0;
	u_long      count = 0, i;

	MD5Init();
//	MD5_CTX md5;
//	MD5Init(&md5);         

	/**********************************************/
	/* Use while loop until we've done 1 Megabyte */
	/**********************************************/
	while (count < 1048576) {
		cp = password_buf;
		for (i = 0; i < 64; i++) {
			/*************************************************/
			/* Take the next octet of the password, wrapping */
			/* to the beginning of the password as necessary.*/
			/*************************************************/
			*cp++ = password[password_index++ % passwordlen];
		}
		MD5Update(password_buf, 64);
//		MD5Update(&md5,password_buf, 64);
		count += 64;
	}
	MD5Final(key);          /* tell MD5 we're done */
	md5FreeBuffer();

//	MD5Final(&md5,key);        

	/*****************************************************/
	/* Now localize the key with the engineID and pass   */
	/* through MD5 to produce final key                  */
	/* May want to ensure that engineLength <= 32,       */
	/* otherwise need to use a buffer larger than 64     */
	/*****************************************************/
	memcpy(password_buf, key, 16);
	memcpy(password_buf+16, engineID, engineLength);
	memcpy(password_buf+16+engineLength, key, 16);

	MD5Init();
	MD5Update(password_buf, 32+engineLength);
	MD5Final(key);
	md5FreeBuffer();

//	MD5Init(&md5);         
//	MD5Update(&md5,password_buf, 32+engineLength);
//	MD5Final(&md5,key);        
	
	return;
}


void AuthKey2K1K2(
  u_char *authKey,    /* IN */
  u_char *K1,    /* OUT  */
  u_char *K2    /* OUT  */
  )
{
	BYTE	extendedAuthKey[64];
	BYTE	IPAD[64];
	BYTE	OPAD[64];

	memset(extendedAuthKey,0x00,64);
	memcpy(extendedAuthKey, authKey, 16);
	memset(IPAD,0x36,64);
	memset(OPAD,0x5C,64);
	for (int i=0;i<64;i++) {
		*(K1+i) = extendedAuthKey[i]^IPAD[i];
		*(K2+i) = extendedAuthKey[i]^OPAD[i];
	}
}

void CalcuateAuthParams(
	u_char *wholeMsg,    /* IN  */
	u_int	wholeMsgLen,   /* IN  */
	u_char *K1,    /* IN  */
	u_char *K2,    /* IN  */
	u_char *msgAuthenticationParameters /* OUT */
	)
{
	BYTE	tempMD5Result[16];
	BYTE	tempMD5Result2[16];

	MD5Init();
	MD5Update(K1, 64);
	MD5Update(wholeMsg, wholeMsgLen);
   	MD5Final(tempMD5Result);
	md5FreeBuffer();
	
	MD5Init();
	MD5Update(K2, 64);
	MD5Update(tempMD5Result, 16);
	MD5Final(tempMD5Result2);
	md5FreeBuffer();

/*
	MD5_CTX md5;
	
	MD5Init(&md5);         
	MD5Update(&md5,K1, 64);
	MD5Update(&md5,wholeMsg, wholeMsgLen);
	MD5Final(&md5,tempMD5Result);        

	MD5Init(&md5);         
	MD5Update(&md5,K2, 64);
	MD5Update(&md5,tempMD5Result, 16);
	MD5Final(&md5,tempMD5Result2);        
*/	
	memcpy(msgAuthenticationParameters,tempMD5Result2,12); // take the first 12 bytes
}

int DesEncryption(const BYTE* desKey, const BYTE* IV, BYTE* pData, DWORD nDataLen, BYTE* outBuff, int nOutBuffLen)
{
	AVDES avDes;

	if (desKey==NULL || outBuff==NULL || nOutBuffLen<((nDataLen+7)/8)*8)
		return 0;

	av_des_init(&avDes, desKey, 64, 0);
	av_des_crypt(&avDes, outBuff, pData, nDataLen, IV, 0);

	return nDataLen;
}

BOOL DecryptMsgData(/*in/out*/BYTE* msgData, /*in*/DWORD msgDataLen, /*in*/BYTE* privacyKey, /*in*/BYTE* msgPrivParams)
{
	if (msgDataLen%8 || msgData==NULL || privacyKey==NULL ||  msgPrivParams==NULL)
		return FALSE;

	BYTE	IV[8];
	for (int i=0;i<8;i++)
		IV[i] = privacyKey[8+i] ^ msgPrivParams[i];

	AVDES avDes;

	av_des_init(&avDes, privacyKey, 64, 0);
	av_des_crypt(&avDes, msgData, msgData, msgDataLen/8, IV, 1);

	return TRUE;
}

//--------------------------------------------------------------------------------------------
CNetIO::CNetIO()
{
}

//--------------------------------------------------------------------------------------------
CNetIO::~CNetIO()
{
}

void CNetIO::InitTargetOID(const char* oid, const char* oid1)
{
	memset(m_targetOID, 0, sizeof(m_targetOID));
	memset(m_targetOID1, 0, sizeof(m_targetOID1));
	
	oidEncode(oid,m_targetOID);
	oidEncode(oid1,m_targetOID1);
}

// returns next byte ptr
BYTE* CNetIO::parseLength(BYTE* data, int *length)
{	
	int	n = 0;
	char	c = *data & 0x80;
	if (c==0x00) {
		*length = *data;
		return (data+1);
	} else {
		c = *data & 0x7f;
		*length = 0;
		data++;
		for (int i=0;i<c;i++) {
			*length = *length << 8;
			*length += (int)(DWORD)*data;
			data++;
		}
		return data;
	}
}

BOOL CNetIO::parseGetResponse(BYTE* udpdata, int len, int *version, char* community, BYTE* requestId, BYTE* errorStatus, BYTE* errorIndex, FNOUTPUTRESPONSEVALUE outputResponseValue)
{
	int	length;
	BYTE*	next;
#ifdef _DEBUG
	char	dbg[1024];
	memset(dbg,0x00,1024);
	OutputDebugString(L"Net: Entering parseSnmpResponse!");
	for (int i=0;i<len;i++) {
		sprintf(dbg+i*3,"%02x ",udpdata[i]);
	}
	OutputDebugStringA(dbg);
#endif

	if (udpdata[0]!=0x30) {
		return FALSE;
	}
	next = parseLength(&udpdata[1], &length);
	//printf("parseGetResponse length=%d, len=%d, next-udpdata=%d\n", length, len, next-udpdata);
	if (length!=len-(next-udpdata)) {
		return FALSE;
	}
	// version
	if (next[0]!=0x02) {
		return FALSE;
	}
	next++;
	next = parseLength(next, &length);
	if (version) {
		if (length==1)
			*version = (int)(*next);
		else	*version = (int)(*next); // I don'care such case!
	}
	next += length;
	// community
	if (next[0]!=0x04) {
		return FALSE;
	}
	next++;
	next = parseLength(next, &length);
	if (community) {
		memcpy(community,next,length);
		community[length] = 0x00;
	}
	next += length;
	// PDU type
	if (*next != 0xa2 && *next != 0xa3) { // check if it is GetResponse or SetResponse
		return FALSE;
	}
	next++;
	next = parseLength(next, &length);
	if (length!=len-(next-udpdata)) { // check length
		return FALSE;
	}
	// request ID
	if (next[0]!=0x02) {
		return FALSE;
	}
	next++;
	next = parseLength(next, &length);
	if (requestId) {
		if (length==1)
			*requestId = *next;
		else	*requestId = *next; // I don'care such case!
	}
	next += length;
	// error status
	if (next[0]!=0x02) {
		return FALSE;
	}
	next++;
	next = parseLength(next, &length);
	if (errorStatus) {
		if (length==1)
			*errorStatus = *next;
		else	*errorStatus = *next; // I don'care such case!
	}
	next += length;
	// error index
	if (next[0]!=0x02) {
		return FALSE;
	}
	next++;
	next = parseLength(next, &length);
	if (errorIndex) {
		if (length==1)
			*errorIndex = *next;
		else	*errorIndex = *next; // I don'care such case!
	}
	next += length;
	
	// sequence for the list of name-value pairs
	if (*next!=0x30) {
		return FALSE;
	}
	next++;
	next = parseLength(next, &length);
	BYTE* p = next;
	BYTE* q = next+length;
	while (p<q) {
		BYTE	*oidTemp;
		int	oidLen;
		BYTE	valType;
		BYTE*	value;
		int	valLen;
		// sequence for a name-value pair
		if (*p!=0x30) {
			return FALSE;
		}
		p++;
		p = parseLength(p, &length);
		if (*p!=0x06) { // this should be an OID type
			return FALSE;
		}
		p++;
		p = parseLength(p, &oidLen); // length of OID
		oidTemp = p;
		p += oidLen; // goto start of value
		valType = *p;
		p++;
		p = parseLength(p, &valLen);
		value = p;
		p = p+valLen;
		// call the callback function to report the name-value pair
		if (outputResponseValue) {
			outputResponseValue(oidTemp,oidLen,valType,value,valLen);
		}
	}
	return TRUE; 
}


int CNetIO::oidEncode (const char* src, BYTE* dst)
{
	char	srcTemp[128];
	int	nSections = 0;
	BYTE*	encoded = dst;
	int	nEnc = 0;
	int	i, j, k;
	BYTE	largeCode[8];

	if (src==NULL || dst==NULL)
		return -1;
	strcpy(srcTemp,src);
	char* p = srcTemp;
	while (*p!='\0') {
		if (*p=='.') {
			*p = '\0';
			p++;
			nSections++;
		} else {
			if (*p>='0' && *p<='9')
				p++;
			else
				return 0;
		}
	}
	nSections++;
	DWORD* oids = new DWORD[nSections];
	p = srcTemp;
	for (i=0;i<nSections;i++) {
		sscanf(p,"%d",&oids[i]);
		while (*p!='\0')
			p++;
		p++;
	}
	
	encoded[0] = (BYTE) (oids[0] * 40 + oids[1]);
	j=1;
	i = 2;
	while (i<nSections) {
		if (oids[i]<128) {
			encoded[j] = (BYTE)oids[i];
			j++;
			i++;
		} else {
			k = 0;
			while (oids[i]!= 0) {
				largeCode[k] = (BYTE) (0x0000007f & oids[i]);
				oids[i] = oids[i] >> 7;
				k++;
			}
			k--;
			while (k>0) {
				encoded[j] = largeCode[k] | 0x80;
				k--;
				j++;
			}
			encoded[j] = largeCode[0];
			j++;
			i++;
		}
	}
	delete []oids;
	return j;
}


BYTE	sysObjId[128];
int	sysObjIdLen = 0;
bool outputOidValue (BYTE* oid, int oidLen, BYTE valueType, BYTE* valueData, int valueLen)
{
	BYTE	oidoid[] = {0x2b, 0x06, 0x01, 0x02, 0x01, 0x01, 0x02, 0x00};

	if (memcmp(oid,oidoid,8)) {
		return false;
	}
	if (valueType!=0x06) {
		return false;
	}
	memcpy(sysObjId,valueData,valueLen);
	sysObjIdLen = valueLen;
	return true;
}

bool CNetIO::parseForOID(BYTE* udpdata, int len, BYTE* oidExpected, int oidlen)
{
	sysObjIdLen = 0;
	
	if (!parseGetResponse(udpdata, len, NULL, NULL, NULL, NULL, NULL, outputOidValue)) {
		return false;
	}

//	return true;//Devid test
/*	
	if (sysObjIdLen<5 || memcmp(sysObjId,oidExpected,sysObjIdLen)) {
	
		return false;
	}
*/

	if(sysObjIdLen < 5)
		return false;
		
	if (memcmp(sysObjId,m_targetOID,sysObjIdLen)  == 0)
		return true;
		
	if (memcmp(sysObjId,m_targetOID1,sysObjIdLen)  == 0)
		return true;
	
	return false;
}

char	g_deviceid[4024];
bool outputDeviceIdValue (BYTE* oid, int oidLen, BYTE valueType, BYTE* valueData, int valueLen)
{
	//printf("outputDeviceIdValue valueType=%d, valueLen=%d\n", valueType, valueLen);
	if (valueType!=0x04) { // string
		return false;
	}
	memcpy(g_deviceid,valueData,valueLen);
	g_deviceid[valueLen] = 0x00;
	//printf("g_deviceid=%s\n", g_deviceid);
	return true;
}

bool CNetIO::parseForDeviceId(BYTE* udpdata, int len, PRINTER_STATUS* status)
{
	CGrandeCmd grandeCmd;

	//printf("parseForDeviceId, len=%d\n", len);
	
	if (!parseGetResponse(udpdata, len, NULL, NULL, NULL, NULL, NULL, outputDeviceIdValue))
		return false;
	if(grandeCmd.DecodStatusFromDeviceID(g_deviceid, status)!= -1);
		return true;
}

char g_RecvBuf[1024];
bool outputRecvBufValue (BYTE* oid, int oidLen, BYTE valueType, BYTE* valueData, int valueLen)
{
	//printf("outputRecvBufValue valueLen=%d\n", valueLen);
	memcpy((BYTE*)g_RecvBuf,valueData,valueLen);
	g_RecvBuf[valueLen] = 0x00;

	return true;
}

bool CNetIO::parseForRecvBuf(BYTE* udpdata, int len, char* pBuf)
{
	memset(g_RecvBuf, 0, sizeof(g_RecvBuf));
	
	if (!parseGetResponse(udpdata, len, NULL, NULL, NULL, NULL, NULL, outputRecvBufValue))
		return false;

	strcpy(pBuf, g_RecvBuf);
	
	return true;
}

bool CNetIO::FindSnmpAgent(const char* community, const char* ip, const char* oid, LPFNFINDCALLBACK FindCallback, void* param, bool bBroadcast)
{
	struct addrinfo *result;
	
	int error = getaddrinfo(ip, NULL, NULL, &result);
	if (error != 0)
	{   
		fprintf(stderr, "error in getaddrinfo: %s\n", gai_strerror(error));
		return -1;
	} 
	if(result->ai_family == AF_INET6)
	{
		return FindSnmpAgentV6_(community,ip,oid,FindCallback,param,bBroadcast); //Goto ipv6 fnc, Artanis added for #31399
		//return FindSnmpAgentV6(community,ip,oid,FindCallback,param,bBroadcast); //Goto ipv6 fnc
	}
	
	const unsigned char request_oid_pf[] = {0xa0,0x19,0x02,0x01,0x00,0x02,0x01,0x00,0x02,0x01,0x00,
				 0x30,0x0e,0x30,0x0c,0x06,0x08,0x2b,0x06,0x01,0x02,0x01,
				 0x01,0x02,0x00,0x05,0x00};
	char	request_oid[256];
	int	request_oid_len;

	int nSendSock;
	int nRet;
	struct sockaddr_in	RecvAddr;
	socklen_t socklen;
	BYTE		response[256];
	BYTE	targetOID[32];	

	if (community==NULL || *community==0x00)
		community = "public";
	request_oid[0] = 0x30;
	request_oid[1] = 5+strlen(community)+sizeof(request_oid_pf);
	request_oid[2] = 0x02;
	request_oid[3] = 0x01;
	request_oid[4] = 0x00;
	request_oid[5] = 0x04;
	request_oid[6] = strlen(community);
	memcpy(&request_oid[7],community,strlen(community));
	memcpy(&request_oid[7+strlen(community)],request_oid_pf,sizeof(request_oid_pf));
	request_oid_len = 7+strlen(community)+sizeof(request_oid_pf);

	int oidlen = oidEncode(oid,targetOID);
	if (oidlen<=0)
	{
		return false;
	}

	struct ifaddrs *ifa_list;
	struct ifaddrs *ifa;
	int n;
	char addrstr[256], netmaskstr[256];
	
	n = getifaddrs(&ifa_list);
	if (n != 0) {
		perror("[ipv4 BC] getifaddrs Error! errno");
		return true;
	}

	for(ifa = ifa_list; ifa != NULL; ifa=ifa->ifa_next) {
		
		memset(addrstr, 0, sizeof(addrstr));
		memset(netmaskstr, 0, sizeof(netmaskstr));
		if (ifa->ifa_addr->sa_family == AF_INET) {
			
			inet_ntop(AF_INET,
					  &((struct sockaddr_in *)ifa->ifa_addr)->sin_addr,
					  addrstr, sizeof(addrstr));
			
			
			inet_ntop(AF_INET,
					  &((struct sockaddr_in *)ifa->ifa_netmask)->sin_addr,
					  netmaskstr, sizeof(netmaskstr));

			fprintf(stderr,"[ipv4 BC] %s\n", ifa->ifa_name);
			fprintf(stderr,"[ipv4 BC] IPv4   : %s\n", addrstr);
			fprintf(stderr,"[ipv4 BC] netmask: %s\n", netmaskstr);

			nSendSock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
			if (nSendSock == -1)
			{
			    continue;
			}

			struct sockaddr_in clnt_addr;
			memset(&clnt_addr, 0, sizeof(clnt_addr));
			clnt_addr.sin_family = AF_INET;
			clnt_addr.sin_addr.s_addr = inet_addr(addrstr);
			clnt_addr.sin_port = htons(0);
			
			int    bOptVal = 1;
			if(bBroadcast == false)
			{
				bOptVal = 0;
			}
			
			setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
			
			struct timeval timeout;
			timeout.tv_sec = 1;
			timeout.tv_usec = 0;
			setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
		    
			if (bind(nSendSock, (struct sockaddr *) &clnt_addr,
					 sizeof(clnt_addr)) < 0)
			{
				perror("[ipv4 BC] ERROR on binding");
				close(nSendSock);
				//printf(" index = %d",index);
				continue;
			}

			
			RecvAddr.sin_family = AF_INET;
			RecvAddr.sin_port = htons(161);
			RecvAddr.sin_addr.s_addr = inet_addr(ip);

			//printf("ipv4=%s\n", ip);

			for(int nTimeCount=0; nTimeCount<3; nTimeCount++)
			{
				nRet = sendto(nSendSock, request_oid, request_oid_len, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
				usleep(30);
			}
			if (nRet <= 0)
			{
				close(nSendSock);
				continue;
			}

			while(1) 
			{
				socklen = sizeof(RecvAddr);
				int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
				//printf("recvfrom nRecv = %d\n", nRecv);
				if (nRecv > 0) 
				{
					if (parseForOID(response, nRecv, targetOID, oidlen))
					{
			        		if (FindCallback != NULL)
				              {
							char szAddr[16];

							strcpy(szAddr, inet_ntoa(RecvAddr.sin_addr));
							//printf("szAddr=%s\n", szAddr);
							FindCallback(szAddr, NULL, param);
						}
				       }
				} 
				else 
				{
					break;
					perror("v4 nRecv");
				}
			}

			close(nSendSock);
		}
	}

	freeifaddrs(ifa_list);


	return true;
}

#ifndef max
int max(int a, int b)
{
	if(a > b)
		return a;
	else
		return b;
}
#endif


struct ifs_info * get_ifs_info(int family, int doaliases)
{
	struct ifs_info		*ifs, *ifshead, **ifspnext;
	int					sockfd, len, lastlen;
	char				*ptr, *buf, lastname[IFNAMSIZ], *sdlname;
	struct ifconf		ifc;
	struct ifreq		*ifr;

	sockfd = socket(AF_INET, SOCK_DGRAM, 0);

	lastlen = 0;
	len = 100 * sizeof(struct ifreq);	/* initial buffer size guess */
	for ( ; ; ) {
		buf = (char*)malloc(len);
		ifc.ifc_len = len;
		ifc.ifc_buf = buf;
		if (ioctl(sockfd, SIOCGIFCONF, &ifc) < 0) {
			if (errno != EINVAL || lastlen != 0) {
				printf("ioctl error");
				return NULL;
			}
		} else {
			if (ifc.ifc_len == lastlen)
				break;		/* success, len has not changed */
			lastlen = ifc.ifc_len;
		}
		len += 10 * sizeof(struct ifreq);	/* increment */
		free(buf);
	}
	ifshead = NULL;
	ifspnext = &ifshead;
	lastname[0] = 0;
	sdlname = NULL;
	/* end get_ifi_info1 */

	/* include get_ifi_info2 */
	for (ptr = buf; ptr < buf + ifc.ifc_len; ) {
		ifr = (struct ifreq *) ptr;

		len = max(sizeof(struct sockaddr), ifr->ifr_addr.sa_len);
		ptr += sizeof(ifr->ifr_name) + len;	/* for next one in buffer */

		if (ifr->ifr_addr.sa_family == AF_LINK) {
			struct sockaddr_dl *sdl = (struct sockaddr_dl *)&ifr->ifr_addr;
			if (0 == sdl->sdl_index)
				continue;

			ifs = (struct ifs_info*)calloc(1, sizeof(struct ifs_info));
			*ifspnext = ifs;			/* prev points to this new one */
			ifspnext = &ifs->ifs_next;	/* pointer to next one goes here */

			memcpy(ifs->name, ifr->ifr_name, IFNAMSIZ);
			ifs->scope_id = sdl->sdl_index;
			printf("ifr_name: %s, scope id: %d\n", ifs->name, ifs->scope_id);
		}
	}
	free(buf);
	return(ifshead);	/* pointer to first structure in linked list */
}
/* end get_ifs_info4 */

char * find_ifname(struct ifs_info *ifshead,int scope_id)
{
	struct ifs_info *ifs, *ifsnext;
	for (ifs = ifshead; ifs != NULL; ifs = ifsnext) {
		ifsnext = ifs->ifs_next;
		if (ifs->scope_id == scope_id)
			return ifs->name;
	}
	return NULL;
}

int find_ifscope_id(struct ifs_info *ifshead,char* name)
{
	struct ifs_info *ifs, *ifsnext;
	for (ifs = ifshead; ifs != NULL; ifs = ifsnext) {
		ifsnext = ifs->ifs_next;
		if (strcmp(ifs->name, name) == 0)
			return ifs->scope_id;
	}
	return 4;
}

/* include free_ifs_info */
void
free_ifs_info(struct ifs_info *ifshead)
{
	struct ifs_info	*ifs, *ifsnext;

	for (ifs = ifshead; ifs != NULL; ifs = ifsnext) {
		ifsnext = ifs->ifs_next;
		free(ifs);
	}
}
/* end free_ifs_info */

#if 1
bool CNetIO::FindSnmpAgentV6_(const char* community, const char* ip, const char* oid, LPFNFINDCALLBACK FindCallback, void* param, bool bBroadcast)
{
	const unsigned char request_oid_pf[] = {0xa0,0x19,0x02,0x01,0x00,0x02,0x01,0x00,0x02,0x01,0x00,
		0x30,0x0e,0x30,0x0c,0x06,0x08,0x2b,0x06,0x01,0x02,0x01,
		0x01,0x02,0x00,0x05,0x00};
	char	request_oid[256];
	int	request_oid_len;
	
	int nSendSock;
	int nRet;
	struct sockaddr_in6	RecvAddr;
	socklen_t socklen;
	BYTE		response[256];
	BYTE	targetOID[32];	

	//struct ifs_info *pFsInfo = NULL;
	
	if (community==NULL || *community==0x00)
		community = "public";
	request_oid[0] = 0x30;
	request_oid[1] = 5+strlen(community)+sizeof(request_oid_pf);
	request_oid[2] = 0x02;
	request_oid[3] = 0x01;
	request_oid[4] = 0x00;
	request_oid[5] = 0x04;
	request_oid[6] = strlen(community);
	memcpy(&request_oid[7],community,strlen(community));
	memcpy(&request_oid[7+strlen(community)],request_oid_pf,sizeof(request_oid_pf));
	request_oid_len = 7+strlen(community)+sizeof(request_oid_pf);
	
	int oidlen = oidEncode(oid,targetOID);
	if (oidlen<=0)
	{
		return false;
	}
	
	int    bOptVal = 1;
	if(bBroadcast == false)
	{
		bOptVal = 0;
	}
	
	struct ifaddrs *ifa_list;
	struct ifaddrs *ifa;
	int n;
	char addrstr[256], netmaskstr[256];
	
	n = getifaddrs(&ifa_list);
	if (n != 0) {
		perror("[ipv6 BC] getifaddrs Error! errno");
		return true;
	}

//	pFsInfo = get_ifs_info(0, 0);
	
	for(ifa = ifa_list; ifa != NULL; ifa=ifa->ifa_next) {
		
		memset(addrstr, 0, sizeof(addrstr));
		memset(netmaskstr, 0, sizeof(netmaskstr));
		if (ifa->ifa_addr->sa_family == AF_INET6) {
			
			inet_ntop(AF_INET6,
					  &((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_addr,
					  addrstr, sizeof(addrstr));
			
			
			inet_ntop(AF_INET6,
					  &((struct sockaddr_in6 *)ifa->ifa_netmask)->sin6_addr,
					  netmaskstr, sizeof(netmaskstr));

//			if(pFsInfo && ((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id<=0)
			if(((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id<=0)
				((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id = if_nametoindex(ifa->ifa_name);//find_ifscope_id(pFsInfo, ifa->ifa_name);
			
			fprintf(stderr,"[ipv6 BC] %s\n", ifa->ifa_name);
			fprintf(stderr,"[ipv6 BC] IPv6   : %s\n", addrstr);
			fprintf(stderr,"[ipv6 BC] netmask: %s\n", netmaskstr);
			fprintf(stderr,"[ipv6 BC] sin6_scope_id: %d\n", ((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id);
			
			
			nSendSock = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
			if (nSendSock == -1)
			{
				perror("[ipv6 BC] socket failed");
				continue;
			}
			struct sockaddr_in6 clnt_addr,dev_addr;
			memset(&clnt_addr, 0, sizeof(clnt_addr));
			clnt_addr.sin6_family = AF_INET6;
			inet_pton(AF_INET6, addrstr, &(clnt_addr.sin6_addr));
			clnt_addr.sin6_port = htons(0);
			clnt_addr.sin6_scope_id=((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id;
			
			if (bind(nSendSock, (struct sockaddr *) &clnt_addr,
					 sizeof(struct sockaddr_in6)) < 0)
			{
				perror("[ipv6 BC] ERROR on binding");
				close(nSendSock);
				//printf(" index = %d",index);
				continue;
			}
			
			memset(&RecvAddr, 0, sizeof(RecvAddr));

			
			char tmpip[255];
			sprintf(tmpip,"%s%s",ip,"%en0");
			printf("tmpip=%s\n", tmpip);
			
			RecvAddr.sin6_family = AF_INET6;
			inet_pton(AF_INET6, ip, &(RecvAddr.sin6_addr));
			//inet_pton(AF_INET6, tmpip, &(RecvAddr.sin6_addr));
			RecvAddr.sin6_port = htons(161);
			RecvAddr.sin6_scope_id=((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id;
			
			
			setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
			
			struct timeval timeout;
			timeout.tv_sec = 1;
			timeout.tv_usec = 0;
			setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
			
			nRet = sendto(nSendSock, request_oid, request_oid_len, 0, (struct sockaddr *) &RecvAddr, sizeof( struct sockaddr_in6));
			
			if (nRet <= 0)
			{
				perror("[ipv6 BC] snedto failed");
				close(nSendSock);
				//printf(" index = %d",index);
				continue;
				//return false;
			}
			
			while(1) 
			{
				socklen = sizeof(struct sockaddr_in6);
				int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
				//		printf("recvfrom nRecv = %d\n", nRecv);
				
				//printf(" nRecv = %d",nRecv);
				fprintf(stderr,"[ipv6 BC] nRecv = %d",nRecv);
				if (nRecv > 0) 
				{
					if(scope_id<=0)
					{
						scope_id=RecvAddr.sin6_scope_id;
						
						strcpy(g_ifsName, "%");
						strcat(g_ifsName, ifa->ifa_name);
					}
					if (parseForOID(response, nRecv, targetOID, oidlen))
					{
						//found=1;
						if (FindCallback != NULL)
						{
							char szAddr[255];
							
							//strcpy(szAddr, inet_ntoa(RecvAddr.sin_addr));
							inet_ntop(PF_INET6,&RecvAddr.sin6_addr,szAddr,sizeof(szAddr));
							//printf("szAddr=%s\n", szAddr);
							FindCallback(szAddr, NULL, param);
							
						}
					}
				} 
				else 
				{
					//perror("nRecv failed");
					break;
				}
				
			}
			
			close(nSendSock);
		}
		
	}
	freeifaddrs(ifa_list);

//	if(pFsInfo)
//	{
//		free_ifs_info(pFsInfo);
//	}

	return true;
}

#endif

#if 1
bool CNetIO::FindSnmpAgentV6(const char* community, const char* ip, const char* oid, LPFNFINDCALLBACK FindCallback, void* param, bool bBroadcast)
{
	const unsigned char request_oid_pf[] = {0xa0,0x19,0x02,0x01,0x00,0x02,0x01,0x00,0x02,0x01,0x00,
		0x30,0x0e,0x30,0x0c,0x06,0x08,0x2b,0x06,0x01,0x02,0x01,
	0x01,0x02,0x00,0x05,0x00};
	char	request_oid[256];
	int	request_oid_len;
	
	int nSendSock;
	int nRet;
	struct sockaddr_in6	RecvAddr;
	socklen_t socklen;
	BYTE		response[256];
	BYTE	targetOID[32];	

	struct ifs_info *pFsInfo = NULL;
	
	if (community==NULL || *community==0x00)
		community = "public";
	request_oid[0] = 0x30;
	request_oid[1] = 5+strlen(community)+sizeof(request_oid_pf);
	request_oid[2] = 0x02;
	request_oid[3] = 0x01;
	request_oid[4] = 0x00;
	request_oid[5] = 0x04;
	request_oid[6] = strlen(community);
	memcpy(&request_oid[7],community,strlen(community));
	memcpy(&request_oid[7+strlen(community)],request_oid_pf,sizeof(request_oid_pf));
	request_oid_len = 7+strlen(community)+sizeof(request_oid_pf);
	
	int oidlen = oidEncode(oid,targetOID);
	if (oidlen<=0)
	{
		return false;
	}
	
	int    bOptVal = 1;
	if(bBroadcast == false)
	{
		bOptVal = 0;
	}
	

	//RecvAddr.sin6_scope_id=0;
	
	//RecvAddr.sin_addr.s_addr = inet_addr(ip);
	char tmpip[255];
	sprintf(tmpip,"%s%s",ip,"%en0");
	

	
	inet_pton(AF_INET6, tmpip, &RecvAddr.sin6_addr);
	
	printf("ipv6=%s\n", tmpip);
	int index=0,found=0;

	pFsInfo = get_ifs_info(0, 0);
	
	for(;index<=65535&&found<=0;index++)
	{
		printf("\nfound=%d \n",found);
		nSendSock = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
		if (nSendSock == -1)
		{
			perror("socket failed");
			return false;
		}
		
		setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
		
		struct timeval timeout;
		timeout.tv_sec = 1;
		timeout.tv_usec = 0;
		setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
		
		RecvAddr.sin6_family = AF_INET6;
		RecvAddr.sin6_port = htons(161);
		
		if(scope_id>0)
		{
		
			printf("[if] scope_id=%d",scope_id);
			RecvAddr.sin6_scope_id=scope_id;
		}
		else
			RecvAddr.sin6_scope_id=index;
			
		for(int nTimeCount=0; nTimeCount<3; nTimeCount++)
		{
			nRet = sendto(nSendSock, request_oid, request_oid_len, 0, (struct sockaddr *) &RecvAddr, sizeof( struct sockaddr_in6));
			usleep(30);
		}

		printf("RecvAddr.sin6_scope_id=%d", RecvAddr.sin6_scope_id);
		/*	
		 printf("Sendto nRet = %d, request_oid_len=%d\n", nRet, request_oid_len);
		 
		 printf("request_oid=\n");
		 for(int i=0; i<request_oid_len; i++)
		 {
		 if((i+1)%8 == 0)
		 printf("%02x\n", (BYTE)request_oid[i]);
		 else
		 printf("%02x ", (BYTE)request_oid[i]);
		 }
		 
		 printf("\n");
		 */	
		if (nRet <= 0)
		{
			perror("sendto failed");
			close(nSendSock);
			printf(" index = %d",index);
			continue;
			//return false;
		}
	
		while(1) 
		{
			socklen = sizeof(RecvAddr);
			int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
			//		printf("recvfrom nRecv = %d\n", nRecv);
			
			printf(" nRecv = %d",nRecv);
			if (nRecv > 0) 
			{
				found=nRecv;
				if(scope_id<=0)
				{
					char* pName = find_ifname(pFsInfo, RecvAddr.sin6_scope_id);
					if(pName != NULL)
					{
						strcpy(g_ifsName, "%");
						strcat(g_ifsName, pName);
					}
					
					scope_id=RecvAddr.sin6_scope_id;
				}
				
				printf("[find] scope id=%d",scope_id);
				/*		
				 printf("response=\n");
				 for(int i=0; i<nRecv; i++)
				 {
				 if((i+1)%8 == 0)
				 printf("%02x\n", response[i]);
				 else
				 printf("%02x ", response[i]);
				 }
				 printf("\n");
				 */
				
				if (parseForOID(response, nRecv, targetOID, oidlen))
				{
					//found=1;
					if (FindCallback != NULL)
					{
						char szAddr[255];
						
						//strcpy(szAddr, inet_ntoa(RecvAddr.sin_addr));
						inet_ntop(PF_INET6,&RecvAddr.sin6_addr,szAddr,sizeof(szAddr));
						printf("szAddr=%s\n", szAddr);
						FindCallback(szAddr, NULL, param);
						
					}
				}
			} 
			else 
			{
				perror("nRecv failed");
				break;
			}
			
		 }
		 
		close(nSendSock);
	}
	
	if(pFsInfo)
	{
		free_ifs_info(pFsInfo);
	}
	
	return true;
}
#endif

BYTE	_sysObjIdOid[128];
BYTE	_sysNameOid[128];
BYTE	_pvtDevIdOid[128];
BYTE	_pvtFwVerOid[128];
BYTE	_pvtMcuVerOid[128];

int		_availFlag;

BYTE	_sysObjIdValue[128];
int		_sysObjIdLen;
char	_sysNameValue[128];
char	_pvtDevIdValue[512];
char	_pvtFwVerValue[128];
char	_pvtMcuVerValue[128];

static WORD	SNMPv3RequestID = 0;
static WORD SNMPv3MsgID = 0;
static DWORD salt_low = 0;

BYTE* CNetIO::berEncodeLength(BYTE* pValue, DWORD len)
{
	BYTE	*p = pValue;
	int		nBytes = 0;

	do {
		p--;
		nBytes++;
		*p = (BYTE)(0x000000ff & len);
		len = len>>8;
	} while (len!=0);

	if (nBytes==1 && *p<=127)
		return p;
	else {
		p--;
		*p = 0x80 | (BYTE)nBytes;
		return p;
	}
}
/*
Hint:
	SNMPv3 packet = [version] + [msgGlobalData] + [msgSecurityParameters] + [msgData]
	where [msgData] = [contextEngineID] + [contextName] + [PDU]
*/

// This function returns the number of byte built in <request> buffer if it successfully constructs the PDU.
// <raw_oid> can be NULL to build an PDU of empty varBindList

// Deprecated. Replaced with BuildSnmpV3PDU.

int CNetIO::BuildSnmpV3GetRequestPDU(WORD requestId, int nObjects, const char* raw_oid[], BYTE* request)
{
	BYTE	temp[MAX_SNMP_LEN], *p; // 484 is the maximum byte count for an SNMP message
	BYTE	oid[128];
	int	total;
	int	n;

	p = temp+MAX_SNMP_LEN;
	//////////////////////////////////////////////////////////
	total = 0;
	for (int i=nObjects-1;i>=0;i--) {
		p--;
		*p = 0; // value length
		p--;
		*p = 0x05; // type ID = NULL
		total += 2;
		n = oidEncode(raw_oid[i], oid);
		if (n<=0)
			return -1;
		p-=n;
		memcpy(p,oid,n); // OID
		total += n;
		p--;
		*p = n;
		p--;
		*p = 0x06; // type: OBJECT Identifier
		total += 2;
		p--;
		*p = 2+n+2;
		p--;
		*p = 0x30; // SEQUENCE
		total += 2;
	}
	p = berEncodeLength(p, total);
	p--;
	*p = 0x30; // SEQUENCE

	//////////////////////////////////////////////////////////
	p--;
	*p = 0x00; // error index is 0
	p--;
	*p = 0x01;
	p--;
	*p = 0x02;
	//////////////////////////////////////////////////////////
	p--;
	*p = 0x00; // error status noError (0)
	p--;
	*p = 0x01;
	p--;
	*p = 0x02;
	//////////////////////////////////////////////////////////
	p--;
	if (HIBYTE(requestId)!=0x00) {	// requestId
		*p = LOBYTE(requestId);
		p--;
		*p = HIBYTE(requestId);
		p--;
		*p = 0x02;
	} else {
		*p = LOBYTE(requestId);
		p--;
		*p = 0x01;
	}
	p--;
	*p = 0x02;
	//////////////////////////////////////////////////////////
	total = MAX_SNMP_LEN - (p-temp); // get request	
	p = berEncodeLength(p,total);
	p--;
	*p = 0xa0;
	//////////////////////////////////////////////////////////
	total = MAX_SNMP_LEN-(p-temp);
	memcpy(request,p,total);
	return total;
}

/*
Hint:
	SNMPv3 packet = [version] + [msgGlobalData] + [msgSecurityParameters] + [msgData]
	where [msgData] = [contextEngineID] + [contextName] + [PDU]
*/

// This function returns the number of byte built in <request> buffer if it successfully constructs the PDU.
// <raw_oid> can be NULL to build an PDU of empty varBindList
// For Get-Request, value, valueLen and typeID should be NULL.
int CNetIO::BuildSnmpV3PDU(WORD requestId, int nObjects, const char* raw_oid[], const BYTE* value[], const char valueLen[], const BYTE typeID[], BYTE* request)
{
	BYTE	temp[MAX_SNMP_LEN], *p; // 484 is the maximum byte count for an SNMP message
	BYTE	oid[128];
	int	total;
	int	n;

	p = temp+MAX_SNMP_LEN;
	//////////////////////////////////////////////////////////
	total = 0;
	for (int i=nObjects-1;i>=0;i--) {
		int valsize = 0;
		if (value!=NULL) {
			BYTE* q = p;
			p-=valueLen[i];
			memcpy(p,value[i],valueLen[i]);
			p = berEncodeLength(p, valueLen[i]);
			p--;
			*p = typeID[i]; // type ID = NULL
			valsize = (q-p);
			total += valsize;			
		} else {
			p--;
			*p = 0; // value length
			p--;
			*p = 0x05; // type ID = NULL
			valsize = 2;
			total += valsize;
		}
		n = oidEncode(raw_oid[i], oid);
		if (n<=0)
			return -1;
		p-=n;
		memcpy(p,oid,n); // OID
		total += n;
		p--;
		*p = n;
		p--;
		*p = 0x06; // type: OBJECT Identifier
		total += 2;
		p--;
		*p = 2+n+valsize;
		p--;
		*p = 0x30; // SEQUENCE
		total += 2;
	}
	p = berEncodeLength(p, total);
	p--;
	*p = 0x30; // SEQUENCE

	//////////////////////////////////////////////////////////
	p--;
	*p = 0x00; // error index is 0
	p--;
	*p = 0x01;
	p--;
	*p = 0x02;
	//////////////////////////////////////////////////////////
	p--;
	*p = 0x00; // error status noError (0)
	p--;
	*p = 0x01;
	p--;
	*p = 0x02;
	//////////////////////////////////////////////////////////
	p--;
	if (HIBYTE(requestId)!=0x00) {	// requestId
		*p = LOBYTE(requestId);
		p--;
		*p = HIBYTE(requestId);
		p--;
		*p = 0x02;
	} else {
		*p = LOBYTE(requestId);
		p--;
		*p = 0x01;
	}
	p--;
	*p = 0x02;
	//////////////////////////////////////////////////////////
	total = MAX_SNMP_LEN - (p-temp); // get/set request	
	p = berEncodeLength(p,total);
	p--;
	*p = value==NULL?0xa0:0xa3;
	//////////////////////////////////////////////////////////
	total = MAX_SNMP_LEN-(p-temp);
	memcpy(request,p,total);
	return total;
}

/*
Hint:
	SNMPv3 packet = [version] + [msgGlobalData] + [msgSecurityParameters] + [msgData]
	where [msgData] = [contextEngineID] + [contextName] + [PDU]
*/

// This function returns the number of byte built in <msgData> buffer if it successfully constructs it.
int CNetIO::BuildSnmpV3msgData(const BYTE *contextEngineID, int contextEngineIdLen, const char* contextName, WORD requestId, int nObjects, const char* oid[], const BYTE* value[], const char valueLen[], const BYTE typeID[], BYTE* msgData)
{
	BYTE	temp[MAX_SNMP_LEN], *p; // 484 is the maximum byte count for an SNMP message
	BYTE	tempPDU[MAX_SNMP_LEN];
	int	total = 0;
	int	n;

	if (msgData==NULL)
		return -1;
	int sizePDU = BuildSnmpV3PDU(requestId, nObjects, oid, value, valueLen, typeID, tempPDU);
	if (sizePDU<=0)
		return -1;
	p = temp + MAX_SNMP_LEN;
	p -= sizePDU;
	memcpy(p,tempPDU,sizePDU);
	// contextName
	int nLenContextLen;
	if (contextName==NULL)
		nLenContextLen = 0;
	else {
		nLenContextLen = strlen(contextName);
		p -= nLenContextLen;
		memcpy(p, contextName, nLenContextLen);
	}
	p--;
	*p = nLenContextLen;
	p--;
	*p = 0x04;
	// contextEngineID	
	if (contextEngineID==NULL || contextEngineIdLen<=0) {
		contextEngineIdLen = 0;
	} 
	if (contextEngineIdLen>0) {
		p -= contextEngineIdLen;
		memcpy(p,contextEngineID,contextEngineIdLen);
	}
	p--;
	*p = contextEngineIdLen;
	p--;
	*p = 0x04;
	///////////////////////
	total = MAX_SNMP_LEN - (p-temp);
	//p--;
	//*p = (BYTE)total;
	p = berEncodeLength(p,total);
	p--;
	*p = 0x30;
	///////////////////////
	total = MAX_SNMP_LEN - (p-temp);
	memcpy(msgData,p,total);
	return total;
}

/*
Hint:
	SNMPv3 packet = [version] + [msgGlobalData] + [msgSecurityParameters] + [msgData]

	RFC3414:
	(1) The msgSecurityParameters in an SNMP message are represented as an OCTET STRING.
	(2) The User-based Security Model defines the contents of the OCTET STRING as a SEQUENCE.
      04 <length>
      30 <length>
      04 <length> <msgAuthoritativeEngineID>
      02 <length> <msgAuthoritativeEngineBoots>
      02 <length> <msgAuthoritativeEngineTime>
      04 <length> <msgUserName>
      04 0c       <HMAC-MD5-96-digest>
      04 08       <salt>
*/

// This function returns the number of byte built in <msgSecurityParameters> buffer if it successfully constructs it.
int CNetIO::BuildSnmpV3msgSecurityParameters(const BYTE *contextEngineID, int contextEngineIdLen, int msgAuthoritativeEngineBoots, int msgAuthoritativeEngineTime, const char* msgUserName, const char* authPassword, const BYTE* msgPrivacyParameters, int msgPrivacyParametersLen, BYTE* msgSecurityParameters, DWORD* piAuthParamOffset)
{
	// initial authParameters
	BYTE	initAuthParameters[12];
	memset(initAuthParameters,0x00,12);


	BYTE	temp[MAX_SNMP_LEN], *p, *q; // 484 is the maximum byte count for an SNMP message
	int	total = 0;
	int	n;

	p = temp + MAX_SNMP_LEN;

	// msgPrivacyParameters
	if (msgPrivacyParametersLen>0) {
		p -= msgPrivacyParametersLen;
		memcpy(p,msgPrivacyParameters,msgPrivacyParametersLen);
	}
	p--;
	*p = msgPrivacyParametersLen;
	p--;
	*p = 0x04;

	// msgAuthenticationParameters
	if (authPassword!=NULL && strlen(authPassword)>0) {
		p -= 12;
		memset(p,0x00,12);		
		q = p; // to remember this offset so the final authParameters can be copied to this place
		p--;
		*p = 12;
	} else {
		p--;
		*p = 0x00;
	}
	p--;
	*p = 0x04;

	// msgUserName
	if (msgUserName==NULL)
		n = 0;
	else
		n = strlen(msgUserName);
	p -= n;
	memcpy(p,msgUserName,n);
	//p--;
	//*p = n;
	p = berEncodeLength(p,n);
	p--;
	*p = 0x04;

	// msgAuthoritativeEngineTime
	if (HIWORD(msgAuthoritativeEngineTime)) {
		p -= 4;
		*((DWORD*)p) = FLIPDWORD(msgAuthoritativeEngineTime);
		p--;
		*p = 4;
	} else if (HIBYTE(LOWORD(msgAuthoritativeEngineTime))) {
		p -= 2;
		*((WORD*)p) = FLIPWORD(LOWORD(msgAuthoritativeEngineTime));
		p--;
		*p = 2;
	} else {
		p--;
		*p = (BYTE)(0x000000ff & msgAuthoritativeEngineTime);
		p--;
		*p = 1;
	}
	p--;
	*p = 0x02;

	// msgAuthoritativeEngineBoots
	if (HIWORD(msgAuthoritativeEngineBoots)) {
		p -= 4;
		*((DWORD*)p) = FLIPDWORD(msgAuthoritativeEngineBoots);
		p--;
		*p = 4;
	} else if (HIBYTE(LOWORD(msgAuthoritativeEngineBoots))) {
		p -= 2;
		*((WORD*)p) = FLIPWORD(LOWORD(msgAuthoritativeEngineBoots));
		p--;
		*p = 2;
	} else {
		p--;
		*p = (BYTE)(0x000000ff & msgAuthoritativeEngineBoots);
		p--;
		*p = 1;
	}
	p--;
	*p = 0x02;

	// contextEngineID
	if (contextEngineID==NULL || contextEngineIdLen<=0)
		contextEngineIdLen = 0;
	else {		
		p -= contextEngineIdLen;
		memcpy(p,contextEngineID,contextEngineIdLen);
	}
	p--;
	*p = contextEngineIdLen;
	p--;
	*p = 0x04;

	// sequence
	total = MAX_SNMP_LEN - (p - temp);
	p = berEncodeLength(p,total);
	p--;
	*p = 0x30;
	// OCT STRING
	total = MAX_SNMP_LEN - (p - temp);
	p = berEncodeLength(p,total);
	p--;
	*p = 0x04;	
	total = MAX_SNMP_LEN - (p - temp);
	//////////////////////////////////////////

	if (piAuthParamOffset)
		*piAuthParamOffset = q-p;
	/////////////////////////////////////////////////////////////////////////////
	memcpy(msgSecurityParameters, p, total);
	return total;
}

/*
Hint:
	SNMPv3 packet = [version] + [msgGlobalData] + [msgSecurityParameters] + [msgData]
*/

// This function returns the number of byte built in <msgGlobalData> buffer if it successfully constructs it.
int CNetIO::BuildSnmpV3msgGlobalDataUSM(int msgID, int msgMaxSize, BOOL bReportable, BOOL bEncrypted, BOOL bAuthenticated, BYTE* msgGlobalData)
{
	BYTE	temp[MAX_SNMP_LEN], *p; // 484 is the maximum byte count for an SNMP message
	int	total = 0;

	p = temp + MAX_SNMP_LEN;
	// USM
	p--;
	*p = 0x03; // USM
	p--;
	*p = 0x01;
	p--;
	*p = 0x02;
	// msgFlags
	p--;
	*p = 0x00;
	if (bAuthenticated)
		*p |= 0x01;
	if (bEncrypted)
		*p |= 0x02;
	if (bReportable)
		*p |= 0x04;
	p--;
	*p = 0x01;
	p--;
	*p = 0x04;
	// msgMaxSize

	fprintf(stderr,"msgMaxSize=%x, FLIPWORD((LOWORD(msgMaxSize)))=%x\n", msgMaxSize, FLIPWORD((LOWORD(msgMaxSize))));

	if (msgMaxSize<256) {
		p--;
		*p = (BYTE)msgMaxSize;
		p--;
		*p = 0x01;
	} else if (msgMaxSize<65536) {
		p -= 2;
		*((WORD*)p) = FLIPWORD((LOWORD(msgMaxSize)));
		p--;
		*p = 0x02;
	} else {
		p -= 4;
		*((DWORD*)p) = FLIPDWORD(msgMaxSize);
		p--;
		*p = 0x04;
	}
	p--;
	*p = 0x02;
	// msgID
	if (msgID<256) {
		p--;
		*p = (BYTE)msgID;
		p--;
		*p = 0x01;
	} else if (msgID<65536) {
		p -= 2;
		*((WORD*)p) = FLIPWORD((LOWORD(msgID)));
		p--;
		*p = 0x02;
	} else {
		p -= 4;
		*((DWORD*)p) = FLIPDWORD(msgID);
		p--;
		*p = 0x04;
	}
	p--;
	*p = 0x02;
	// sequence
	total =  MAX_SNMP_LEN - (p - temp);
	//p--;
	//*p = (BYTE)total;
	p = berEncodeLength(p,total);

	p--;
	*p = 0x30;
	///////////////////////////////
	total =  MAX_SNMP_LEN - (p - temp);
	memcpy(msgGlobalData, p, total);
	return total;
}

/*
Hint:
	SNMPv3 packet = [version] + [msgGlobalData] + [msgSecurityParameters] + [msgData]
*/

// This function returns the number of byte built in <snmpV3Packet> buffer if it successfully constructs it.
int CNetIO::BuildSnmpV3Packet(BYTE* msgGlobalData, int msgGlobalDataLen, BYTE* msgSecurityParameters, int msgSecurityParametersLen, BYTE* msgData, int msgDataLen, DWORD* piAuthParamOffset, BYTE* snmpV3Packet)
{
	BYTE	temp[MAX_SNMP_LEN], *p, *q; // 484 is the maximum byte count for an SNMP message
	int	total = 0;
	int	n;

	p = temp + MAX_SNMP_LEN;

	// msgData
	p -= msgDataLen;
	memcpy(p,msgData,msgDataLen);
	// msgSecurityParameters
	p -= msgSecurityParametersLen;
	memcpy(p,msgSecurityParameters,msgSecurityParametersLen);
	// msgGlobalData
	p -= msgGlobalDataLen;
	memcpy(p,msgGlobalData,msgGlobalDataLen);

	if (piAuthParamOffset)
		*piAuthParamOffset += msgGlobalDataLen;
	q = p;
	// version
	p--;
	*p = 0x03;
	p--;
	*p = 0x01;
	p--;
	*p = 0x02;
	// sequence
	total = MAX_SNMP_LEN - (p-temp);
	p = berEncodeLength(p,total);
	/*
	if (total<=127) {
		p--;
		*p = (BYTE)total;
	} else {
		p -= 2;
		*p = ((BYTE)((total>>7)&0x0000007f))|0x80;
		*(p+1) = (BYTE)(total&0x0000007f);
	}*/
	p--;
	*p = 0x30;
	/////////////////
	if (piAuthParamOffset)
		*piAuthParamOffset += q-p;
	///////////////////////////////////////
	total = MAX_SNMP_LEN - (p-temp);
	memcpy(snmpV3Packet,p,total);
	return total;
}

// return the packet length
int CNetIO::BuildSnmpV3GetEngineIdPacket(WORD requestID, WORD msgID, BYTE* snmpv3Packet, int snmpv3PacketSize)
{
	BYTE msgData[MAX_SNMP_LEN];
	int	 msgDataLen;
	BYTE msgSecurityParameters[MAX_SNMP_LEN];
	int	 msgSecurityParametersLen;
	BYTE msgGlobalData[MAX_SNMP_LEN];
	int	 msgGlobalDataLen;

	msgDataLen = BuildSnmpV3msgData(NULL,0,NULL,requestID,0,NULL,NULL,NULL,NULL,msgData);
	msgSecurityParametersLen = BuildSnmpV3msgSecurityParameters(NULL,0,0,0,NULL,NULL,NULL,0,msgSecurityParameters,NULL);
	msgGlobalDataLen = BuildSnmpV3msgGlobalDataUSM(msgID,MAX_SNMP_LEN,TRUE,FALSE,FALSE,msgGlobalData);
	int snmpv3PacketLen = BuildSnmpV3Packet(msgGlobalData,msgGlobalDataLen,msgSecurityParameters,msgSecurityParametersLen,msgData,msgDataLen,NULL,snmpv3Packet);
	return snmpv3PacketLen;
}

BOOL CNetIO::parseSnmpV3Response(
	BYTE* udpdata, 
	int len, 
	int *version,
	BYTE* requestId, 
	BYTE* errorStatus, 
	BYTE* errorIndex, 
	SNMP_PARAM_V3* param)
{
	int	length;
	BYTE*	next;
	
	//// V3
	int	TempBuffSize;
	int msgId;
	int	msgSize;
	BYTE msgFlag;
	BYTE msgSecurityModel;
	BYTE msgEngineId[32];
	int  msgEngineIdLen;
	int  msgEngineBoots;
	int  msgEngineTime;
	char msgUserName[64];
	BYTE msgAuthParams[12];
	int  msgAuthParamsLen;
	BYTE msgPrivParams[64];
	int  msgPrivParamsLen;
	char contextName[64];
	
/*
	char	dbg[2048];
	memset(dbg,0x00,2048);
	//printf("Net: Entering parseSnmpV3Response!\n");
	for (int i=0;i<len;i++) {
		sprintf(dbg+i*3,"%02x ",udpdata[i]);
	}
	printf(dbg);
*/
	if (udpdata[0]!=0x30) {
		return FALSE;
	}
	
	//printf("Net: Entering parseSnmpV3Response0!\n");
	
	next = parseLength(&udpdata[1], &length);
	if (length!=len-(next-udpdata)) {
		return FALSE;
	}

	//printf("Net: Entering parseSnmpV3Response1!\n");
	
	TempBuffSize = length;
	// version
	if (next[0]!=0x02) {
		return FALSE;
	}

	//printf("Net: Entering parseSnmpV3Response2!\n");
	
	next++;
	next = parseLength(next, &length);
	if (version) {
		if (length==1)
			*version = (int)(*next);
		else	*version = (int)(*next); // I don'care such case!
	}
	next += length;

	// msgGlobalData 
	if (next[0]!=0x30)
		return FALSE;
	next++;
	next = parseLength(next, &length);	
	
	// msgId
	if (next[0]!=0x02) 
		return FALSE;
	next++;
	next = parseLength(next, &length);
	msgId = readIntValue(next,length);
	next += length;

	// maxSize
	if (next[0]!=0x02) 
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response3!\n");
		
	next++;
	next = parseLength(next, &length);
	msgSize = readIntValue(next,length);
	next += length;

	// msgFlag
	if (next[0]!=0x04) 
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response4!\n");
		
	next++;
	next = parseLength(next, &length);
	msgFlag = next[0];
	next += length;

	// msgSecurityModel
	if (next[0]!=0x02) 
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response5!\n");
		
	next++;
	next = parseLength(next, &length);
	msgSecurityModel = readIntValue(next,length);
	next += length;

	// msgSecurityParameters: OCT_STRING(SEQUENCE(engine_id, boots, time, ...))
	if (next[0]!=0x04)
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response6!\n");
		
	next++;
	next = parseLength(next, &length);

	if (next[0]!=0x30)
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response7!\n");
		
	next++;
	next = parseLength(next, &length);
	// EngineId
	if (next[0]!=0x04)
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response8!\n");
		
	next++;
	next = parseLength(next, &length);
	msgEngineIdLen = length;
	memcpy(msgEngineId,next,msgEngineIdLen);
	next += length;
	// msgAuthoritativeEngineBoots
	if (next[0]!=0x02)
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response9!\n");
		
	next++;
	next = parseLength(next, &length);
	msgEngineBoots = readIntValue(next, length);
	next += length;

	// msgAuthoritativeEngineTime
	if (next[0]!=0x02)
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response10!\n");
		
	next++;
	next = parseLength(next, &length);
	msgEngineTime = readIntValue(next, length);
	next += length;
	
	////////// save parsed value to param structure
	param->engineIDLen = msgEngineIdLen;
	memcpy(param->engineID,msgEngineId,msgEngineIdLen);
	param->msgAuthoritativeEngineBoots = msgEngineBoots;
	param->msgAuthoritativeEngineTime = msgEngineTime;
	///////////////////////////////////////////////

	// msgUserName
	if (next[0]!=0x04)
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response11!\n");
		
	next++;
	next = parseLength(next, &length);
	memset(msgUserName,0x00,sizeof(msgUserName));
	memcpy(msgUserName,next,length);
	next += length;

	// msgAuthParams;
	// msgAuthParamsLen;
	if (next[0]!=0x04)
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response12!\n");
		
	next++;
	next = parseLength(next, &length);
	msgAuthParamsLen = length;
	if (msgAuthParamsLen>0) {
		memset(msgAuthParams,0x00,sizeof(msgAuthParams));
		memcpy(msgAuthParams,next,msgAuthParamsLen);
		// clear authParam and check its correctness
		memset(next,0x00,msgAuthParamsLen);
		
		BYTE	K1[64], K2[64];
		AuthKey2K1K2(param->authKey,K1,K2);
		BYTE	msgAuthParam2[12];
		CalcuateAuthParams(udpdata,len,K1,K2,msgAuthParam2);
		if (memcmp(msgAuthParams,msgAuthParam2,msgAuthParamsLen)) {
			// Authentication error
			return FALSE;
		}
	}

	//printf("Net: Entering parseSnmpV3Response13!\n");

	next += length;

	// msgPrivParams[64];
	// msgPrivParamsLen;
	if (next[0]!=0x04)
		return FALSE;

	//printf("Net: Entering parseSnmpV3Response14!\n");
		
	next++;
	next = parseLength(next, &length);
	msgPrivParamsLen = length;
	memset(msgPrivParams,0x00,sizeof(msgPrivParams));
	memcpy(msgPrivParams,next,length);
	next += length;

	// msgData
	if (msgFlag&0x02) { // Encrypted
		if (next[0]!=0x04)
			return FALSE;
			
	//printf("Net: Entering parseSnmpV3Response15!\n");
			
		next++;
		next = parseLength(next, &length);
		if(!DecryptMsgData(next, length, param->privacyKey, msgPrivParams)) {
			return FALSE;
		}
	}

	//printf("Net: Entering parseSnmpV3Response16!\n");
	
	// msgData sequence
	if (next[0]!=0x30) {
		return FALSE;
	}

	//printf("Net: Entering parseSnmpV3Response17!\n");
	
	next++;
	next = parseLength(next, &length);
	// contextEngineID
	if (next[0]!=0x04) {
		return FALSE;
	}

	//printf("Net: Entering parseSnmpV3Response18!\n");

	next++;
	next = parseLength(next, &length);
	if (length!=msgEngineIdLen || memcmp(next,msgEngineId,msgEngineIdLen)) {
		return FALSE;
	}
	next += length;
	// contextName
	if (next[0]!=0x04) {
		return FALSE;
	}

	//printf("Net: Entering parseSnmpV3Response19!\n");
	
	next++;
	next = parseLength(next, &length);
	memset(contextName,0x00,sizeof(contextName));
	memcpy(contextName,next,length);
	next += length;

	// PDU type
	if (*next != 0xa2 && *next != 0xa3 && *next != 0xa8) { // check if it is GetResponse or SetResponse or Report
		return FALSE;
	}

	//printf("Net: Entering parseSnmpV3Response20!\n");
	
	next++;
	next = parseLength(next, &length);
	if (length>len-(next-udpdata)) { // not necessary to be equal because of padding for DES
		return FALSE;
	}
	// request ID
	if (next[0]!=0x02) {
		return FALSE;
	}

	//printf("Net: Entering parseSnmpV3Response21!\n");
	
	next++;
	next = parseLength(next, &length);
	if (requestId) {
		if (length==1)
			*requestId = *next;
		else	*requestId = *next; // I don'care such case!
	}
	next += length;
	// error status
	if (next[0]!=0x02) {
		return FALSE;
	}

	//printf("Net: Entering parseSnmpV3Response22!\n");
	
	next++;
	next = parseLength(next, &length);
	if (errorStatus) {
		if (length==1)
			*errorStatus = *next;
		else	*errorStatus = *next; // I don'care such case!
	}
	next += length;
	// error index
	if (next[0]!=0x02) {
		return FALSE;
	}

	//printf("Net: Entering parseSnmpV3Response23!\n");
	
	next++;
	next = parseLength(next, &length);
	if (errorIndex) {
		if (length==1)
			*errorIndex = *next;
		else	*errorIndex = *next; // I don'care such case!
	}
	next += length;
	
	// sequence for the list of name-value pairs
	if (*next!=0x30) {
		return FALSE;
	}

	//printf("Net: Entering parseSnmpV3Response24!\n");
	
	next++;
	next = parseLength(next, &length);
	BYTE* p = next;
	BYTE* q = next+length;
	while (p<q) {
		BYTE	*oidTemp;
		int	oidLen;
		BYTE	valType;
		BYTE*	value;
		int	valLen;
		// sequence for a name-value pair
		if (*p!=0x30) {
			return FALSE;
		}

	//printf("Net: Entering parseSnmpV3Response25!\n");
		
		p++;
		p = parseLength(p, &length);
		if (*p!=0x06) { // this should be an OID type
			return FALSE;
		}

	//printf("Net: Entering parseSnmpV3Response26!\n");
		
		p++;
		p = parseLength(p, &oidLen); // length of OID
		oidTemp = p;
		p += oidLen; // goto start of value
		valType = *p;
		p++;
		p = parseLength(p, &valLen);
		value = p;
		p = p+valLen;
		// call the callback function to report the name-value pair
		if (param->responseFunc) {
			param->responseFunc(oidTemp,oidLen,valType,value,valLen);
		}
	}

	//printf("Net: Entering parseSnmpV3Response27!\n");
	
	return TRUE; 
}

int CNetIO::BuildSnmpV3RequestPacket(const BYTE* engineID, int engineIDLen, DWORD msgAuthoritativeEngineBoots, DWORD msgAuthoritativeEngineTime, int nObjects, const char* raw_oid[], const BYTE* value[], const char valueLen[], const BYTE typeID[], const char* msgUserName, const char* passwdAuth, const char* passwdPriv, BYTE* authKey, BYTE* encryptKey, BYTE* snmpv3Packet)
{
	BYTE msgData[MAX_SNMP_LEN];
	int	 msgDataLen;
	BYTE msgSecurityParameters[MAX_SNMP_LEN];
	int	 msgSecurityParametersLen;
	BYTE msgGlobalData[MAX_SNMP_LEN];
	int	 msgGlobalDataLen;
	int	 snmpv3PacketLen;
	BYTE msgPrivacyParameters[8];
	BYTE tempBuff[MAX_SNMP_LEN];
	int j;

	memset(msgData,0x00,MAX_SNMP_LEN);
	msgDataLen = BuildSnmpV3msgData(engineID,engineIDLen,NULL,SNMPv3RequestID,nObjects,raw_oid,value,valueLen,typeID,msgData);
	SNMPv3RequestID++;	

	BYTE*	p;
	memset(encryptKey,0x00,16);
	if (passwdPriv) {		
		// Calculate IV (privParameters)		
		BYTE	IV[8];
		Password_to_Key_md5((BYTE*)passwdPriv,strlen(passwdPriv), engineID, engineIDLen, encryptKey);
		BYTE	PreIV[8];
		BYTE	salt[8];
		memcpy(PreIV,&encryptKey[8],8);
		*((DWORD*)&salt[0]) = FLIPDWORD(msgAuthoritativeEngineBoots);
		*((DWORD*)&salt[4]) = FLIPDWORD(salt_low);
		salt_low++;
		for (int i=0;i<8;i++)
			IV[i] = PreIV[i]^salt[i];
		//memcpy(msgPrivacyParameters, IV, 8);
		memcpy(msgPrivacyParameters, salt, 8);
		// Encrypt
		//DWORD encodeLen = ((msgDataLen+7)/8)*8;
		// test
		DWORD encodeLen = ((msgDataLen+7)/8)*8;
		if ((encodeLen=DesEncryption(encryptKey, IV, msgData, encodeLen, tempBuff, MAX_SNMP_LEN))<=0) {
			return 0;
		}
		p = msgData+MAX_SNMP_LEN-encodeLen;
		memcpy(p,tempBuff,encodeLen);
		p = berEncodeLength(p,encodeLen);
		p--;
		*p = 0x04;
		msgDataLen = msgData+MAX_SNMP_LEN-p;
	} else {
		p = msgData;
	}
	// now p points to the start point of [msgData] stream
	DWORD	iAuthParamOffset=0;	
		
	msgSecurityParametersLen = BuildSnmpV3msgSecurityParameters(engineID,engineIDLen,msgAuthoritativeEngineBoots,msgAuthoritativeEngineTime,msgUserName,passwdAuth,passwdPriv==NULL?NULL:msgPrivacyParameters,passwdPriv==NULL?0:8,msgSecurityParameters,passwdAuth?&iAuthParamOffset:NULL);
	
	msgGlobalDataLen = BuildSnmpV3msgGlobalDataUSM(SNMPv3MsgID,MAX_SNMP_LEN,TRUE,passwdPriv?TRUE:FALSE,passwdAuth?TRUE:FALSE,msgGlobalData);
	SNMPv3MsgID++;

	snmpv3PacketLen = BuildSnmpV3Packet(msgGlobalData,msgGlobalDataLen,msgSecurityParameters,msgSecurityParametersLen,p,msgDataLen,&iAuthParamOffset,snmpv3Packet);

	// Calculate authParameters 
	memset(authKey,0x00,16);
	if (passwdAuth) {
		Password_to_Key_md5((BYTE*)passwdAuth,strlen(passwdAuth),engineID, engineIDLen, authKey);
		BYTE	K1[64], K2[64];
		AuthKey2K1K2(authKey,K1,K2);
		BYTE	msgAuthParam[12];
		CalcuateAuthParams(snmpv3Packet,snmpv3PacketLen,K1,K2,msgAuthParam);
		memcpy(&snmpv3Packet[iAuthParamOffset],msgAuthParam,12);
	}
	return snmpv3PacketLen;
}

bool searchAgentProCallbackEx2(BYTE* oid, int oidLen, BYTE valueType, BYTE* valueData, int valueLen)
{
	// Pro
	if(!memcmp(oid,_sysObjIdOid,oidLen)) {
		memcpy(_sysObjIdValue,valueData,valueLen);
		_sysObjIdLen = valueLen;
		_availFlag |= 0x01;
		return TRUE;
	}
	if(!memcmp(oid,_sysNameOid,oidLen)) {
		memcpy((BYTE*)_sysNameValue,valueData,valueLen);
		_sysNameValue[valueLen] = 0x00;
		_availFlag |= 0x02;
		return TRUE;
	}
	// Ex1
	if(!memcmp(oid,_pvtFwVerOid,oidLen)) {
		memcpy((BYTE*)_pvtFwVerValue,valueData,valueLen);
		_pvtFwVerValue[valueLen] = 0x00;
		_availFlag |= 0x04;
		return TRUE;
	}
	if(!memcmp(oid,_pvtMcuVerOid,oidLen)) {
		memcpy((BYTE*)_pvtMcuVerValue,valueData,valueLen);
		_pvtMcuVerValue[valueLen] = 0x00;
		_availFlag |= 0x08;
		return TRUE;
	}

	return false;
}

void Big2LittleEndian_(char* src)
{
	int x = 1;
	bool little_endian = false;
	if (*(char *) &x ==1)
	{
		return;	    
	}

	char dst[4];
	dst[0] = src[3];
	dst[1] = src[2];
	dst[2] = src[1];
	dst[3] = src[0];

	memcpy(src, dst, 4);
}

bool CNetIO::FindSnmpV3Agent(const char* community, const char* ip, const char* oid, LPFNFINDCALLBACK FindCallback, void* param, bool bBroadcast)
{
	struct addrinfo *result;
    int error = getaddrinfo(ip, NULL, NULL, &result);
    if (error != 0)
    {   
        fprintf(stderr, "error in getaddrinfo: %s\n", gai_strerror(error));
        return -1;
    } 

	//DS_LogText("FindSnmpV3Agent enter\n");

	if(result->ai_family == AF_INET6)
	{
		return FindSnmpV3AgentV6_(community,ip,oid,FindCallback,param,bBroadcast); //Goto ipv6 fnc, Artanis added for #31399
	}

	BYTE	snmpv3GetEngineIdPacket[MAX_SNMP_LEN];
	int snmpv3GetEngineIdPacketLen = BuildSnmpV3GetEngineIdPacket(SNMPv3RequestID,SNMPv3MsgID,snmpv3GetEngineIdPacket,sizeof(snmpv3GetEngineIdPacket));
	SNMPv3RequestID++;
	SNMPv3MsgID++;

	int nSendSock;
	int nRet;
	struct sockaddr_in	RecvAddr;
	socklen_t socklen;
	BYTE		response[MAX_SNMP_LEN];

	oidEncode(SYSOBJECTID_OID,_sysObjIdOid);
	oidEncode(SYSNAME_OID,_sysNameOid);
	oidEncode(PVT_DEVICEID_OID,_pvtDevIdOid);

	struct ifaddrs *ifa_list;
	struct ifaddrs *ifa;
	int n;
	char addrstr[256], netmaskstr[256];
	
	n = getifaddrs(&ifa_list);
	if (n != 0) {
		perror("[ipv4 BC] getifaddrs Error! errno");
		return true;
	}

	for(ifa = ifa_list; ifa != NULL; ifa=ifa->ifa_next) {
		
		memset(addrstr, 0, sizeof(addrstr));
		memset(netmaskstr, 0, sizeof(netmaskstr));
		if (ifa->ifa_addr->sa_family == AF_INET) {
			
			inet_ntop(AF_INET,
					  &((struct sockaddr_in *)ifa->ifa_addr)->sin_addr,
					  addrstr, sizeof(addrstr));
			
			
			inet_ntop(AF_INET,
					  &((struct sockaddr_in *)ifa->ifa_netmask)->sin_addr,
					  netmaskstr, sizeof(netmaskstr));

			fprintf(stderr,"[ipv4 BC] %s\n", ifa->ifa_name);
			fprintf(stderr,"[ipv4 BC] IPv4   : %s\n", addrstr);
			fprintf(stderr,"[ipv4 BC] netmask: %s\n", netmaskstr);

			struct sockaddr_in clnt_addr;
			memset(&clnt_addr, 0, sizeof(clnt_addr));
			clnt_addr.sin_family = AF_INET;
			clnt_addr.sin_addr.s_addr = inet_addr(addrstr);
			clnt_addr.sin_port = htons(0);
			
			nSendSock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
			if (nSendSock == -1)
			{
			    continue;
			}

			int    bOptVal = 1;

			if(bBroadcast == false)
			{
				bOptVal = 0;
			}
			
			setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
			
			struct timeval timeout;
			timeout.tv_sec = 1;
			timeout.tv_usec = 0;
			setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
	
			if (bind(nSendSock, (struct sockaddr *) &clnt_addr,
					 sizeof(clnt_addr)) < 0)
			{
				perror("[ipv4 BC] ERROR on binding");
				close(nSendSock);
				//printf(" index = %d",index);
				continue;
			}

			RecvAddr.sin_family = AF_INET;
			RecvAddr.sin_port = htons(161);
			RecvAddr.sin_addr.s_addr = inet_addr(ip);
//			RecvAddr.sin_addr.s_addr = inet_addr("10.128.19.57");

			printf("ipv4=%s\n", ip);

		//	for(int nTimeCount=0; nTimeCount<3; nTimeCount++)
			{
				nRet = sendto(nSendSock, (char*)snmpv3GetEngineIdPacket, snmpv3GetEngineIdPacketLen, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
				printf("sendto: nRet=%d\n", nRet);
				
				usleep(30);
			}
			if (nRet <= 0)
			{
				close(nSendSock);
				continue;
			}

			int nRecvCount=0;
			while(1) 
			{
				socklen = sizeof(RecvAddr);
				int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
				if(nRecv>0)
				{
					char szAddr[256];

					strcpy(szAddr, inet_ntoa(RecvAddr.sin_addr));
					
					printf("recvfrom nRecv = %d, szAddr=%s\n", nRecv, szAddr);
					
					//if(strcmp(szAddr, "10.128.18.203") !=0)
					//	continue;
				}
/*				
				if(nRecv<=0)
				{
					if(nRecvCount++<3)
					{
						sleep(1);
						continue;
					}
				}
*/				
				if(nRecv > 0) 
				{
					BYTE	errorStatus;
					BYTE	errorIndex;
					SNMP_PARAM_V3	v3Param;
					BYTE		snmpv3RequestPacket[MAX_SNMP_LEN];
					unsigned long tempEngineID;
					
					const char*	printInfo[] = { SYSOBJECTID_OID, SYSNAME_OID, PVT_DEVICEID_OID };

					memset(&v3Param, 0, sizeof(SNMP_PARAM_V3));
					strcpy(v3Param.msgUserName,MSGUSERNAME);
					strcpy(v3Param.passwdAuth,PASSWDAUTH);
					strcpy(v3Param.passwdPriv,PASSWDPRIV);

					if (!parseSnmpV3Response(response, nRecv, NULL, NULL, &errorStatus, &errorIndex, &v3Param) || errorStatus!=0x00)
					{
						continue;			
					} 

					memcpy(&tempEngineID, v3Param.engineID, sizeof(tempEngineID));
					Big2LittleEndian_((char*)&tempEngineID);
					
					if(EngineEnterpriseId != tempEngineID)
						continue;

					int nSendSock2 = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
					if (nSendSock2 == -1)
					{
						continue;
					}

					setsockopt(nSendSock2, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

					//DS_LogText("FindSnmpV3Agent 4\n");

					if (bind(nSendSock2, (struct sockaddr *) &clnt_addr,
							 sizeof(clnt_addr)) < 0)
					{
						perror("nSendSock2 [ipv4 BC] ERROR on binding");
						close(nSendSock2);
						//printf(" index = %d",index);
						continue;
					}
					

					int snmpv3RequestPacketLen = BuildSnmpV3RequestPacket(v3Param.engineID, v3Param.engineIDLen, v3Param.msgAuthoritativeEngineBoots, v3Param.msgAuthoritativeEngineTime, 3, printInfo, NULL, NULL, NULL, v3Param.msgUserName, v3Param.passwdAuth, v3Param.passwdPriv, v3Param.authKey, v3Param.privacyKey, snmpv3RequestPacket);
					
					int n_sent = sendto(nSendSock2, (char*)snmpv3RequestPacket, snmpv3RequestPacketLen, 0, (struct sockaddr*)&RecvAddr, sizeof(RecvAddr));
					if (n_sent!=snmpv3RequestPacketLen) {
						close(nSendSock2);
						continue;		
					}

					while(1)
					{
						BYTE		response2[MAX_SNMP_LEN];
						socklen_t socklen2 = sizeof(RecvAddr);

						memset(response2, 0, sizeof(response2));	
						int nRecv2 = recvfrom(nSendSock2, response2, (size_t)sizeof(response2), 0, (struct sockaddr*) &RecvAddr, &socklen2);
						{
							char szAddr[256];

							strcpy(szAddr, inet_ntoa(RecvAddr.sin_addr));
							
							printf("recvfrom nRecv2 = %d, szAddr=%s\n", nRecv2, szAddr);
						}
						
						if(nRecv2 > 0) 
						{
							BYTE	errorStatus2;
							BYTE	errorIndex2;

							v3Param.responseFunc = NULL;//searchAgentProCallbackEx2; 

							printf("parseSnmpV3Response begin\n");
							if (!parseSnmpV3Response(response2, nRecv2, NULL, NULL, &errorStatus2, &errorIndex2, &v3Param) || errorStatus2!=0x00)
							{
								printf("parseSnmpV3Response end\n");
								continue;
							}

							printf("parseSnmpV3Response end1\n");

							bool	bFound=false;

							if (memcmp(_sysObjIdValue,m_targetOID,_sysObjIdLen)  == 0)
								bFound =  true;
				
							if (memcmp(_sysObjIdValue,m_targetOID1,_sysObjIdLen)  == 0)
								bFound =  true;

							if(bFound)
							{
		        				if (FindCallback != NULL)
								{
									char szAddr[256];

									strcpy(szAddr, inet_ntoa(RecvAddr.sin_addr));
									printf("FindSnmpV3Agent szAddr=%s\n", szAddr);
									FindCallback(szAddr, NULL, param);
								}
							}
						}
						else
						{
							printf("break\n");

							break;
						}
					}

					close(nSendSock2);
				} 
				else 
				{
					break;
					perror("v4 nRecv");
				}
			}

			close(nSendSock);
		}
	}

	freeifaddrs(ifa_list);
	
	return true;
}

bool CNetIO::FindSnmpV3AgentV6_(const char* community, const char* ip, const char* oid, LPFNFINDCALLBACK FindCallback, void* param, bool bBroadcast)
{
	int nSendSock;
	int nRet;
	struct sockaddr_in6	RecvAddr;
	socklen_t socklen;
	BYTE		response[MAX_SNMP_LEN];

	int    bOptVal = 1;
	if(bBroadcast == false)
	{
		bOptVal = 0;
	}
	
	BYTE	snmpv3GetEngineIdPacket[MAX_SNMP_LEN];
	int snmpv3GetEngineIdPacketLen = BuildSnmpV3GetEngineIdPacket(SNMPv3RequestID,SNMPv3MsgID,snmpv3GetEngineIdPacket,sizeof(snmpv3GetEngineIdPacket));
	SNMPv3RequestID++;
	SNMPv3MsgID++;

	oidEncode(SYSOBJECTID_OID,_sysObjIdOid);
	oidEncode(SYSNAME_OID,_sysNameOid);
	oidEncode(PVT_DEVICEID_OID,_pvtDevIdOid);

	struct ifaddrs *ifa_list;
	struct ifaddrs *ifa;
	int n;
	char addrstr[256], netmaskstr[256];
	
	n = getifaddrs(&ifa_list);
	if (n != 0) {
		perror("[ipv6 BC] getifaddrs Error! errno");
		return true;
	}

	for(ifa = ifa_list; ifa != NULL; ifa=ifa->ifa_next) {
		
		memset(addrstr, 0, sizeof(addrstr));
		memset(netmaskstr, 0, sizeof(netmaskstr));
		if (ifa->ifa_addr->sa_family == AF_INET6) {
			
			inet_ntop(AF_INET6,
					  &((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_addr,
					  addrstr, sizeof(addrstr));
			
			
			inet_ntop(AF_INET6,
					  &((struct sockaddr_in6 *)ifa->ifa_netmask)->sin6_addr,
					  netmaskstr, sizeof(netmaskstr));

//			if(pFsInfo && ((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id<=0)
			if(((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id<=0)
				((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id = if_nametoindex(ifa->ifa_name);//find_ifscope_id(pFsInfo, ifa->ifa_name);
			
			fprintf(stderr,"[ipv6 BC] %s\n", ifa->ifa_name);
			fprintf(stderr,"[ipv6 BC] IPv6   : %s\n", addrstr);
			fprintf(stderr,"[ipv6 BC] netmask: %s\n", netmaskstr);
			fprintf(stderr,"[ipv6 BC] sin6_scope_id: %d\n", ((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id);
			
			
			nSendSock = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
			if (nSendSock == -1)
			{
				perror("[ipv6 BC] socket failed");
				return false;
			}
			struct sockaddr_in6 clnt_addr,dev_addr;
			memset(&clnt_addr, 0, sizeof(clnt_addr));
			clnt_addr.sin6_family = AF_INET6;
			inet_pton(AF_INET6, addrstr, &(clnt_addr.sin6_addr));
			clnt_addr.sin6_port = htons(0);
			clnt_addr.sin6_scope_id=((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id;
			
			if (bind(nSendSock, (struct sockaddr *) &clnt_addr,
					 sizeof(struct sockaddr_in6)) < 0)
			{
				perror("[ipv6 BC] ERROR on binding");
				close(nSendSock);
				//printf(" index = %d",index);
				continue;
			}
			
			memset(&RecvAddr, 0, sizeof(RecvAddr));

			
			char tmpip[255];
			sprintf(tmpip,"%s%s",ip,"%en0");
			printf("tmpip=%s\n", tmpip);
			
			RecvAddr.sin6_family = AF_INET6;
			inet_pton(AF_INET6, ip, &(RecvAddr.sin6_addr));
			//inet_pton(AF_INET6, tmpip, &(RecvAddr.sin6_addr));
			RecvAddr.sin6_port = htons(161);
			RecvAddr.sin6_scope_id=((struct sockaddr_in6 *)ifa->ifa_addr)->sin6_scope_id;
			
			
			setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
			
			struct timeval timeout;
			timeout.tv_sec = 1;
			timeout.tv_usec = 0;
			setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
			
			nRet = sendto(nSendSock, (char*)snmpv3GetEngineIdPacket, snmpv3GetEngineIdPacketLen, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
			
			if (nRet <= 0)
			{
				perror("[ipv6 BC] snedto failed");
				close(nSendSock);
				//printf(" index = %d",index);
				continue;
			}
			
			while(1) 
			{
				socklen = sizeof(struct sockaddr_in6);
				int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
				//		printf("recvfrom nRecv = %d\n", nRecv);
				
				{
					char szAddr[256];
					inet_ntop(PF_INET6,&RecvAddr.sin6_addr,szAddr,sizeof(szAddr));
					printf("szAddr=%s\n", szAddr);
				}
				//printf(" nRecv = %d",nRecv);
				fprintf(stderr,"[ipv6 BC] nRecv = %d",nRecv);
				if (nRecv > 0) 
				{
					if(scope_id<=0)
					{
						scope_id=RecvAddr.sin6_scope_id;
						
						strcpy(g_ifsName, "%");
						strcat(g_ifsName, ifa->ifa_name);
					}

					BYTE	errorStatus;
					BYTE	errorIndex;
					SNMP_PARAM_V3	v3Param;
					BYTE		snmpv3RequestPacket[MAX_SNMP_LEN];
					const char*	printInfo[] = { SYSOBJECTID_OID, SYSNAME_OID, PVT_DEVICEID_OID };
					unsigned long tempEngineID;
					
					memset(&v3Param, 0, sizeof(SNMP_PARAM_V3));
					strcpy(v3Param.msgUserName,MSGUSERNAME);
					strcpy(v3Param.passwdAuth,PASSWDAUTH);
					strcpy(v3Param.passwdPriv,PASSWDPRIV);

					if (!parseSnmpV3Response(response, nRecv, NULL, NULL, &errorStatus, &errorIndex, &v3Param) || errorStatus!=0x00)
					{
						continue;			
					} 

					memcpy(&tempEngineID, v3Param.engineID, sizeof(tempEngineID));
					Big2LittleEndian_((char*)&tempEngineID);
					
					if(EngineEnterpriseId != tempEngineID)
						continue;

					int nSendSock2 = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
					if (nSendSock2 == -1)
					{
						continue;
					}

					if (bind(nSendSock2, (struct sockaddr *) &clnt_addr,
							 sizeof(struct sockaddr_in6)) < 0)
					{
						close(nSendSock2);
						continue;
					}

					setsockopt(nSendSock2, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

					int snmpv3RequestPacketLen = BuildSnmpV3RequestPacket(v3Param.engineID, v3Param.engineIDLen, v3Param.msgAuthoritativeEngineBoots, v3Param.msgAuthoritativeEngineTime, 3, printInfo, NULL, NULL, NULL, v3Param.msgUserName, v3Param.passwdAuth, v3Param.passwdPriv, v3Param.authKey, v3Param.privacyKey, snmpv3RequestPacket);

					printf("snmpv3RequestPacketLen = %d",snmpv3RequestPacketLen);
					
					int n_sent = sendto(nSendSock2, (char*)snmpv3RequestPacket, snmpv3RequestPacketLen, 0, (struct sockaddr*)&RecvAddr, sizeof(RecvAddr));
					if (n_sent!=snmpv3RequestPacketLen) {
						close(nSendSock2);
						continue;		
					}

					while(1)
					{
						BYTE		response2[MAX_SNMP_LEN];
						socklen_t socklen2 = sizeof(RecvAddr);

						int nRecv2 = recvfrom(nSendSock2, response2, (size_t)sizeof(response2), 0, (struct sockaddr*) &RecvAddr, &socklen2);
						if(nRecv2 > 0) 
						{
							BYTE	errorStatus2;
							BYTE	errorIndex2;

							{
								char szAddr[256];
								inet_ntop(PF_INET6,&RecvAddr.sin6_addr,szAddr,sizeof(szAddr));
								printf("szAddr=%s\n", szAddr);
							}

							v3Param.responseFunc = NULL;//searchAgentProCallbackEx2; 

							if (!parseSnmpV3Response(response2, nRecv2, NULL, NULL, &errorStatus2, &errorIndex2, &v3Param) || errorStatus2!=0x00)
							{
								continue;
							}

							bool	bFound=false;

							if (memcmp(_sysObjIdValue,m_targetOID,_sysObjIdLen)  == 0)
								bFound =  true;
		
							if (memcmp(_sysObjIdValue,m_targetOID1,_sysObjIdLen)  == 0)
								bFound =  true;

							if(bFound)
							{
        						if (FindCallback != NULL)
								{
									char szAddr[256];

									inet_ntop(PF_INET6,&RecvAddr.sin6_addr,szAddr,sizeof(szAddr));
									printf("FindSnmpV3AgentV6_ szAddr=%s\n", szAddr);
									FindCallback(szAddr, NULL, param);
								}
							}
						}
						else
						{
							break;
						}
					}

					close(nSendSock2);

				} 
				else 
				{
					break;
				}
				
			}
			
			close(nSendSock);
		}
	}
	freeifaddrs(ifa_list);

	return true;
}

int CNetIO::NetworkConnectV6(char *server, int port)
{
	char ipv6[256];
	strcpy(ipv6, server);
	strcat(ipv6, g_ifsName);
	printf("NetworkConnectV6=%s\n", ipv6);

	
	if(m_socket.Open(AF_INET6, SOCK_STREAM, IPPROTO_TCP)!=0)
		return -1;
	
	struct sockaddr_in6 sin;
	
	memset(&sin, 0, sizeof(sin));
	
	sin.sin6_len = sizeof(sin);
	sin.sin6_family = AF_INET6;
	sin.sin6_scope_id=scope_id;
	//sin.sin_addr.s_addr = inet_addr(ipv6);
	inet_pton(AF_INET6, ipv6, &sin.sin6_addr);
	sin.sin6_port = htons(port);
	int nRet = m_socket.Connect((const struct sockaddr *)&sin, sizeof(sin));
	printf("nRet = %x\n", nRet);
	return nRet;
	
}	

int CNetIO::NetworkConnect(char *server, int port)
{
	struct addrinfo *result;

	printf("NetworkConnect server=%s\n", server);
	
	/* resolve the domain name into a list of addresses */
    int error = getaddrinfo(server, NULL, NULL, &result);
    if (error != 0)
    {   
        fprintf(stderr, "error in getaddrinfo: %s\n", gai_strerror(error));
        return -1;
    } 
	if(result->ai_family == AF_INET6)
	{
		int nReturn = NetworkConnectV6(server,port);
		printf("nReturn = %x\n", nReturn);
		return nReturn;
	}
		
	
	
	if(m_socket.Open(AF_INET, SOCK_STREAM, IPPROTO_TCP)!=0)
		return -1;

	struct sockaddr_in sin;

	memset(&sin, 0, sizeof(sin));

	sin.sin_len = sizeof(sin);
	sin.sin_family = AF_INET;
	sin.sin_addr.s_addr = inet_addr(server);
	sin.sin_port = htons(port);
	return m_socket.Connect((const struct sockaddr *)&sin, sizeof(sin));
						
/*
	int sd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	printf("NetworkConnect sd=%d server=%s, port=%d\n", sd, server, port);
	if(sd<0)
		return -1;
	
       int err = fcntl(sd, F_SETFL, O_NONBLOCK);
        if (err < 0) 
        {
        	close(sd);
        	return -1;
        }

	struct sockaddr_in sin;

	memset(&sin, 0, sizeof(sin));

	sin.sin_len = sizeof(sin);
	sin.sin_family = AF_UNSPEC;
	sin.sin_addr.s_addr = inet_addr(server);
	sin.sin_port = htons(23010);

	int rc = connect(sd, (const struct sockaddr*)&sin, sizeof(sin)); 		
	printf("NetworkConnect rc=%d\n", rc);
	if(rc<0)
	{
		close(sd);
		return -1;
	}

	return sd;
*/	
}

int CNetIO::NetworkRead(int sd, void* buff, DWORD len) 
{
	size_t bytesRead;
	m_socket.Read(buff, len, &bytesRead);
	return bytesRead;
/*	
	int total_read = 0;
	int nRead;
	while (total_read<len) {
		nRead =  recv(sd, (char*)buff+total_read, len-total_read,0);
		if (nRead>0) {
			total_read += nRead;
		} else	{
			break;
		}
	}
	return total_read;
*/	
}

int CNetIO::NetworkWrite(int sd, void* buff, DWORD len) 
{
	size_t bytesWritten;
	m_socket.Write(buff, len, &bytesWritten);
	return bytesWritten;
/*	
	int total_sent = 0;
	int sent;
	while (total_sent<len) {
		sent = send(sd, (char*)buff+total_sent, len-total_sent, 0);
		if (sent>0) {
			total_sent += sent;
		} else	{
			break;
		}
	}
	return total_sent;
*/	
}

void CNetIO::NetworkClose(int sd)
{
	m_socket.Close();
	//close(sd);
}

bool CNetIO::NetSnmpGetV4(const char* ip, char* community, char* oid, char* buf, int buffsize)
{
	bool bRet = false;
	char SendBuf[1024];
	int nSendSock;
	int nRet;
	struct sockaddr_in	RecvAddr;
	socklen_t socklen;
	BYTE		response[256];

	nSendSock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (nSendSock == -1)
	{
	    return bRet;
	}

	int    bOptVal = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
	
	struct timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    
	RecvAddr.sin_family = AF_INET;
	RecvAddr.sin_port = htons(161);
	RecvAddr.sin_addr.s_addr = inet_addr(ip);

	int SendLen = BuildGetRequestFor(1, oid, community, (BYTE*)SendBuf);

//	nRet = sendto(nSendSock, SendBuf, SendLen, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
	for(int nTimeCount=0; nTimeCount<3; nTimeCount++)
	{
		nRet = sendto(nSendSock, SendBuf, SendLen, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
		usleep(30);
	}
	
	if (nRet <= 0)
	{
		close(nSendSock);
		return bRet;
	}

	socklen = sizeof(RecvAddr);
	int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
	printf("NetSnmpGetV4 recvfrom nRecv = %d\n", nRecv);
	if (nRecv > 0) 
	{
		bRet = parseForRecvBuf(response, nRecv, buf);
	} 

	close(nSendSock);

	return bRet;
}

bool CNetIO::NetSnmpGetV4SNMPv3(const char* ip, char* name, char* fwVersion, char* MCUVersion, int buffsize)
{
	bool bRet = false;
	
	BYTE	snmpv3GetEngineIdPacket[MAX_SNMP_LEN];
	int snmpv3GetEngineIdPacketLen = BuildSnmpV3GetEngineIdPacket(SNMPv3RequestID,SNMPv3MsgID,snmpv3GetEngineIdPacket,sizeof(snmpv3GetEngineIdPacket));
	SNMPv3RequestID++;
	SNMPv3MsgID++;

	int nSendSock;
	int nRet;
	struct sockaddr_in	RecvAddr;
	socklen_t socklen;
	BYTE		response[MAX_SNMP_LEN];

	nSendSock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (nSendSock == -1)
	{
		return bRet;
	}

	int    bOptVal = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));

	struct timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
	
	RecvAddr.sin_family = AF_INET;
	RecvAddr.sin_port = htons(161);
	RecvAddr.sin_addr.s_addr = inet_addr(ip);

	printf("ipv4=%s\n", ip);

	nRet = sendto(nSendSock, (char*)snmpv3GetEngineIdPacket, snmpv3GetEngineIdPacketLen, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
	printf("sendto: nRet=%d\n", nRet);
	if (nRet <= 0)
	{
		close(nSendSock);
		return bRet;
	}

	int nRecvCount=0;
	while(1) 
	{
		socklen = sizeof(RecvAddr);
		int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
		if(nRecv>0)
		{
			char szAddr[256];
			strcpy(szAddr, inet_ntoa(RecvAddr.sin_addr));
			printf("recvfrom nRecv = %d, szAddr=%s\n", nRecv, szAddr);

			BYTE	errorStatus;
			BYTE	errorIndex;
			SNMP_PARAM_V3	v3Param;
			BYTE		snmpv3RequestPacket[MAX_SNMP_LEN];
			unsigned long tempEngineID;
					
			const char*	printInfo[] = { SYSNAME_OID, PVT_FWVER_OID, PVT_MCUVER_OID };

			oidEncode(SYSNAME_OID,_sysNameOid);
			oidEncode(PVT_FWVER_OID,_pvtFwVerOid);
			oidEncode(PVT_MCUVER_OID,_pvtMcuVerOid);

			memset(_sysNameValue, 0, sizeof(_sysNameValue));
			memset(_pvtFwVerValue, 0, sizeof(_pvtFwVerValue));
			memset(_pvtMcuVerValue, 0, sizeof(_pvtMcuVerValue));

			memset(&v3Param, 0, sizeof(SNMP_PARAM_V3));
			strcpy(v3Param.msgUserName,MSGUSERNAME);
			strcpy(v3Param.passwdAuth,PASSWDAUTH);
			strcpy(v3Param.passwdPriv,PASSWDPRIV);

			if (!parseSnmpV3Response(response, nRecv, NULL, NULL, &errorStatus, &errorIndex, &v3Param) || errorStatus!=0x00)
			{
				continue;			
			} 

			memcpy(&tempEngineID, v3Param.engineID, sizeof(tempEngineID));
			Big2LittleEndian_((char*)&tempEngineID);
					
			if(EngineEnterpriseId != tempEngineID)
				continue;

			int nSendSock2 = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
			if (nSendSock2 == -1)
			{
				continue;
			}

			setsockopt(nSendSock2, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

			int snmpv3RequestPacketLen = BuildSnmpV3RequestPacket(v3Param.engineID, v3Param.engineIDLen, v3Param.msgAuthoritativeEngineBoots, v3Param.msgAuthoritativeEngineTime, 3, printInfo, NULL, NULL, NULL, v3Param.msgUserName, v3Param.passwdAuth, v3Param.passwdPriv, v3Param.authKey, v3Param.privacyKey, snmpv3RequestPacket);
					
			int n_sent = sendto(nSendSock2, (char*)snmpv3RequestPacket, snmpv3RequestPacketLen, 0, (struct sockaddr*)&RecvAddr, sizeof(RecvAddr));
			if (n_sent!=snmpv3RequestPacketLen) {
				close(nSendSock2);
				continue;		
			}

			while(1)
			{
				BYTE		response2[MAX_SNMP_LEN];
				socklen_t socklen2 = sizeof(RecvAddr);

				memset(response2, 0, sizeof(response2));	
				int nRecv2 = recvfrom(nSendSock2, response2, (size_t)sizeof(response2), 0, (struct sockaddr*) &RecvAddr, &socklen2);
						
				if(nRecv2 > 0) 
				{
					BYTE	errorStatus2;
					BYTE	errorIndex2;

					v3Param.responseFunc = searchAgentProCallbackEx2; 

					printf("parseSnmpV3Response begin\n");
					if (!parseSnmpV3Response(response2, nRecv2, NULL, NULL, &errorStatus2, &errorIndex2, &v3Param) || errorStatus2!=0x00)
					{
						continue;
					}

					if(strlen(_sysNameValue)>0)
					{
						strcpy(name, _sysNameValue);
						bRet = true;
					}
					
					if(strlen(_pvtFwVerValue)>0)
					{
						strcpy(fwVersion, _pvtFwVerValue);
						bRet = true;
					}

					if(strlen(_pvtMcuVerValue)>0)
					{
						strcpy(MCUVersion, _pvtMcuVerValue);
						bRet = true;
					}
				}
				else
				{
					break;
				}
			}

			close(nSendSock2);
		} 
		else 
		{
			break;
		}
	}

	close(nSendSock);

	return bRet;

}

bool CNetIO::NetSnmpGetV6(const char* ip, char* community, char* oid, char* buf, int buffsize)
{
	bool bRet = false;
	char SendBuf[1024];
	int nSendSock;
	int nRet;
	struct sockaddr_in6	RecvAddr;
	socklen_t socklen;
	BYTE		response[256];
	
	nSendSock = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
	if (nSendSock == -1)
	{
	    return bRet;
	}
	
	int    bOptVal = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
	
	struct timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

	RecvAddr.sin6_family = AF_INET6;
	RecvAddr.sin6_port = htons(161);
	//RecvAddr.sin_addr.s_addr = inet_addr(ip);
	inet_pton(AF_INET6, ip , &RecvAddr.sin6_addr);
	RecvAddr.sin6_scope_id=scope_id;
	printf("scope id=%d",scope_id);
	int SendLen = BuildGetRequestFor(1, oid, community, (BYTE*)SendBuf);
	
//	nRet = sendto(nSendSock, SendBuf, SendLen, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));

	for(int nTimeCount=0; nTimeCount<3; nTimeCount++)
	{
		nRet = sendto(nSendSock, SendBuf, SendLen, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
		usleep(30);
	}

	
	if (nRet <= 0)
	{
		perror("getv6 nRet");
		close(nSendSock);
		return bRet;
	}
	
	socklen = sizeof(RecvAddr);
	int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
	printf("NetSnmpGetV4 recvfrom nRecv = %d\n", nRecv);
	if (nRecv > 0) 
	{
		bRet = parseForRecvBuf(response, nRecv, buf);
	} 
	
	close(nSendSock);
	
	return bRet;
}

bool CNetIO::NetSnmpGetV6SNMPv3(const char* ip, char* name, char* fwVersion, char* MCUVersion, int buffsize)
{
	bool bRet = false;
	int nSendSock;
	int nRet;
	struct sockaddr_in6	RecvAddr;
	socklen_t socklen;
	BYTE		response[MAX_SNMP_LEN];

	BYTE	snmpv3GetEngineIdPacket[MAX_SNMP_LEN];
	int snmpv3GetEngineIdPacketLen = BuildSnmpV3GetEngineIdPacket(SNMPv3RequestID,SNMPv3MsgID,snmpv3GetEngineIdPacket,sizeof(snmpv3GetEngineIdPacket));
	SNMPv3RequestID++;
	SNMPv3MsgID++;

	nSendSock = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
	if (nSendSock == -1)
	{
	    return bRet;
	}

	int    bOptVal = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
	
	RecvAddr.sin6_family = AF_INET6;
	RecvAddr.sin6_port = htons(161);
	inet_pton(AF_INET6, ip , &RecvAddr.sin6_addr);
	RecvAddr.sin6_scope_id=scope_id;

	struct timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
			
	nRet = sendto(nSendSock, (char*)snmpv3GetEngineIdPacket, snmpv3GetEngineIdPacketLen, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));

	if (nRet <= 0)
	{
		perror("[ipv6 BC] snedto failed");
		close(nSendSock);
		return bRet;
	}
			
	while(1) 
	{
		socklen = sizeof(struct sockaddr_in6);
		int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
		fprintf(stderr,"[ipv6 BC] nRecv = %d",nRecv);
		if (nRecv > 0) 
		{
			BYTE	errorStatus;
			BYTE	errorIndex;
			SNMP_PARAM_V3	v3Param;
			BYTE		snmpv3RequestPacket[MAX_SNMP_LEN];
			unsigned long tempEngineID;

			const char*	printInfo[] = { SYSNAME_OID, PVT_FWVER_OID, PVT_MCUVER_OID };

			oidEncode(SYSNAME_OID,_sysNameOid);
			oidEncode(PVT_FWVER_OID,_pvtFwVerOid);
			oidEncode(PVT_MCUVER_OID,_pvtMcuVerOid);

			memset(_sysNameValue, 0, sizeof(_sysNameValue));
			memset(_pvtFwVerValue, 0, sizeof(_pvtFwVerValue));
			memset(_pvtMcuVerValue, 0, sizeof(_pvtMcuVerValue));

			memset(&v3Param, 0, sizeof(SNMP_PARAM_V3));
			strcpy(v3Param.msgUserName,MSGUSERNAME);
			strcpy(v3Param.passwdAuth,PASSWDAUTH);
			strcpy(v3Param.passwdPriv,PASSWDPRIV);

			if (!parseSnmpV3Response(response, nRecv, NULL, NULL, &errorStatus, &errorIndex, &v3Param) || errorStatus!=0x00)
			{
				continue;			
			} 

			memcpy(&tempEngineID, v3Param.engineID, sizeof(tempEngineID));
			Big2LittleEndian_((char*)&tempEngineID);
					
			if(EngineEnterpriseId != tempEngineID)
				continue;

			int nSendSock2 = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
			if (nSendSock2 == -1)
			{
				continue;
			}

			setsockopt(nSendSock2, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

			int snmpv3RequestPacketLen = BuildSnmpV3RequestPacket(v3Param.engineID, v3Param.engineIDLen, v3Param.msgAuthoritativeEngineBoots, v3Param.msgAuthoritativeEngineTime, 3, printInfo, NULL, NULL, NULL, v3Param.msgUserName, v3Param.passwdAuth, v3Param.passwdPriv, v3Param.authKey, v3Param.privacyKey, snmpv3RequestPacket);

			int n_sent = sendto(nSendSock2, (char*)snmpv3RequestPacket, snmpv3RequestPacketLen, 0, (struct sockaddr*)&RecvAddr, sizeof(RecvAddr));
			if (n_sent!=snmpv3RequestPacketLen) {
				close(nSendSock2);
				continue;		
			}

			while(1)
			{
				BYTE		response2[MAX_SNMP_LEN];
				socklen_t socklen2 = sizeof(RecvAddr);

				int nRecv2 = recvfrom(nSendSock2, response2, (size_t)sizeof(response2), 0, (struct sockaddr*) &RecvAddr, &socklen2);
				if(nRecv2 > 0) 
				{
					BYTE	errorStatus2;
					BYTE	errorIndex2;

					v3Param.responseFunc = searchAgentProCallbackEx2; 

					if (!parseSnmpV3Response(response2, nRecv2, NULL, NULL, &errorStatus2, &errorIndex2, &v3Param) || errorStatus2!=0x00)
					{
						continue;
					}

					if(strlen(_sysNameValue)>0)
					{
						strcpy(name, _sysNameValue);
						bRet = true;
					}

					if(strlen(_pvtFwVerValue)>0)
					{
						strcpy(fwVersion, _pvtFwVerValue);
						bRet = true;
					}

					if(strlen(_pvtMcuVerValue)>0)
					{
						strcpy(MCUVersion, _pvtMcuVerValue);
						bRet = true;
					}
				}
				else
				{
					break;
				}
			}

			close(nSendSock2);

		} 
		else 
		{
			break;
		}
				
	}
			
	close(nSendSock);

	return bRet;}

int CNetIO::GrandeNetworkGetPrinterName(const char* ip, BYTE ipversion, char* name, int buffsize)
{
	bool bRet = false;
	
	char	oid[128]="1.3.6.1.2.1.1.5.0"; // for printer name
	printf("GrandeNetworkGetPrinterName enter\n");
	struct addrinfo *result;
	/* resolve the domain name into a list of addresses */
	int error = getaddrinfo(ip, NULL, NULL, &result);
	if (error != 0)
	{   
		fprintf(stderr, "error in getaddrinfo: %s\n", gai_strerror(error));
		return -1;
	}

#if (PERRY_CP115W || PERRY_CP116W || PERRY_CP225W || PERRY_CM115W || PERRY_CM225FW || PERRY_6020 || PERRY_6022 || PERRY_6025 || PERRY_6027)
    	FILE *fp; 
	char cline[1024]; 
	char szCmd[1024];
	
	sprintf(szCmd, "smbutil status %s", ip);

	for(int i=0; i<3; i++)
	{
		fp = popen(szCmd, "r"); 

		while(!feof(fp)) 
		{ 
			memset(cline, 0, sizeof(cline)); 
			fgets(cline, 1024, fp); 
			if(cline[0] == NULL) 
				break; 

			char* pStr = strstr(cline, "Server: ");
			if(pStr)
			{
			//	for(int i=0; i<strlen(cline); i++)
			//		fprintf(stderr, "%x ", cline[i]);
				strcpy(name, pStr+strlen("Server: "));
				int nLength = strlen(name);
				if(nLength > 0)
					name[nLength - 1] = 0;
				bRet = true;
				break;
			}
		} 
		
		pclose(fp); 

		if(bRet == true)
			break;

		sleep(1);
	}

	if(bRet == false)
		if(result->ai_family == AF_INET6)
		{
			bRet = NetSnmpGetV6(ip, "public", oid, name, buffsize);
			if(bRet == false)
				bRet = NetSnmpGetV6(ip, "public", oid, name, buffsize);
		}
		else	
			bRet = NetSnmpGetV4(ip, "public", oid, name,buffsize);
#else
	if(result->ai_family == AF_INET6)
	{
		bRet = NetSnmpGetV6(ip, "public", oid, name, buffsize);
		if(bRet == false)
			bRet = NetSnmpGetV6(ip, "public", oid, name, buffsize);
	}
	else	
		bRet = NetSnmpGetV4(ip, "public", oid, name,buffsize);
#endif

	if(bRet == true)
		return 0;
	else
		return -1;
}

int CNetIO::GrandeNetworkGetNameAndFwAndMCUVersion(const char* ip, char* name, char* fwVersion, char* MCUVersion, int buffsize)
{
	bool bRet = false;

	struct addrinfo *result;
    int error = getaddrinfo(ip, NULL, NULL, &result);
    if (error != 0)
    {   
        fprintf(stderr, "error in getaddrinfo: %s\n", gai_strerror(error));
        return -1;
    } 
	if(result->ai_family == AF_INET6)
	{
		bRet = NetSnmpGetV6SNMPv3(ip, name, fwVersion, MCUVersion, buffsize);
	}
	else	
		bRet = NetSnmpGetV4SNMPv3(ip, name, fwVersion, MCUVersion, buffsize);

	if(bRet == true)
		return 0;
	else
		return -1;
}

int CNetIO::GrandeNetworkGetFwVersion(const char* ip, BYTE ipversion, char* version, int buffsize)
{
	bool bRet = false;
	
	char	oid[128]="1.3.6.1.4.1.26266.886.300.369.8531.1.2.1.0"; // for firmware version
	printf("GrandeNetworkGetFwVersion enter\n");
	struct addrinfo *result;
	/* resolve the domain name into a list of addresses */
    int error = getaddrinfo(ip, NULL, NULL, &result);
    if (error != 0)
    {   
        fprintf(stderr, "error in getaddrinfo: %s\n", gai_strerror(error));
        return -1;
    } 
	if(result->ai_family == AF_INET6)
	{
		bRet = NetSnmpGetV6(ip, "public", oid, version, buffsize);
		if(bRet == false)
			bRet = NetSnmpGetV6(ip, "public", oid, version, buffsize);
	}
	else	
		bRet = NetSnmpGetV4(ip, "public", oid, version, buffsize);

	if(bRet == true)
		return 0;
	else
		return -1;
}

int CNetIO::GrandeNetworkGetFwMCUVersion(const char* ip, BYTE ipversion, char* version, int buffsize)
{
	bool bRet = false;
	
	char	oid[128]="1.3.6.1.4.1.26266.886.300.369.8531.1.2.3.0"; // for firmware MCU version
	printf("GrandeNetworkGetFwMCUVersion enter\n");
	struct addrinfo *result;
	/* resolve the domain name into a list of addresses */
    int error = getaddrinfo(ip, NULL, NULL, &result);
    if (error != 0)
    {   
        fprintf(stderr, "error in getaddrinfo: %s\n", gai_strerror(error));
        return -1;
    } 
	if(result->ai_family == AF_INET6)
	{
		bRet = NetSnmpGetV6(ip, "public", oid, version, buffsize);
		if(bRet == false)
			bRet = NetSnmpGetV6(ip, "public", oid, version, buffsize);
	}
	else	
		bRet = NetSnmpGetV4(ip, "public", oid, version, buffsize);

	if(bRet == true)
		return 0;
	else
		return -1;
}

bool CNetIO::NetworkReadStatusV6(const char* community, const char* ip, PRINTER_STATUS *status,char *DeviceID)
{
	bool bRet = false;
	
	unsigned char std_liteon_device_id_req[51] = {0x30, 0x31, 0x02, 0x01, 0x00, 0x04, 0x06, 0x70, 0x75, 0x62, 0x6c, 0x69, 0x63, 0xa0, 0x24, 0x02, 0x01, 0x00, 0x02, 0x01, 0x00, 0x02, 0x01, 0x00, 0x30, 0x19, 0x30, 0x17, 0x06, 0x13, 0x2b, 0x06, 0x01, 0x04, 0x01, 0x81, 0xcd, 0x1a, 0x86, 0x76, 0x82, 0x2c, 0x82, 0x71, 0xc2, 0x53, 0x01, 0x01, 0x00, 0x05, 0x00, };
	
	int std_len = 51;
	
	
	char liteon_device_id_req[256];
	int total;
	total = std_len-13; // the length after "public"
	liteon_device_id_req[0] = 0x30;
	liteon_device_id_req[1] = total+strlen(community)+2+3;
	liteon_device_id_req[2] = 0x02;
	liteon_device_id_req[3] = 0x01;
	liteon_device_id_req[4] = 0x00;
	liteon_device_id_req[5] = 0x04;
	liteon_device_id_req[6] = strlen(community);
	memcpy(&liteon_device_id_req[7],community,strlen(community));
	memcpy(liteon_device_id_req+7+strlen(community),std_liteon_device_id_req+13, total);
	total = total+strlen(community)+2+3+2; 
	
	int nSendSock;
	int nRet;
	struct sockaddr_in6	RecvAddr;
	socklen_t socklen;
	BYTE		response[4024];
	
	nSendSock = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
	if (nSendSock == -1)
	{
	    return bRet;
	}
	
	int    bOptVal = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
	
	struct timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 50000;
	setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    
	RecvAddr.sin6_family = AF_INET6;
	RecvAddr.sin6_port = htons(161);
	//RecvAddr.sin_addr.s_addr = inet_addr(ip);
	inet_pton(AF_INET6, ip , &RecvAddr.sin6_addr);
	RecvAddr.sin6_scope_id=scope_id;
	
	for(int nTimeCount=0; nTimeCount<3; nTimeCount++)
	{
		nRet = sendto(nSendSock, liteon_device_id_req, total, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
	}
	
	printf("Sendto nRet = %d, request_oid_len=%d\n", nRet, total);
	
	if (nRet <= 0)
	{
		close(nSendSock);
		return bRet;
	}
	
	socklen = sizeof(RecvAddr);
	int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
	printf("recvfrom nRecv = %d\n", nRecv);
	if (nRecv > 0) 
	{
		printf("NetworkReadStatus response=\n");
/*		
		for(int i=0; i<nRecv; i++)
		{
			if((i+1)%8 == 0)
				printf("%02x\n", response[i]);
			else
				printf("%02x ", response[i]);
		}
		printf("\n");
*/		
		bRet = parseForDeviceId(response, nRecv, status);
		if(bRet)
			strcpy(DeviceID,g_deviceid);
	} 
	
	close(nSendSock);
	
	return bRet;
}

bool CNetIO::NetworkReadStatusV6SNMPv3(const char* community, const char* ip, PRINTER_STATUS *status,char * DeviceID)
{
	bool bRet = false;
	int nSendSock;
	int nRet;
	struct sockaddr_in6	RecvAddr;
	socklen_t socklen;
	BYTE		response[MAX_SNMP_LEN];

	BYTE	snmpv3GetEngineIdPacket[MAX_SNMP_LEN];
	int snmpv3GetEngineIdPacketLen = BuildSnmpV3GetEngineIdPacket(SNMPv3RequestID,SNMPv3MsgID,snmpv3GetEngineIdPacket,sizeof(snmpv3GetEngineIdPacket));
	SNMPv3RequestID++;
	SNMPv3MsgID++;

	nSendSock = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
	if (nSendSock == -1)
	{
	    return bRet;
	}

	int    bOptVal = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));

	RecvAddr.sin6_family = AF_INET6;
	RecvAddr.sin6_port = htons(161);
	inet_pton(AF_INET6, ip , &RecvAddr.sin6_addr);
	RecvAddr.sin6_scope_id=scope_id;

	struct timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
			
	nRet = sendto(nSendSock, (char*)snmpv3GetEngineIdPacket, snmpv3GetEngineIdPacketLen, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
			
	if (nRet <= 0)
	{
		perror("[ipv6 BC] snedto failed");
		close(nSendSock);
		return bRet;
	}
			
	while(1) 
	{
		socklen = sizeof(struct sockaddr_in6);
		int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
		fprintf(stderr,"[ipv6 BC] nRecv = %d",nRecv);
		if (nRecv > 0) 
		{
			BYTE	errorStatus;
			BYTE	errorIndex;
			SNMP_PARAM_V3	v3Param;
			BYTE		snmpv3RequestPacket[MAX_SNMP_LEN];
			const char*	printInfo[] = { PVT_DEVICEID_OID };
			unsigned long tempEngineID;
					
			memset(&v3Param, 0, sizeof(SNMP_PARAM_V3));
			strcpy(v3Param.msgUserName,MSGUSERNAME);
			strcpy(v3Param.passwdAuth,PASSWDAUTH);
			strcpy(v3Param.passwdPriv,PASSWDPRIV);

			if (!parseSnmpV3Response(response, nRecv, NULL, NULL, &errorStatus, &errorIndex, &v3Param) || errorStatus!=0x00)
			{
				continue;			
			} 

			memcpy(&tempEngineID, v3Param.engineID, sizeof(tempEngineID));
			Big2LittleEndian_((char*)&tempEngineID);
					
			if(EngineEnterpriseId != tempEngineID)
				continue;

			int nSendSock2 = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
			if (nSendSock2 == -1)
			{
				continue;
			}

			setsockopt(nSendSock2, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

			int snmpv3RequestPacketLen = BuildSnmpV3RequestPacket(v3Param.engineID, v3Param.engineIDLen, v3Param.msgAuthoritativeEngineBoots, v3Param.msgAuthoritativeEngineTime, 1, printInfo, NULL, NULL, NULL, v3Param.msgUserName, v3Param.passwdAuth, v3Param.passwdPriv, v3Param.authKey, v3Param.privacyKey, snmpv3RequestPacket);

			int n_sent = sendto(nSendSock2, (char*)snmpv3RequestPacket, snmpv3RequestPacketLen, 0, (struct sockaddr*)&RecvAddr, sizeof(RecvAddr));
			if (n_sent!=snmpv3RequestPacketLen) {
				close(nSendSock2);
				continue;		
			}

			while(1)
			{
				BYTE		response2[MAX_SNMP_LEN];
				socklen_t socklen2 = sizeof(RecvAddr);

				int nRecv2 = recvfrom(nSendSock2, response2, (size_t)sizeof(response2), 0, (struct sockaddr*) &RecvAddr, &socklen2);
				if(nRecv2 > 0) 
				{
					BYTE	errorStatus2;
					BYTE	errorIndex2;

					v3Param.responseFunc = outputDeviceIdValue; 

					if (!parseSnmpV3Response(response2, nRecv2, NULL, NULL, &errorStatus2, &errorIndex2, &v3Param) || errorStatus2!=0x00)
					{
						continue;
					}

					CGrandeCmd grandeCmd;
					if(grandeCmd.DecodStatusFromDeviceID(g_deviceid, status) != -1)
						bRet = true;
					if(bRet)
						strcpy(DeviceID,g_deviceid);

				}
				else
				{
					break;
				}
			}

			close(nSendSock2);

		} 
		else 
		{
			break;
		}
				
	}
			
	close(nSendSock);

	return bRet;
}


bool CNetIO::NetworkReadStatus(const char* community, const char* ip, PRINTER_STATUS *status,char * DeviceID)
{
	bool bRet = false;
	
	struct addrinfo *result;
	/* resolve the domain name into a list of addresses */
    int error = getaddrinfo(ip, NULL, NULL, &result);
    if (error != 0)
    {   
        fprintf(stderr, "error in getaddrinfo: %s\n", gai_strerror(error));
        return bRet;
    } 
	char deviceid[2048];
	if(result->ai_family == AF_INET6)
		return NetworkReadStatusV6(community,ip,status,deviceid);
	
	unsigned char std_liteon_device_id_req[51] = {0x30, 0x31, 0x02, 0x01, 0x00, 0x04, 0x06, 0x70, 0x75, 0x62, 0x6c, 0x69, 0x63, 0xa0, 0x24, 0x02, 0x01, 0x00, 0x02, 0x01, 0x00, 0x02, 0x01, 0x00, 0x30, 0x19, 0x30, 0x17, 0x06, 0x13, 0x2b, 0x06, 0x01, 0x04, 0x01, 0x81, 0xcd, 0x1a, 0x86, 0x76, 0x82, 0x2c, 0x82, 0x71, 0xc2, 0x53, 0x01, 0x01, 0x00, 0x05, 0x00, };

       int std_len = 51;


	char liteon_device_id_req[256];
	int total;
	total = std_len-13; // the length after "public"
	liteon_device_id_req[0] = 0x30;
	liteon_device_id_req[1] = total+strlen(community)+2+3;
	liteon_device_id_req[2] = 0x02;
	liteon_device_id_req[3] = 0x01;
	liteon_device_id_req[4] = 0x00;
	liteon_device_id_req[5] = 0x04;
	liteon_device_id_req[6] = strlen(community);
	memcpy(&liteon_device_id_req[7],community,strlen(community));
	memcpy(liteon_device_id_req+7+strlen(community),std_liteon_device_id_req+13, total);
	total = total+strlen(community)+2+3+2; 

	int nSendSock;
	int nRet;
	struct sockaddr_in	RecvAddr;
	socklen_t socklen;
	BYTE		response[4024];

	nSendSock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (nSendSock == -1)
	{
	    return bRet;
	}

	int    bOptVal = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
	
	struct timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 50000;
	setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
    
	RecvAddr.sin_family = AF_INET;
	RecvAddr.sin_port = htons(161);
	RecvAddr.sin_addr.s_addr = inet_addr(ip);

	for(int nTimeCount=0; nTimeCount<3; nTimeCount++)
	{
		nRet = sendto(nSendSock, liteon_device_id_req, total, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
	}
	
	printf("Sendto nRet = %d, request_oid_len=%d\n", nRet, total);
	
	if (nRet <= 0)
	{
		close(nSendSock);
		return bRet;
	}

	socklen = sizeof(RecvAddr);
	int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
	printf("recvfrom nRecv = %d\n", nRecv);
	if (nRecv > 0) 
	{
/*	
		printf("NetworkReadStatus response=\n");
		for(int i=0; i<nRecv; i++)
		{
			if((i+1)%8 == 0)
				printf("%02x\n", response[i]);
			else
				printf("%02x ", response[i]);
		}
		printf("\n");
*/
		
		
		
		bRet = parseForDeviceId(response, nRecv, status);
		if(bRet)
			strcpy(DeviceID,g_deviceid);
	} 

	close(nSendSock);

	return bRet;
}

bool CNetIO::NetworkReadStatusSNMPv3(const char* community, const char* ip, PRINTER_STATUS *status,char * DeviceID)
{
	bool bRet = false;
	struct addrinfo *result;
	/* resolve the domain name into a list of addresses */
    int error = getaddrinfo(ip, NULL, NULL, &result);
    if (error != 0)
    {   
        //fprintf(stderr, "error in getaddrinfo: %s\n", gai_strerror(error));
        return bRet;
    } 
	char DeviceIDa[2049];
	if(result->ai_family == AF_INET6)
		return NetworkReadStatusV6SNMPv3(community,ip,status,DeviceIDa);
	
	BYTE	snmpv3GetEngineIdPacket[MAX_SNMP_LEN];
	int snmpv3GetEngineIdPacketLen = BuildSnmpV3GetEngineIdPacket(SNMPv3RequestID,SNMPv3MsgID,snmpv3GetEngineIdPacket,sizeof(snmpv3GetEngineIdPacket));
	SNMPv3RequestID++;
	SNMPv3MsgID++;

	int nSendSock;
	int nRet;
	struct sockaddr_in	RecvAddr;
	socklen_t socklen;
	BYTE		response[MAX_SNMP_LEN];

	nSendSock = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (nSendSock == -1)
	{
		return bRet;
	}

	int    bOptVal = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));

	struct timeval timeout;
	timeout.tv_sec = 1;
	timeout.tv_usec = 0;
	setsockopt(nSendSock, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
	
	RecvAddr.sin_family = AF_INET;
	RecvAddr.sin_port = htons(161);
	RecvAddr.sin_addr.s_addr = inet_addr(ip);

	//printf("ipv4=%s\n", ip);

	nRet = sendto(nSendSock, (char*)snmpv3GetEngineIdPacket, snmpv3GetEngineIdPacketLen, 0, (struct sockaddr*) &RecvAddr, sizeof(RecvAddr));
	//printf("sendto: nRet=%d\n", nRet);
	if (nRet <= 0)
	{
		close(nSendSock);
		return bRet;
	}

	int nRecvCount=0;
	while(1) 
	{
		socklen = sizeof(RecvAddr);
		int nRecv = recvfrom(nSendSock, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddr, &socklen);
		if(nRecv>0)
		{
			char szAddr[256];
			strcpy(szAddr, inet_ntoa(RecvAddr.sin_addr));
			//printf("recvfrom nRecv = %d, szAddr=%s\n", nRecv, szAddr);

			BYTE	errorStatus;
			BYTE	errorIndex;
			SNMP_PARAM_V3	v3Param;
			BYTE		snmpv3RequestPacket[MAX_SNMP_LEN];
			unsigned long tempEngineID;
					
			const char*	printInfo[] = { PVT_DEVICEID_OID };
	
			memset(&v3Param, 0, sizeof(SNMP_PARAM_V3));
			strcpy(v3Param.msgUserName,MSGUSERNAME);
			strcpy(v3Param.passwdAuth,PASSWDAUTH);
			strcpy(v3Param.passwdPriv,PASSWDPRIV);

			if (!parseSnmpV3Response(response, nRecv, NULL, NULL, &errorStatus, &errorIndex, &v3Param) || errorStatus!=0x00)
			{
				continue;			
			} 

			memcpy(&tempEngineID, v3Param.engineID, sizeof(tempEngineID));
			Big2LittleEndian_((char*)&tempEngineID);
					
			if(EngineEnterpriseId != tempEngineID)
				continue;

			int nSendSock2 = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
			if (nSendSock2 == -1)
			{
				continue;
			}

			setsockopt(nSendSock2, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));

			int snmpv3RequestPacketLen = BuildSnmpV3RequestPacket(v3Param.engineID, v3Param.engineIDLen, v3Param.msgAuthoritativeEngineBoots, v3Param.msgAuthoritativeEngineTime, 1, printInfo, NULL, NULL, NULL, v3Param.msgUserName, v3Param.passwdAuth, v3Param.passwdPriv, v3Param.authKey, v3Param.privacyKey, snmpv3RequestPacket);
					
			int n_sent = sendto(nSendSock2, (char*)snmpv3RequestPacket, snmpv3RequestPacketLen, 0, (struct sockaddr*)&RecvAddr, sizeof(RecvAddr));
			if (n_sent!=snmpv3RequestPacketLen) {
				close(nSendSock2);
				continue;		
			}

			while(1)
			{
				BYTE		response2[MAX_SNMP_LEN];
				socklen_t socklen2 = sizeof(RecvAddr);

				memset(response2, 0, sizeof(response2));	
				int nRecv2 = recvfrom(nSendSock2, response2, (size_t)sizeof(response2), 0, (struct sockaddr*) &RecvAddr, &socklen2);
						
				if(nRecv2 > 0) 
				{
					BYTE	errorStatus2;
					BYTE	errorIndex2;

					v3Param.responseFunc = outputDeviceIdValue; 

					//printf("parseSnmpV3Response begin\n");
					if (!parseSnmpV3Response(response2, nRecv2, NULL, NULL, &errorStatus2, &errorIndex2, &v3Param) || errorStatus2!=0x00)
					{
						continue;
					}

					CGrandeCmd grandeCmd;
					if(grandeCmd.DecodStatusFromDeviceID(g_deviceid, status) != -1)
						bRet = true;
					if(bRet)
						strcpy(DeviceID,g_deviceid);
				}
				else
				{
					break;
				}
			}

			close(nSendSock2);
		} 
		else 
		{
			break;
		}
	}

	close(nSendSock);

	return bRet;
}

int CNetIO::BuildGetRequestFor(int nObjects, char* raw_oid, char* community, BYTE* request)
{
	BYTE	oid[128];
	BYTE	temp[MAX_SNMP_LEN], *p; // 484 is the maximum byte count for an SNMP message
	int	total = 0;
	int	n;

	if (nObjects<=0 || raw_oid==NULL || request==NULL)
		return -1;
	p = temp+MAX_SNMP_LEN;
	for (int i=nObjects-1;i>=0;i--) {
		p--;
		*p = 0; // value length
		p--;
		*p = 0x05; // type ID = NULL
		total += 2;
		n = oidEncode(raw_oid, oid);
		if (n<=0)
			return -1;
		p-=n;
		memcpy(p,oid,n); // OID
		total += n;
		p--;
		*p = n;
		p--;
		*p = 0x06; // type: OBJECT Identifier
		total += 2;
		p--;
		*p = 2+n+2;
		p--;
		*p = 0x30; // SEQUENCE
		total += 2;
	}
	p--;
	*p = total;
	p--;
	*p = 0x30; // SEQUENCE
	total += 2;
	p--;
	*p = 0x00;
	p--;
	*p = 0x01;
	p--;
	*p = 0x02; // INTEGER
	p--;
	*p = 0x00;
	p--;
	*p = 0x01;
	p--;
	*p = 0x02; // INTEGER
	p--;
	*p = 0x00;
	p--;
	*p = 0x01;
	p--;
	*p = 0x02; // INTEGER
	total += 9;
	p--;
	*p = total;
	p--;
	*p = 0xa0; // SetRequest
	total += 2;
	if (community==NULL) {
		p-=6;
		memcpy(p,"public",6);
		p--;
		*p = 0x06;
		total += 6;
	} else {
		p-=strlen(community);
		memcpy(p,community,strlen(community));
		p--;
		*p = strlen(community);
		total += *p;
	}
	p--;
	*p = 0x04; // OCTET String
	total += 2;
	p--;
	*p = 0x00;
	p--;
	*p = 0x01;
	p--;
	*p = 0x02;
	total += 3;
	p--;
	*p = total;
	p--;
	*p = 0x30; // SEQUENCE
	total += 2;

	if (total>MAX_SNMP_LEN)
		return -1;
	memcpy(request,p,total);
	return total;
}


bool NetworkReadStatus(const char* community, const char* ip, PRINTER_STATUS *status,char * DeviceID){

	CNetIO myNetIO;
	
	
	return myNetIO.NetworkReadStatus(community,ip,status,DeviceID);
}

bool NetworkReadStatusSNMPv3(const char* community, const char* ip, PRINTER_STATUS *status,char * DeviceID){
	
	CNetIO myNetIO;
	return myNetIO.NetworkReadStatusSNMPv3(community,ip,status,DeviceID);
}

bool NetworkReadStatusV6(const char* community, const char* ip, PRINTER_STATUS *status,char * DeviceID){
	CNetIO myNetIO;
	return myNetIO.NetworkReadStatusV6(community,ip,status,DeviceID);
}

bool NetworkReadStatusV6SNMPv3(const char* community, const char* ip, PRINTER_STATUS *status,char * DeviceID){
	CNetIO myNetIO;
	return myNetIO.NetworkReadStatusV6SNMPv3(community,ip,status, DeviceID);
}



bool CNetIO::FindSnmpAgent3Times(const char* community, const char* oid, LPFNFINDCALLBACK FindCallback, void* param)
{
	char ipV4[256] = "255.255.255.255";
	char ipV6[256] = "ff02::1";
	static int index=-1;
	
	const unsigned char request_oid_pf[] = {0xa0,0x19,0x02,0x01,0x00,0x02,0x01,0x00,0x02,0x01,0x00,
		0x30,0x0e,0x30,0x0c,0x06,0x08,0x2b,0x06,0x01,0x02,0x01,
	0x01,0x02,0x00,0x05,0x00};
	
	char	request_oid[256];
	int	request_oid_len;
	
	int nSendSockV4 = -1;
	int nSendSockV6 = -1;
	int nRet;
	struct sockaddr_in	RecvAddrV4;
	struct sockaddr_in6	RecvAddrV6;
	socklen_t socklen;
	BYTE		response[256];
	BYTE	targetOID[32];	

	struct ifs_info *pFsInfo = NULL;
	
	if (community==NULL || *community==0x00)
		community = "public";
	request_oid[0] = 0x30;
	request_oid[1] = 5+strlen(community)+sizeof(request_oid_pf);
	request_oid[2] = 0x02;
	request_oid[3] = 0x01;
	request_oid[4] = 0x00;
	request_oid[5] = 0x04;
	request_oid[6] = strlen(community);
	memcpy(&request_oid[7],community,strlen(community));
	memcpy(&request_oid[7+strlen(community)],request_oid_pf,sizeof(request_oid_pf));
	request_oid_len = 7+strlen(community)+sizeof(request_oid_pf);
	
	int oidlen = oidEncode(oid,targetOID);
	if (oidlen<=0)
	{
		return false;
	}
	
	int    bOptVal = 1;

	nSendSockV4 = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP);
	if (nSendSockV4 != -1)
	{
		setsockopt(nSendSockV4, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
		
		struct timeval timeout;
		timeout.tv_sec = 1;
		timeout.tv_usec = 0;
		setsockopt(nSendSockV4, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
	    
		RecvAddrV4.sin_family = AF_INET;
		RecvAddrV4.sin_port = htons(161);
		RecvAddrV4.sin_addr.s_addr = inet_addr(ipV4);

		for(int nTimeCount=0; nTimeCount<3; nTimeCount++)
		{
			nRet = sendto(nSendSockV4, request_oid, request_oid_len, 0, (struct sockaddr*) &RecvAddrV4, sizeof(RecvAddrV4));
			usleep(30);
		}
		
		if (nRet <= 0)
		{
			close(nSendSockV4);
			nSendSockV4 = -1;
		}
	}	

	char tmpip[255];
	sprintf(tmpip,"%s%s",ipV6,"%en0");
	
	inet_pton(AF_INET6, tmpip, &RecvAddrV6.sin6_addr);
	
	int found=0;
	int nCount = 0;
	
	while(1)
	{
		//printf("\ntmpip=%s \n",tmpip);
		nSendSockV6 = socket(AF_INET6, SOCK_DGRAM, IPPROTO_UDP);
		if (nSendSockV6 == -1)
		{
			perror("socket failed");
			break;
		}
		
		setsockopt(nSendSockV6, SOL_SOCKET, SO_BROADCAST, (char*)&bOptVal, sizeof(bOptVal));
		
		struct timeval timeout;
		timeout.tv_sec = 1;
		timeout.tv_usec = 0;
		setsockopt(nSendSockV6, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
		
		RecvAddrV6.sin6_family = AF_INET6;
		RecvAddrV6.sin6_port = htons(161);
		
		if(scope_id>0)
		{
		
			//printf("[if] scope_id=%d",scope_id);
			RecvAddrV6.sin6_scope_id=scope_id;
		}
		else
			RecvAddrV6.sin6_scope_id=nCount;

		if(index != -1)
		{
			for(int nTimeCount=0; nTimeCount<3; nTimeCount++)
			{
				nRet = sendto(nSendSockV6, request_oid, request_oid_len, 0, (struct sockaddr *) &RecvAddrV6, sizeof( struct sockaddr_in6));
				usleep(30);
			}
			break;
		}

		else
		{
			nRet = sendto(nSendSockV6, request_oid, request_oid_len, 0, (struct sockaddr *) &RecvAddrV6, sizeof( struct sockaddr_in6));
		}
		
		if(nRet > 0)
		{
			socklen = sizeof(RecvAddrV6);
			int nRecv = recvfrom(nSendSockV6, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddrV6, &socklen);

			if (nRecv > 0) 
			{
				index = nCount;
				break;
			}
		}
			
		if (nRet <= 0)
		{
			perror("sendto failed");
			close(nSendSockV6);
			nSendSockV6 = -1;
			//printf(" index = %d",nCount);
		}

		nCount++;

		if(nCount >= 65535)
			break;
	}

	if(nSendSockV4 != -1)
	{
		while(1) 
		{
			socklen = sizeof(RecvAddrV4);
			int nRecv = recvfrom(nSendSockV4, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddrV4, &socklen);
			if (nRecv > 0) 
			{

				if (parseForOID(response, nRecv, targetOID, oidlen))
				{
		        		if (FindCallback != NULL)
			              {
						char szAddr[16];

						strcpy(szAddr, inet_ntoa(RecvAddrV4.sin_addr));
						//printf("szAddr=%s\n", szAddr);
						FindCallback(szAddr, NULL, param);
					}
			       }
			} 
			else 
			{
				break;
			}
		}

		close(nSendSockV4);
	}

	if(nSendSockV6 != -1)
	{
		pFsInfo = get_ifs_info(0, 0);

		while(1) 
		{
			socklen = sizeof(RecvAddrV6);
			int nRecv = recvfrom(nSendSockV6, response, (size_t)sizeof(response), 0, (struct sockaddr*) &RecvAddrV6, &socklen);
			
			//printf(" nSendSockV6 nRecv = %d",nRecv);
			if (nRecv > 0) 
			{
				found=nRecv;
				if(scope_id<=0)
				{
					char* pName = find_ifname(pFsInfo, index);
					if(pName != NULL)
					{
						strcpy(g_ifsName, "%");
						strcat(g_ifsName, pName);
					}
					
					scope_id=index;
				}
				
				//printf("[find] scope id=%d",scope_id);
				
				if (parseForOID(response, nRecv, targetOID, oidlen))
				{
					if (FindCallback != NULL)
					{
						char szAddr[255];
						
						inet_ntop(PF_INET6,&RecvAddrV6.sin6_addr,szAddr,sizeof(szAddr));
						//printf("szAddr=%s\n", szAddr);
						FindCallback(szAddr, NULL, param);
						
					}
				}
			} 
			else 
			{
				perror("nRecv failed");
				break;
			}
			
		 }
		 
		if(pFsInfo)
		{
			free_ifs_info(pFsInfo);
		}
		
		close(nSendSockV6);
	}

	return true;
}

#if 0
LPFNFINDCALLBACK gFindCallback=NULL;
void* gParam=NULL;
extern char g_BonjourIPV6[256];

void ServiceCallBack(CFNetServiceRef theService, CFStreamError* error, void* info)
{
	//DS_LogText("ServiceCallBack enter!\n");
	CFNetServiceUnscheduleFromRunLoop(theService, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
	
	if (error && error->error)
	{
		CFRunLoopStop(CFRunLoopGetCurrent());
	}
	else
	{
		struct sockaddr * socketAddress = NULL;
		CFArrayRef pAddressArray = CFNetServiceGetAddressing(theService);
	//	DS_LogText("MyNetServiceBrowserClientCallBack pAddressArray=%p\n", pAddressArray);
		if(pAddressArray)
		{
		 	//DS_LogText("ServiceCallBack CFArrayGetCount(pAddressArray)=%d\n",CFArrayGetCount(pAddressArray));

		 	char szIPV6_2001[256] = "";
      			memset(g_BonjourIPV6, 0, sizeof(g_BonjourIPV6));
		 	
		        for (int i = 0; i < CFArrayGetCount(pAddressArray); i++)
		        {
		        	CFDataRef pData = (CFDataRef)CFArrayGetValueAtIndex(pAddressArray, i);
		        	socketAddress = (struct sockaddr *)CFDataGetBytePtr(pData);
		        	if (socketAddress && socketAddress->sa_family == AF_INET)
		        	{
		        		//char szIPV4[256];
		        		//memset(szIPV4, 0, sizeof(szIPV4));
		        		//inet_ntop(AF_INET, &((struct sockaddr_in *)socketAddress)->sin_addr, szIPV4, sizeof(szIPV4));
		        		//DS_LogText("ResolveCallback szIPV4=%s\n",szIPV4);
		        	}
		        	else if (socketAddress && socketAddress->sa_family == AF_INET6)
		        	{
		        		char szIPV6[256];
		        		memset(szIPV6, 0, sizeof(szIPV6));
		        		inet_ntop(AF_INET6, &((struct sockaddr_in6 *)socketAddress)->sin6_addr, szIPV6, sizeof(szIPV6));
		        	//	DS_LogText("MyNetServiceBrowserClientCallBack szIPV6=%s\n",szIPV6);
		        		//strcat(szIPV6, "lske");
		        		if(szIPV6[0]=='2')
		        		{
		        			strcpy(szIPV6_2001, szIPV6);
		        		}
		        		else
		        		{
		        			strcpy(g_BonjourIPV6, szIPV6);
		        		}
		        	}
		        }

		        if(strlen(szIPV6_2001)>4 && gFindCallback)
        			gFindCallback(szIPV6_2001, NULL, gParam);
		}

		CFRunLoopStop(CFRunLoopGetCurrent());
	}
}

CFNetServiceBrowserRef pServiceBrowserRef=NULL;

#include "BundleUtilities.h"

void MyNetServiceBrowserClientCallBack (
			   CFNetServiceBrowserRef browser,
			   CFOptionFlags flags,
			   CFTypeRef domainOrService,
			   CFStreamError* error,
			   void* info)
{
	//DS_LogText("MyNetServiceBrowserClientCallBack enter!flags=%d\n", flags);

   	if(flags & kCFNetServiceFlagIsDomain)
   	{
   		//domainOrService contains a domain
   	}
   	else
   	{
   		//domainOrService contains a CFNetService
		CFNetServiceRef theService = (CFNetServiceRef)domainOrService;
		//DS_LogText("MyNetServiceBrowserClientCallBack theService=%p\n", theService);
		if(theService)
		{
			CFNetServiceClientContext c = {0, NULL, NULL, NULL, NULL};

			CFStringRef strName = CFNetServiceGetName(theService);
			if(strName)
			{
				char strPtr[256];
				CFStringGetCString(strName, strPtr, sizeof(strPtr), kCFStringEncodingASCII);
			//	DS_LogText("MyNetServiceBrowserClientCallBack strName=%s\n", strPtr);

				if(FindString(strName, g_strModelName, kCFCompareCaseInsensitive)
					|| g_strModelName1&&FindString(strName, g_strModelName1, kCFCompareCaseInsensitive))
				{
					if (CFNetServiceSetClient(theService, ServiceCallBack, &c))
					{                               
						CFNetServiceScheduleWithRunLoop(theService, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);

						if (CFNetServiceResolveWithTimeout(theService, 5.0, NULL))
							CFRunLoopRun();
					}		
				}
			}
		}
	}

	if((flags & kCFNetServiceFlagMoreComing) ==0)
	{
		//DS_LogText("MyNetServiceBrowserClientCallBack release!\n");
		CFNetServiceBrowserUnscheduleFromRunLoop(pServiceBrowserRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
		CFNetServiceBrowserStopSearch(pServiceBrowserRef, NULL);
		CFRelease(pServiceBrowserRef);
		pServiceBrowserRef = NULL;
		CFRunLoopStop(CFRunLoopGetCurrent());
	}
}

EventLoopTimerRef g_BrowsingTimer = NULL;
static int count=0;

pascal void BrowsingTimerAction(EventLoopTimerRef theTimer, void* userData)
{

	if(count++>10)
	{
		RemoveEventLoopTimer(g_BrowsingTimer);
		g_BrowsingTimer = NULL;
		count = 0;
		
		if(pServiceBrowserRef)
		{
			CFNetServiceBrowserUnscheduleFromRunLoop(pServiceBrowserRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
			CFNetServiceBrowserStopSearch(pServiceBrowserRef, NULL);
			CFRelease(pServiceBrowserRef);
			pServiceBrowserRef = NULL;
			CFRunLoopStop(CFRunLoopGetCurrent());
		}
	}

  //	DS_LogText("BrowsingTimerAction count=%d\n", count);
}

Boolean StartBrowsingForServices(CFStringRef type, CFStringRef domain, LPFNFINDCALLBACK FindCallback, void* param) {
     CFNetServiceClientContext clientContext = { 0, NULL, NULL, NULL, NULL };
     CFStreamError error;
     Boolean result;
 
  //	DS_LogText("StartBrowsingForServices enter!\n");

  	 gFindCallback = FindCallback;
  	 gParam = param;

	if(g_BrowsingTimer == NULL)
	{
		EventLoopRef mainLoop;
		EventLoopTimerUPP timerUPP;

		count=0;
		mainLoop = GetMainEventLoop();
		timerUPP = NewEventLoopTimerUPP(BrowsingTimerAction);
		InstallEventLoopTimer(mainLoop,
			0,
			kEventDurationSecond,
			timerUPP,
			NULL,
			&g_BrowsingTimer);
	}
  	
	pServiceBrowserRef = CFNetServiceBrowserCreate(kCFAllocatorDefault, MyNetServiceBrowserClientCallBack, &clientContext);
	if(pServiceBrowserRef)
	{
	  //	DS_LogText("StartBrowsingForServices pServiceBrowserRef=%p\n", pServiceBrowserRef);
	  	
		CFNetServiceBrowserScheduleWithRunLoop(pServiceBrowserRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);

		 result = CFNetServiceBrowserSearchForServices(pServiceBrowserRef, domain, type, &error);
	  //	DS_LogText("CFNetServiceBrowserSearchForServices result=%d\n", result);
		 if (result == false)
		 {
			CFNetServiceBrowserUnscheduleFromRunLoop(pServiceBrowserRef, CFRunLoopGetCurrent(), kCFRunLoopCommonModes);
			CFRelease(pServiceBrowserRef);
			pServiceBrowserRef = NULL;
			fprintf(stderr, "CFNetServiceBrowserSearchForServices returned (domain = %d, error = %ld)\n", error.domain, error.error);
		 }
		 else
		 {
			CFRunLoopRun();
			
		  //	DS_LogText("StartBrowsingForServices CFRunLoopRun end\n");
		 }
	} 

	if(g_BrowsingTimer)
	{
		//DS_LogText("StartBrowsingForServices RemoveEventLoopTimer!\n");
		RemoveEventLoopTimer(g_BrowsingTimer);
		g_BrowsingTimer = NULL;
	}
	
	return result;
}

#endif
