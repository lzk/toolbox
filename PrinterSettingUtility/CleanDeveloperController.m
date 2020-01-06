//
//  CleanDeveloperController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "CleanDeveloperController.h"


@implementation CleanDeveloperController

- (void)awakeFromNib
{
    [cleanDeveloperTextField setStringValue:NSLocalizedString(@"Clean Developer", NULL)];
    [startButton setTitle:NSLocalizedString(@"Start", NULL)];
}
- (id)init
{
    self = [super init];
    
    if (self) {
        NSString * nibName = [self NIBName];
        self = [self initWithNibName:nibName bundle:nil];
        
        ID_PrinterSettings = ID_DIAGNOSIS_CLEAN_DEVELOPER;
       contentTitle= NSLocalizedString(@"Clean Developer", NULL);
        SettingsName = NSLocalizedString(@"Clean Developer", NULL);
        
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
    return @"CleanDeveloper";
}

+ (NSString *)description
{
    return NSLocalizedString(@"Clean Developer", NULL);
}


- (IBAction)onStartButton:(id)sender {
    [devciePropertyList removeAllObjects];
    
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:DEV_CMD_GROUP_ID_DEVELOPER_STIR_MODE CodeID:DEV_CMD_CODE_ID_DEVELOPER_STIR_MODE needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}
@end
