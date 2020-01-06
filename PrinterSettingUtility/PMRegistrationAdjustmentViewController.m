//
//  PMRegistrationAdjustmentViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "PMRegistrationAdjustmentViewController.h"
#import "DeviceProperty.h"

@interface PMRegistrationAdjustmentViewController ()

@end

@implementation PMRegistrationAdjustmentViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"Registration Adjustment", nil);
        [devciePropertyList addObject:[[[RegistrationAdjustment alloc] init] autorelease]];
        
        [self initWithNibName:@"PMRegistrationAdjustmentViewController" bundle:nil];
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Registration Adjustment", nil);
}

- (void)awakeFromNib
{    
    [button1 setTitle:NSLocalizedString(@"Apply New Settings", nil)];
    [button2 setTitle:NSLocalizedString(@"Apply New Settings", nil)];
        
    [autoBox setTitle:NSLocalizedString(@"Auto Registration Adjustment", nil)];
    [manualBox setTitle:NSLocalizedString(@"Manual Registration Adjustments", nil)];
    [adjustBox1 setTitle:NSLocalizedString(@"Color Registration Adjustment 1 (Lateral)", nil)];
    [adjustBox2 setTitle:NSLocalizedString(@"Color Registration Adjustment 2 (Process)", nil)];
    
    [autoRATextField setStringValue:NSLocalizedString(@"Auto Registration Adjustment", nil)];
    
    [autoCorrectTextField setStringValue:NSLocalizedString(@"Auto Correct", nil)];
    [printCRCTextField setStringValue:NSLocalizedString(@"Print Color Regi Chart", nil)];
    
    [yTextField setStringValue:NSLocalizedString(@"Y (Yellow)", nil)];
    [mTextField setStringValue:NSLocalizedString(@"M (Magenta)", nil)];
    [cTextField setStringValue:NSLocalizedString(@"C (Cyan)", nil)];
    
    [lyTextField setStringValue:NSLocalizedString(@"LY (Left Yellow)", nil)];
    [lmTextField setStringValue:NSLocalizedString(@"LM (Left Magenta)", nil)];
    [lcTextField setStringValue:NSLocalizedString(@"LC (Left Cyan)", nil)];
    [ryTextField setStringValue:NSLocalizedString(@"RY (Right Yellow)", nil)];
    [rmTextField setStringValue:NSLocalizedString(@"RM (Right Magenta)", nil)];
    [rcTextField setStringValue:NSLocalizedString(@"RC (Right Cyan)", nil)];
    
    [autoRATextButton setTitle:NSLocalizedString(@"On", nil)];
    [autoCorrectButton setTitle:NSLocalizedString(@"Start", nil)];
    [printCRCButton setTitle:NSLocalizedString(@"Start", nil)];
    
    [autoRATextButton setState:NSOnState];
    
    [self setComboBoxItems:yComoBox];
    [self setComboBoxItems:mComoBox];
    [self setComboBoxItems:cComoBox];
    
    [self setComboBoxItems:lyComoBox];
    [self setComboBoxItems:lmComoBox];
    [self setComboBoxItems:lcComoBox];
    [self setComboBoxItems:ryComoBox];
    [self setComboBoxItems:rmComoBox];
    [self setComboBoxItems:rcComoBox];
    
    isUpdateView = YES;
}

- (void)setComboBoxItems:(NSComboBox *)comboBox
{
    int i;
    for (i = -5; i < 1; i++)
    {
        [comboBox addItemWithObjectValue:[NSString stringWithFormat:@"%d", i]];
    }
    
    for (i = 1; i < 6; i++)
    {
        [comboBox addItemWithObjectValue:[NSString stringWithFormat:@"+%d", i]];
    }
    
    [comboBox setNumberOfVisibleItems:[comboBox numberOfItems]];
    [comboBox selectItemAtIndex:5];
    [comboBox setEditable:NO];
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
    startDetectChangeEvent = NO;
    [super UpdatePrinterPropertyToView:directionWithResult];
        
    NSNumber *result = [directionWithResult objectAtIndex:1];
    if([result intValue] != DEV_ERROR_SUCCESS)
    {
        [[scrollview verticalScroller] setEnabled:YES];
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
    if (isUpdateView)
    {
        DEV_REGISTRATION_ADJUSTMENT *devData = (DEV_REGISTRATION_ADJUSTMENT *)data;
        
        [autoRATextButton setState:devData->iAutoRegistrationAdjustment];
        
        [yComoBox selectItemAtIndex:(5)];
        [mComoBox selectItemAtIndex:(5)];
        [cComoBox selectItemAtIndex:(5)];
        
        [lyComoBox selectItemAtIndex:(5)];
        [lmComoBox selectItemAtIndex:(5)];
        [lcComoBox selectItemAtIndex:(5)];
        [ryComoBox selectItemAtIndex:(5)];
        [rmComoBox selectItemAtIndex:(5)];
        [rcComoBox selectItemAtIndex:(5)];
        
        isChanged = NO;
        [button1 setEnabled:NO];
        [button2 setEnabled:NO];
        
        if ([autoRATextButton state] == NSOnState)
        {
            [self enableManualInput:NO];
        }
        else
        {
            [self enableManualInput:YES];
        }

    }
}

- (IBAction)applyButtonAction:(id)sender
{
    isUpdateView = YES;
    
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[RegistrationAdjustment alloc] init] autorelease]];
    
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        DEV_REGISTRATION_ADJUSTMENT settings;
        [self getDataFormView:&settings];
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_REGISTRATION_ADJUSTMENT)];
        
        [self setInfoToDevice];
    }
}

- (void)getDataFormView:(void *)addr
{
    DEV_REGISTRATION_ADJUSTMENT data;
    memset(&data, 0, sizeof(DEV_REGISTRATION_ADJUSTMENT));
    
    data.iAutoRegistrationAdjustment = [autoRATextButton state];
    
    data.iColor[0] = [yComoBox indexOfSelectedItem] - 5;
    data.iColor[1] = [mComoBox indexOfSelectedItem] - 5;
    data.iColor[2] = [cComoBox indexOfSelectedItem] - 5;
    
    data.iColor[3] = [lyComoBox indexOfSelectedItem] - 5;
    data.iColor[4] = [lmComoBox indexOfSelectedItem] - 5;
    data.iColor[5] = [lcComoBox indexOfSelectedItem] - 5;
    data.iColor[6] = [ryComoBox indexOfSelectedItem] - 5;
    data.iColor[7] = [rmComoBox indexOfSelectedItem] - 5;
    data.iColor[8] = [rcComoBox indexOfSelectedItem] - 5;
    
    memcpy(addr, &data, sizeof(DEV_REGISTRATION_ADJUSTMENT));
}

- (IBAction)autoCorrectButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];    
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x03 needRestart:NO] autorelease]];
    [self sendInfoToDevice];
}

- (IBAction)printCRCButtonAction:(id)sender
{
    isUpdateView = NO;
    
    [devciePropertyList removeAllObjects];    
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x04 needRestart:NO] autorelease]];
    [self sendInfoToDevice];    
}

- (IBAction)checkButtonAction:(id)sender
{
    isChanged = YES;
    [button1 setEnabled:YES];
    [button2 setEnabled:YES];
    
    if ([autoRATextButton state] == NSOnState)
    {
        [self enableManualInput:NO];
    }
    else
    {
        [self enableManualInput:YES];
    }
    
    [devciePropertyList removeAllObjects];     //content has modified.
    [devciePropertyList addObject:[[[RegistrationAdjustment alloc] init] autorelease]];
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    if (startDetectChangeEvent == YES)
    {
        isChanged = YES;
        [button1 setEnabled:YES];
        [button2 setEnabled:YES];
        
        [devciePropertyList removeAllObjects];     //content has modified.
        [devciePropertyList addObject:[[[RegistrationAdjustment alloc] init] autorelease]];
    }
}

- (void)enableManualInput:(BOOL)enable
{
    [autoCorrectButton setEnabled:enable];
    [printCRCButton setEnabled:enable];
    
    [yComoBox setEnabled:enable];
    [mComoBox setEnabled:enable];
    [cComoBox setEnabled:enable];
    
    [lyComoBox setEnabled:enable];
    [lmComoBox setEnabled:enable];
    [lcComoBox setEnabled:enable];
    [ryComoBox setEnabled:enable];
    [rmComoBox setEnabled:enable];
    [rcComoBox setEnabled:enable];
}

@end
