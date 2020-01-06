//
//  NetDevice.m
//  MachineSetup
//
//  Created by Wang Kun on 10/25/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "NetDevice.h"
#import "DataStructure.h"
#import "AppDelegate.h"

#import <sys/types.h>
#import <sys/socket.h>
#import <string.h>
#import <stdio.h>
#import <netinet/in.h>
#import <sys/stat.h>
#import <sys/fcntl.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netdb.h>
#include <netinet/tcp.h>
#include <net/if.h>


#define DEV_PORT     9100
#define BUFSIZE      1024

@implementation NetDevice

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (BOOL)isHostIPv4Available
{
    NSMutableArray *ipv4Array = [[NSMutableArray alloc] init];
    char cIPv4[16];
    
    struct ifaddrs *hostAddr;
    if (getifaddrs(&hostAddr) == -1)
    {
        return NO;
    }
    
	while (hostAddr)
    {
        if (hostAddr->ifa_addr->sa_family == AF_INET)
        {
            if (inet_ntop(AF_INET, &(((struct sockaddr_in *)(hostAddr->ifa_addr))->sin_addr), cIPv4, 16))
            {
                [ipv4Array addObject:[NSString stringWithUTF8String:cIPv4]];
            }
		}
		
		hostAddr = hostAddr->ifa_next;
	}
    
    if ([ipv4Array count] == 1 && [[ipv4Array objectAtIndex:0] isEqualToString:@"127.0.0.1"])
    {
        return NO;
    }
    
    return YES;
}

- (BOOL)getNetDeviceAddress:(void *)devAddr family:(int *)family devURI:(NSString *)devURI
{
    NSURL *url = [NSURL URLWithString:devURI];
	
    if (url == nil)
    {
        return NO;
    }
	
	
	
	[mDNSIP removeAllObjects];
	[mDNSType removeAllObjects];
	mDNSIP = [NSMutableArray arrayWithCapacity:255];
	mDNSType = [NSMutableArray arrayWithCapacity:255];
	
	
    NSString *scheme = [url scheme];
    if ([scheme isEqualToString:@"socket"] ||
        [scheme isEqualToString:@"ipp"]    ||
        [scheme isEqualToString:@"lpd"])
    {
		NSLog(@"[net] scheme=%@",scheme);

        NSString *ip = [url host];
		NSLog(@"[net] ip=%@",ip);

		//	ip = [ip stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		const char *cIP;
		ip = [ip stringByReplacingOccurrencesOfString:@"]" withString:@""];
		ip = [ip stringByReplacingOccurrencesOfString:@"[" withString:@""];
		ip = [ip stringByReplacingOccurrencesOfString:@" " withString:@""];
		cIP = [ip cStringUsingEncoding:NSUTF8StringEncoding];
		
		NSLog(@"[net] cIP=%s",cIP);

#if 0
		NSArray *ipSplit = [ip componentsSeparatedByString:@"%"];
		if([ipSplit count] > 1)
		{
			NSArray *ipSplit1 = [[ipSplit objectAtIndex:0] componentsSeparatedByString:@"["];
			ifName = [[ipSplit objectAtIndex:1] stringByReplacingOccurrencesOfString:@"]" withString:@""];
            cIP = [[ipSplit1 objectAtIndex:1] cStringUsingEncoding:NSUTF8StringEncoding];
		}
		else {
			cIP = [ip cStringUsingEncoding:NSUTF8StringEncoding];
		}
#endif
		
		struct hostent *host_entry=NULL;
		host_entry=gethostbyname2(cIP,AF_INET6);
		char ipaddr[256];
		
		NSLog(@"[net] host_entry=%x",host_entry);

		if(host_entry==NULL)
		{
			//PDEProlog(@"Netprinter [%s] ipv6 lookup faild",domaincString);
			host_entry=gethostbyname2(cIP,AF_INET);
			NSLog(@"[net] host_entry1=%x",host_entry);

			if(host_entry==NULL)
			{
				//PDEProlog(@"Netprinter ipv4 lookup faild");
				//[ipAddress release];
				NSLog(@"[net] invaild ip [%s]",cIP);
				return NO;
			}
			inet_ntop(PF_INET,(struct in_addr *)host_entry->h_addr,ipaddr,sizeof(ipaddr));
			NSLog(@"[net] cIP [%s]",ipaddr);
			if (inet_pton(AF_INET, ipaddr, &((struct sockaddr_in *)devAddr)->sin_addr))
			{
				*family = AF_INET;
				struct sockaddr_in *ipv4 = (struct sockaddr_in *)devAddr;
				ipv4->sin_family = AF_INET;
				if([[url port] intValue] == 0)
				{
					
					ipv4->sin_port = htons(9100);
					
					
				}
				else {
					ipv4->sin_port = htons([[url port] intValue]);
				}
				
				
				[mDNSType addObject:@"IPv4"];
				[mDNSIP addObject:[NSData dataWithBytes:ipv4 length:sizeof(struct sockaddr_in)]];
				
				return YES;
			}
			
			
		}
		else
		{
			//char* ipaddr = inet_ntoa (*(struct in_addr *)*host_entry->h_addr_list);
			inet_ntop(PF_INET6,(struct in_addr *)host_entry->h_addr,ipaddr,sizeof(ipaddr));
			NSLog(@"[net] cIP [%s]",ipaddr);
			if (inet_pton(AF_INET6, ipaddr, &((struct sockaddr_in6 *)devAddr)->sin6_addr))
			{
				*family = AF_INET6;
				struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)devAddr;
				ipv6->sin6_family = AF_INET6;
				
				if([[url port] intValue] == 0)
				{
					
					ipv6->sin6_port = htons(9100);
					
					
				}
				else {
					ipv6->sin6_port = htons([[url port] intValue]);
				}
				
				NSLog(@"[net] ipv6->sin6_scope_id=%d\r\n",ipv6->sin6_scope_id);
							
				ipv6->sin6_scope_id = 0;
				
				struct addrinfo *result;
				
				int error = getaddrinfo(cIP, NULL, NULL, &result);
				if (error == 0)
				{   
					if(result->ai_family == AF_INET6)
					{
						ipv6->sin6_scope_id = ((struct sockaddr_in6 *)result->ai_addr)->sin6_scope_id;
					}
				} 
									
				NSLog(@"[net] ipv6->sin6_scope_id1=%d\r\n",ipv6->sin6_scope_id);

				[mDNSType addObject:@"IPv6"];
				[mDNSIP addObject:[NSData dataWithBytes:ipv6 length:sizeof(struct sockaddr_in6)]];
				
				return YES;
			}
		}
#if 0
		[ipAddress release];
		//ipAddress=[NSString alloc];
		ipAddress=[[NSString alloc] initWithFormat:@"%s",ipaddr ];
		[mDNSIP addObject:ipAddress];
		
		
		
		
        if (inet_pton(AF_INET, cIP, &((struct sockaddr_in *)devAddr)->sin_addr))
        {
            *family = AF_INET;
            struct sockaddr_in *ipv4 = (struct sockaddr_in *)devAddr;
            ipv4->sin_family = AF_INET;
            if([[url port] intValue] == 0)
			{
				
				ipv4->sin_port = htons(9100);
				
				
			}
			else {
				ipv4->sin_port = htons([[url port] intValue]);
			}
			
			
            [mDNSType addObject:@"IPv4"];
			[mDNSIP addObject:[NSData dataWithBytes:ipv4 length:sizeof(struct sockaddr_in)]];
			
            return YES;
        }
        else if (inet_pton(AF_INET6, cIP, &((struct sockaddr_in6 *)devAddr)->sin6_addr))
        {
            *family = AF_INET6;
            struct sockaddr_in6 *ipv6 = (struct sockaddr_in6 *)devAddr;
            ipv6->sin6_family = AF_INET6;
			
			if([[url port] intValue] == 0)
			{
				
				ipv6->sin6_port = htons(9100);
				
				
			}
			else {
				ipv6->sin6_port = htons([[url port] intValue]);
			}
			
			ipv6->sin6_scope_id = 0;

            
			[mDNSType addObject:@"IPv6"];
			[mDNSIP addObject:[NSData dataWithBytes:ipv6 length:sizeof(struct sockaddr_in6)]];
			
            return YES;
        }
#endif
        NSLog(@"[net] invaild ip [%s]",cIP);
        return NO;
    }
    
	else if ([scheme compare:@"mdns" options:NSCaseInsensitiveSearch] == NSOrderedSame ||
			 [scheme compare:@"dnssd" options:NSCaseInsensitiveSearch] == NSOrderedSame
			 )
    {
        NSString *host = [url host];
        NSRange range = [host rangeOfString:@"."];
        NSString *name = [host substringToIndex:range.location];
		NSNetService *service = [[NSNetService alloc] initWithDomain:@"local." type:@"_pdl-datastream._tcp" name:name];
        service.delegate = self;
        
		
		
        /*
		 [service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:kCFRunLoopDefaultMode];
		 [service resolveWithTimeout:5];
		 BOOL done = NO;
		 do
		 {
		 SInt32 result = CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, YES);
		 if (result == kCFRunLoopRunFinished || result == kCFRunLoopRunStopped)
		 {
		 done = YES;
		 NSLog(@"Yes");
		 }
		 
		 NSLog(@"while");
		 
		 } while (!done);
		 [service stop];
		 */
        [service scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:@"PrivatePMode"];
        [service resolveWithTimeout:8.0];
        CFAbsoluteTime deadline = CFAbsoluteTimeGetCurrent() + 3.0;
        CFTimeInterval remaining;
        while ((remaining = (deadline - CFAbsoluteTimeGetCurrent())) > 0 && [[service addresses] count] <=2)
        {
            CFRunLoopRunInMode((CFStringRef)@"PrivatePMode", remaining, true);
        }
        [service stop];
        
        NSLog(@"address = %@ %d", [service addresses], [[service addresses] count]);
        NSArray *addresses = [service addresses];
        int i;
		for(i = 0; i < [addresses count]; i++)
		{
			char addr[256];
			
			struct sockaddr *sa = (struct sockaddr *)
			[[addresses objectAtIndex:i] bytes];
			
			if(sa->sa_family == AF_INET6)
			{
				struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)sa;
				
				if(inet_ntop(AF_INET6, &sin6->sin6_addr, addr, sizeof(addr)))
				{
					
					NSLog(@"[net][IPv6] %s scopeid [%i]", addr,sin6->sin6_scope_id);
					[mDNSType addObject:@"IPv6"];
					[mDNSIP addObject:[NSData dataWithBytes:sin6 length:sizeof(struct sockaddr_in6)]];
					
					NSLog(@"[net] [mDNSIP index] = %i", [mDNSType count]);

				}
			}
		}
		
		for(i = 0; i < [addresses count]; i++)
		{
			char addr[256];
			
			struct sockaddr *sa = (struct sockaddr *)
			[[addresses objectAtIndex:i] bytes];
			
			if(sa->sa_family == AF_INET)
			{
				struct sockaddr_in *sin = (struct sockaddr_in *)sa;
				
				if(inet_ntop(AF_INET, &sin->sin_addr, addr, sizeof(addr)))
				{
					NSLog(@"[net][IPv4] %s", addr);
					[mDNSType addObject:@"IPv4"];
					[mDNSIP addObject:[NSData dataWithBytes:sin length:sizeof(struct sockaddr_in)]];
				}
			}
		}
		
		NSLog(@"[net] [mDNSIP count] = %i", [mDNSType count]);
		 [service release];
		if([mDNSIP count] >= 1)
			return YES;
    }
    
    return NO;
}

- (BOOL)connetToNetDevice:(NSString *)devURI
{
    int n = sizeof(struct sockaddr_in);
    char devSockAddr[n];
    int sockFamily;
    
    if ([self getNetDeviceAddress:devSockAddr family:&sockFamily devURI:devURI] == NO)
    {
		NSLog(@"getNetDeviceAddress no count=%i",[mDNSIP count]);
        return NO;
    }
    
	NSLog(@"getNetDeviceAddress yes count=%i",[mDNSIP count]);
	BOOL isConnected=FALSE;
	
	NSInteger mDNScnt=[mDNSIP count];
	NSInteger IpCnt;
	if(mDNScnt<=0)
		return NO;
	
	char printername[2049];
	PRINTER_STATUS printer_status;
#if 1
	for(IpCnt = 0; IpCnt < mDNScnt; IpCnt++)
	{
		int k=0;
		
		for (;k<10 ;k++)
		{
			
			if([[mDNSType objectAtIndex:IpCnt] isEqualToString:@"IPv4"] ){
				
				struct sockaddr_in dev_addr;
				memcpy(&dev_addr, [[mDNSIP objectAtIndex:IpCnt] bytes], sizeof(struct sockaddr_in));
				char ip[16];
				inet_ntop(AF_INET, &dev_addr.sin_addr, ip, 16);
				
				//NSString *address = [mDNSIP objectAtIndex:IpCnt];
				if(NetworkReadStatus("public",ip,&printer_status,printername) == 1)
				{   
					
					NSString* NSprintername = [NSString stringWithFormat:@"%s" , printername];
					NSLog(@"[net] 1284id = [%@]",NSprintername);
					
					
#ifdef MACHINESETUP_IBG				
					if(([NSprintername rangeOfString:@"DocuPrint CP115/118 w"].location == NSNotFound) && 
					   ([NSprintername rangeOfString:@"DocuPrint CP116/119 w"].location == NSNotFound))
#endif
#ifdef MACHINESETUP_XC
						if([NSprintername rangeOfString:@"Phaser 6020"].location == NSNotFound)
#endif
						{
							
							return NO;
							
						}else {
							
							break;
						}
					
					
					
					
					
				}
#if SNMPV3				
				if(NetworkReadStatusSNMPv3("public",ip,&printer_status,printername) == 1)
				{   
					
					NSString* NSprintername = [NSString stringWithFormat:@"%s" , printername];
					NSLog(@"[net] 1284id = [%@]",NSprintername);
					
#ifdef MACHINESETUP_IBG				
					if(([NSprintername rangeOfString:@"DocuPrint CP115/118 w"].location == NSNotFound) && 
					   ([NSprintername rangeOfString:@"DocuPrint CP116/119 w"].location == NSNotFound))
#endif
#ifdef MACHINESETUP_XC
						if([NSprintername rangeOfString:@"Phaser 6020"].location == NSNotFound)
#endif
						{
							
							return NO;
							
						}else {
							break;
						}
					
				}
				
				
				
				
				
				
#endif
			}
			else if ([[mDNSType objectAtIndex:IpCnt] isEqualToString:@"IPv6"]){
				
				struct sockaddr_in6 dev_addr;
				memcpy(&dev_addr, [[mDNSIP objectAtIndex:IpCnt] bytes], sizeof(struct sockaddr_in6));
				char ip[40];
				inet_ntop(AF_INET6, &dev_addr.sin6_addr, ip, 40);
				
				//NSString *address = [mDNSIP objectAtIndex:IpCnt];
				if(NetworkReadStatusV6("public",ip,&printer_status,printername) == 1)
				{   
					
					NSString* NSprintername = [NSString stringWithFormat:@"%s" , printername];
					NSLog(@"[net] 1284id = [%@]",NSprintername);
					
#ifdef MACHINESETUP_IBG				
					if(([NSprintername rangeOfString:@"DocuPrint CP115/118 w"].location == NSNotFound) && 
					   ([NSprintername rangeOfString:@"DocuPrint CP116/119 w"].location == NSNotFound))
#endif
#ifdef MACHINESETUP_XC
						if([NSprintername rangeOfString:@"Phaser 6020"].location == NSNotFound)
#endif
						{
							
							return NO;
							
						}else {
							break;
						}
					
					
					
					
					
				}break;
				
#if SNMPV3				
				if(NetworkReadStatusV6SNMPv3("public",[address cStringUsingEncoding:NSASCIIStringEncoding],&printer_status,printername) == 1)
				{   
					
					NSString* NSprintername = [NSString stringWithFormat:@"%s" , printername];
					NSLog(@"[net] 1284id = [%@]",NSprintername);
					
#ifdef MACHINESETUP_IBG				
					if(([NSprintername rangeOfString:@"DocuPrint CP115/118 w"].location == NSNotFound) && 
					   ([NSprintername rangeOfString:@"DocuPrint CP116/119 w"].location == NSNotFound))
#endif
#ifdef MACHINESETUP_XC
						if([NSprintername rangeOfString:@"Phaser 6020"].location == NSNotFound)
#endif
						{
							
							return NO;
							
						}else {
							break;
						}
					
					
					
					
					
				}
#endif
			}
		}
	}
#endif
	for(IpCnt = 0; IpCnt < mDNScnt; IpCnt++)
	{
		
		if ( [[mDNSType objectAtIndex:IpCnt] isEqualToString:@"IPv4"] )
		{
			NSLog(@"[net] ipv4");
			struct sockaddr_in dev_addr;
			memcpy(&dev_addr, [[mDNSIP objectAtIndex:IpCnt] bytes], sizeof(struct sockaddr_in));
			char ip[16];
			inet_ntop(AF_INET, &dev_addr.sin_addr, ip, 16);
			
			dev_addr.sin_port = htons(9100);

			
			struct addrinfo hints,*result,*r;
			
			memset(&hints, 0, sizeof(hints));
			hints.ai_family = AF_INET;
			hints.ai_socktype = SOCK_STREAM;
			hints.ai_protocol=IPPROTO_TCP;
			char port[15];
			sprintf(port, "%d", ntohs(dev_addr.sin_port));
			NSLog(@"[net] port = %s", port);

			int error = getaddrinfo(ip, port, &hints, &result);
			if (error != 0)
			{   
				NSLog(@"[net] [V4] error in getaddrinfo: %s\n", gai_strerror(error));
				//return NO;
				continue;
			} 	
			else
			{
				
				[[NSApp delegate] setDevIP:[NSString stringWithCString:ip encoding:NSUTF8StringEncoding]];
				NSLog(@"[net] ip = %s", ip);
				ipVer = 4;
				for (r=result; r; r=r->ai_next) {
					
					if ((sockfd = socket(r->ai_family, SOCK_STREAM, 0)) == -1)
					{
						NSLog(@"[net] socket open failed. ip = [%s]", ip);
						continue;
					}
					
				//	struct timeval timeout;
				//	timeout.tv_sec = 2;
				//	timeout.tv_usec = 500;
				//	setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO, &timeout, sizeof(timeout));
					
					
					if (connect(sockfd, (struct sockaddr *)r->ai_addr, sizeof(struct sockaddr_in)) == -1)
					{
						NSLog(@"[net] connect failed. ip = [%s]", ip);
						// return NO;
						continue;
					}
					else {
						isConnected=TRUE;
						break;
					}
				}
				if (isConnected == TRUE)
					break;
			}
		}
		else if ([[mDNSType objectAtIndex:IpCnt] isEqualToString:@"IPv6"])
		{
			NSLog(@"[net] ipv6 IpCnt=%d", IpCnt);
			struct sockaddr_in6 dev_addr;
			memcpy(&dev_addr, [[mDNSIP objectAtIndex:IpCnt] bytes], sizeof(struct sockaddr_in6));
			NSLog(@"dev_addr.sin6_scope_id=%d",dev_addr.sin6_scope_id);

			char ip[40];
			inet_ntop(AF_INET6, &dev_addr.sin6_addr, ip, 40);
			
			NSLog(@"[net] dev_addr.sin6_port = %d", ntohs(dev_addr.sin6_port));

			dev_addr.sin6_port = htons(9100);
			
			struct addrinfo hints,*result,*r;
			
			memset(&hints, 0, sizeof(hints));
			hints.ai_family = AF_INET6;
			hints.ai_socktype = SOCK_STREAM;
			hints.ai_protocol=IPPROTO_TCP;
			char port[15];
			sprintf(port, "%d", ntohs(dev_addr.sin6_port));
			NSLog(@"[net] port = %s", port);

			int error = getaddrinfo(ip, port, &hints, &result);
			if (error != 0)
			{   
				NSLog(@"[net] [V6] error in getaddrinfo: %s\n", gai_strerror(error));
				//return NO;
				continue;
			} 		
			else 
			{
				
				[[NSApp delegate] setDevIP:[NSString stringWithCString:ip encoding:NSUTF8StringEncoding]];
				NSLog(@"[net] ip = %s", ip);
				ipVer = 6;
				for (r=result; r; r=r->ai_next) {
					
					
					struct sockaddr_in6 * tmp=r->ai_addr;
					
					NSLog(@"[net] tmp->port = %d", ntohs(tmp->sin6_port));

					//tmp->sin6_scope_id = if_nametoindex([ifName cStringUsingEncoding:NSUTF8StringEncoding]);
					//NSLog(@"[net] ifName [%@], scopeid [%i]",ifName,tmp->sin6_scope_id);
					if ((sockfd = socket(r->ai_family, SOCK_STREAM, 0)) == -1)
					{
						NSLog(@"(sockfd = socket(r->ai_family, SOCK_STREAM, 0)) == -1");

						continue;
					}
					
					tmp->sin6_scope_id = dev_addr.sin6_scope_id;
					
					if (connect(sockfd, (struct sockaddr *)tmp, sizeof(struct sockaddr_in6)) == -1)
					{
						
						
						NSLog(@"[net] conect fail, scopeid [%i]",tmp->sin6_scope_id);
						continue;
					}
					else {
						NSLog(@"[net] conect ok, scopeid [%i]",tmp->sin6_scope_id);

						isConnected=TRUE;
						break; //connected
					}
					
					
					
				}
				
				if (isConnected == TRUE)
					break;
			}
			
			
			
			
			
		}
		
		
		
	}
	
	
	
	
	if (isConnected == FALSE) 
		return NO;
	
	int i = 1;
	
	struct timeval tv;
	NSBundle * bundle = [NSBundle mainBundle];
	NSString * timeout = [bundle objectForInfoDictionaryKey:@"NetTimeout"];
	if(timeout)
		tv.tv_sec = [timeout intValue];       /* Timeout in seconds */
	else
		tv.tv_sec = 5;
	tv.tv_usec = 0; 
	setsockopt(sockfd, SOL_SOCKET, SO_SNDTIMEO,( char * )&tv,sizeof(struct timeval));
	setsockopt(sockfd, SOL_SOCKET, SO_RCVTIMEO,( char * )&tv,sizeof(struct timeval));
	
	setsockopt(sockfd, IPPROTO_TCP, TCP_NODELAY, (char *)&i, sizeof(int));
	
	int optval = 1;
	socklen_t optlen = sizeof(optval);
	setsockopt(sockfd, SOL_SOCKET, SO_KEEPALIVE, &optval, optlen);
	
	
	return YES;
}

- (BOOL)isPrinterOpen
{
	return TRUE;
}

- (int)wirteToNetDevice:(void *)buffer length:(int)len
{
	
	NSLog(@"[net] write [%i].\n",len);
	
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
			{	NSLog(@"[net] read failed.[%s]\n",strerror(errno));
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

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSLog(@"resolve");
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"unrlsov");
}

@end
