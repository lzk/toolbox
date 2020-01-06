//
//  NetDevice.h
//  MachineSetup
//
//  Created by Wang Kun on 10/25/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NetDevice : NSObject <NSNetServiceDelegate>
{
	NSMutableArray *mDNSIP,*mDNSType;
	NSString * ifName;
	
@private
    int sockfd;
	
}

- (BOOL)connetToNetDevice:(NSString *)devURI;
- (BOOL)isPrinterOpen;
- (int)wirteToNetDevice:(void *)buffer length:(int)len;
- (int)readFromNetDevice:(void *)buffer length:(int)len;
- (void)closeSocket;

@end
