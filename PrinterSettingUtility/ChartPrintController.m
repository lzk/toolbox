//
//  ChartPrintController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ChartPrintController.h"
#import <Carbon/Carbon.h>

@implementation ChartPrintController


- (void)awakeFromNib
{
	[self registerHotKeys];

	
    [pitchConfigurationChartButton setTitle:NSLocalizedString(@"Pitch Configuration Chart", NULL)];
    [ghostConfigurationChartButton setTitle:NSLocalizedString(@"Ghost Configuration Chart", NULL)];
    [FourColorsConfigurationChartButton setTitle:NSLocalizedString(@"4 &Colors Configuration Chart", NULL)];
    [mqChartButton setTitle:NSLocalizedString(@"MQ Chart", NULL)];
    [alignmentChartButton setTitle:NSLocalizedString(@"Alignment Chart", NULL)];
    [drumRefreshConfigurationChartButton setTitle:NSLocalizedString(@"Drum Refresh Configuration Chart", nil)];
    [grid2ChartButton setTitle:NSLocalizedString(@"Grid 2 Chart", nil)];
    [tonerPaletteCheckButton setTitle:NSLocalizedString(@"Toner Palette Check", nil)];
	[grid2ChartButton setEnabled:NO];
	[tonerPaletteCheckButton setEnabled:NO];
	
	[grid2ChartButton setHidden:YES];
	[tonerPaletteCheckButton setHidden:YES];
	
}
- (id)init
{
    self = [super init];
    
    if (self) {
        NSString * nibName = [self NIBName];
        self = [self initWithNibName:nibName bundle:nil];
        
        ID_PrinterSettings = ID_DIAGNOSIS_CHART_PRINTER;
        contentTitle= NSLocalizedString(@"Chart Print", NULL);
        SettingsName = NSLocalizedString(@"Chart Print", NULL);
        
        if(nil != devciePropertyList)
        {
			[devciePropertyList addObject:[[[PrinterInformation alloc] init] autorelease]];
        }
    }
    

	
    return self;
}

OSStatus OnHotKeyEvent(EventHandlerCallRef nextHandler,EventRef theEvent,void *userData)
{
    EventHotKeyID hkCom;
	
    GetEventParameter(theEvent, kEventParamDirectObject, typeEventHotKeyID, NULL, sizeof(hkCom), NULL, &hkCom);
   
	selfID = userData;
    int l = hkCom.id;
	
    switch (l) {
        case 1: 		
			NSLog(@"Capture area");	
			[selfID CEChartToggleButton];
			break;

    }
	
    return noErr;
}

EventHotKeyRef gMyHotKeyRef;
-(void)registerHotKeys
{	

    EventHotKeyID gMyHotKeyID;
    EventTypeSpec eventType;
    eventType.eventClass=kEventClassKeyboard;
    eventType.eventKind=kEventHotKeyPressed;	
	
    InstallApplicationEventHandler(&OnHotKeyEvent, 1, &eventType, (void *)self, NULL);
	
    gMyHotKeyID.signature='htk1';
    gMyHotKeyID.id=1;
    RegisterEventHotKey(kVK_ANSI_P, optionKey+kVK_ANSI_C, gMyHotKeyID, GetApplicationEventTarget(), 0, &gMyHotKeyRef);	
	
}



- (void)dealloc
{
	
	OSStatus error;
	EventHotKeyRef hotKeyRef = gMyHotKeyRef;// The HotKeyRef for the HotKey you want to unregister;
	error = UnregisterEventHotKey(hotKeyRef);
	if(error){
		//handle error
	}
	
	
	RemoveEventHandler(&OnHotKeyEvent);
	
    [super dealloc];
}

- (NSString *)NIBName
{
    return @"ChartPrint";
}

+ (NSString *)description
{
    return NSLocalizedString(@"Chart Print", NULL);
}

- (IBAction)pitchConfigurationChartButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_CHART_PRINT CodeID:DEV_CMD_CODE_ID_CHART_PRINT_PITCH_CONF needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)ghostConfigurationChartButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_CHART_PRINT CodeID:DEV_CMD_CODE_ID_CHART_PRINT_GHOST_CONF needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)FourColorsConfigurationChartButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_CHART_PRINT CodeID:DEV_CMD_CODE_ID_CHART_PRINT_FOUR_COLORS_CONF needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];

}

- (IBAction)mqChartButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_CHART_PRINT CodeID:DEV_CMD_CODE_ID_CHART_PRINT_MQ needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)alignmentChartButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_CHART_PRINT CodeID:DEV_CMD_CODE_ID_CHART_PRINT_ALIGNMENT needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)drumRefreshConfigurationChartButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_CHART_PRINT CodeID:DEV_CMD_CODE_ID_CHART_PRINT_DRUM_REFRESH_CONF needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)grid2ChartButton:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_CHART_PRINT CodeID:DEV_CMD_CODE_ID_CHART_PRINT_GRID2 needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)tonerPaletterChenkButton:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_CHART_PRINT CodeID:DEV_CMD_CODE_ID_CHART_PRINT_TONER_PALETTE_CHECK needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}



- (void)CEChartToggleButton
{
	//[tonerPaletteCheckButton setEnabled:YES];
	//[grid2ChartButton setEnabled:YES];
	
	[tonerPaletteCheckButton setHidden:NO];
	[grid2ChartButton setHidden:NO];
	
	
}

@end
