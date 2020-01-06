//
//  PMInternetServicesViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "PMInternetServicesViewController.h"
#import "DeviceProperty.h"
#import "AppDelegate.h"
#import "DataStructure.h"

@interface PMInternetServicesViewController ()

@end

@implementation PMInternetServicesViewController

- (id)init
{
    self = [super init];
    if (self)
    {
#ifdef MACHINESETUP_IBG
        contentTitle = NSLocalizedString(@"Internet Services", nil);
#endif
#ifdef MACHINESETUP_XC
        contentTitle = NSLocalizedString(@"CWIS", nil);
#endif
        [devciePropertyList addObject:[[[EWS alloc] init] autorelease]];
        
        [self initWithNibName:@"PMInternetServicesViewController" bundle:nil];
    }
    
    return self;
}

+ (NSString *)description
{
#ifdef MACHINESETUP_IBG
    return NSLocalizedString(@"Internet Services", nil);
#endif
#ifdef MACHINESETUP_XC
    return NSLocalizedString(@"CWIS", nil);
#endif
}

- (void)awakeFromNib
{
    [printServerSettingsLabel setStringValue:NSLocalizedString(@"Print Server Settings", nil)];
    [displayButton setTitle:NSLocalizedString(@"Display", nil)];

	
    
    
#ifdef MACHINESETUP_IBG
    [DisplayofCISLabel setStringValue:NSLocalizedString(@"Display of CentreWare Internet Services", nil)];
#endif
#ifdef MACHINESETUP_XC
    [DisplayofCISLabel setStringValue:NSLocalizedString(@"Display of CWIS", nil)];
#endif
    [checkButton setTitle:NSLocalizedString(@"On", nil)];
    [checkButton setState:NSOnState];
    
    [applyButton setTitle:NSLocalizedString(@"Apply New Settings", nil)];
    [restartButton setTitle:NSLocalizedString(@"Restart printer to apply new settings", nil)];
    
    isShowRestartAlert = NO;
    isNeedRestart = NO;
    isRestarting = NO;
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
        DEV_EWS *devData = (DEV_EWS *)data;
        [checkButton setState:devData->iDisplayOfEWS];
        if ([checkButton state] == 0)
        {
            [displayButton setEnabled:NO];
        }
    }
    
	//NSLog(@"[net] getSelectedDevType [%i]",[[NSApp delegate] getSelectedDevType]);
	if ([[NSApp delegate] getSelectedDevType] == DEV_TYPE_USB)
    {
		
        [displayButton setEnabled:NO];
    }
	
    isChanged = NO;
    [applyButton setEnabled:NO];
    [restartButton setEnabled:NO];
    
    if (isShowRestartAlert)
    {
        isShowRestartAlert = NO;
        [self showRestartAlert];
    }
    
    if (isNeedRestart)
    {
        isNeedRestart = NO;
        [self restartPrinter];
    }
}

- (IBAction)applyButtonAction:(id)sender
{
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        DEV_EWS settings;
        [self getDataFormView:&settings];
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_EWS)];
        
        isShowRestartAlert = YES;
        [self setInfoToDevice];
    }
}

- (IBAction)restartButtonAction:(id)sender
{
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        DEV_EWS settings;
        [self getDataFormView:&settings];
        [aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_EWS)];
        
        isNeedRestart = YES;
        [self setInfoToDevice];
    }
}

- (void)getDataFormView:(void *)addr
{
    DEV_EWS data;
    memset(&data, 0, sizeof(DEV_EWS));
    
    data.iDisplayOfEWS = [checkButton state];
    
    memcpy(addr, &data, sizeof(DEV_EWS));
}

- (IBAction)displayButtonAction:(id)sender
{
	
    NSString *http = @"http://";
    NSString *url = nil;
	switch (ipVer) {
		case 4:
			 url = [http stringByAppendingString:[[NSApp delegate] devIP]];
			
			break;
		case 6:
			url = [http stringByAppendingString:@"["];
			url = [url stringByAppendingString:[[NSApp delegate] devIP]];
			url = [url stringByAppendingString:@"]/"];
			break;
		default:
			break;
	}
	
	 [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:url]];
   
	NSLog(@"[net] URL = [%@]",url);
	


}

- (IBAction)checkButtonAction:(id)sender
{
    isChanged = YES;
    [applyButton setEnabled:YES];
    [restartButton setEnabled:YES];
    
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[EWS alloc] init] autorelease]];
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

- (void)restartPrinter
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x06 needRestart:YES] autorelease]];
    isRestarting = YES;
    
    [self sendInfoToDevice];
}

@end
