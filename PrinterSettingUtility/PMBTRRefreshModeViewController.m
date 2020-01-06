//
//  PMBTRRefreshModeViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "PMBTRRefreshModeViewController.h"
#import "DeviceProperty.h"

@interface PMBTRRefreshModeViewController ()

@end

@implementation PMBTRRefreshModeViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"BTR Refresh Mode", nil);
        [devciePropertyList addObject:[[[BTRRefresh alloc] init] autorelease]];
        
        [self initWithNibName:@"PMBTRRefreshModeViewController" bundle:nil];
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"BTR Refresh Mode", nil);
}

- (void)awakeFromNib
{    
    [textField setStringValue:NSLocalizedString(@"BTR Refresh Mode", nil)];
    [checkButton setTitle:NSLocalizedString(@"On", nil)];
    [checkButton setState:NSOffState];
    [applyButton setTitle:NSLocalizedString(@"Apply New Settings", nil)];
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
    [super UpdatePrinterPropertyToView:directionWithResult];
    
    NSNumber *result = [directionWithResult objectAtIndex:1];
    if([result intValue] != DEV_ERROR_SUCCESS)
    {
        return;
    }
    
    int i;
    for (i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *data = [devciePropertyList objectAtIndex:0];
        [self updateView:[data deviceData]];
    }
}

- (void)updateView:(id)data
{
    DEV_BTR_REFRESH *devData = (DEV_BTR_REFRESH *)data;
    
    [checkButton setState:devData->iBTRRefresh];
    
    isChanged = NO;
    [applyButton setEnabled:NO];
}

- (IBAction)applyButtonAction:(id)sender
{
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        DEV_BTR_REFRESH settings;
        [self getDataFormView:&settings];
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_BTR_REFRESH)];
        
        [self setInfoToDevice];
    }
}

- (void)getDataFormView:(void *)addr
{
    DEV_BTR_REFRESH data;
    memset(&data, 0, sizeof(DEV_BTR_REFRESH));
    data.iBTRRefresh = [checkButton state];
    
    memcpy(addr, &data, sizeof(DEV_BTR_REFRESH));
}

- (IBAction)checkButtonAction:(id)sender
{
    isChanged = YES;
    [applyButton setEnabled:YES];
}

@end
