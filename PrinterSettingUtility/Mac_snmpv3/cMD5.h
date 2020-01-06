#ifndef CMD5_H
#define CMD5_H
#include <stdlib.h> // pulls in declaration of malloc, free
#include <string.h> // pulls in declaration for strlen.
#include <stdio.h>
#if 0
#define _ReadBufSize 1000000

char* md5CalcMD5FromString(const char *s8_Input);
char* md5CalcMD5FromFile  (const char *s8_Path);
#endif

void md5FreeBuffer();
void md5cMD5();
void MD5Init();
void MD5Update(unsigned char *buf, unsigned len);
void MD5Final (unsigned char digest[16]);
 
typedef struct 
{
    unsigned long buf[4];
    unsigned long bits[2];
    unsigned char in[64];
} MD5Context;
 
    
void MD5Transform(unsigned long buf[4], unsigned long in[16]);
char* MD5FinalToString();

void md5byteReverse (unsigned char *buf, unsigned longs);

#endif
 
