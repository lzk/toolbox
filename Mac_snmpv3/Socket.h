/*******************************************************************

   Copyright (C), 2008, LiteON

   File name: Socket.h

   Author: James Yu   Version: 1.0   Date: 2008-06-18

   Description: 

   History: 
      James Yu  2008-06-18   1.0   build this module
      
*******************************************************************/

#ifndef __SOCKET_H__
#define __SOCKET_H__

typedef enum 
{
    kSocketSelectConnect,
    kSocketSelectRead,
    kSocketSelectWrite
} SOCKETSELECTMODE;

class CSocket
{
public:
    CSocket();
    ~CSocket();

    int Open(int domain, int type, int protocol);
    void Close();
    
    bool Valid();
    
    int Select(SOCKETSELECTMODE mode, bool *dataPresent);
    
    int Connect(const struct sockaddr *name, int namelen);
    
    int Read(void *buf, size_t nbytes, size_t *bytesReadPtr);
    int Write(const void *buf, size_t nbytes, size_t *bytesWrittenPtr);
    
    int Cancel();

private:
    int sock;
    int sndCancel;
    int rcvCancel;
    int maxFD;
    
    bool didCancel;
};

#endif  // __SOCKET_H__

