//
//  ResetDefaultsController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ResetDefaultsController.h"


@implementation ResetDefaultsController

- (void)awakeFromNib
{
    [systemSectionButton setTitle:NSLocalizedString(@"System Section", NULL)]; 
}
- (id)init
{
    self = [super init];
    
    if (self) {
        NSString * nibName = [self NIBName];
        self = [self initWithNibName:nibName bundle:nil];
        
        ID_PrinterSettings = ID_PSR_REPORTS;
       contentTitle= NSLocalizedString(@"Reset Defaults", NULL);
        SettingsName = NSLocalizedString(@"Reset Defaults", NULL);
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
    return @"ResetDefaults";
}

+ (NSString *)description
{
    return NSLocalizedString(@"Reset Defaults", NULL);
}

- (IBAction)onSystemSection:(id)sender {
    
    [devciePropertyList removeAllObjects];
    
    [devciePropertyList addObject:[[[ResetSystemSectionCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_RESET_DEFAULTS CodeID:DEV_CMD_CODE_ID_RESET_SYSTEM_SECTION needRestart:YES] autorelease]];
    
    [self sendInfoToDevice];
}


@end
