//
//  InformationPagesController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "InformationPagesController.h"


@implementation InformationPagesController


- (void)awakeFromNib
{
    [systemSettingsButton setTitle:NSLocalizedString(@"System Settings", NULL)];
#ifdef MACHINESETUP_XC
	[systemSettingsButton setTitle:NSLocalizedString(@"IDS_CONFIGURATION_PAGE", NULL)];
#endif
    [jobHistoryButton setTitle:NSLocalizedString(@"Job History", NULL)];
    [panelSettingsButton setTitle:NSLocalizedString(@"Panel Settings", NULL)];
    [errorHistoryButton setTitle:NSLocalizedString(@"Error History", NULL)];
    [demoPageButton setTitle:NSLocalizedString(@"Demo Page", NULL)];
    
    
   
}
- (id)init
{
    self = [super init];
    
    if (self) {
        
        isNeedCheckPanelPassword = FALSE;
        
        NSString * nibName = [self NIBName];
        self = [self initWithNibName:nibName bundle:nil];
        
        ID_PrinterSettings = ID_PSR_REPORTS;
        //SettingsTitle = NSLocalizedString(@//, NULL);
        //SettingsName = NSLocalizedString(@//, NULL);
#ifdef MACHINESETUP_IBG
        contentTitle= NSLocalizedString(@"Reports", NULL);
#endif
#ifdef MACHINESETUP_XC
        contentTitle= NSLocalizedString(@"Information Pages", NULL);
#endif
        
        if(nil != devciePropertyList)
        {
            [devciePropertyList addObject:[[[PrinterInformation alloc] init] autorelease]];
        }
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString *)NIBName
{
    return @"InformationPages";
}

+ (NSString *)description
{
#ifdef MACHINESETUP_IBG
    return NSLocalizedString(@"Reports", NULL);
#endif
#ifdef MACHINESETUP_XC
    return NSLocalizedString(@"Information Pages", NULL);
#endif
}

- (IBAction)onSystemSettings:(id)sender {
    [devciePropertyList removeAllObjects];
    
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_PSR_REPORTS CodeID:DEV_CMD_CODE_ID_REPORTS_SYSTEM_SETTINGS needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)onPanelSettings:(id)sender {
    [devciePropertyList removeAllObjects];
    
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_PSR_REPORTS CodeID:DEV_CMD_CODE_ID_REPORTS_PANEL_SETTINGS needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)onJobHistory:(id)sender {
    [devciePropertyList removeAllObjects];
    
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_PSR_REPORTS CodeID:DEV_CMD_CODE_ID_REPORTS_JOB_HISTORY needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)onErrorHistory:(id)sender {
    [devciePropertyList removeAllObjects];
    
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_PSR_REPORTS CodeID:DEV_CMD_CODE_ID_REPORTS_ERROR_HISTORY needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)onDemoPage:(id)sender {
    [devciePropertyList removeAllObjects];
    //[devciePropertyList addObject:[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_CHART_PRINT CodeID:DEV_CMD_CODE_ID_CHART_PRINT_DEMO_PAGE needRestart:NO]];

    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_PSR_REPORTS CodeID:DEV_CMD_CODE_ID_REPORTS_DEMO_PAGE needRestart:NO] autorelease]];

    [self sendInfoToDevice];
}
@end
