/*********************************************************************
*	File:		GrandeCmd.cp
*	
*	Description:	Read Printer info from USB and Network.
*
*	Author:	Devid
*
*	Copyright: 	� Copyright 2009 Liteon, Inc. All rights reserved.
*
**********************************************************************/

#include "GrandeCmd.h"


/*** characters used for Base64 encoding  ***/  
const char *BASE64_CHARS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

/**
* @param triple three bytes that should be encoded
 * @param result buffer of four characters where the result is stored
 */  

// extern SETTINGS m_Settings;;
 
void _base64_encode_triple(unsigned char triple[3], char result[4])
 {
    int tripleValue, i;

    tripleValue = triple[0];
    tripleValue *= 256;
    tripleValue += triple[1];
    tripleValue *= 256;
    tripleValue += triple[2];

    for (i=0; i<4; i++)
    {
          result[3-i] = BASE64_CHARS[tripleValue%64];
          tripleValue /= 64;
    }
} 

/**
* @param source the source buffer
 * @param sourcelen the length of the source buffer
 * @param target the target buffer
 * @param targetlen the length of the target buffer
 * @return 1 on success, 0 otherwise
 */  
int base64_encode(unsigned char *source, size_t sourcelen, char *target, size_t targetlen)
 {
    /* check if the result will fit in the target buffer */
    if ((sourcelen+2)/3*4 > targetlen-1)
         return 0;

    /* encode all full triples */
    while (sourcelen >= 3)
    {
          _base64_encode_triple(source, target);
          sourcelen -= 3;
          source += 3;
          target += 4;
    }

    /* encode the last one or two characters */
    if (sourcelen > 0)
    {
          unsigned char temp[3];
          memset(temp, 0, sizeof(temp));
          memcpy(temp, source, sourcelen);
          _base64_encode_triple(temp, target);
          target[3] = '=';
          if (sourcelen == 1)
              target[2] = '=';

          target += 4;
    }

    /* terminate the string */
    target[0] = 0;

    return 1;
}

/**
 * determine the value of a base64 encoding character
 *
 * @param base64char the character of which the value is searched
 * @return the value in case of success (0-63), -1 on failure
 */  
int _base64_char_value(unsigned char base64char)
 {
    if (base64char >= 'A' && base64char <= 'Z')
         return base64char-'A';
    if (base64char >= 'a' && base64char <= 'z')
         return base64char-'a'+26;
    if (base64char >= '0' && base64char <= '9')
         return base64char-'0'+2*26;
    if (base64char == '+')
         return 2*26+10;
    if (base64char == '/')
         return 2*26+11;
    return -1;
} 

/**
 * decode a 4 char base64 encoded byte triple
* @param quadruple the 4 characters that should be decoded
 * @param result the decoded data
 * @return lenth of the result (1, 2 or 3), 0 on failure
 */  
int _base64_decode_triple(char quadruple[4], char *result)
 {
    int i, triple_value, bytes_to_decode = 3, only_equals_yet = 1;
    int char_value[4];

    for (i=0; i<4; i++)
         char_value[i] = _base64_char_value(quadruple[i]);

    for (i=3; i>=0; i--)
    {
         if (char_value[i]<0)
         {
             if (only_equals_yet && quadruple[i]=='=')
             {
                  char_value[i]=0;
                  bytes_to_decode--;
                  continue;
             }
             return 0;
         }
         only_equals_yet = 0;
    }

    if (bytes_to_decode < 0)
         bytes_to_decode = 0;

    triple_value = char_value[0];
    triple_value *= 64;
    triple_value += char_value[1];
    triple_value *= 64;
    triple_value += char_value[2];
    triple_value *= 64;
    triple_value += char_value[3];

    for (i=bytes_to_decode; i<3; i++)
         triple_value /= 256;
    for (i=bytes_to_decode-1; i>=0; i--)
    {
         result[i] = triple_value%256;
         triple_value /= 256;
    }

    return bytes_to_decode;
} 

/**
 * decode base64 encoded data
* @param source the encoded data (zero terminated)
 * @param target pointer to the target buffer
 * @param targetlen length of the target buffer
 * @return length of converted data on success, -1 otherwise
 */  
size_t base64_decode(char *source, unsigned char *target, size_t targetlen)
 {
    char *src, *tmpptr;
    char quadruple[4], tmpresult[3];
    int i, tmplen = 3;
    size_t converted = 0;

    src = (char *)malloc(strlen(source)+5);
    if (src == NULL)
         return -1;
    strcpy(src, source);
    strcat(src, "====");
    tmpptr = src;
    while (tmplen == 3)
    {
         /* get 4 characters to convert */
         for (i=0; i<4; i++)
         {
             while (*tmpptr != '=' && _base64_char_value(*tmpptr)<0)
                  tmpptr++;
             quadruple[i] = *(tmpptr++);
         }
         tmplen = _base64_decode_triple(quadruple,tmpresult);
         if (targetlen < tmplen)
         {
             free(src);
             return -1;
         }
         memcpy(target, tmpresult, tmplen);
         target += tmplen;
         targetlen -= tmplen;
         converted += tmplen;
    }
    free(src);
    return converted;
}

//--------------------------------------------------------------------------------------------

CGrandeCmd::CGrandeCmd()
{
}

//--------------------------------------------------------------------------------------------
CGrandeCmd::~CGrandeCmd()
{
}

#include <unistd.h>

void Big2LittleEndian(char* src)
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


//extern void list_devices();
char pDevideID[1024];
int DecodStatusFromDeviceID(char* device_id, PRINTER_STATUS* status)
{
	CGrandeCmd grandeCmd;
	
	return grandeCmd.DecodStatusFromDeviceID(device_id, status);
}

int CGrandeCmd::DecodStatusFromDeviceID(char* device_id, PRINTER_STATUS* status)
{
	//printf("DecodStatusFromDeviceID enter\n");
	
	if (device_id==NULL || status==NULL)
		return -1;
	
	char *p = device_id;
/*
	char *ptr = device_id;
	int i=0;
	printf("device_id=\n");
	while(*ptr != NULL)
	{
		if((i+1)%8 == 0)
			printf("%02x\n", *ptr);
		else
			printf("%02x ", *ptr);

		ptr++;
		i++;
	}
	printf("\n");
*/
	
	while (*p!=NULL && strncmp(p,"STS:",4)!=0) // Look for "STS:"
		p++;
	
	if (*p==NULL)	{ // "STS:" not found
		//printf("STS: not found\n");
		return -1;
	}
	p += 4;	// Skip "STS:"
	int nLength = base64_decode(p,(unsigned char*)status,sizeof(PRINTER_STATUS));
	//printf("base64_decode nLength=%d, sizeof(PRINTER_STATUS)=%d\n", nLength, sizeof(PRINTER_STATUS));
	if(nLength != sizeof(PRINTER_STATUS))
		return -1;
	
	return 0;
}


