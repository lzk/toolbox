//
//  PMDensityAdjustmentViewController.m
//  PrinterSettingUtility
//
//  Created by Wang Kun on 12/18/13.
//  Copyright (c) 2013 Wang Kun. All rights reserved.
//

#import "PMDensityAdjustmentViewController.h"
#import "DeviceProperty.h"

@interface PMDensityAdjustmentViewController ()

@end

@implementation PMDensityAdjustmentViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"Density Adjustment", nil);
        [devciePropertyList addObject:[[[DensityAdjustment alloc] init] autorelease]];
        
        [self initWithNibName:@"PMDensityAdjustmentViewController" bundle:nil];
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Density Adjustment", nil);
}

- (void)awakeFromNib
{
    [textField setStringValue:NSLocalizedString(@"Density Adjustment", nil)];
    [comboBox setEditable:NO];
    int i;
    for (i = -3; i < 4; i++)
    {
        [comboBox addItemWithObjectValue:[NSNumber numberWithInt:i]];
    }
    [comboBox selectItemWithObjectValue:[NSNumber numberWithInt:0]];
    [comboBox setNumberOfVisibleItems:[comboBox numberOfItems]];
        
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
    DEV_DENSITY_ADJUSTMENT *devData = (DEV_DENSITY_ADJUSTMENT *)data;
    
    [comboBox selectItemAtIndex:devData->iDensityAdjustment];
    
    isChanged = NO;
    [applyButton setEnabled:NO];
}

- (IBAction)applyButtonAction:(id)sender
{
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        DEV_DENSITY_ADJUSTMENT settings;
        [self getDataFormView:&settings];
        
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_DENSITY_ADJUSTMENT)];
        
        [self setInfoToDevice];
    }
}

- (void)getDataFormView:(void *)addr
{
    DEV_DENSITY_ADJUSTMENT data;
    memset(&data, 0, sizeof(DEV_DENSITY_ADJUSTMENT));
    data.iDensityAdjustment = [comboBox indexOfSelectedItem];
    
    memcpy(addr, &data, sizeof(DEV_DENSITY_ADJUSTMENT));
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
