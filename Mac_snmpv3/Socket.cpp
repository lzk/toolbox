/*******************************************************************

   Copyright (C), 2008, LiteON

   File name: Socket.cpp

   Author: James Yu   Version: 1.0   Date: 2008-06-18

   Description: 

   History: 
      James Yu  2008-06-18   1.0   build this module
      
*******************************************************************/

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <fcntl.h>
#include <unistd.h>
#include <errno.h>

#include "socket.h"


CSocket::CSocket()
{
    sock = -1;
    sndCancel = -1;
    rcvCancel = -1;
    didCancel = false;
}

CSocket::~CSocket()
{
    Cancel();
    Close();
}

int CSocket::Open(int domain, int type, int protocol)
{
    int err = 0;

    if (Valid())
    {
        Cancel();
        Close();
    }
        
    sock = socket(domain, type, protocol);
    if (sock < 0) 
    {
        err = errno;
    }

    if (err == 0) 
    {
        err = fcntl(sock, F_SETFL, O_NONBLOCK);
        if (err < 0) 
        {
            err = errno;
        }
    }
    
    if (err == 0) 
    {
        int tmpSock[2];
        
        err = socketpair(AF_UNIX, SOCK_STREAM, 0, tmpSock);
        if (err < 0) 
        {
            err = errno;
        } 
        else 
        {
            sndCancel = tmpSock[0];
            rcvCancel = tmpSock[1];
        }
    }
    
    if (err == 0) 
    {
        maxFD = sock;
        
        if (sndCancel > maxFD) 
        {
            maxFD = sndCancel;
        }
        
        if (rcvCancel > maxFD) 
        {
            maxFD = rcvCancel;
        }
    }
    
    // Clean up.
    
    if (err != 0) 
    {
        Close();
    }
    
    return err;
}

void CSocket::Close()
{
    int junk;
    
    if (sock != -1) 
    {
        junk = close(sock);
        sock = -1;
    }
    
    if (sndCancel != -1) 
    {
        junk = close(sndCancel);
        sndCancel = -1;
    }
    
    if (rcvCancel != -1) 
    {
        junk = close(rcvCancel);
        rcvCancel = -1;
    }

    didCancel = false;
}

bool CSocket::Valid()
{
    return (sock != -1)
            && (sndCancel != -1)
            && (rcvCancel != -1)
            && (maxFD >= sock)
            && (maxFD >= sndCancel)
            && (maxFD >= rcvCancel);
}


int CSocket::Select(SOCKETSELECTMODE mode, bool *dataPresent)
{
    int             err;
    fd_set        readFDs;
    fd_set        writeFDs;
    fd_set *     dataPresentFDs;
    int             selectResult;
    
    FD_ZERO(&readFDs);
    FD_ZERO(&writeFDs);

    // We always want the cancel socket in the read FD set.
    
    FD_SET(rcvCancel, &readFDs);

    // Add other sockets to the FD sets.  Also remember which 
    // FD set we're supposed to return whether data is present in.
    
    switch (mode) 
    {
        case kSocketSelectConnect:
        {
            FD_SET(sock, &readFDs);
            FD_SET(sock, &writeFDs);
            dataPresentFDs = NULL;
            break;
        }
        
        case kSocketSelectRead:
        {
            FD_SET(sock, &readFDs);
            dataPresentFDs = &readFDs;
            break;
        }
        
        case kSocketSelectWrite:
        {
            FD_SET(sock, &writeFDs);
            dataPresentFDs = &writeFDs;
            break;
        }
        
        default:
        {
            break;
        }
    }

    // Do the select, looping while we get EINTR errors.
    
    err = 0;
    do 
    {
        selectResult = select(maxFD + 1, &readFDs, &writeFDs, NULL, NULL);
        
        if (selectResult < 0) 
        {
            err = errno;
        }
    } while (err == EINTR);
    
    if (err == 0) 
    {
        // We have an infinite timeout, so a result of 0 should be impossible, 
        // so assert that selectResult is positive.

        // Check for cancellation first.
        
        if ( FD_ISSET(rcvCancel, &readFDs) ) 
        {
            err = ECANCELED;
        } 
        else 
        {
            if ( (dataPresent != NULL) && (dataPresentFDs != NULL) ) 
            {
                *dataPresent = ( FD_ISSET(sock, dataPresentFDs) != 0 );
            }
        }
    }

    return err;
}

int CSocket::Connect(const struct sockaddr *name, int namelen)
{
    int err;

    if (name == NULL)
    {
        return -1;
    }
    
    // Start the connect.
    
    err = connect(sock, name, namelen);

    // Handle any error conditions.
    
    if (err < 0) 
    {
        err = errno;
        
        // EINPROGRESS means that the connect started, and we have to wait 
        // for it to complete.  Let's do that.  Any other error is passed to 
        // the caller.
        
        if (err == EINPROGRESS) 
        {
            bool           connected;
            socklen_t   len;
            
            connected = false;

            err = Select(kSocketSelectConnect, NULL);
            if (err == 0) 
            {
                // Not cancelled, so must have either connected or failed.  
                // Check to see if we're connected by calling getpeername.
                
                len = 0;
                err = getpeername(sock, NULL, &len);
                if (err < 0) 
                {
                    err = errno;
                }
                
                if (err == 0) 
                {
                    // The connection attempt worked.
                    connected = true;
                } 
                else if (err == ENOTCONN) 
                {
                    int tmpErr;
                    
                    // The connection failed.  Get the error associated with 
                    // the connection attempt.
                    
                    len = sizeof(tmpErr);
                    err = getsockopt(sock, SOL_SOCKET, SO_ERROR, &tmpErr, &len);
                    if (err < 0) 
                    {
                        err = errno;
                    } 
                    else 
                    {
                        err = tmpErr;
                    }
                }
            }
        }
    }

	//printf("Connect err=%x\n", err);
	
    return err;
}

int CSocket::Read(void *buf, size_t nbytes, size_t *bytesReadPtr)
{
    int             err;
    size_t        bytesLeft;
    char *        cursor;
    ssize_t       bytesThisTime;
    bool           dataPresent;

    if (!Valid())
    {
        return -1;
    }
    
    err = 0;
    bytesLeft = nbytes;
    cursor = (char *) buf;

    while ( (err == 0) && (bytesLeft > 0) ) 
    {
        bytesThisTime = read(sock, cursor, bytesLeft);
        if (bytesThisTime > 0) 
        {
            cursor    += bytesThisTime;
            bytesLeft -= bytesThisTime;
        } 
        else if (bytesThisTime == 0) 
        {
            err = EPIPE;
        } 
        else 
        {
            err = errno;

            // We don't need to handle EINTR because read never blocks, 
            // and thus can never be interrupted.
            
            if (err == EAGAIN) 
            {
                err = Select(kSocketSelectRead, &dataPresent);
            }
        }
    }
    
    // Clean up.
    
    if (bytesReadPtr != NULL) 
    {
        *bytesReadPtr = nbytes - bytesLeft;        
    }
    return err;
}

int CSocket::Write(const void *buf, size_t nbytes, size_t *bytesWrittenPtr)
{
    int                  err;
    size_t             bytesLeft;
    const char *    cursor;
    ssize_t            bytesThisTime;
    bool                spaceAvailable;

    if (!Valid())
    {
        return -1;
    }

    err = 0;
    bytesLeft = nbytes;
    cursor = (const char *) buf;

    while ( (err == 0) && (bytesLeft > 0) ) 
    {
        bytesThisTime = write(sock, cursor, bytesLeft);
		//printf("bytesLeft=%d, bytesThisTime = %d\n", bytesLeft, bytesThisTime);
        if (bytesThisTime > 0)
        {
            cursor    += bytesThisTime;
            bytesLeft -= bytesThisTime;
        } 
        else if (bytesThisTime == 0) 
        {
            err = EPIPE;
        } 
        else 
        {
            err = errno;

            // We don't need to handle EINTR because write never blocks, 
            // and thus can never be interrupted.

            if (err == EAGAIN) 
            {
                err = Select(kSocketSelectWrite, &spaceAvailable);
            }
        }
    }

    // Clean up.
    
    if (bytesWrittenPtr != NULL) 
    {
        *bytesWrittenPtr = nbytes - bytesLeft;
    }
    
    return err;
}

int CSocket::Cancel()
{
    int                     err;
    ssize_t               bytesWritten;
    static const char  kCancelMessage = 0;
    
    err = 0;
    if (!didCancel) 
    {
        bytesWritten = write(sndCancel, &kCancelMessage, sizeof(kCancelMessage));
        if (bytesWritten < 0) 
        {
            err = errno;

            // I don't bother handling EINTR here because writing a single 
            // byte will never block, and thus can't be interrupted.

            //assert( err != EINTR);
        } 
        else 
        {
            didCancel = true;
        }
    }
    return err;
}


