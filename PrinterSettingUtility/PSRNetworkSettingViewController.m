//
//  PSRNetworkSettingViewController.m
//  PrinterSettingUtility
//
//  Created by Wang Kun on 2/24/14.
//  Copyright (c) 2014 Wang Kun. All rights reserved.
//

#import "PSRNetworkSettingViewController.h"

@interface PSRNetworkSettingViewController ()

@end

@implementation PSRNetworkSettingViewController

- (void)dealloc
{
    [contentTitle release];
    [firstColumnItems1 release];
    [firstColumnItems2 release];
    [firstColumnItems3 release];
    [firstColumnItems4 release];
    [firstColumnItems5 release];
    [firstColumnItems6 release];
    [secondColumnItems1 release];
    [secondColumnItems2 release];
    [secondColumnItems3 release];
    [secondColumnItems4 release];
    [secondColumnItems5 release];
    [secondColumnItems6 release];
    [firstColumnItems release];
    [secondColumnItems release];
	[directFirstColumnItems release];
	[directSecondColumnItems release];
	
	
	
	
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = [[NSString alloc] initWithString:NSLocalizedString(@"Network Settings", nil)];
        
        firstColumnItems1 = [[NSMutableArray alloc] init];
        firstColumnItems2 = [[NSMutableArray alloc] init];
        firstColumnItems3 = [[NSMutableArray alloc] init];
        firstColumnItems4 = [[NSMutableArray alloc] init];
        firstColumnItems5 = [[NSMutableArray alloc] init];
        firstColumnItems6 = [[NSMutableArray alloc] init];
        firstColumnItems7 = [[NSMutableArray alloc] init];

        secondColumnItems1 = [[NSMutableArray alloc] init];
        secondColumnItems2 = [[NSMutableArray alloc] init];
        secondColumnItems3 = [[NSMutableArray alloc] init];
        secondColumnItems4 = [[NSMutableArray alloc] init];
        secondColumnItems5 = [[NSMutableArray alloc] init];
        secondColumnItems6 = [[NSMutableArray alloc] init];
        secondColumnItems7 = [[NSMutableArray alloc] init];

        [firstColumnItems1 addObject:NSLocalizedString(@"Ethernet", nil)];
        
        [firstColumnItems2 addObject:NSLocalizedString(IDS_LPD, nil)];

        [firstColumnItems2 addObject:NSLocalizedString(@"Port9100", nil)];
        [firstColumnItems2 addObject:NSLocalizedString(@"IPP", nil)];
        [firstColumnItems2 addObject:NSLocalizedString(@"WSD", nil)];
        [firstColumnItems2 addObject:NSLocalizedString(@"SNMP v1/v2c", nil)];
#ifdef MACHINESETUP_XC
		[firstColumnItems2 addObject:NSLocalizedString(@"IDS_E-mail Alert", nil)];
#endif
#ifdef MACHINESETUP_IBG
		[firstColumnItems2 addObject:NSLocalizedString(@"StatusMessenger", nil)];
#endif
        [firstColumnItems2 addObject:NSLocalizedString(@"Internet Services", nil)];
        [firstColumnItems2 addObject:NSLocalizedString(@"Bonjour(mDNS)", nil)];
        
		NSString * string1 = [[NSString alloc] initWithFormat:@"    %@",  NSLocalizedString(@"IP Address", nil)];
		NSString * string2 = [[NSString alloc] initWithFormat:@"    %@",  NSLocalizedString(IDS_SUBNET, nil)];
		NSString * string3 = [[NSString alloc] initWithFormat:@"    %@",  NSLocalizedString(@"Mode", nil)];
		[firstColumnItems3 addObject:NSLocalizedString(@"1", nil)];
		
        [firstColumnItems3 addObject:string1];
        [firstColumnItems3 addObject:string2];
        [firstColumnItems3 addObject:string3];
        
		[firstColumnItems3 addObject:NSLocalizedString(@"2", nil)];
        [firstColumnItems3 addObject:string1];
        [firstColumnItems3 addObject:string2];
        [firstColumnItems3 addObject:string3];
        
		[firstColumnItems3 addObject:NSLocalizedString(@"3", nil)];
        [firstColumnItems3 addObject:string1];
        [firstColumnItems3 addObject:string2];
        [firstColumnItems3 addObject:string3];
        
		[firstColumnItems3 addObject:NSLocalizedString(@"4", nil)];
        [firstColumnItems3 addObject:string1];
        [firstColumnItems3 addObject:string2];
        [firstColumnItems3 addObject:string3];

		[firstColumnItems3 addObject:NSLocalizedString(@"5", nil)];
        [firstColumnItems3 addObject:string1];
        [firstColumnItems3 addObject:string2];
        [firstColumnItems3 addObject:string3];
		
		[string1 release];
		[string2 release];
		[string3 release];

        int i;
        for (i = 0; i < [firstColumnItems1 count]; i++)
        {
            [secondColumnItems1 addObject:@"--"];
        }
        
        for (i = 0; i < [firstColumnItems2 count]; i++)
        {
            [secondColumnItems2 addObject:@"--"];
        }
        
        for (i = 0; i < [firstColumnItems3 count]; i++)
        {
			if(i%4!=0)
				[secondColumnItems3 addObject:@"--"];
			else {
				[secondColumnItems3 addObject:@""];
			}

        }
        

		
		
		
        firstColumnItems = [[NSMutableArray alloc] init];
        secondColumnItems = [[NSMutableArray alloc] init];
        
		[firstColumnItems addObject:NSLocalizedString(@"Status", nil)];
        [firstColumnItems addObject:NSLocalizedString(@"SSID", nil)];
        [firstColumnItems addObject:NSLocalizedString(@"Encryption Type", nil)];

        
        int n = [firstColumnItems count];
       // int i;
        for (i = 0; i < n; i++)
        {
            [secondColumnItems addObject:@"--"];
        }
        
		directFirstColumnItems = [[NSMutableArray alloc] init];
		directSecondColumnItems = [[NSMutableArray alloc] init];
		

		
		[directFirstColumnItems addObject:NSLocalizedString(@"Wi-Fi Direct", nil)];
		[directFirstColumnItems addObject:NSLocalizedString(@"IDS_Group Role", nil)];
		[directFirstColumnItems addObject:NSLocalizedString(@"IDS_Connection Status", nil)];

		
		int k = [directFirstColumnItems count];
		// int i;
        for (i = 0; i < k; i++)
        {
            [directSecondColumnItems addObject:@"--"];
        }
		
        //[self initWithNibName:@"PSRWirelessSetupViewController" bundle:nil];
		[self initWithNibName:@"PSRNetworkSettingViewController" bundle:nil];
        [devciePropertyList addObject:[[[NetwrokSettings alloc] init] autorelease]];
        [devciePropertyList addObject:[[[WirelessSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WirelessDirectSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WifiStatus alloc] init] autorelease]];
		
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Network Settings", nil);
}

- (void)awakeFromNib
{
    //[tableView reloadData];
    [ethernetLabel setStringValue:NSLocalizedString(@"Ethernet", nil)];
    [protocolsLabel setStringValue:NSLocalizedString(@"Protocols", nil)];

#ifdef MACHINESETUP_XC
    NSString *list = NSLocalizedString(@"Host Access List", nil);
	[filter1Label setStringValue:list];
#endif
#ifdef MACHINESETUP_IBG
	NSString *ipfilter = NSLocalizedString(@"IP Filter", nil);
	[filter1Label setStringValue:ipfilter];

#endif

	[filter6Label setStringValue:[[NSString alloc] initWithString:NSLocalizedString(@"IDS_Wi-Fi Setup", nil)]];
	[filter7Label setStringValue:[[NSString alloc] initWithString:NSLocalizedString(@"Wi-Fi Direct Setup", nil)]];
	
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    switch (tableView.tag) {
        case 1:
            return [firstColumnItems1 count];
            break;
        case 2:
            return [firstColumnItems2 count];
            break;
        case 3:
            return [firstColumnItems3 count];
            break;
        case 4:
            return [firstColumnItems4 count];
            break;
        case 5:
            return [firstColumnItems5 count];
            break;
        case 6:
            return [firstColumnItems6 count];
            break;
        case 7:
            return [firstColumnItems7 count];
            break;
		case 8:
			return [firstColumnItems count];
			break;
		case 9:
			return [directFirstColumnItems count];
			break;
        default:
            return nil;
            break;
    }
	
	
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier = [tableColumn identifier];
    NSString *value1 = nil;
    NSString *value2 = nil;
    
    switch (tableView.tag) {
        case 1:
            value1 = [firstColumnItems1 objectAtIndex:row];
            value2 = [secondColumnItems1 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 2:
            value1 = [firstColumnItems2 objectAtIndex:row];
            value2 = [secondColumnItems2 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 3:
            value1 = [firstColumnItems3 objectAtIndex:row];
            value2 = [secondColumnItems3 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 4:
            value1 = [firstColumnItems4 objectAtIndex:row];
            value2 = [secondColumnItems4 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 5:
            value1 = [firstColumnItems5 objectAtIndex:row];
            value2 = [secondColumnItems5 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 6:
            value1 = [firstColumnItems6 objectAtIndex:row];
            value2 = [secondColumnItems6 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 7:
            value1 = [firstColumnItems7 objectAtIndex:row];
            value2 = [secondColumnItems7 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
		case 8:
			if ([[tableColumn identifier] isEqualToString:@"first"])
			{
				return [firstColumnItems objectAtIndex:row];
			}
			else
			{
				return [secondColumnItems objectAtIndex:row];
			}
			break;
		case 9:
			if ([[tableColumn identifier] isEqualToString:@"first"])
			{
				return [directFirstColumnItems objectAtIndex:row];
			}
			else
			{
				return [directSecondColumnItems objectAtIndex:row];
			}
			break;

        default:
            return nil;
            break;
    }
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
    [super UpdatePrinterPropertyToView:directionWithResult];
    
    NSNumber *result = [directionWithResult objectAtIndex:1];
    if([result intValue] != DEV_ERROR_SUCCESS)
    {
        [[scrollView verticalScroller] setEnabled:YES];
        return;
    }

    
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        [self UpdateItemStrings:[aCommond deviceData] index:i];
    }
	
	
	
}

- (void)UpdateItemStrings:(id)deviceData index:(int)index
{
    DEV_NETWROK_SETTINGS *data;
	DEV_WIRELESS_SETTINGS *data1;
	DEV_WIFI_DIRECT_SETTINGS *data2;
	DEV_WIFI_STATUS *data3;

	switch (index) {
		case 0:
			data = (DEV_NETWROK_SETTINGS *)deviceData;
			int index = 0;
			NSString *string = nil;
#if 0			
			switch (data->u8ConnectSpeed) {
				case 0:
					[secondColumnItems1 replaceObjectAtIndex:0 withObject:NSLocalizedString(@"Auto", nil)];
					break;
				case 1:
					[secondColumnItems1 replaceObjectAtIndex:0 withObject:NSLocalizedString(@"10BASE-T Half", nil)];
					break;
				case 2:
					[secondColumnItems1 replaceObjectAtIndex:0 withObject:NSLocalizedString(@"10BASE-T Full", nil)];
					break;
				case 3:
					[secondColumnItems1 replaceObjectAtIndex:0 withObject:NSLocalizedString(@"100BASE-T Half", nil)];
					break;
				case 4:
					[secondColumnItems1 replaceObjectAtIndex:0 withObject:NSLocalizedString(@"100BASE-T Full", nil)];
					break;
				default:
					break;
			}
#endif
			if(data->u8Protocol_LPD)    
			{
				[secondColumnItems2 replaceObjectAtIndex:0 withObject:NSLocalizedString(@"On", nil)];
			}
			else
			{
				[secondColumnItems2 replaceObjectAtIndex:0 withObject:NSLocalizedString(@"Off", nil)];
				
			}
			
			if(data->u8Protocol_Port9100)
			{
				[secondColumnItems2 replaceObjectAtIndex:1 withObject:NSLocalizedString(@"On", nil)];
			}
			else
			{
				[secondColumnItems2 replaceObjectAtIndex:1 withObject:NSLocalizedString(@"Off", nil)];
				
			}
			
			if(data->u8Protocol_IPP)
			{
				[secondColumnItems2 replaceObjectAtIndex:2 withObject:NSLocalizedString(@"On", nil)];
			}
			else
			{
				[secondColumnItems2 replaceObjectAtIndex:2 withObject:NSLocalizedString(@"Off", nil)];
				
			}
			
			if(data->u8Protocol_WSD_PRINT)
			{
				[secondColumnItems2 replaceObjectAtIndex:3 withObject:NSLocalizedString(@"On", nil)];
			}
			else
			{
				[secondColumnItems2 replaceObjectAtIndex:3 withObject:NSLocalizedString(@"Off", nil)];
				
			}
			
			if(data->u8Protocol_SNMP)
			{
				[secondColumnItems2 replaceObjectAtIndex:4 withObject:NSLocalizedString(@"On", nil)];
			}
			else
			{
				[secondColumnItems2 replaceObjectAtIndex:4 withObject:NSLocalizedString(@"Off", nil)];
				
			}
			
			if(data->u8Protocol_EAMIL_ALERT)
			{
				[secondColumnItems2 replaceObjectAtIndex:5 withObject:NSLocalizedString(@"On", nil)];
			}
			else
			{
				[secondColumnItems2 replaceObjectAtIndex:5 withObject:NSLocalizedString(@"Off", nil)];
				
			}
			
			if(data->u8Protocol_CentreWare_IS)
			{
				[secondColumnItems2 replaceObjectAtIndex:6 withObject:NSLocalizedString(@"On", nil)];
			}
			else
			{
				[secondColumnItems2 replaceObjectAtIndex:6 withObject:NSLocalizedString(@"Off", nil)];
				
			}
			
			if(data->u8Protocol_Bonjour)
			{
				[secondColumnItems2 replaceObjectAtIndex:7 withObject:NSLocalizedString(@"On", nil)];
			}
			else
			{
				[secondColumnItems2 replaceObjectAtIndex:7 withObject:NSLocalizedString(@"Off", nil)];
				
			}
			
			[secondColumnItems3 replaceObjectAtIndex:1 withObject:[NSString stringWithFormat:@"%d.%d.%d.%d", data->u8IPFilter1_Address[0], data->u8IPFilter1_Address[1], data->u8IPFilter1_Address[2], data->u8IPFilter1_Address[3]]];
			[secondColumnItems3 replaceObjectAtIndex:2 withObject:[NSString stringWithFormat:@"%d.%d.%d.%d", data->u8IPFilter1_SubnetMask[0], data->u8IPFilter1_SubnetMask[1], data->u8IPFilter1_SubnetMask[2], data->u8IPFilter1_SubnetMask[3]]];
			switch (data->u8IPFilter1_Mode) {
				case 0:
					[secondColumnItems3 replaceObjectAtIndex:3 withObject:NSLocalizedString(@"Off", nil)];
					break;
				case 1:
					[secondColumnItems3 replaceObjectAtIndex:3 withObject:NSLocalizedString(@"Accept", nil)];
					break;
				case 2:
					[secondColumnItems3 replaceObjectAtIndex:3 withObject:NSLocalizedString(@"Reject", nil)];
					break;
				default:
					break;
			}
			
			[secondColumnItems3 replaceObjectAtIndex:5 withObject:[NSString stringWithFormat:@"%d.%d.%d.%d", data->u8IPFilter2_Address[0], data->u8IPFilter2_Address[1], data->u8IPFilter2_Address[2], data->u8IPFilter2_Address[3]]];
			[secondColumnItems3 replaceObjectAtIndex:6 withObject:[NSString stringWithFormat:@"%d.%d.%d.%d", data->u8IPFilter2_SubnetMask[0], data->u8IPFilter2_SubnetMask[1], data->u8IPFilter2_SubnetMask[2], data->u8IPFilter2_SubnetMask[3]]];
			switch (data->u8IPFilter2_Mode) {
				case 0:
					[secondColumnItems3 replaceObjectAtIndex:7 withObject:NSLocalizedString(@"Off", nil)];
					break;
				case 1:
					[secondColumnItems3 replaceObjectAtIndex:7 withObject:NSLocalizedString(@"Accept", nil)];
					break;
				case 2:
					[secondColumnItems3 replaceObjectAtIndex:7 withObject:NSLocalizedString(@"Reject", nil)];
					break;
				default:
					break;
			}
			
			[secondColumnItems3 replaceObjectAtIndex:9 withObject:[NSString stringWithFormat:@"%d.%d.%d.%d", data->u8IPFilter3_Address[0], data->u8IPFilter3_Address[1], data->u8IPFilter3_Address[2], data->u8IPFilter3_Address[3]]];
			[secondColumnItems3 replaceObjectAtIndex:10 withObject:[NSString stringWithFormat:@"%d.%d.%d.%d", data->u8IPFilter3_SubnetMask[0], data->u8IPFilter3_SubnetMask[1], data->u8IPFilter3_SubnetMask[2], data->u8IPFilter3_SubnetMask[3]]];
			switch (data->u8IPFilter3_Mode) {
				case 0:
					[secondColumnItems3 replaceObjectAtIndex:11 withObject:NSLocalizedString(@"Off", nil)];
					break;
				case 1:
					[secondColumnItems3 replaceObjectAtIndex:11 withObject:NSLocalizedString(@"Accept", nil)];
					break;
				case 2:
					[secondColumnItems3 replaceObjectAtIndex:11 withObject:NSLocalizedString(@"Reject", nil)];
					break;
				default:
					break;
			}
			
			[secondColumnItems3 replaceObjectAtIndex:13 withObject:[NSString stringWithFormat:@"%d.%d.%d.%d", data->u8IPFilter4_Address[0], data->u8IPFilter4_Address[1], data->u8IPFilter4_Address[2], data->u8IPFilter4_Address[3]]];
			[secondColumnItems3 replaceObjectAtIndex:14 withObject:[NSString stringWithFormat:@"%d.%d.%d.%d", data->u8IPFilter4_SubnetMask[0], data->u8IPFilter4_SubnetMask[1], data->u8IPFilter4_SubnetMask[2], data->u8IPFilter4_SubnetMask[3]]];
			switch (data->u8IPFilter4_Mode) {
				case 0:
					[secondColumnItems3 replaceObjectAtIndex:15 withObject:NSLocalizedString(@"Off", nil)];
					break;
				case 1:
					[secondColumnItems3 replaceObjectAtIndex:15 withObject:NSLocalizedString(@"Accept", nil)];
					break;
				case 2:
					[secondColumnItems3 replaceObjectAtIndex:15 withObject:NSLocalizedString(@"Reject", nil)];
					break;
				default:
					break;
					
			}
			
			[secondColumnItems3 replaceObjectAtIndex:17 withObject:[NSString stringWithFormat:@"%d.%d.%d.%d", data->u8IPFilter5_Address[0], data->u8IPFilter5_Address[1], data->u8IPFilter5_Address[2], data->u8IPFilter5_Address[3]]];
			[secondColumnItems3 replaceObjectAtIndex:18 withObject:[NSString stringWithFormat:@"%d.%d.%d.%d", data->u8IPFilter5_SubnetMask[0], data->u8IPFilter5_SubnetMask[1], data->u8IPFilter5_SubnetMask[2], data->u8IPFilter5_SubnetMask[3]]];
			switch (data->u8IPFilter5_Mode) {
				case 0:
					[secondColumnItems3 replaceObjectAtIndex:19 withObject:NSLocalizedString(@"Off", nil)];
					break;
				case 1:
					[secondColumnItems3 replaceObjectAtIndex:19 withObject:NSLocalizedString(@"Accept", nil)];
					break;
				case 2:
					[secondColumnItems3 replaceObjectAtIndex:19 withObject:NSLocalizedString(@"Reject", nil)];
					break;
				default:
					break;
					
			}
			
			
			break;
		case 1:
			data1 = (DEV_WIRELESS_SETTINGS *)deviceData;
			
			[secondColumnItems replaceObjectAtIndex:1 withObject:[NSString stringWithUTF8String:data1->cSSID]];
			
			
			switch (data1->cEncryptType) {
				case 0:
					switch (data1->cAuthMode) {
						case 0:
							[secondColumnItems replaceObjectAtIndex:2 withObject:NSLocalizedString(@"No Security", nil)];
							break;
						default:
							break;
					}
					
					break;
				case 3:
					switch (data1->cAuthMode) {
						case 1:
							[secondColumnItems replaceObjectAtIndex:2 withObject:NSLocalizedString(@"WEP", nil)];
							break;
						default:
							break;
					}
					
					break;
				case 8:
					switch (data1->cAuthMode) {
						case 8:
							[secondColumnItems replaceObjectAtIndex:2 withObject:NSLocalizedString(@"WPA2-PSK-AES", nil)];
							break;
						default:
							break;
					}
					
					break;
				case 12:
					switch (data1->cAuthMode) {
						case 12:
							[secondColumnItems replaceObjectAtIndex:2 withObject:NSLocalizedString(@"Mixed mode PSK", nil)];
							break;
						default:
							break;
					}
			
					break;
				default:
					break;
			}
			

			
			break;
		case 2:
			data2 = (DEV_WIFI_DIRECT_SETTINGS *)deviceData;
			switch (data2->cP2PEnable) {
				case 0:
					[directSecondColumnItems replaceObjectAtIndex:0 withObject:[NSString stringWithString:NSLocalizedString(@"Disable", nil)]];
					break;
				case 1:
					[directSecondColumnItems replaceObjectAtIndex:0 withObject:[NSString stringWithString:NSLocalizedString(@"Enable", nil)]];
					break;
				default:
					break;
			}

			
			switch (data2->cP2PRole) {
				case 0:
					[directSecondColumnItems replaceObjectAtIndex:1 withObject:[NSString stringWithString:NSLocalizedString(@"Disable", nil)]];
					break;
				case 1:
					[directSecondColumnItems replaceObjectAtIndex:1 withObject:[NSString stringWithString:NSLocalizedString(@"IDS_Idle", nil)]];
					break;
				case 2:
					[directSecondColumnItems replaceObjectAtIndex:1 withObject:[NSString stringWithString:NSLocalizedString(@"IDS_Client", nil)]];
					break;
				case 3:
					[directSecondColumnItems replaceObjectAtIndex:1 withObject:[NSString stringWithString:NSLocalizedString(@"IDS_Group Owner", nil)]];
					break;
				default:
					break;
			}
			

			if(data2->cP2PEnable == 1)
				[directSecondColumnItems replaceObjectAtIndex:2 withObject:[NSString stringWithUTF8String:data2->cDhcpsDevList[0]]];

			
			
			break;

		case 3:
		{
		data3 = (DEV_WIFI_STATUS *)deviceData;
		
			
			switch (data3->Status) {
				case 0:
					[secondColumnItems replaceObjectAtIndex:0 withObject:[NSString stringWithString:NSLocalizedString(@"IDS_No Reception", nil)]];
					break;
				case 1:
					[secondColumnItems replaceObjectAtIndex:0 withObject:[NSString stringWithString:NSLocalizedString(@"IDS_Low", nil)]];
					break;
				case 2:
					[secondColumnItems replaceObjectAtIndex:0 withObject:[NSString stringWithString:NSLocalizedString(@"IDS_Acceptable", nil)]];
					break;
				case 3:
					[secondColumnItems replaceObjectAtIndex:0 withObject:[NSString stringWithString:NSLocalizedString(@"IDS_Good", nil)]];
					break;
				default:
					break;
		
		}
		}
			break;
		default:
			break;
	}
	

    //[tableView reloadData];
}

@end
