//
//  SystemSettingsController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SystemSettingsController.h"


@implementation SystemSettingsController

- (void)awakeFromNib
{
    [super awakeFromNib];

	[powerSaverTimerBox setTitle:NSLocalizedString(@"Power Saver Timer", NULL)];
#if MACHINESETUP_IBG
    [powerSaverMode1TextField setStringValue:NSLocalizedString(@"Low Power Timer", NULL)];
    [powerSaverMode2TextField setStringValue:NSLocalizedString(@"Sleep Timer", NULL)];


    NSString *tmp = NSLocalizedString(@"minutes", nil);
    NSString *string = [NSString stringWithFormat:@"%@ (%d - %d)", tmp, 5, 30];
    [sleepMode1RangeTextField setStringValue:string];
    
    int i;
    for(i = 5; i <= 30; i++)
    {
        [sleepMode1Combo addItemWithObjectValue:[NSNumber numberWithInt:i]];
    }
    [sleepMode1Combo selectItemWithObjectValue:[NSNumber numberWithInt:5]];
    
    tmp = NSLocalizedString(@"minutes", nil);
    string = [NSString stringWithFormat:@"%@ (%d - %d)", tmp, 1, 6];
    [sleepMode2RangeTextField setStringValue:string];
    
    for(i = 1; i <= 6; i++)
    {
        [sleepMode2Combo addItemWithObjectValue:[NSNumber numberWithInt:i]];
    }
    [sleepMode2Combo selectItemWithObjectValue:[NSNumber numberWithInt:6]];

	
#endif   

#if MACHINESETUP_XC
    [powerSaverMode1TextField setStringValue:NSLocalizedString(@"Power Saver Mode 1 ", NULL)];
    [powerSaverMode2TextField setStringValue:NSLocalizedString(@"Power Saver Mode 2", NULL)];
    
    NSString *tmp = NSLocalizedString(@"minutes", nil);
    NSString *string = [NSString stringWithFormat:@"%@ (%d - %d)", tmp, 5, 60];
    [sleepMode1RangeTextField setStringValue:string];
    
    int i;
    for(i = 5; i <= 60; i++)
    {
        [sleepMode1Combo addItemWithObjectValue:[NSNumber numberWithInt:i]];
    }
    [sleepMode1Combo selectItemWithObjectValue:[NSNumber numberWithInt:5]];
    
    tmp = NSLocalizedString(@"minutes", nil);
    string = [NSString stringWithFormat:@"%@ (%d - %d)", tmp, 1, 60];
    [sleepMode2RangeTextField setStringValue:string];
    
    for(i = 1; i <= 60; i++)
    {
        [sleepMode2Combo addItemWithObjectValue:[NSNumber numberWithInt:i]];
    }
    [sleepMode2Combo selectItemWithObjectValue:[NSNumber numberWithInt:6]];

#endif
    
    [jobTimeOutTextField setStringValue:NSLocalizedString(@"Job Timeout", NULL)];
    [faultTimeOutTextField setStringValue:NSLocalizedString(@"Fault Timeout", NULL)];
    
    int maxValue, minValue, defaultValue;
    maxValue = 300;
    minValue = 5;
    defaultValue = 60;
    
    string = [NSString stringWithFormat:NSLocalizedString(@"seconds (0: Off, 5 - 300)", NULL)];
    
    [jobTimeOutRangeTextField setStringValue:string];
    
    [jobTimeOutCombo addItemWithObjectValue:[NSNumber numberWithInt:0]];
    for(i = minValue; i <= maxValue; i++)
    {
        [jobTimeOutCombo addItemWithObjectValue:[NSNumber numberWithInt:i]];
    }
    [jobTimeOutCombo selectItemWithObjectValue:[NSNumber numberWithInt:defaultValue]];
    
    maxValue = 300;
    minValue = 3;
    defaultValue = 60;
    
    string = [NSString stringWithFormat:NSLocalizedString(@"seconds (0: Off, 3 - 300)", NULL),
              minValue, maxValue];
    
    [faultTimeOutRangeTextField setStringValue:string];
    [faultTimeOutCombo addItemWithObjectValue:[NSNumber numberWithInt:0]];
    for(i = minValue; i <= maxValue; i++)
    {
        [faultTimeOutCombo addItemWithObjectValue:[NSNumber numberWithInt:i]];
    }
    [faultTimeOutCombo selectItemWithObjectValue:[NSNumber numberWithInt:defaultValue]]; 

    [mmInchTextField setStringValue:NSLocalizedString(@"mm/inch", NULL)];
    [mmInchCombo addItemWithObjectValue:NSLocalizedString(@"millimeter (mm)", NULL)];
    [mmInchCombo addItemWithObjectValue:NSLocalizedString(@"inch (\")", NULL)];
    [mmInchCombo selectItemWithObjectValue:NSLocalizedString(@"millimeter (mm)", NULL)];
    
    [lowTAMTextField setStringValue:NSLocalizedString(@"Low Toner Alert Message", nil)];
    [lowTAMBox addItemWithObjectValue:NSLocalizedString(@"Off", nil)];
    [lowTAMBox addItemWithObjectValue:NSLocalizedString(@"On", nil)];
    [lowTAMBox selectItemAtIndex:1];
    
    [autoRTextField setStringValue:NSLocalizedString(@"Auto Reset", nil)];
    NSString *unit = NSLocalizedString(@"seconds", nil);
    [autoRBox addItemWithObjectValue:[NSString stringWithFormat:@"%d %@", 45, unit]];
    [autoRBox addItemWithObjectValue:[NSString stringWithString:NSLocalizedString(@"1 minute", nil)]];
    [autoRBox addItemWithObjectValue:[NSString stringWithString:NSLocalizedString(@"2 minutes", nil)]];
    [autoRBox addItemWithObjectValue:[NSString stringWithString:NSLocalizedString(@"3 minutes", nil)]];
    [autoRBox addItemWithObjectValue:[NSString stringWithString:NSLocalizedString(@"4 minutes", nil)]];
    [autoRBox selectItemAtIndex:0];
    [autoRBox setNumberOfVisibleItems:[autoRBox numberOfItems]];
    
    [showPaperSizeErrorField setStringValue:NSLocalizedString(@"Show Paper Size Error", nil)];
    [showPaperSizeErrorComboBox addItemWithObjectValue:NSLocalizedString(@"Off", nil)];
    [showPaperSizeErrorComboBox addItemWithObjectValue:NSLocalizedString(@"On", nil)];
    [showPaperSizeErrorComboBox addItemWithObjectValue:NSLocalizedString(@"On (except A4/Ltr)", nil)];
    [showPaperSizeErrorComboBox selectItemAtIndex:2];

#ifdef MACHINESETUP_XC
    [reportLanguageField setStringValue:NSLocalizedString(@"Report Language", nil)];
    [reportLanguageComboBox addItemWithObjectValue:NSLocalizedString(@"English", nil)];
    [reportLanguageComboBox addItemWithObjectValue:NSLocalizedString(@"French", nil)];
    [reportLanguageComboBox addItemWithObjectValue:NSLocalizedString(@"Russian", nil)];
    [reportLanguageComboBox selectItemAtIndex:0];
    [reportLanguageComboBox setNumberOfVisibleItems:[reportLanguageComboBox numberOfItems]];
#endif
#ifdef MACHINESETUP_IBG
    [reportLanguageField setEnabled:NO];
    [reportLanguageComboBox setEnabled:NO];
	
	[reportLanguageField setHidden:YES];
    [reportLanguageComboBox setHidden:YES];
	
#endif
    /*
    [showPaperSizeErrorField removeFromSuperview];
    [showPaperSizeErrorComboBox removeFromSuperview];
    showPaperSizeErrorField = nil;
    showPaperSizeErrorComboBox = nil;
     */
}

- (id)init
{
    self = [super init];
    
    if (self) {
        NSString * nibName = [self NIBName];
        self = [self initWithNibName:nibName bundle:nil];
        
        ID_PrinterSettings = ID_PM_SYSTEM_SETTINGS;
       contentTitle= NSLocalizedString(@"System Settings", NULL);
        
        if(nil != devciePropertyList)
        {
            [devciePropertyList addObject:[[[SystemSettings alloc] init] autorelease]];
        }
    }
    
    return self;
}
+ (NSString *)description
{
    return NSLocalizedString(@"System Settings", NULL);
}
- (void)dealloc
{
    [super dealloc];
}

- (NSString *)NIBName
{
    return @"SystemSettings";
}

- (void)UPdateItemValues:(id)deviceData
{
    DEV_SYSTEM_SETTINGS *info = (DEV_SYSTEM_SETTINGS *)deviceData;
    
    [sleepMode1Combo selectItemWithObjectValue:[NSNumber numberWithInt:info->iPowerSaverTimerMode1]];
    [sleepMode2Combo selectItemWithObjectValue:[NSNumber numberWithInt:info->iPowerSaverTimerMode2]];
    [jobTimeOutCombo selectItemWithObjectValue:[NSNumber numberWithInt:EndianU16_NtoL(info->iTimeOut)]];
    [faultTimeOutCombo selectItemWithObjectValue:[NSNumber numberWithInt:EndianU16_NtoL(info->iFaultTimeOut)]];
    [mmInchCombo selectItemAtIndex:info->iMMorInch];
    [lowTAMBox selectItemAtIndex:info->reserved[0]];
    [autoRBox selectItemAtIndex:info->iAutoReset];
    [showPaperSizeErrorComboBox selectItemAtIndex:info->reserved[2]];
#ifdef MACHINESETUP_XC
    
	switch (info->iPanelLanguage) {
		case 0:
			[reportLanguageComboBox selectItemAtIndex:0];
			break;
		case 1:
			[reportLanguageComboBox selectItemAtIndex:1];
			break;
		case 9:
			[reportLanguageComboBox selectItemAtIndex:2];
			break;
			
		default:
			break;
	}
	

#endif
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
    //NSNumber *direction = [directionWithResult objectAtIndex:0];
    startDetectChangeEvent = NO;
    [super UpdatePrinterPropertyToView:directionWithResult];
	
    NSNumber *result = [directionWithResult objectAtIndex:1];
    
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
    DEV_SYSTEM_SETTINGS settings;
    memset(&settings, 0, sizeof(DEV_SYSTEM_SETTINGS));
    
    settings.iPowerSaverTimerMode1 = [sleepMode1Combo intValue];
    settings.iPowerSaverTimerMode2 = [sleepMode2Combo intValue];
    settings.iTimeOut = [jobTimeOutCombo intValue];
    settings.iFaultTimeOut = [faultTimeOutCombo intValue];
    settings.iMMorInch = [mmInchCombo indexOfSelectedItem];
    settings.reserved[0] = [lowTAMBox indexOfSelectedItem];
    settings.iAutoReset = 0x00;
    settings.reserved[2] = [showPaperSizeErrorComboBox indexOfSelectedItem];
    
	switch ([reportLanguageComboBox indexOfSelectedItem]) {
		case 0:
			settings.iPanelLanguage = 0;
			break;
		case 1:
			settings.iPanelLanguage = 1;
			break;
		case 2:
			settings.iPanelLanguage = 9;
			break;
		default:
			break;
	}
	
    
    memcpy(deviceData, &settings, sizeof(DEV_SYSTEM_SETTINGS));
    
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
        
        DEV_SYSTEM_SETTINGS settings;
        [self getPrinterPropertyFromView:(void*)&settings];
        
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_SYSTEM_SETTINGS)];
    }
    
    [self setInfoToDevice];
}
@end
