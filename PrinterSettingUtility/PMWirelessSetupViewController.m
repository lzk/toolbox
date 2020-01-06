//
//  PMWirelessSetupViewController.m
//  PrinterSettingUtility
//
//  Created by Wang Kun on 12/24/13.
//  Copyright (c) 2013 Wang Kun. All rights reserved.
//

#import "PMWirelessSetupViewController.h"
#import "DeviceProperty.h"

@interface PMWirelessSetupViewController ()

@end

@implementation PMWirelessSetupViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"Wireless Setup", nil);
        [devciePropertyList addObject:[[WirelessSettings alloc] init]];
        
        [self initWithNibName:@"PMWirelessSetupViewController" bundle:nil];
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Wireless Setup", nil);
}

- (void)awakeFromNib
{
    [wifiLable setStringValue:NSLocalizedString(@"Wi-Fi", nil)];
    [wifiCheckButton setTitle:NSLocalizedString(@"On", nil)];
    
    [selelctModeLabel setStringValue:NSLocalizedString(@"Select Mode", nil)];
    [selectModeComboBox addItemWithObjectValue:NSLocalizedString(@"Infrastructure", nil)];
    [selectModeComboBox addItemWithObjectValue:NSLocalizedString(@"Ad-Hoc", nil)];
    [selectModeComboBox selectItemAtIndex:0];
    [selectModeComboBox setNumberOfVisibleItems:[selectModeComboBox numberOfItems]];
    [selectModeComboBox setEditable:NO];
    [selectModeComboBox setDelegate:self];
    
    [ssidLabel setStringValue:NSLocalizedString(@"SSID", nil)];
    [ssidTextField setDelegate:self];
    
    [encryptionLabel setStringValue:NSLocalizedString(@"Encryption Type", nil)];
    [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
    [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];
   // [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA-PSK-TKIP", nil)];// remove
    [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA2-PSK-AES", nil)];
    [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"Mixed mode PSK", nil)];
    [encryptionComboBox selectItemAtIndex:0];
    [encryptionComboBox setNumberOfVisibleItems:[encryptionComboBox numberOfItems]];
    [encryptionComboBox setEditable:NO];
    [encryptionComboBox setDelegate:self];
    
    [passwordLabel setStringValue:NSLocalizedString(@"Password", nil)];
    [passwordCheckButton setTitle:NSLocalizedString(@"Display Characters", nil)];
    [passwordTextField setDelegate:self];
    
    NSString *wepkey = NSLocalizedString(@"WEP Key", nil);
    [transmitLabel setStringValue:NSLocalizedString(@"Transmit Key", nil)];
    [transmitComboBox addItemWithObjectValue:NSLocalizedString(@"Auto", nil)];
    [transmitComboBox addItemWithObjectValue:[wepkey stringByAppendingFormat:@"%@%d", wepkey, 1]];
    [transmitComboBox addItemWithObjectValue:[wepkey stringByAppendingFormat:@"%@%d", wepkey, 2]];
    [transmitComboBox addItemWithObjectValue:[wepkey stringByAppendingFormat:@"%@%d", wepkey, 3]];
    [transmitComboBox addItemWithObjectValue:[wepkey stringByAppendingFormat:@"%@%d", wepkey, 4]];
    [transmitComboBox selectItemAtIndex:0];
    [transmitComboBox setNumberOfVisibleItems:[transmitComboBox numberOfItems]];
    [transmitComboBox setEditable:NO];
    [transmitComboBox setDelegate:self];
    
    [directSetupLabel setStringValue:NSLocalizedString(@"Wi-Fi Direct Setup", nil)];
    [directSetupCheckButton setTitle:NSLocalizedString(@"Enable", nil)];
    
    [applyButton setTitle:NSLocalizedString(@"Apply New Settings", nil)];
    [restartButton setTitle:NSLocalizedString(@"Restart printer to apply new settings", nil)];

    isShowRestartAlert = NO;
    isNeedRestart = NO;
    isRestarting = NO;
    ssidWrong = NO;
    passwordWrong = NO;
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
    if (isRestarting)
    {
        isRestarting = NO;
        
    }
    else
    {
        DEV_WIRELESS_SETTINGS *devData = (DEV_WIRELESS_SETTINGS *)data;
        
        [selectModeComboBox selectItemAtIndex:devData->cNetWorkType];
        [ssidTextField setStringValue:[NSString stringWithCString:devData->cSSID encoding:NSASCIIStringEncoding]];
        
        if ((devData->cAuthMode == 0) && (devData->cEncryptType == 0))
        {
            [encryptionComboBox selectItemAtIndex:0];
        }
        else if ((devData->cAuthMode == 1) && (devData->cEncryptType == 3))
        {
            [encryptionComboBox selectItemAtIndex:1];
        }
 /*
		else if ((devData->cAuthMode == 4) && (devData->cEncryptType == 4))
        {
            [encryptionComboBox selectItemAtIndex:2];
        }
  */
        else if ((devData->cAuthMode == 8) && (devData->cEncryptType == 8))
        {
            [encryptionComboBox selectItemAtIndex:2];
        }
        else if ((devData->cAuthMode == 12) && (devData->cEncryptType == 12))
        {
            [encryptionComboBox selectItemAtIndex:3];
        }
        
        [transmitComboBox selectItemAtIndex:devData->cDefaultKeyld];
        /*if (devData->cNetWorkType == 0)
        {
            [encryptionComboBox removeAllItems];
            [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
            [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];            
        }
        else if (devData->cNetWorkType == 1)
        {
            [encryptionComboBox removeAllItems];
            [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
            [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];
            [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA-PSK-TKIP", nil)];
            [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA2-PSK-AES", nil)];
            [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"Mixed mode PSK", nil)];
        }
        [encryptionComboBox setNumberOfVisibleItems:[encryptionComboBox numberOfItems]];
        [encryptionComboBox selectItemAtIndex:devData->cNetWorkType];*/

    }
    
    if ([encryptionComboBox indexOfSelectedItem] == 0)
    {
        [transmitComboBox setEnabled:NO];
        [passwordTextField setEnabled:NO];
        [passwordCheckButton setEnabled:NO];
    }
    else
    {
        [transmitComboBox setEnabled:YES];
        [passwordTextField setEnabled:YES];
        [passwordCheckButton setEnabled:YES];
    }
    
    isChanged = NO;
    [applyButton setEnabled:NO];
    [restartButton setEnabled:NO];
    
    if (isShowRestartAlert)
    {
        isShowRestartAlert = NO;
        [self performSelectorOnMainThread:@selector(showRestartAlert) withObject:nil waitUntilDone:NO];
    }
    
    if (isNeedRestart)
    {
        isNeedRestart = NO;
        [self restartPrinter];
    }
}

- (IBAction)applyButtonAction:(id)sender
{
    [passwordTextField resignFirstResponder];
    
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[WirelessSettings alloc] init]];
    DeviceCommond *aCommond = [devciePropertyList objectAtIndex:0];
    DEV_WIRELESS_SETTINGS settings;

    
    [self getDataFormView:&settings];
    if (ssidWrong)
    {
        [self showSsidWrongAlert];
        return;
    }
    if (passwordWrong)
    {
        [self showPasswordWrongAlert];
        return;
    }
    [aCommond setDeviceData:(void *)&settings dataSize:sizeof(DEV_WIRELESS_SETTINGS)];
    isShowRestartAlert = NO;
    [self setInfoToDevice];
}

- (IBAction)restartButtonAction:(id)sender
{    
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[WirelessSettings alloc] init]];
    DeviceCommond *aCommond = [devciePropertyList objectAtIndex:0];
    DEV_WIRELESS_SETTINGS settings;
    [self getDataFormView:&settings];
    if (ssidWrong)
    {
        [self showSsidWrongAlert];
        return;
    }
    if (passwordWrong)
    {
        [self showPasswordWrongAlert];
        return;
    }
    [aCommond setDeviceData:(void *)&settings dataSize:sizeof(DEV_WIRELESS_SETTINGS)];
    
    isNeedRestart = YES;
    [self setInfoToDevice];
}

- (void)getDataFormView:(void *)addr
{
    DEV_WIRELESS_SETTINGS data;
    memset(&data, 0, sizeof(DEV_WIRELESS_SETTINGS));
    
    data.cNetWorkType = [selectModeComboBox indexOfSelectedItem];
    
    NSString *ssid = [ssidTextField stringValue];
    if ([ssid length] > 32 || [ssid length] == 0)
    {
        ssidWrong = YES;
        return;
    }
    
    ssidWrong = NO;
    const char *cSsid = [ssid cStringUsingEncoding:NSASCIIStringEncoding];
    strcpy(data.cSSID, cSsid);
    
    switch ([encryptionComboBox indexOfSelectedItem]) {
        case 0:
            data.cAuthMode = 0;
            data.cEncryptType = 0;
            break;
        case 1:
            data.cAuthMode = 1;
            data.cEncryptType = 3;
            break;
 /*
		case 2:
            data.cAuthMode = 4;
            data.cEncryptType = 4;
            break;
  */
        case 2:
            data.cAuthMode = 8;
            data.cEncryptType = 8;
            break;
        case 3:
            data.cAuthMode = 12;
            data.cEncryptType = 12;
            break;
        default:
            break;
    }
    
    data.cDefaultKeyld = [transmitComboBox indexOfSelectedItem];
    
    if ([encryptionComboBox indexOfSelectedItem] == 1)
    {
        NSString *password = [passwordTextField stringValue];
        int len = [password length];
        if (len != 5 && len != 13 && len != 10 && len != 26)
        {
            passwordWrong = YES;
            return;
        }
        
        if (len == 10)
        {
            int i;
            for (i = 0; i < 10; i++)
            {
                char c = [password characterAtIndex:i];
                if (!((c > 47 && c < 58) || (c > 64 && c < 71) || (c > 96 && c < 103)))
                {
                    passwordWrong = YES;
                    return;
                }
            }
        }
        
        if (len == 26)
        {
            int i;
            for (i = 0; i < 26; i++)
            {
                char c = [password characterAtIndex:i];
                if (!((c > 47 && c < 58) || (c > 64 && c < 71) || (c > 96 && c < 103)))
                {
                    passwordWrong = YES;
                    return;
                }
            }
        }
        
        passwordWrong = NO;
        const char *cPassword = [password cStringUsingEncoding:NSASCIIStringEncoding];
        strcpy((char *)data.cWEPKey[data.cDefaultKeyld-1], cPassword);

    }
    else if ([encryptionComboBox indexOfSelectedItem] > 1)
    {
        NSString *password = [passwordTextField stringValue];
        int len = [password length];
        if (len > 64)
        {
            passwordWrong = YES;
            return;
        }
        
        if (len == 64)
        {
            int i;
            for (i = 0; i < 64; i++)
            {
                char c = [password characterAtIndex:i];
                if (!((c > 47 && c < 58) || (c > 64 && c < 71) || (c > 96 && c < 103)))
                {
                    passwordWrong = YES;
                    return;
                }
            }

        }
        
        passwordWrong = NO;
        const char *cPassword = [password cStringUsingEncoding:NSASCIIStringEncoding];
        strcpy((char *)data.cWPAPSKKey, cPassword);
    }

    memcpy(addr, &data, sizeof(DEV_WIRELESS_SETTINGS));
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    isChanged = YES;
    [applyButton setEnabled:YES];
    [restartButton setEnabled:YES];
    
    /*if ([selectModeComboBox indexOfSelectedItem] == 0)
    {
        [encryptionComboBox removeAllItems];
        [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
        [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];
    }
    else if ([selectModeComboBox indexOfSelectedItem] == 1)
    {
        [encryptionComboBox removeAllItems];
        [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
        [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];
        [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA-PSK-TKIP", nil)];
        [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA2-PSK-AES", nil)];
        [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"Mixed mode PSK", nil)];
    }
    [encryptionComboBox setNumberOfVisibleItems:[encryptionComboBox numberOfItems]];
    [encryptionComboBox reloadData];*/

    
    if ([encryptionComboBox indexOfSelectedItem] == 0)
    {
        [transmitComboBox selectItemAtIndex:0];
        [transmitComboBox setEnabled:NO];
        [passwordTextField setEnabled:NO];
        [passwordCheckButton setEnabled:NO];
    }
    else if ([encryptionComboBox indexOfSelectedItem] == 1)
    {
        [transmitComboBox setEnabled:YES];
        [passwordTextField setEnabled:YES];
        [passwordCheckButton setEnabled:YES];
    }
    else
    {
        [transmitComboBox selectItemAtIndex:0];
        [transmitComboBox setEnabled:NO];
        [passwordTextField setEnabled:YES];
        [passwordCheckButton setEnabled:YES];
    }
    
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[WirelessSettings alloc] init]];
}

- (void)controlTextDidChange:(NSNotification *)obj
{
    isChanged = YES;
    [applyButton setEnabled:YES];
    [restartButton setEnabled:YES];
    
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[WirelessSettings alloc] init]];
}

- (IBAction)checkButtonAction:(id)sender
{
    isChanged = YES;
    [applyButton setEnabled:YES];
    [restartButton setEnabled:YES];
    
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[WirelessSettings alloc] init]];
}

- (void)showRestartAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
    [alert setInformativeText:NSLocalizedString(@"Restart printer for new settings to take effect.\rDo you want to restart printer?", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    if([alert runModal] == NSAlertFirstButtonReturn)
    {
        [alert release];
        [self restartPrinter];
    }
    else
    {
        [alert release];
    }
}

- (void)showPasswordWrongAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
    [alert setInformativeText:NSLocalizedString(@"Incorrect Password.", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
    
    if([alert runModal] == NSAlertFirstButtonReturn)
    {
        [alert release];
    }
    else
    {
        [alert release];
    }
}

- (void)showSsidWrongAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
    [alert setInformativeText:NSLocalizedString(@"Incorrect SSID.", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
    
    if([alert runModal] == NSAlertFirstButtonReturn)
    {
        [alert release];
    }
    else
    {
        [alert release];
    }
}


- (void)restartPrinter
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x06 needRestart:YES]];
    isRestarting = YES;
    [self sendInfoToDevice];
}

@end
