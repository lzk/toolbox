//
//  PSRTCPIPViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/15/13.
//
//

#import "PSRTCPIPViewController.h"
#import "DataStructure.h"
#import "DeviceProperty.h"


@interface PSRTCPIPViewController ()

@end


@implementation PSRTCPIPViewController

- (void)dealloc
{    
    [super dealloc];
}

- (id)init
{
    NSLog(@"init s");
    self = [super init];
    if (self)
    {
        contentTitle = [[NSString alloc] initWithString:NSLocalizedString(@"TCP/IP Settings", nil)];
        tableView1firstColumnItems = [[NSMutableArray alloc] init];
        tableView1secondColumnItems = [[NSMutableArray alloc] init];
        
		
        tableView2firstColumnItems = [[NSMutableArray alloc] init];
        tableView2secondColumnItems = [[NSMutableArray alloc] init];

        
        [tableView1firstColumnItems addObject:NSLocalizedString(@"IP Mode", nil)];
        
        [tableView2firstColumnItems addObject:NSLocalizedString(@"IP Address Mode", nil)];
        [tableView2firstColumnItems addObject:NSLocalizedString(@"IP Address", nil)];

        [tableView2firstColumnItems addObject:NSLocalizedString(IDS_SUBNET, nil)];
		
        [tableView2firstColumnItems addObject:NSLocalizedString(@"Gateway Address", nil)];
        
        int i;
        for (i = 0; i < [tableView1firstColumnItems count]; i++)
        {
            [tableView1secondColumnItems addObject:@"--"];
        }
        
        for (i = 0; i < [tableView2firstColumnItems count]; i++)
        {
            [tableView2secondColumnItems addObject:@"--"];
        }
        

        [devciePropertyList addObject:[[TCPIPSettings alloc] init]];
		
		tableView3firstColumnItems = [[NSMutableArray alloc] init];
        tableView3secondColumnItems = [[NSMutableArray alloc] init];
        
	

        
        [tableView3firstColumnItems addObject:NSLocalizedString(@"IDS_IPv6UseManualAddress", nil)];
        [tableView3firstColumnItems addObject:NSLocalizedString(@"IP Address", nil)];
		[tableView3firstColumnItems addObject:NSLocalizedString(@"IDS_ManualGatewayAddress", nil)];

		
		
     
        for (i = 0; i < [tableView3firstColumnItems count]; i++)
        {
            [tableView3secondColumnItems addObject:@"--"];
        }

        
        [self initWithNibName:@"PSRTCPIPViewController" bundle:nil];
		
		
		
		
		
		[devciePropertyList addObject:[[[TCPIPSettingsV2 alloc] init] autorelease]];
    }

    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"TCP/IP Settings", nil);
}

- (void)awakeFromNib
{
    //[tableView reloadData];
    [ipModeLabel setStringValue:NSLocalizedString(@"IP Mode", nil)];
    [ipv4Label setStringValue:NSLocalizedString(@"IPv4", nil)];
	[ipv6Label setStringValue:NSLocalizedString(@"IPv6", nil)];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    switch (tableView.tag) {
        case 1:
            return [tableView1firstColumnItems count];
            break;
        case 2:
            return [tableView2firstColumnItems count];
            break;
		case 3:
			return [tableView3firstColumnItems count];
        default:
            return 0;
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
            value1 = [tableView1firstColumnItems objectAtIndex:row];
            value2 = [tableView1secondColumnItems objectAtIndex:row];
            return [identifier isEqualToString:@"first"] ? value1 : value2;
            break;
        case 2:
            value1 = [tableView2firstColumnItems objectAtIndex:row];
            value2 = [tableView2secondColumnItems objectAtIndex:row];
            return [identifier isEqualToString:@"first"] ? value1 : value2;
            break;
		case 3:
            value1 = [tableView3firstColumnItems objectAtIndex:row];
            value2 = [tableView3secondColumnItems objectAtIndex:row];
            return [identifier isEqualToString:@"first"] ? value1 : value2;
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
        return;
    }
    
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        [self UpdateItemStrings:[aCommond deviceData] index:i];
    }
    
}

- (void)UpdateItemStrings:(id)deviceData index:(int)cmdIndex
{
	
	
	switch (cmdIndex) {
		case 0:
		{
		
		    DEV_TCPIP_SETTINGS *data = (DEV_TCPIP_SETTINGS *)deviceData;
			
			int index = 0;
			NSString *string = nil;
			
			switch (data->iIPMode) {
				case 0:
					[tableView1secondColumnItems replaceObjectAtIndex:0 withObject:NSLocalizedString(@"IPv4", nil)];    
					break;
				case 1:
					[tableView1secondColumnItems replaceObjectAtIndex:0 withObject:NSLocalizedString(@"Dual Stack", nil)];
				default:
					break;
			}
			
			switch (data->iIPAddressMode) {
				case 0:
					string = [[NSString alloc] initWithString:NSLocalizedString(@"DHCP/AutoIP", nil)];
					break;
				case 1:
					string = [[NSString alloc] initWithString:NSLocalizedString(@"BOOTP", nil)];
					break;
				case 2:
					string = [[NSString alloc] initWithString:NSLocalizedString(@"RARP", nil)];
					break;
				case 3:
					string = [[NSString alloc] initWithString:NSLocalizedString(@"DHCP", nil)];
					break;
				case 4:
					string = [[NSString alloc] initWithString:NSLocalizedString(@"Panel", nil)];
					break;
				default:
					break;
			}
			
			if(string)
			{
				[tableView2secondColumnItems replaceObjectAtIndex:index withObject:string];
			}
			[string release];
			string = nil;
			
			index++;
			string = [[NSString alloc] initWithFormat:@"%d.%d.%d.%d", data->dIPAddress[0], data->dIPAddress[1],
					  data->dIPAddress[2], data->dIPAddress[3]];
			if (string)
			{
				[tableView2secondColumnItems replaceObjectAtIndex:index withObject:string];
			}
			[string release];
			string = nil;
			
			index++;
			string = [[NSString alloc] initWithFormat:@"%d.%d.%d.%d", data->dSubnetMask[0], data->dSubnetMask[1],
					  data->dSubnetMask[2], data->dSubnetMask[3]];
			if (string)
			{
				[tableView2secondColumnItems replaceObjectAtIndex:index withObject:string];
			}
			[string release];
			string = nil;
			
			index++;
			string = [[NSString alloc] initWithFormat:@"%d.%d.%d.%d", data->dGatewayAddress[0], data->dGatewayAddress[1],
					  data->dGatewayAddress[2], data->dGatewayAddress[3]];
			if (string)
			{
				[tableView2secondColumnItems replaceObjectAtIndex:index withObject:string];
			}
			[string release];
			string = nil;
			
		
		}
			break;
		case 1:
		{
			DEV_TCPIP_SETTINGSV2 *data = (DEV_TCPIP_SETTINGSV2 *)deviceData;
			int index = 0;
			NSString *string = nil;
			switch (data->u8IPv6UseManualAddress) {
				case 0:
					string = [[NSString alloc] initWithString:NSLocalizedString(@"Disable", nil)];
					break;
				case 1:
					string = [[NSString alloc] initWithString:NSLocalizedString(@"Enable", nil)];
					break;
				default:
					break;
			}
		
			if(string)
			{
				[tableView3secondColumnItems replaceObjectAtIndex:index withObject:string];
			}
			[string release];
			
			index++;

			[tableView3secondColumnItems replaceObjectAtIndex:index withObject:[[NSString alloc] initWithFormat:@"%s/%d",data->u8aIPv6ManualAddress,data->u32IPv6ManualMask] ];
			
			index++;
			[tableView3secondColumnItems replaceObjectAtIndex:index withObject:[NSString stringWithUTF8String:data->u8aIPv6ManualGatewayAddress]];
			

		}
			
			
			
			
			
			break;
		default:
			break;
	}
	
	
    
    //[tableView reloadData];
}


@end


















