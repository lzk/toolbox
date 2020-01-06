//
//  RefreshModeController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RefreshModeController.h"


@implementation RefreshModeController


- (void)awakeFromNib
{
    [box setTitle:NSLocalizedString(@"Toner Refresh Mode", nil)];
    [yButton setTitle:NSLocalizedString(@"Y (Yellow)", nil)];
    [mButton setTitle:NSLocalizedString(@"M (Magenta)", nil)];
    [cButton setTitle:NSLocalizedString(@"C (Cyan)", nil)];
    [blackButton setTitle:NSLocalizedString(@"Black", nil)];
}
- (id)init
{
    self = [super init];
    
    if (self) {
        NSString * nibName = [self NIBName];
        self = [self initWithNibName:nibName bundle:nil];
        
        ID_PrinterSettings = ID_DIAGNOSIS_REFRESH_MODE;
        contentTitle= NSLocalizedString(@"Refresh Mode", NULL);
        //SettingsName = NSLocalizedString(@//, NULL);
        
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
    return @"RefreshMode";
}

+ (NSString *)description
{
    return NSLocalizedString(@"Refresh Mode", NULL);
}

- (IBAction)yButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0x08 CodeID:0x01 needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)mButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0x08 CodeID:0x02 needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)cButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0x08 CodeID:0x03 needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

- (IBAction)blackButtonAction:(id)sender
{
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0x08 CodeID:0x04 needRestart:NO] autorelease]];
    
    [self sendInfoToDevice];
}

@end
