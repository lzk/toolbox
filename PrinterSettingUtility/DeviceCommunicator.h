//
//  DeviceCommunicator.h
//  MachineSetup
//
//  Created by Helen Liu on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceProperty.h"

@interface DeviceCommunicator : NSObject {
@private
    id device;
	int devType;
	UInt32	m_nToken;
	BOOL m_bLogin;
    int contectResult;
    
    NSString *pURI;
}

- (int)connectPrinter:(NSString *)printerURI;
- (int)communicateInfo:(DeviceCommond *)aCommond Direction:(int)cmdDirection;
- (void) closePrinter;
- (BOOL) isPrinterOpen;
- (int)chartPrint:(DeviceCommond *)aCommond;
- (int)printerStatus:(UInt32 *)status  CurrentPrinterID:(NSString *)printerID IsNeedWait:(BOOL)isNeedWait;
- (int)canCommunicateWithPrinterID:(NSString *)printerID Status:(UInt32)status;
- (int)getDevType;
- (void)relDevice;

- (void)setConnectResult;
- (int)getConnectResulet;
- (void)setConnectThreadExit;
@end
