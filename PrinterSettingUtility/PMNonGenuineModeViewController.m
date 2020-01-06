//
//  PMNonGenuineModeViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "PMNonGenuineModeViewController.h"
#import "DeviceProperty.h"

@interface PMNonGenuineModeViewController ()

@end

@implementation PMNonGenuineModeViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"Non-Genuine Mode", nil);
        [devciePropertyList addObject:[[[NonGenToner alloc] init] autorelease]];
        
        [self initWithNibName:@"PMNonGenuineModeViewController" bundle:nil];
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Non-Genuine Mode", nil);
}

- (void)awakeFromNib
{
    [textField setStringValue:NSLocalizedString(@"Non-Genuine Mode", nil)];
    [checkButton setTitle:NSLocalizedString(@"On", nil)];
    [applyButton setTitle:NSLocalizedString(@"Apply New Settings", nil)];
    [applyButton setEnabled:NO];
    [checkButton setState:NSOffState];
    
    [textView setString:NSLocalizedStringFromTable(IDS_CAUTION, @"CrossVendor_I",nil)];   
#ifdef MACHINESETUP_XC
	[textView setString:NSLocalizedStringFromTable(IDS_CAUTION, @"CrossVendor_X",nil)];
#endif
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
    DEV_NON_GEN_TONER *devData = (DEV_NON_GEN_TONER *)data;
    
    [checkButton setState:devData->iNonGenToner];
    
    isChanged = NO;
    [applyButton setEnabled:NO];
}

- (IBAction)applyButtonAction:(id)sender
{
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        DEV_NON_GEN_TONER settings;
        [self getDataFormView:&settings];
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_NON_GEN_TONER)];
        
        [self setInfoToDevice];
    }
}

- (void)getDataFormView:(void *)addr
{
    DEV_NON_GEN_TONER data;
    memset(&data, 0, sizeof(DEV_NON_GEN_TONER));
    data.iNonGenToner = [checkButton state];
    
    memcpy(addr, &data, sizeof(DEV_NON_GEN_TONER));
}

- (IBAction)checkButtonAction:(id)sender
{
    [applyButton setEnabled:YES];
    isChanged = YES;
}

@end
