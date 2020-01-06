//
//  AdjustAltitudeController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AdjustAltitudeController.h"


@implementation AdjustAltitudeController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [adjustAltitudeTextField setStringValue:NSLocalizedString(@"Adjust Altitude", NULL)];
    
    
    
    [adjustAltitudeCombo addItemWithObjectValue:NSLocalizedString(@"0 meter", NULL)];
    [adjustAltitudeCombo addItemWithObjectValue:NSLocalizedString(@"1000 meters", NULL)];
    [adjustAltitudeCombo addItemWithObjectValue:NSLocalizedString(@"2000 meters", NULL)];
    [adjustAltitudeCombo addItemWithObjectValue:NSLocalizedString(@"3000 meters", NULL)];
    
    
    
    [adjustAltitudeCombo selectItemWithObjectValue:NSLocalizedString(@"0 meter", NULL)]; 
    
}
- (id)init
{
    self = [super init];
    
    if (self) {
        NSString * nibName = [self NIBName];
        self = [self initWithNibName:nibName bundle:nil];
        
        ID_PrinterSettings = ID_PSR_REPORTS;
       contentTitle= NSLocalizedString(@"Adjust Altitude", NULL);
        SettingsName = NSLocalizedString(@"Adjust Altitude", NULL);
        if(nil != devciePropertyList)
        {
            [devciePropertyList addObject:[[[AdjustAltitude alloc] init] autorelease]];
        }
        
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString *)NIBName
{
    return @"AdjustAltitude";
}

+ (NSString *)description
{
    return NSLocalizedString(@"Adjust Altitude", NULL);
}

- (void)UPdateItemValues:(id)deviceData
{
    DEV_ADJUST_ALTITUDE *info = (DEV_ADJUST_ALTITUDE *)deviceData;
    
    [adjustAltitudeCombo selectItemAtIndex:info->iAdjustAltitude]; 
    
    
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
    //NSNumber *direction = [directionWithResult objectAtIndex:0];
    NSNumber *result = [directionWithResult objectAtIndex:1];
    
    startDetectChangeEvent = FALSE;
    [super UpdatePrinterPropertyToView:directionWithResult];
    
    if(DEV_ERROR_SUCCESS != [result intValue])
    {
        return;
    }
    
    if(nil == devciePropertyList)
    {
        return;
    }
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        [self UPdateItemValues:[aCommond deviceData]];
    }
    startDetectChangeEvent = TRUE;
}

-(void)getPrinterPropertyFromView:(id)deviceData
{
    DEV_ADJUST_ALTITUDE settings;
    memset(&settings, 0, sizeof(DEV_ADJUST_ALTITUDE));
    
    settings.iAdjustAltitude = [adjustAltitudeCombo indexOfSelectedItem];
    
    
    memcpy(deviceData, &settings, sizeof(DEV_ADJUST_ALTITUDE));
    
}
- (IBAction)onApplyNewSettings:(id)sender {
    
    if(nil == devciePropertyList)
    {
        return;
    }
    int i;
    
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        
        DEV_ADJUST_ALTITUDE settings;
        [self getPrinterPropertyFromView:(void*)&settings];
        
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_ADJUST_ALTITUDE)];
    }
    
    [self setInfoToDevice];
}
@end
