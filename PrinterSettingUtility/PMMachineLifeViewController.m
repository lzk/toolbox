//
//  PMMachineLifeViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "PMMachineLifeViewController.h"
#import "DeviceProperty.h"

@interface PMMachineLifeViewController ()

@end

@implementation PMMachineLifeViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"Machine Life", nil);
        [devciePropertyList addObject:[[[LifeSetting alloc] init] autorelease]];
        
        [self initWithNibName:@"PMMachineLifeViewController" bundle:nil];
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Machine Life", nil);
}

- (void)awakeFromNib
{
    [checkButton setTitle:NSLocalizedString(@"C&ontinue Print", nil)];
    [checkButton setState:NSOffState];
    [textView setString:NSLocalizedString(@"IDS_CU_XERO_LIFE", nil)];
    [textView setEditable:NO];
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
    DEV_XERO_LIFE_SETTING *devData = (DEV_XERO_LIFE_SETTING *)data;
    
    [checkButton setState:devData->setting];
    
    isChanged = NO;
    [applyButton setEnabled:NO];
}

- (IBAction)applyButtonAction:(id)sender
{
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        DEV_XERO_LIFE_SETTING settings;
        [self getDataFormView:&settings];
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_XERO_LIFE_SETTING)];
        
        [self setInfoToDevice];
    }
}

- (void)getDataFormView:(void *)addr
{
    DEV_XERO_LIFE_SETTING data;
    memset(&data, 0, sizeof(DEV_XERO_LIFE_SETTING));
    data.setting = [checkButton state];
    
    memcpy(addr, &data, sizeof(DEV_XERO_LIFE_SETTING));
}

- (IBAction)checkButtonAction:(id)sender
{
    isChanged = YES;
    [applyButton setEnabled:YES];
}

@end
