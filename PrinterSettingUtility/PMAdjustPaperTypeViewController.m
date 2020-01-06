//
//  PMAdjustPaperTypeViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "PMAdjustPaperTypeViewController.h"
#import "DeviceProperty.h"

@interface PMAdjustPaperTypeViewController ()

@end

@implementation PMAdjustPaperTypeViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"Adjust Paper Type", nil);
        [devciePropertyList addObject:[[[PaperDensity alloc] init] autorelease]];
        
        [self initWithNibName:@"PMAdjustPaperTypeViewController" bundle:nil];
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Adjust Paper Type", nil);
}

- (void)awakeFromNib
{
    [pTextField setStringValue:NSLocalizedString(@"Plain Paper", nil)];
    [pBox setEditable:NO];
    [pBox addItemWithObjectValue:NSLocalizedString(@"Lightweight", nil)];
    [pBox addItemWithObjectValue:NSLocalizedString(@"Heavyweight", nil)];
    [pBox selectItemAtIndex:1];
    
    [lTextField setStringValue:NSLocalizedString(@"Labels", nil)];
    [lBox setEditable:NO];
    [lBox addItemWithObjectValue:NSLocalizedString(@"Lightweight", nil)];
    [lBox addItemWithObjectValue:NSLocalizedString(@"Heavyweight", nil)];
    [lBox selectItemAtIndex:1];
    
    [applyButton setTitle:NSLocalizedString(@"Apply New Settings", nil)];
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
    startDetectChangeEvent = NO;
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
    
    startDetectChangeEvent = YES;
}

- (void)updateView:(id)data
{
    DEV_PAPER_DENSITY *devData = (DEV_PAPER_DENSITY *)data;
    
    [pBox selectItemAtIndex:devData->iPlain];
    [lBox selectItemAtIndex:devData->iLabel];
    
    isChanged = NO;
    [applyButton setEnabled:NO];
}

- (IBAction)applyButtonAction:(id)sender
{
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        DEV_PAPER_DENSITY settings;
        [self getDataFormView:&settings];
        
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_PAPER_DENSITY)];
        
        [self setInfoToDevice];
    }
}

- (void)getDataFormView:(void *)addr
{
    DEV_PAPER_DENSITY data;
    memset(&data, 0, sizeof(DEV_PAPER_DENSITY));
    data.iPlain = [pBox indexOfSelectedItem];
    data.iLabel = [lBox indexOfSelectedItem];

    memcpy(addr, &data, sizeof(DEV_PAPER_DENSITY));
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    if (startDetectChangeEvent == YES)
    {
        isChanged = YES;
        [applyButton setEnabled:YES];
    }
}

@end
