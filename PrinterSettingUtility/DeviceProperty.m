//
//  DeviceProperty.m
//  MachineSetup
//
//  Created by Helen Liu on 7/24/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DeviceProperty.h"
#import "DataStructure.h"
#import "ProgressController.h"

@implementation DeviceCommond
@synthesize payloadSizeCommand;
@synthesize payloadSizeResponse;
@synthesize commandName;
@synthesize printerInformation2Available;
@synthesize isNeedRestart;
@synthesize IDCode;

//@synthesize IDGroup;
//@synthesize IDCode;
- (id)init
{
    self = [super init];
    if (self) {
        payloadSizeCommand = 0;
        payloadSizeResponse = 0;
        IDCode = 0;
        IDGroupGet = IDGroupSet = 0;
        deviceData = nil;
        printerInformation2Available = NO;
        isNeedRestart = NO;
    }
    
    return self;
}

- (void)dealloc
{
    if(nil != deviceData)
    {
        free(deviceData);
		deviceData = nil;
        //NSLog(@"************ free deviceData **************");
    }
    [super dealloc];
}


- (id)initWithGroupID:(UInt8)groupID CodeID:(UInt8)codeID needRestart:(BOOL)need
{
    self = [super init];
    if (self) {
        payloadSizeCommand = 0;
        payloadSizeResponse = 0;
        IDCode = codeID;
        IDGroupGet = IDGroupSet = groupID;
        deviceData = nil;
        isNeedRestart = need;
    }
    
    return self;
}

- (void)fillCommandHeader:(id)lpData
{
    DEV_COMMAND *lpCmd = (DEV_COMMAND *)lpData;
    lpCmd->cmd_mark = CMD_MARK;
    lpCmd->utility_mark1 = UTILITY_MARK1;
    lpCmd->utility_mark2 = UTILITY_MARK2;
    lpCmd->utility_mark3 = UTILITY_MARK3;
  
}

- (UInt32)fillCommandToGet:(id)lpData
{
    [self fillCommandHeader:lpData];
    
    DEV_COMMAND *lpCmd = (DEV_COMMAND *)lpData;
    lpCmd->cmd_group_mark = IDGroupGet;
    lpCmd->cmd_code_mark = IDCode;
    lpCmd->payload_size = 0;
    
    return sizeof(DEV_COMMAND);
}
- (UInt32)fillCommandToSet:(id)lpData
{
    [self fillCommandHeader:lpData];
    
    DEV_COMMAND *lpCmd = (DEV_COMMAND *)lpData;
    lpCmd->cmd_group_mark = IDGroupSet;
    lpCmd->cmd_code_mark = IDCode;
    lpCmd->payload_size = EndianU32_NtoL(payloadSizeCommand);
    
    void *dest = (void*)lpData + sizeof(DEV_COMMAND);
    memcpy(dest, deviceData, payloadSizeCommand);
    
    return sizeof(DEV_COMMAND) + payloadSizeCommand;
}

- (UInt32)responseDataSize:(BOOL)isToGet
{
    UInt32 size = sizeof(DEV_RESPONSE);
    
    if(isToGet)
    {
        size += payloadSizeCommand;
    }
    
    return size;
    
}
- (void)commandData:(id)lpData size:(UInt32 *)dataSize isToGet:(BOOL)isToGet responseDataSize:(UInt32 *)responseSize
{
    UInt32 size = 0;
    
    if(isToGet)
    {
        size = [self fillCommandToGet:lpData];
    }
    else
    {
        size = [self fillCommandToSet:lpData];
    }
    
    *dataSize = size;
    *responseSize = [self responseDataSize:isToGet];
    
} 


- (BOOL)initDeviceData
{
    if(nil == deviceData)
    {
        size_t size = payloadSizeCommand + 1;
        deviceData = (void*)malloc(size);
        memset(deviceData, 0, size);
    }
    
    return TRUE;
}

- (BOOL)setDeviceData:(id)data dataSize:(UInt32) dataSize
{
    if(nil == deviceData)
        return FALSE;
    //Ming
	//DEV_WIFI_DIRECT_SETTINGS *tmp = deviceData; 
    memcpy(deviceData, data, dataSize);

    return TRUE;
}

- (id)deviceData
{
    return deviceData;
}

- (void)GroupID_Get:(UInt8 *)idGet ID_Set:(UInt8 *)idSet
{
    *idGet = IDGroupGet;
    *idSet = IDGroupSet;
}
- (UInt8)CodeID
{
    return IDCode;
}

@end


/*
 * PrinterInformation.
 */
@implementation PrinterInformation
- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_PRINTER_INFORMATION;
        
        payloadSizeCommand = sizeof(DEV_PSR_PRINTERINFORMATION);
        commandName = [[NSString alloc] initWithString:@"PrinterInformation"];
        
    
        
        [self initDeviceData];
       
    }
    
    return self;
}

@end




@implementation PrinterInformation2

- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_PRINTER_INFORMATION2;
        
        payloadSizeCommand = sizeof(DEV_PSR_PRINTERINFORMATION_2);
        commandName = [[NSString alloc] initWithString:@"PrinterInformation2"];
    
        [self initDeviceData];
        
    }
    
    return self;
}

@end


/*
 * SystemSettings.
 */
@implementation SystemSettings
- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_SYSTEM_SETTINGS;
        
        payloadSizeCommand = sizeof(DEV_SYSTEM_SETTINGS);
        
        [self initDeviceData];
        
    }
    
    return self;
}

@end




@implementation BillingMeters

- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_METER_READINGS;
        
        payloadSizeCommand = sizeof(DEV_BILLING_METERS);
        
        [self initDeviceData];
        
    }
    
    return self;
}


@end




@implementation PaperDensity

- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_PAPER_DENSITY;
        
        payloadSizeCommand = sizeof(DEV_PAPER_DENSITY);
        
        [self initDeviceData];
        
    }
    
    return self;
}

@end



@implementation AdjustBTR

- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_ADJUST_BTR;
        
        payloadSizeCommand = sizeof(DEV_ADJUST_BTR);
        
        [self initDeviceData];
        
    }
    
    return self;
}

@end

/*
 * AdjustFuser.
 */
@implementation AdjustFuser
- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_ADJUST_FUSER;
        
        payloadSizeCommand = sizeof(DEV_ADJUST_FUSER);
        
        [self initDeviceData];
        
    }
    
    return self;
}

@end




@implementation RegistrationAdjustment

- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_REGISTRATION_ADJUSTMENT;
        
        payloadSizeCommand = sizeof(DEV_REGISTRATION_ADJUSTMENT);
        
        [self initDeviceData];
        
    }
    
    return self;
}

@end




@implementation AdjustAltitude
- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_ADJUST_ALTITUDE;
        
        payloadSizeCommand = sizeof(DEV_ADJUST_ALTITUDE);
        
        [self initDeviceData];
        
    }
    
    return self;
}

@end




@implementation NonGenToner

- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_NON_GEN_TONER;
        
        payloadSizeCommand = sizeof(DEV_NON_GEN_TONER);
        
        [self initDeviceData];
        
    }
    
    return self;
}

@end




@implementation BTRRefresh

- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_BTR_REFRESH_MODE;
        
        payloadSizeCommand = sizeof(DEV_BTR_REFRESH);
        
        [self initDeviceData];
        
    }
    
    return self;
}



@end

@implementation DensityAdjustment

- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_DENSITY_ADJUSTMENT;
        
        payloadSizeCommand = sizeof(DEV_DENSITY_ADJUSTMENT);
        
        [self initDeviceData];
        
    }
    
    return self;
}

@end

/*
 * AdjustAltitude.
 */


/*
 * TraySettings.
 */
@implementation TraySettings
- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_TRAY_SETTINGS;
        
        payloadSizeCommand = sizeof(DEV_TRAY_SETTINGS);
        
        [self initDeviceData];
        
    }
    
    return self;
}

@end


@implementation EnvironmentSensorInfo

- (id)init
{
    self = [super init];
    if (self) {
        
        
        IDGroupGet = DEV_CMD_GROUP_ID_GET_ENVIRONMENT_SENSOR_INFO;
        //IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_ENVIRONMENT_SENSOR_INFO;
        
        payloadSizeCommand = sizeof(DEV_ENVIRONMENT_SENSOR_INFO);
        
        [self initDeviceData];
        
    }
    
    return self;
}


@end


/*
 * reset system section, printer will restart, toolbox should be not read the response.
 */
@implementation ResetSystemSectionCommond

- (UInt32)responseDataSize:(BOOL)isToGet
{
       
    return 0;
    
}

@end


@implementation NetwrokSettings

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_NETWORK_SETTINGS;
        payloadSizeCommand = sizeof(DEV_NETWROK_SETTINGS);
        
        [self initDeviceData];
    }
    
    return self;
}

@end


@implementation WirelessSettings

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_WIRELESS_SETTINGS;
        payloadSizeCommand = sizeof(DEV_WIRELESS_SETTINGS);
        
        [self initDeviceData];
    }
    
    return self;
}


@end

@implementation WirelessDirectSettings

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_WIRELESSDIRECT_SETTINGS;
        payloadSizeCommand = sizeof(DEV_WIFI_DIRECT_SETTINGS);
        
        [self initDeviceData];
    }
    
    return self;
}


@end


@implementation WifiPIN

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_WIFI_PIN;
        payloadSizeCommand = sizeof(DEV_WIFI_PIN);
        
        [self initDeviceData];
    }
    
    return self;
}


@end

@implementation WirelessDirectIP

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_WIRELESSDIRECT_IP_SETTINGS;
        payloadSizeCommand = sizeof(DEV_WIFI_P2P_IP);
        
        [self initDeviceData];
    }
    
    return self;
}


@end


@implementation WifiStatus

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_WIFI_STATUS;
        payloadSizeCommand = sizeof(DEV_WIFI_STATUS);
        
        [self initDeviceData];
    }
    
    return self;
}
@end

@implementation WifiFeatures

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_WIFI_FEATURES_SETTINGS;
        payloadSizeCommand = sizeof(DEV_WIFI_FEATURES);
        
        [self initDeviceData];
    }
    
    return self;
}


@end




@implementation TCPIPSettings

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_TCP_IP_SETTINGS;
        payloadSizeCommand = sizeof(DEV_TCPIP_SETTINGS);

        [self initDeviceData];
    }
    
    return self;
}

@end

@implementation TCPIPSettingsV2

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_TCP_IP_SETTINGS_V2;
        payloadSizeCommand = sizeof(DEV_TCPIP_SETTINGSV2);
		
        [self initDeviceData];
    }
    
    return self;
}

@end

@implementation SecuritySettings

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_SECURE_SETTINGS;
        payloadSizeCommand = sizeof(DEV_SECURE_SETTINGS);
        
        [self initDeviceData];
    }
    
    return self;
}

@end


@implementation EWS

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_EWS;
        payloadSizeCommand = sizeof(DEV_EWS);
        
        [self initDeviceData];
    }
    
    return self;
}

@end


@implementation LifeSetting

- (id)init
{
    self = [super init];
    if (self)
    {
        IDGroupGet = DEV_CMD_GROUP_ID_GET;
        IDGroupSet = DEV_CMD_GROUP_ID_SET;
        IDCode = DEV_CMD_CODE_ID_GET_LIFE_SETTING;
        payloadSizeCommand = sizeof(DEV_XERO_LIFE_SETTING);
        
        [self initDeviceData];
    }
    
    return self;
}

@end






