//
//  DeviceProperty.h
//  MachineSetup
//
//  Created by Helen Liu on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

@interface DeviceCommond : NSObject {
@private

@protected
    UInt32 payloadSizeCommand;
    UInt32 payloadSizeResponse;
    UInt8 IDCode;
    UInt8 IDGroupGet;
    UInt8 IDGroupSet;
    
    id      deviceData;
    
    NSString *commandName;
    BOOL printerInformation2Available;
    BOOL isNeedRestart;
}
- (id)initWithGroupID:(UInt8)groupID CodeID:(UInt8)codeID needRestart:(BOOL)need;

@property (readonly) UInt32 payloadSizeCommand;
@property (readonly) UInt32 payloadSizeResponse;
@property (nonatomic, copy) NSString *commandName;
@property (nonatomic, assign) BOOL printerInformation2Available;
@property (assign) BOOL isNeedRestart;
@property (assign) UInt8 IDCode;


- (void)commandData:(id)lpData size:(UInt32 *)dataSize isToGet:(BOOL)isToGet responseDataSize:(UInt32*)responseSize;
//- (void)setResponseData:(id)lpData size:(UInt32)dataSize;
- (UInt32)responseDataSize:(BOOL)isToGet;
- (BOOL)initDeviceData;
- (BOOL)setDeviceData:(id)data dataSize:(UInt32) dataSize;
- (id)deviceData;
- (void)GroupID_Get:(UInt8 *)idGet ID_Set:(UInt8 *)idSet;
- (UInt8)CodeID;
@end



@interface PrinterInformation : DeviceCommond 

@end



@interface PrinterInformation2 : DeviceCommond

@end



@interface SystemSettings : DeviceCommond 

@end



@interface BillingMeters : DeviceCommond

@end



@interface PaperDensity : DeviceCommond

@end



@interface AdjustBTR : DeviceCommond 

@end



@interface AdjustFuser : DeviceCommond 

@end



@interface RegistrationAdjustment : DeviceCommond

@end



@interface AdjustAltitude : DeviceCommond

@end



@interface NonGenToner : DeviceCommond

@end



@interface BTRRefresh : DeviceCommond

@end


@interface EnvironmentSensorInfo : DeviceCommond

@end



@interface DensityAdjustment : DeviceCommond {
@private
    
    
}

@end



@interface TraySettings : DeviceCommond {
@private
    
    
}

@end



@interface ResetSystemSectionCommond : DeviceCommond {
@private
    
    
}

@end


@interface NetwrokSettings : DeviceCommond 
    
@end


@interface WirelessSettings : DeviceCommond

@end

@interface WirelessDirectSettings : DeviceCommond

@end

@interface WifiPIN : DeviceCommond

@end

@interface WirelessDirectIP : DeviceCommond

@end

@interface WifiStatus : DeviceCommond

@end


@interface WifiFeatures : DeviceCommond

@end

@interface TCPIPSettings : DeviceCommond

@end


@interface TCPIPSettingsV2 : DeviceCommond

@end


@interface SecuritySettings : DeviceCommond

@end



@interface EWS : DeviceCommond

@end

@interface LifeSetting : DeviceCommond

@end


