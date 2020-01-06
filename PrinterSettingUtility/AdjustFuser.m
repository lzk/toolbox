//
//  AdjustFuser.m
//  MachineSetup
//
//  Created by Helen Liu on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AdjustFuser.h"


@implementation AdjustFuserController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [plainField setStringValue:NSLocalizedString(@"Plain", NULL)];
    [bondField setStringValue:NSLocalizedString(@"Bond", nil)];
    [lightweightCField setStringValue:NSLocalizedString(@"Lightweight Cardstock", NULL)];
    [lightweightGCField setStringValue:NSLocalizedString(@"Lightweight Glossy Cardstock", nil)];
    [labelField setStringValue:NSLocalizedString(@"Labels", NULL)];
    [envelopeField setStringValue:NSLocalizedString(@"Envelope", NULL)];
    [recycledField setStringValue:NSLocalizedString(@"Recycled", NULL)];
    
    int i;
    for(i = -3; i <= 0; i++)
    {
        [plainBox addItemWithObjectValue:[NSNumber numberWithInt:i]];
        [bondBox addItemWithObjectValue:[NSNumber numberWithInt:i]];
        [lightweightCBox addItemWithObjectValue:[NSNumber numberWithInt:i]];
        [lightweightGCBox addItemWithObjectValue:[NSNumber numberWithInt:i]];
        [labelBox addItemWithObjectValue:[NSNumber numberWithInt:i]];
        [envelopeBox addItemWithObjectValue:[NSNumber numberWithInt:i]];
        [recycledBox addItemWithObjectValue:[NSNumber numberWithInt:i]];
    }
    //int i;
    for(i = 1; i <= 3; i++)
    {
        NSString * string = [NSString stringWithFormat:@"+%d", i];
        
        [plainBox addItemWithObjectValue:string];
        [bondBox addItemWithObjectValue:string];
        [lightweightCBox addItemWithObjectValue:string];
        [lightweightGCBox addItemWithObjectValue:string];
        [labelBox addItemWithObjectValue:string];
        [envelopeBox addItemWithObjectValue:string];
        [recycledBox addItemWithObjectValue:string];
    }
    
    [plainBox selectItemAtIndex:3];
    [bondBox selectItemAtIndex:3];
    [lightweightCBox selectItemAtIndex:3];
    [lightweightGCBox selectItemAtIndex:3];
    [labelBox selectItemAtIndex:3];
    [envelopeBox selectItemAtIndex:3];
    [recycledBox selectItemAtIndex:3];
}
- (id)init
{
    self = [super init];
    
    if (self) {
        NSString * nibName = [self NIBName];
        self = [self initWithNibName:nibName bundle:nil];
        
        ID_PrinterSettings = ID_PSR_REPORTS;
       contentTitle= NSLocalizedString(@"Adjust Fusing Unit", NULL);
        SettingsName = NSLocalizedString(@"Adjust Fusing Unit", NULL);
        if(nil != devciePropertyList)
        {
            [devciePropertyList addObject:[[[AdjustFuser alloc] init] autorelease]];
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
    return @"AdjustFuser";
}

+ (NSString *)description
{
    return NSLocalizedString(@"Adjust Fusing Unit", NULL);
}

- (void)UPdateItemValues:(id)deviceData
{
    DEV_ADJUST_BTR *info = (DEV_ADJUST_BTR *)deviceData;
    
    [plainBox selectItemAtIndex:info->iPlain];
    [bondBox selectItemAtIndex:info->iBond];
    [lightweightCBox selectItemAtIndex:info->iCardStock];
    [lightweightGCBox selectItemAtIndex:info->iLightGlossyStock];
    [labelBox selectItemAtIndex:info->iLabel];
    [envelopeBox selectItemAtIndex:info->iEnvelope];
    [recycledBox selectItemAtIndex:info->iRecycled];
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
    DEV_ADJUST_FUSER settings;
    memset(&settings, 0, sizeof(DEV_ADJUST_FUSER));
    
    settings.iPlain = [plainBox indexOfSelectedItem];
    settings.iBond = [bondBox indexOfSelectedItem];
    settings.iCardStock = [lightweightCBox indexOfSelectedItem];
    settings.iLightGlossyStock = [lightweightGCBox indexOfSelectedItem];
    settings.iLabel = [labelBox indexOfSelectedItem];
    settings.iEnvelope = [envelopeBox indexOfSelectedItem];
    settings.iRecycled = [recycledBox indexOfSelectedItem];
    
    memcpy(deviceData, &settings, sizeof(DEV_ADJUST_FUSER));
    
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
        
        DEV_ADJUST_FUSER settings;
        [self getPrinterPropertyFromView:(void*)&settings];
        
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_ADJUST_FUSER)];
    }
    
    [self setInfoToDevice];
}
@end
