//
//  NetPrinter.h
//  PrinterSettingUtility
//
//  Created by Wang Kun on 3/3/14.
//  Copyright (c) 2014 Wang Kun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetPrinter : NSObject
{
    int sock;
    int sndCancel;
    int rcvCancel;
    int maxFD;
    
    int bFinishIPv4, bFinishIPv6;
    bool didCancel;
    
    NSString* ipAddress4;
    NSString* ipAddress6;
    
    int sockfd;
}

//- (BOOL) openPrinter:(NSString*) printerURI;
- (void) closePrinter;
- (BOOL) isPrinterOpen;

- (BOOL)connetToNetDevice:(NSString *)devURI;
- (int)wirteToNetDevice:(void *)buffer length:(int)len;
- (int)readFromNetDevice:(void *)buffer length:(int)len;
- (void)closeSocket;

@end
