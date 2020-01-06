//
//  PMTraySettingsViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "PMTraySettingsViewController.h"
#import "DeviceProperty.h"

@interface PMTraySettingsViewController ()

@end

@implementation PMTraySettingsViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"Tray Settings", nil);
        [devciePropertyList addObject:[[[TraySettings alloc] init] autorelease]];
        
        [self initWithNibName:@"PMTraySettingsViewController" bundle:nil];
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Tray Settings", nil);
}

- (void)awakeFromNib
{
    [papeTypeTextField setStringValue:NSLocalizedString(@"Paper Type", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Plain", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Bond", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Lightweight &Cardstock", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Lightweight Glossy Cardstock", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Labels", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Recycled", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Envelope", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Plain - Reloaded", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Bond - Reloaded", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Lightweight &Cardstock - Reloaded", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Lightweight Glossy Cardstock - Reloaded", nil)];
    [papeTypeComboBox addItemWithObjectValue:NSLocalizedString(@"Recycled - Reloaded", nil)];
    [papeTypeComboBox setNumberOfVisibleItems:[papeTypeComboBox numberOfItems]];
    [papeTypeComboBox selectItemAtIndex:0];
    [papeTypeComboBox setEditable:NO];
    
    [paperSizeTextField setStringValue:NSLocalizedString(@"Paper Size", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"A4", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"A5", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"B5", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"8.5x11\"", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"8.5x13\"", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"8.5x14\"", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"7.25x10.5\"", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"Commercial 10 Envelope", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"Monarch Envelope", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"Monarch Envelope Landscape", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"C5", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"DL", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"DL Landscape", nil)];
    [paperSizeComboBox addItemWithObjectValue:NSLocalizedString(@"Custom Size", nil)];
    [paperSizeComboBox setNumberOfVisibleItems:[paperSizeComboBox numberOfItems]];
    [paperSizeComboBox selectItemAtIndex:0];
    [paperSizeComboBox setEditable:NO];
    
    [customSizeYTextField setStringValue:NSLocalizedString(@"Custom Size - Y", nil)];
    [yUnitTextField setStringValue:NSLocalizedString(@"millimeters", nil)];
    int i;
    for (i = 127; i < 356; i++)
    {
        [customSizeYComboBox addItemWithObjectValue:[NSString stringWithFormat:@"%d", i]];
    }
    [customSizeYComboBox setNumberOfVisibleItems:12];
    [customSizeYComboBox selectItemAtIndex:0];
    [customSizeYComboBox setEditable:NO];
    
    [customSizeXTextField setStringValue:NSLocalizedString(@"Custom Size - X", nil)];
    [xUnitTextField setStringValue:NSLocalizedString(@"millimeters", nil)];

    for (i = 77; i < 216; i++)
    {
        [customSizeXComboBox addItemWithObjectValue:[NSString stringWithFormat:@"%d", i]];
    }
    [customSizeXComboBox setNumberOfVisibleItems:12];
    [customSizeXComboBox selectItemAtIndex:0];
    [customSizeXComboBox setEditable:NO];
    
    [displayScreenTextField setStringValue:NSLocalizedString(@"Display Screen", nil)];
    [displayScreenButton setTitle:NSLocalizedString(@"On", nil)];
    [displayScreenButton setState:NSOnState];
    
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
    DEV_TRAY_SETTINGS *devData = (DEV_TRAY_SETTINGS *)data;
    
    [papeTypeComboBox selectItemAtIndex:devData->iPaperType];
    [paperSizeComboBox selectItemAtIndex:devData->iPaperSize];
    [displayScreenButton setState:devData->iDisplayPopup];
    
    if ([paperSizeComboBox indexOfSelectedItem] == 13)
    {
        [customSizeYComboBox selectItemAtIndex:EndianU16_NtoL(devData->iCustomSizeY - 127)];
        [customSizeXComboBox selectItemAtIndex:EndianU16_NtoL(devData->iCustomSizeX - 77)];

        [customSizeYComboBox setEnabled:YES];
        [customSizeXComboBox setEnabled:YES];
    }
    else
    {
        [customSizeYComboBox setEnabled:NO];
        [customSizeXComboBox setEnabled:NO];
    }

    isChanged = NO;
    [applyButton setEnabled:NO];
}

- (IBAction)applyButtonAction:(id)sender
{
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        DEV_TRAY_SETTINGS settings;
        [self getDataFormView:&settings];
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_TRAY_SETTINGS)];
        
        [self setInfoToDevice];
    }
}

- (void)getDataFormView:(void *)addr
{
    DEV_TRAY_SETTINGS data;
    memset(&data, 0, sizeof(DEV_TRAY_SETTINGS));
    
    data.iPaperType = [papeTypeComboBox indexOfSelectedItem];
    data.iPaperSize = [paperSizeComboBox indexOfSelectedItem];
    if (data.iPaperSize == 13)
    {
        data.iCustomSizeY = [customSizeYComboBox indexOfSelectedItem] + 127;
        data.iCustomSizeX = [customSizeXComboBox indexOfSelectedItem] + 77;
    }
    data.iDisplayPopup = [displayScreenButton state];
    
    memcpy(addr, &data, sizeof(DEV_TRAY_SETTINGS));
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    isChanged = YES;
    
    if ([paperSizeComboBox indexOfSelectedItem] == 13)
    {
        [customSizeYComboBox setEnabled:YES];
        [customSizeXComboBox setEnabled:YES];
    }
    else
    {
        [customSizeYComboBox setEnabled:NO];
        [customSizeXComboBox setEnabled:NO];
    }
    
    [applyButton setEnabled:YES];
}

- (IBAction)checkButtonAction:(id)sender
{
    isChanged = YES;
    [applyButton setEnabled:YES];
}

@end
