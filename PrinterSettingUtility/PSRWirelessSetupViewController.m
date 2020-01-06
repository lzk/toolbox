//
//  PSRWirelessSetupViewController.m
//  PrinterSettingUtility
//
//  Created by Wang Kun on 2/24/14.
//  Copyright (c) 2014 Wang Kun. All rights reserved.
//

#import "PSRWirelessSetupViewController.h"

@interface PSRWirelessSetupViewController ()

@end

@implementation PSRWirelessSetupViewController

- (void)dealloc
{
    [firstColumnItems release];
    [secondColumnItems release];
    
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = [[NSString alloc] initWithString:NSLocalizedString(@"Wireless Setup", nil)];
        firstColumnItems = [[NSMutableArray alloc] init];
        secondColumnItems = [[NSMutableArray alloc] init];
        
        [firstColumnItems addObject:NSLocalizedString(@"Wi-Fi", nil)];
        [firstColumnItems addObject:NSLocalizedString(@"Select Mode", nil)];
        [firstColumnItems addObject:NSLocalizedString(@"Status", nil)];
        
        int n = [firstColumnItems count];
        int i;
        for (i = 0; i < n; i++)
        {
            [secondColumnItems addObject:@"--"];
        }
        
        [self initWithNibName:@"PSRWirelessSetupViewController" bundle:nil];
        [devciePropertyList addObject:[[[WirelessSettings alloc] init] autorelease]];
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Wireless Setup", nil);
}

- (void)awakeFromNib
{
    //[tableView reloadData];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [firstColumnItems count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([[tableColumn identifier] isEqualToString:@"first"])
    {
        return [firstColumnItems objectAtIndex:row];
    }
    else
    {
        return [secondColumnItems objectAtIndex:row];
    }
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
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        [self UpdateItemStrings:[aCommond deviceData]];
    }
}

- (void)UpdateItemStrings:(id)deviceData
{
    DEV_WIRELESS_SETTINGS *data = (DEV_WIRELESS_SETTINGS *)deviceData;
    
    [secondColumnItems replaceObjectAtIndex:0 withObject:[NSString stringWithUTF8String:data->cSSID]];
    
    if (data->cNetWorkType == 0)
    {
        [secondColumnItems replaceObjectAtIndex:1 withObject:NSLocalizedString(@"Infrastructure", nil)];
    }
    else
    {
        [secondColumnItems replaceObjectAtIndex:1 withObject:NSLocalizedString(@"Ad-Hoc", nil)];
    }
    
}




@end
