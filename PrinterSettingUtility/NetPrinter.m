//
//  NetPrinter.m
//  PrinterSettingUtility
//
//  Created by Wang Kun on 3/3/14.
//  Copyright (c) 2014 Wang Kun. All rights reserved.
//

#import "NetPrinter.h"
#import <sys/types.h>
#import <sys/socket.h>
#import <netinet/in.h>
#import <fcntl.h>
#import <unistd.h>
#import <errno.h>
//#import "stdafx.h"
#import <netdb.h>
#import <ifaddrs.h>
#include <netinet/tcp.h>

#define DEV_PORT     9100
#define BUFSIZE      1024

typedef enum
{
	kSocketSelectConnect,
	kSocketSelectRead,
	kSocketSelectWrite
} SOCKETSELECTMODE;


@implementation NetPrinter


- (BOOL)connetToNetDevice:(NSString *)devURI
{
    if([devURI length] <= 0)
    {
        return FALSE;
    }
    
	NSURL *url = [NSURL URLWithString:devURI];
	NSString *address = [self getAddressFromURL:url];
    NSLog(@"IP address = %@, URL = %@", address, devURI);
	if (address == nil)
	{
		return FALSE;
	}
    
    if ((sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1)
    {
		NSLog(@"(sockfd = socket(AF_INET, SOCK_STREAM, 0)) == -1");

        return FALSE;
    }
    
    const char *ip = [address cStringUsingEncoding:NSASCIIStringEncoding];
    struct sockaddr_in dev_addr;
    dev_addr.sin_family = AF_INET;
    dev_addr.sin_port = htons(DEV_PORT);
    dev_addr.sin_addr.s_addr = inet_addr(ip);
    memset(&(dev_addr.sin_zero), 0, sizeof(dev_addr.sin_zero));
    
	
	

    if (connect(sockfd, (struct sockaddr *)&dev_addr, sizeof(struct sockaddr)) == -1)
    {
        NSLog(@"connect netDev fail");
        return FALSE;
    }
	
	struct timeval tv;
	

	
	int i = 1;
	NSBundle * bundle = [NSBundle mainBundle];
	NSString * timeout = [bundle objectForInfoDictionaryKey:@"NetTimeout"];
	if(timeout)
		tv.tv_sec = [timeout intValue];       /* Timeout in seconds */
	else
		tv.tv_sec = 5;
	
	//tv.tv_sec = 5;       /* Timeout in seconds */
	tv.tv_usec = 0; 
	setsockopt(sockfd, SOL_SOCKET, SO_SNDTIMEO,( char * )&tv,sizeof(struct timeval));
	setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO,( char * )&tv,sizeof(struct timeval));
	
    setsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, (char *)&i, sizeof(int));
    
	int optval = 1;
	socklen_t optlen = sizeof(optval);
	setsockopt(sockfd, SOL_SOCKET, SO_KEEPALIVE, &optval, optlen);
	
    return TRUE;
    
/*
	struct addrinfo hints, *res=NULL;
	bzero(&hints, sizeof(struct addrinfo));
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;
	
    
	int n = getaddrinfo([address cStringUsingEncoding:NSASCIIStringEncoding], "9100", &hints, &res);
	if (n != 0) {
		NSLog(@"%s", gai_strerror(n));
		[address release];
		return FALSE;
	}
	
	if ([self openSockFamily:res->ai_family socktype:res->ai_socktype protocol:res->ai_protocol] != 0)
	{
		[address release];
		freeaddrinfo(res);
		return FALSE;
	}
    
	int err = [self connectWithAddr:res->ai_addr length:res->ai_addrlen];
    
    
	[address release];
	freeaddrinfo(res);
	
	if (err != 0)
	{
        NSLog(@"Open printer fail!");
		return FALSE;
	}
	else
	{
        NSLog(@"Open printer OK!");
		return TRUE;
	}
	
	return FALSE;
*/
}

- (void) closePrinter
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

- (BOOL) isPrinterOpen
{
    return true;
}

- (int)wirteToNetDevice:(void *)buffer length:(int)len
{
    size_t nLeft;
    ssize_t nWrite;
    const char *pBuffer;
    
    pBuffer = buffer;
    nLeft = len;
    
    while (nLeft > 0)
    {
        nWrite = write(sockfd, pBuffer, nLeft);
        if (nWrite <= 0)
        {
            if (nWrite < 0 && errno == EINTR)
            {
				NSLog(@"[net] EINTR write failed.\n");
                nWrite = 0;
            }
            else
            {
				NSLog(@"[net] write failed.\n");
                return -1;
            }
        }
        
        nLeft -= nWrite;
        pBuffer += nWrite;
    }
    
    return len;
}

- (int)readFromNetDevice:(void *)buffer length:(int)len
{
    size_t nLeft;
    ssize_t nRead;
    char *pBuffer;
    
    pBuffer = buffer;
    nLeft = len;
    
    while (nLeft > 0)
    {
        nRead = read(sockfd, pBuffer, nLeft);
        if (nRead < 0)
        {
            if (errno == EINTR)
            {
				NSLog(@"[net] EINTR read failed.\n");
                nRead = 0;
            }
            else
            {
				NSLog(@"[net] read failed.[%s]\n",strerror(errno));
                return -1;
            }
        }
        else if (nRead == 0)
        {
            break;
        }
        
        nLeft -= nRead;
        pBuffer += nRead;
    }
    
    return len - nLeft;
}

- (void)closeSocket
{
    int rtn=close(sockfd);
	shutdown(sockfd, SHUT_RDWR);
}


- (int) cancel
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

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		sock = -1;
		sndCancel = -1;
		rcvCancel = -1;
		didCancel = false;
        bFinishIPv4 = 0;
        bFinishIPv6 = 0;
	}
	
	return self;
}

- (void)dealloc
{
	if ([self isPrinterOpen])
	{
		[self cancel];
		[self closePrinter];
	}
	
	[super dealloc];
}

- (int) openSockFamily:(int) family socktype:(int)socktype protocol:(int) protocol
{
    int err = 0;
	
    if ([self isPrinterOpen])
    {
		[self closePrinter];
    }
	
    //sock = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    sock = socket(family, socktype, protocol);
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
        [self closePrinter];
    }
    
    return err;
}

- (int) selectWithMode:(SOCKETSELECTMODE) mode dataPresent:(bool*) dataPresent
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

- (int) connectWithAddr:(const struct sockaddr*) name length:(int) namelen
{
	int				n, error;
	socklen_t		len;
	fd_set			rset, wset;
	struct timeval	tval;
    
	error = 0;

	if ( (n = connect(sock, name, namelen)) < 0)
	{
		error = errno;
		if (errno != EINPROGRESS)
			return(-1);
	}
    
	if (n == 0)
		goto done;	/* connect completed immediately */
    
	FD_ZERO(&rset);
	FD_SET(sock, &rset);
	wset = rset;
	tval.tv_sec = 35;
	tval.tv_usec = 0;
	
	if ( (n = select(sock+1, &rset, &wset, NULL, &tval)) == 0) {
		close(sock);		/* timeout */
		errno = ETIMEDOUT;
		return(-1);
	}
	
	if (FD_ISSET(sock, &rset) || FD_ISSET(sock, &wset)) {
		len = sizeof(error);
		if (getsockopt(sock, SOL_SOCKET, SO_ERROR, &error, &len) < 0)
			return(-1);			/* Solaris pending error */
	} else
		return(-1);		//err_quit("select error: sockfd not set");
	
done:
	if (error) {
		close(sock);		/* just in case */
		errno = error;
		return(-1);
	}
	
	int i = 1;
	
	struct timeval tv;
	NSBundle * bundle = [NSBundle mainBundle];
	NSString * timeout = [bundle objectForInfoDictionaryKey:@"NetTimeout"];
	if(timeout)
		tv.tv_sec = [timeout intValue];       /* Timeout in seconds */
	else
		tv.tv_sec = 5;
	//tv.tv_sec = 5;       /* Timeout in seconds */
	tv.tv_usec = 0; 
	setsockopt(sock, SOL_SOCKET, SO_SNDTIMEO,( char * )&tv,sizeof(struct timeval));
	setsockopt(sock, SOL_SOCKET, SO_RCVTIMEO,( char * )&tv,sizeof(struct timeval));
	
    setsockopt(sock, IPPROTO_TCP, TCP_NODELAY, (char *)&i, sizeof(int));
	
	int optval = 1;
	socklen_t optlen = sizeof(optval);
	setsockopt(sock, SOL_SOCKET, SO_KEEPALIVE, &optval, optlen);
	
	return(0);
}


- (BOOL) getAddressFromIPv6:(NSString* ) strIPv6
{
    int err = 0;
    char buftemp[1024] = {0};
    char buffer[1024] = {0};
    const char *formatted;
    int sock2 = -1;
    NSLog(@"getAddressFromIPv6 start");
    int				nn, error;
	socklen_t		len;
	fd_set			rset, wset;
	struct timeval	tval;
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    strcpy(buffer, [strIPv6 cStringUsingEncoding:NSASCIIStringEncoding]);
    
    int y = 0;
    for(y = 0; y < 10; y++)
    {
        char sztemp[20] = {0};
        sprintf(sztemp, "%%en%d", y); // ming change ...go to do....
        strcpy(buftemp, buffer);
        strcat(buftemp, sztemp);
        formatted = buftemp;
        ipAddress6 = [[NSString alloc] initWithCString:formatted];
        
        struct addrinfo hints, *res=NULL;
        bzero(&hints, sizeof(struct addrinfo));
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;
        
        
        int n = getaddrinfo([ipAddress6 cStringUsingEncoding:NSASCIIStringEncoding], "9100", &hints, &res);
        if (n != 0) {
            NSLog(@"%s", gai_strerror(n));
            [pool release];
            return FALSE;
        }
        
        sock2 = socket((int)res->ai_family, (int)res->ai_socktype, (int)res->ai_protocol);
        
        const struct sockaddr* name = (const struct sockaddr*)res->ai_addr;
        int lenght = (int)res->ai_addrlen;
        if ( (nn = connect(sock2, name, lenght)) < 0)
        {
            error = errno;
            if (errno != EINPROGRESS)
            {
                NSLog(@"Ming1: Fail, IPv6(%@) can not open printer!!!!", ipAddress6);
                close(sock2);
                continue;
            }
        }
        
        if (nn == 0)
            goto done;	// connect completed immediately
        
        FD_ZERO(&rset);
        FD_SET(sock2, &rset);
        wset = rset;
        tval.tv_sec = 35;
        tval.tv_usec = 0;
        
        if ( (nn = select(sock2 + 1, &rset, &wset, NULL, &tval)) == 0)
        {
            close(sock2);
            errno = ETIMEDOUT;
            NSLog(@"Ming2: Fail, IPv6 can not open printer!!!!");
            continue;
        }
        
        if (FD_ISSET(sock2, &rset) || FD_ISSET(sock2, &wset))
        {
            len = sizeof(error);
            if (getsockopt(sock2, SOL_SOCKET, SO_ERROR, &error, &len) < 0)
            {
                NSLog(@"Ming3: Fail, IPv6 can not open printer!!!!");
                close(sock2);
                continue;
            }
        }
        else
        {
            NSLog(@"Ming4: Fail, IPv6 can not open printer!!!!");
            close(sock2);
            continue;		//err_quit("select error: sockfd not set");
        }
    done:
        if(err == 0)
        {
            NSLog(@"Ming, IPv6 can open printer!!!!");
            bFinishIPv6 = 6;
            break;
        }
        else
        {
            NSLog(@"Ming, IPv6 can't open printer!!!!");
            bFinishIPv6 = 2;
        }
    }
    
    close(sock2);
    [pool release];
    NSLog(@"getAddressFromIPv6 end");
    if(bFinishIPv6 == 6)
        return YES;
    else
        return NO;
}
//*/
- (BOOL) getAddressFromIPv4:(NSString* ) strIPv4
{
    int sock2 = -1;
    int err = 0;
    int				nn, error;
	socklen_t		len;
	fd_set			rset, wset;
	struct timeval	tval;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    struct addrinfo hints, *res=NULL;
    bzero(&hints, sizeof(struct addrinfo));
    hints.ai_family = AF_UNSPEC;
    hints.ai_socktype = SOCK_STREAM;
    NSLog(@"getAddressFromIPv4 start");
    
    int n = getaddrinfo([strIPv4 cStringUsingEncoding:NSASCIIStringEncoding], "9100", &hints, &res);
    if (n != 0)
    {
        NSLog(@"%s", gai_strerror(n));
        bFinishIPv4 = 2;
        [pool release];
        return FALSE;
    }
    sock2 = socket(res->ai_family, res->ai_socktype, res->ai_protocol);
    
	error = 0;
    const struct sockaddr* name = (const struct sockaddr*)res->ai_addr;
    int lenght = (int)res->ai_addrlen;
	if ( (nn = connect(sock2, name, lenght)) < 0)
	{
		error = errno;
		if (errno != EINPROGRESS)
        {
            NSLog(@"Ming1: Fail, IPv4 can not open printer!!!!");
            close(sock2);
            bFinishIPv4 = 2;
            [pool release];
			return NO;
        }
	}
    
	if (nn == 0)
		goto done;	// connect completed immediately
    
	FD_ZERO(&rset);
	FD_SET(sock2, &rset);
	wset = rset;
	tval.tv_sec = 35;
	tval.tv_usec = 0;
	
	if ( (nn = select(sock2 + 1, &rset, &wset, NULL, &tval)) == 0) {
		close(sock2);
		errno = ETIMEDOUT;
        NSLog(@"Ming2: Fail, IPv4 can not open printer!!!!");
        
        bFinishIPv4 = 2;
        [pool release];
		return NO;
	}
	
	if (FD_ISSET(sock2, &rset) || FD_ISSET(sock2, &wset))
    {
		len = sizeof(error);
		if (getsockopt(sock2, SOL_SOCKET, SO_ERROR, &error, &len) < 0)
        {
            NSLog(@"Ming3: Fail, IPv4 can not open printer!!!!");
            
            bFinishIPv4 = 2;
            [pool release];
			return NO;
        }
	}
    else
    {
        NSLog(@"Ming4: Fail, IPv4 can not open printer!!!!");
        
        bFinishIPv4 = 2;
        [pool release];
		return NO;		//err_quit("select error: sockfd not set");
    }
	
done:
	if (error) {
		close(sock2);
		errno = error;
        
        bFinishIPv4 = 2;
        [pool release];
		return NO;
	}
    
    
    if(err == 0)
    {
        NSLog(@"Ming, IPv4 can open printer!!!!");
    }
    close(sock2);
    bFinishIPv4 = 4;
    [pool release];
    NSLog(@"getAddressFromIPv4 end");
    return YES;
}
//*/

//-----
-(int)GetIPAddress
{
    NSLog(@"GetIPAddress Start");
    NSString *address = @"error";
    NSString *address6 = @"error";
    int iValue = 0, iValue6 = 0;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    if(success == 0)
    {
        temp_addr = interfaces;
        while (temp_addr != NULL)
        {
            if(temp_addr ->ifa_addr ->sa_family == AF_INET)
            {
                address = [NSString stringWithUTF8String:(const char*)inet_ntoa(((struct sockaddr_in *)temp_addr ->ifa_addr) ->sin_addr)];
                if(![address hasPrefix:@"127"] && [address componentsSeparatedByString:@"."])
                {
                    NSLog(@"local ipv4 = %@", address);
                    iValue = 4;
                }
            }
            else if(temp_addr ->ifa_addr ->sa_family == AF_INET6)
            {
                address6 = [NSString stringWithUTF8String:(const char*)inet_ntoa(((struct sockaddr_in6 *)temp_addr ->ifa_addr) ->sin6_addr)];
                if(![address6 hasPrefix:@"254"] && ![address6 hasPrefix:@"0"] && [address componentsSeparatedByString:@"."])
                {
                    NSLog(@"local ipv6 = %@", address6);
                    iValue6 = 6;
                }
            }
            
            temp_addr = temp_addr ->ifa_next;
        }
    }
    
    NSLog(@"GetIPAddress End");

    
    return iValue + iValue6;
}
//-----
- (NSString*) getAddressFromURL:(NSURL*) url
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSString *scheme = [url scheme];
	NSString *ipAddress = nil;
    NSString *version = [[NSProcessInfo processInfo] operatingSystemVersionString];
    NSRange versionrange = [version rangeOfString:@"10.4"];
    if ([scheme compare:@"socket" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
		[scheme compare:@"ipp" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
		[scheme compare:@"lpd" options:NSCaseInsensitiveSearch] == NSOrderedSame
		)
	{
        //ipAddress = [[NSString alloc] initWithString:[url host]];
		NSString *ipstr = [NSString stringWithString:[url host]];
        NSLog(@"ipstr = %@", ipstr);
        
		if ([ipstr length] > 2
			&& [ipstr characterAtIndex:0] == '['
			&& [ipstr characterAtIndex:([ipstr length] - 1)] == ']') {
			NSRange range;
			range.location = 1;
			range.length = [ipstr length] - 2;
			ipAddress = [[NSString alloc] initWithString:[ipstr substringWithRange:range]];
		} else {
			ipAddress = [[NSString alloc] initWithString:ipstr];
		}
        
		
	}
	else if ([scheme compare:@"mdns" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
             [scheme compare:@"dnssd" options:NSCaseInsensitiveSearch] == NSOrderedSame
             )
	{
        
        int ipMode = [self GetIPAddress];
        
        int i = 0, j =0;
        while(ipAddress == nil)
        {
            NSLog(@"while");
            NSString *host = [url host];
            NSLog(@"host = %@", host);
            NSRange range = [host rangeOfString:@"."];
            NSString *name = [host substringToIndex:range.location];
            NSLog(@"name = %@", name);
            NSNetService *service = [[NSNetService alloc] initWithDomain:@"local." type:@"_printer._tcp." name:name port:515];
            
            [service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:@"PrivatePMode"];
            [service resolveWithTimeout:1.0];
            CFAbsoluteTime deadline = CFAbsoluteTimeGetCurrent() + 8.0;
            CFTimeInterval remaining;
            while ((remaining = (deadline - CFAbsoluteTimeGetCurrent())) > 0 && [[service addresses] count] == 0)
            {
                NSLog(@"**********");
                CFRunLoopRunInMode((CFStringRef)@"PrivatePMode", remaining, true);
            }
            [service stop];
            
            NSArray *addresses = [service addresses];
            NSLog(@"%@", [service addresses]);
            
            for(i=0; i<[addresses count]; i++)
            {
                NSLog(@"For Start");
                NSData *address = [addresses objectAtIndex:i];
                
                const char *formatted;
                char buffer[1024];
                
                struct sockaddr *address_sin = (struct sockaddr *)[address bytes];
                
                if (address_sin->sa_family == AF_INET)//address_sin && address_sin->sa_family == AF_INET && (ipMode == 4 || ipMode == 10))
                {
                    formatted = (const char*)inet_ntop(AF_INET, &((struct sockaddr_in *)address_sin)->sin_addr, buffer, sizeof(buffer));
                    ipAddress4 = [[NSString alloc] initWithCString:formatted];
                    //  ipAddress = ipAddress4;
                    NSLog(@"IPv4 = %@", ipAddress4);
                    if([self getAddressFromIPv4:ipAddress4])
                    {
                        ipAddress = ipAddress4;
                        break;
                    }
                    else
                        j = 5;
                    //    [NSThread detachNewThreadSelector:@selector(getAddressFromIPv4:) toTarget:self withObject:ipAddress4];
                    //   NSLog(@"NSThread ipv4 be Created;");
                }
                else if (address_sin->sa_family == AF_INET6)//address_sin && address_sin->sa_family == AF_INET6 && ipMode >= 6)
                {
                    
                    formatted = (const char*)inet_ntop(AF_INET6, &((struct sockaddr_in6 *)address_sin)->sin6_addr, buffer, sizeof(buffer));
                    ipAddress6 = [[NSString alloc] initWithCString:formatted];
                    
                    if([ipAddress6 length] > 0)
                    {
                        NSLog(@"IPv6 = %@", ipAddress6);
                        if([self getAddressFromIPv6:ipAddress6])
                        {
                            ipAddress = ipAddress6;
                            break;
                        }
                        else
                            j = 5;
                        //   [NSThread detachNewThreadSelector:@selector(getAddressFromIPv6:) toTarget:self withObject:ipAddress6];
                        //  NSLog(@"NSThread ipv6 be Created;");
                    }
                    
                }//*/
                NSLog(@"For end");
                
            }
            
            
            [service release];
            
            if(j > 4 || versionrange.length < 1 || [addresses count] == 0)
            {
                break;
            }
            j++;
            sleep(1);
            NSLog(@"** --j = %d ** --", j);
            
        }
        // [service release];
        NSLog(@"Service Release");
	}
    
    NSLog(@"ip = %@", ipAddress);
    [pool release];
	return ipAddress;
}



@end
