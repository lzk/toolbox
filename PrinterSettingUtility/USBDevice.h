//
//  USBDevice.h
//  MachineSetup
//
//  Created by Helen Liu on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOKit/usb/IOUSBLib.h>
#import <mach/mach.h>
#import "DataStructure.h"

@interface USBDevice : NSObject {
@private
    IOUSBInterfaceInterface300	**intfPrinter;
    IOUSBDeviceInterface300		**devPrinter;
    
    UInt8					outPipeRef;
    UInt8					inPipeRef;
	
    UInt32					maxOutPacketSize;	       // size data packet
    UInt32					maxInPacketSize;	       // size data packet
}

- (BOOL)USBConnect:(NSString*) printerURI;
- (void)USBDisconnect;
- (IOResult) USBRead:(LPVOID) buffer bufferLength:(UInt32) length;
- (IOResult) USBWrite:(LPVOID) buffer bufferLength:(UInt32) length;
@end
