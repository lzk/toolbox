//
//  PMTCPIPViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "PMTCPIPViewController.h"
#import "DeviceProperty.h"
#include <arpa/inet.h>
#import "CustomTextFieldFormatter.h"


@interface PMTCPIPViewController ()

@end

@implementation PMTCPIPViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"TCP/IP Settings", nil);
        [devciePropertyList addObject:[[[TCPIPSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[TCPIPSettingsV2 alloc] init] autorelease]];
        [devciePropertyList addObject:[[[WirelessDirectIP alloc] init] autorelease]];
        [self initWithNibName:@"PMTCPIPViewController" bundle:nil];
		
		isDone == TRUE;
    }
    
    return self;
}

- (void)dealloc
{
	[[[self view] window] makeFirstResponder:nil];
    
	[super dealloc];
}


+ (NSString *)description
{
    return NSLocalizedString(@"TCP/IP Settings", nil);
}

- (void)awakeFromNib
{
    [ipModeLabel setStringValue:NSLocalizedString(@"IP Mode", nil)];
    [ipModelComboBox addItemWithObjectValue:NSLocalizedString(@"IPv4", nil)];
    [ipModelComboBox addItemWithObjectValue:NSLocalizedString(@"Dual Stack", nil)];
    [ipModelComboBox selectItemAtIndex:1];
    [ipModelComboBox setEditable:NO];
    [ipModelComboBox setNumberOfVisibleItems:[ipModelComboBox numberOfItems]];
    [ipModelComboBox setDelegate:self];
	
	
    [box setTitle:NSLocalizedString(@"IPv4", nil)];
	[box6 setTitle:NSLocalizedString(@"IPv6", nil)];
    
    [ipAddressModeLabel setStringValue:NSLocalizedString(@"IP Address Mode", nil)];
    [ipAddressModelComboBox addItemWithObjectValue:NSLocalizedString(@"DHCP/AutoIP", nil)];
    [ipAddressModelComboBox addItemWithObjectValue:NSLocalizedString(@"BOOTP", nil)];
    [ipAddressModelComboBox addItemWithObjectValue:NSLocalizedString(@"RARP", nil)];
    [ipAddressModelComboBox addItemWithObjectValue:NSLocalizedString(@"DHCP", nil)];
    [ipAddressModelComboBox addItemWithObjectValue:NSLocalizedString(@"Panel", nil)];
    [ipAddressModelComboBox selectItemAtIndex:0];
    [ipAddressModelComboBox setEditable:NO];
    
    [ipAddressLabel setStringValue:NSLocalizedString(@"IP Address", nil)];
    [ipTextField1 setStringValue:@"0"];
    [ipTextField2 setStringValue:@"0"];
    [ipTextField3 setStringValue:@"0"];
    [ipTextField4 setStringValue:@"0"];
    [ipDotTextField1 setStringValue:@"."];
    [ipDotTextField2 setStringValue:@"."];
    [ipDotTextField3 setStringValue:@"."];
    
    [subnetMaskLabel setStringValue:NSLocalizedString(IDS_SUBNET, nil)];
	
	
    [subnetMaskTextField1 setStringValue:@"0"];
    [subnetMaskTextField2 setStringValue:@"0"];
    [subnetMaskTextField3 setStringValue:@"0"];
    [subnetMaskTextField4 setStringValue:@"0"];
    [subnetMaskDotTextField1 setStringValue:@"."];
    [subnetMaskDotTextField2 setStringValue:@"."];
    [subnetMaskDotTextField3 setStringValue:@"."];
    
    [gatewayLabel setStringValue:NSLocalizedString(@"Gateway Address", nil)];
    [gatewayTextField1 setStringValue:@"0"];
    [gatewayTextField2 setStringValue:@"0"];
    [gatewayTextField3 setStringValue:@"0"];
    [gatewayTextField4 setStringValue:@"0"];
    [gatewayDotTextField1 setStringValue:@"."];
    [gatewayDotTextField2 setStringValue:@"."];
    [gatewayDotTextField3 setStringValue:@"."];
    
	CustomTextFieldFormatter* numberFormatter = [[CustomTextFieldFormatter alloc] init];
	[numberFormatter setNumberOnly:YES];
	[numberFormatter setMaximumLength:3];
	[numberFormatter setMaximumNumber:255];
	[subnetMaskTextField1 setFormatter:numberFormatter];
	[subnetMaskTextField2 setFormatter:numberFormatter];
	[subnetMaskTextField3 setFormatter:numberFormatter];
	[subnetMaskTextField4 setFormatter:numberFormatter];
	
	[gatewayTextField1 setFormatter:numberFormatter];
	[gatewayTextField2 setFormatter:numberFormatter];
	[gatewayTextField3 setFormatter:numberFormatter];
	[gatewayTextField4 setFormatter:numberFormatter];
	
	[ipTextField1 setFormatter:numberFormatter];
	[ipTextField2 setFormatter:numberFormatter];
	[ipTextField3 setFormatter:numberFormatter];
	[ipTextField4 setFormatter:numberFormatter];
	
	
	CustomTextFieldFormatter* ipAFormatter = [[CustomTextFieldFormatter alloc] init];
	[ipAFormatter setNumberOnly:YES];
	[ipAFormatter setMaximumLength:3];
	[ipAFormatter setIPA:YES];
	[ipAFormatter setMaximumNumber:223];
	//[subnetMaskTextField1 setFormatter:ipAFormatter];
	[ipTextField1 setFormatter:ipAFormatter];
	[gatewayTextField1 setFormatter:ipAFormatter];
	[ipAFormatter release];
	
	CustomTextFieldFormatter* ipDFormatter = [[CustomTextFieldFormatter alloc] init];
	[ipDFormatter setNumberOnly:YES];
	[ipDFormatter setMaximumLength:3];
	[ipDFormatter setMaximumNumber:254];
	
	[subnetMaskTextField4 setFormatter:ipDFormatter];
	[ipDFormatter release];
	
	
	[ipv6ModeLabel setStringValue:NSLocalizedString(@"IDS_IPv6UseManualAddress", nil)];
    [ipv6ModelCheckBox setTitle:NSLocalizedString(@"Enable", nil)];
    [ipv6ModelCheckBox setState:NSOffState];
	
	
	[ip6AddressLabel setStringValue:NSLocalizedString(@"IP Address", nil)];
	[gateway6Label setStringValue:NSLocalizedString(@"Gateway Address", nil)];
	[ip6PrefixText setStringValue:@"/"];
	
	CustomTextFieldFormatter* ipv6Formatter = [[CustomTextFieldFormatter alloc] init];
	[ipv6Formatter setNumberOnly:YES];
	[ipv6Formatter setMaximumLength:3];
	[ipv6Formatter setMaximumNumber:128];
	[ip6PrefixTextField setFormatter:ipv6Formatter];
	
	[ipv6Formatter release];
    [applyButton setTitle:NSLocalizedString(@"Apply New Settings", nil)];
    [restartButton setTitle:NSLocalizedString(@"Restart printer to apply new settings", nil)];
    
    isShowRestartAlert = NO;
    isNeedRestart = NO;
    isRestarting = NO;
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
	
	//isNotReflesh = NO;
	startDetectChangeEvent = NO;
	if(isApply)
	{
		
		isChanged = NO;
		[applyButton setEnabled:NO];
		[restartButton setEnabled:NO];
		isApply = NO;
		
		[super UpdatePrinterPropertyToView:directionWithResult];
		NSNumber *result = [directionWithResult objectAtIndex:1];
		if([result intValue] != DEV_ERROR_SUCCESS)
		{
			[[scrollView verticalScroller] setEnabled:YES];
			return;
		}
		startDetectChangeEvent = YES;
		if (isShowRestartAlert)
		{
			isShowRestartAlert = NO;
			[self performSelectorOnMainThread:@selector(showRestartAlert) withObject:nil waitUntilDone:NO];
		}
		if (isNeedRestart)
		{
			isNeedRestart = NO;
			[self restartPrinter];
		}
		
		return;
		
	}
	
    
    [super UpdatePrinterPropertyToView:directionWithResult];
    
    NSNumber *result = [directionWithResult objectAtIndex:1];
    if([result intValue] != DEV_ERROR_SUCCESS)
    {
		[[scrollView verticalScroller] setEnabled:YES];
        return;
    }
    isDone = FALSE;
    int i;
    for (i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *data = [devciePropertyList objectAtIndex:i];
        [self updateView:[data deviceData] index:i];
    }
    isDone = TRUE;
	isChanged = NO;
    [applyButton setEnabled:NO];
    [restartButton setEnabled:NO];
    
	
    
	
	if (isShowRestartAlert)
	{
		isShowRestartAlert = NO;
		[self performSelectorOnMainThread:@selector(showRestartAlert) withObject:nil waitUntilDone:NO];
	}
	
	
	
    if (isNeedRestart)
    {
        isNeedRestart = NO;
        [self restartPrinter];
    }
	
	
    startDetectChangeEvent = YES;
}

- (void)updateView:(id)data index:(int)i
{
    if (isRestarting)
    {
        isRestarting = NO;
        
    }
    else
    {
		switch (i) {
			case 0:
			{
				
				DEV_TCPIP_SETTINGS *devData = (DEV_TCPIP_SETTINGS *)data;
				[ipModelComboBox selectItemAtIndex:devData->iIPMode];
				
				if([ipModelComboBox indexOfSelectedItem] == 1){
					
					[ip6PrefixTextField setEnabled:YES];
					[ip6TextField setEnabled:YES];
					[gateway6TextField setEnabled:YES];
					
					[ipv6ModelCheckBox setState:NSOnState];
					[ipv6ModelCheckBox setEnabled:YES];
					
				}else {
					
					[ipv6ModelCheckBox setState:NSOffState];
					[ipv6ModelCheckBox setEnabled:NO];
					[ip6PrefixTextField setEnabled:NO];
					[ip6TextField setEnabled:NO];
					[gateway6TextField setEnabled:NO];
				}
				
				[ipAddressModelComboBox selectItemAtIndex:devData->iIPAddressMode];
				
				if ([ipAddressModelComboBox indexOfSelectedItem] == 4)
				{
					[self enableIPInput:YES];
				}
				else
				{
					[self enableIPInput:NO];
				}
				
				[ipTextField1 setStringValue:[NSString stringWithFormat:@"%d", devData->dIPAddress[0]]];
				[ipTextField2 setStringValue:[NSString stringWithFormat:@"%d", devData->dIPAddress[1]]];
				[ipTextField3 setStringValue:[NSString stringWithFormat:@"%d", devData->dIPAddress[2]]];
				[ipTextField4 setStringValue:[NSString stringWithFormat:@"%d", devData->dIPAddress[3]]];
				
				[subnetMaskTextField1 setStringValue:[NSString stringWithFormat:@"%d", devData->dSubnetMask[0]]];
				[subnetMaskTextField2 setStringValue:[NSString stringWithFormat:@"%d", devData->dSubnetMask[1]]];
				[subnetMaskTextField3 setStringValue:[NSString stringWithFormat:@"%d", devData->dSubnetMask[2]]];
				[subnetMaskTextField4 setStringValue:[NSString stringWithFormat:@"%d", devData->dSubnetMask[3]]];
				
				[gatewayTextField1 setStringValue:[NSString stringWithFormat:@"%d", devData->dGatewayAddress[0]]];
				[gatewayTextField2 setStringValue:[NSString stringWithFormat:@"%d", devData->dGatewayAddress[1]]];
				[gatewayTextField3 setStringValue:[NSString stringWithFormat:@"%d", devData->dGatewayAddress[2]]];
				[gatewayTextField4 setStringValue:[NSString stringWithFormat:@"%d", devData->dGatewayAddress[3]]];
				
				
			}
				break;
			case 1:
			{
				DEV_TCPIP_SETTINGSV2 *devData = (DEV_TCPIP_SETTINGSV2 *)data;
				switch (devData->u8IPv6UseManualAddress) {
					case 0:
					{
						[ipv6ModelCheckBox setState:NSOffState];
						[ip6PrefixTextField setEnabled:NO];
						[ip6TextField setEnabled:NO];
						[gateway6TextField setEnabled:NO];
						
					}
						break;
					case 1:
					{
						[ipv6ModelCheckBox setState:NSOnState];
						[ip6PrefixTextField setEnabled:YES];
						[ip6TextField setEnabled:YES];
						[gateway6TextField setEnabled:YES];
						
					}
						break;
					default:
						break;
				}
				[ip6TextField setStringValue:[NSString stringWithCString:devData->u8aIPv6ManualAddress encoding:NSASCIIStringEncoding]];
				[ip6PrefixTextField setStringValue:[NSString stringWithFormat:@"%d", devData->u32IPv6ManualMask]];
				NSArray *ipSplit = [[NSString stringWithCString:devData->u8aIPv6ManualGatewayAddress encoding:NSASCIIStringEncoding] componentsSeparatedByString:@"/"];
				
				[gateway6TextField setStringValue:[ipSplit objectAtIndex:0]];
				
				
				
			}
				break;
			case 2:
			{
				memset(&devP2PIPData,0x00,sizeof(DEV_WIFI_P2P_IP));
				memcpy(&devP2PIPData, data, sizeof(DEV_WIFI_P2P_IP));
				
			}
				break;
			default:
				break;
		}
		
    }
    
    
	
}

- (IBAction)applyButtonAction:(id)sender
{
	isNotReflesh = YES;
    //[ipTextField1 resignFirstResponder];
	[[[self view] window] makeFirstResponder:nil];
	
	DeviceCommond *aCommond;
	DEV_TCPIP_SETTINGS settings;
	DEV_TCPIP_SETTINGSV2 settings1;
	
	
	
    isApply = YES;
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
		
		switch (i) {
			case 0:
			{
				aCommond = [devciePropertyList objectAtIndex:i];
				//DEV_TCPIP_SETTINGS settings;
				[self getDataFormView:&settings index:i];
				[aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_TCPIP_SETTINGS)];
				if (resevedDirect)
				{
					[self showResevedDirectAlert];
					return;
				}else if (collisionDirect) {
					[self showCollisionDirectAlert];
					return;
				}
				
				isShowRestartAlert = YES;
			}
				break;
			case 1:
			{
				
				aCommond = [devciePropertyList objectAtIndex:i];
				
				[self getDataFormView:&settings1 index:i];
				[aCommond setDeviceData:(void*)&settings1 dataSize:sizeof(DEV_TCPIP_SETTINGSV2)];
				//NSLog(@"[net] badIP %d ",badIP);
				if (badIP)
				{
					[self showBadIPAlert];
					return;
				}
				else if(badGate)
				{
					[self showBadGateAlert];
					return;
				}
				
				isShowRestartAlert = YES;
			}
				break;
			default:
				break;
		}
		
		
    }
	
	[self setInfoToDevice];
	
	isShowRestartAlert = YES;
	isChanged = NO;
	
	
}

- (IBAction)restartButtonAction:(id)sender
{
	isNotReflesh = YES;
	[[[self view] window] makeFirstResponder:nil];
	isApply = YES;
	
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
		switch (i) {
			case 0:
			{
				DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
				DEV_TCPIP_SETTINGS settings;
				[self getDataFormView:&settings index:i];
				[aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_TCPIP_SETTINGS)];
				if (resevedDirect)
				{
					[self showResevedDirectAlert];
					return;
				}else if (collisionDirect) {
					[self showCollisionDirectAlert];
					return;
				}
				
				isShowRestartAlert = NO;
			}
				break;
			case 1:
			{
				
				DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
				DEV_TCPIP_SETTINGSV2 settings;
				
				[self getDataFormView:&settings index:i];
				
				[aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_TCPIP_SETTINGSV2)];
				//NSLog(@"[net] badIP %d ",badIP);
				if (badIP)
				{
					[self showBadIPAlert];
					return;
				}
				else if(badGate)
				{
					[self showBadGateAlert];
					return;
				}
				isShowRestartAlert = NO;
			}
				break;
			default:
				break;
		}
		
    }
	isNeedRestart = YES;
	[self setInfoToDevice];
	isChanged = NO;
}

- (int)checkVaildIP:(char *)addr maskaddr:(char *)maskaddr gateaddr:(char *)gateaddr ver:(int)ver
{
	struct sockaddr_in sa,blacksa,gatesa,masksa;
	
	int cidr=0;
	struct sockaddr_in6 sa6,blacksa6,gatesa6,masksa6;

	//Tansfroming 
	switch (ver) {
		case 4:
			
			inet_pton(AF_INET, addr, &(sa.sin_addr));
			

			//0.0.0.0/8
			inet_pton(AF_INET, "0.0.0.0", &(blacksa.sin_addr));
			inet_pton(AF_INET, "255.0.0.0", &(masksa.sin_addr));

			if((blacksa.sin_addr.s_addr & masksa.sin_addr.s_addr) ==  (sa.sin_addr.s_addr & masksa.sin_addr.s_addr))
				return -1;
			
#if 0
			//169.254.0.0/16
			inet_pton(AF_INET, "169.254.0.0", &(blacksa.sin_addr));
			inet_pton(AF_INET, "255.255.0.0", &(masksa.sin_addr));
			if((blacksa.sin_addr.s_addr & masksa.sin_addr.s_addr) !=  (sa.sin_addr.s_addr & masksa.sin_addr.s_addr))
				  return -1;
#endif		
			//check netmask
			inet_pton(AF_INET, maskaddr, &(masksa.sin_addr));
			uint32_t a =  ~masksa.sin_addr.s_addr;
			if((a & (a + 1)) != 0)
				return -1;
			
			//check ip and netmask
			uint32_t hostaddr = 0;
			uint32_t result = 0;
			hostaddr = (~masksa.sin_addr.s_addr)&sa.sin_addr.s_addr;
			result = hostaddr^masksa.sin_addr.s_addr;
			if(result != 0xFFFFFFFFUL)
				return -1;
			
#if 0			
			//check gateway
			inet_pton(AF_INET, gateaddr, &(gatesa.sin_addr));
			//inet_pton(AF_INET, maskaddr, &(masksa.sin_addr));
			if((blacksa.sin_addr.s_addr & masksa.sin_addr.s_addr) !=  (sa.sin_addr.s_addr & masksa.sin_addr.s_addr))
				return -1;
#endif
			
			break;
		case 6:
			
			//build cidr blocks
			cidr = atoi(maskaddr);
			uint32_t netmaskint[4];
			netmaskint[0]=0x00000000; 
			netmaskint[1]=0x00000000; 
			netmaskint[2]=0x00000000; 
			netmaskint[3]=0x00000000; 
			
			if (cidr<0) {
				return -1;
			}
			
			
			int i = 128 - cidr;
			if (i >= 96) {
				
				
				int j=32-(i - 96);
				if(j>=1)
					netmaskint[0]=0x80000000; //cidr = 1
				
				for(;j>1;j--)
				{
				 //right shift
					netmaskint[0] |= netmaskint[0] >> 1 ;
				
				
				}
				//NSLog(@"[net] i >= 96 [%08x]",netmaskint[0]);
				
			}
			else if (i >= 64) {
				netmaskint[0]=0xffffffff;
				int j=32-(i - 64);
				if(j>=1)
					netmaskint[1]=0x80000000;
				
				for(;j>1;j--)
				{
					//right shift
					netmaskint[1] |= netmaskint[1] >> 1;
					
					
				}
				//NSLog(@"[net] i >= 64 [%08x]",netmaskint[1]);
			}
			else if (i >= 32) {
				netmaskint[0]=0xffffffff;
				netmaskint[1]=0xffffffff;
				int j=32-(i - 32);
				if(j>=1)
					netmaskint[2]=0x80000000;
				
				for(;j>1;j--)
				{
					//right shift
					netmaskint[2] |= netmaskint[2] >> 1;
					
					
				}
				//NSLog(@"[net] i >= 32 [%08x]",netmaskint[2]);
				
			}
			else if (i >= 0) {
				netmaskint[0]=0xffffffff;
				netmaskint[1]=0xffffffff;
				netmaskint[2]=0xffffffff;
				int j=32-i;
				if(j>=1)
					netmaskint[3]=0x80000000;
				
				for(;j>1;j--)
				{
					//right shift
					netmaskint[3] |= netmaskint[3] >> 1;
					
					
				}
				//NSLog(@"[net] i >= 0 [%08x]",netmaskint[3]);
				
			}
			//NSLog(@"[net] cidr=[%d]",cidr);
			//NSLog(@"[net] netmaskint=[%08x][%08x][%08x][%08x]",netmaskint[0],netmaskint[1],netmaskint[2],netmaskint[3]);
			// store this IP address in sa:
			inet_pton(AF_INET6, addr, &(sa6.sin6_addr));
			uint32_t ipstr1[4],ipstr2[4],ipstr3[4];
			i=0;
			memcpy(ipstr1,&sa6.sin6_addr,sizeof(struct in6_addr));
			
			
			
			//::1/128
			inet_pton(AF_INET6, "::1", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF:FFFF", &(masksa6.sin6_addr));
			

			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			

			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
			
#if 0
			NSLog(@"[net] 0000::/8");
			//0000::/8
			inet_pton(AF_INET6, "0000::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FF00:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif			
#if 0
			NSLog(@"[net] 0100::/8");
			//0100::/8
			inet_pton(AF_INET6, "0100::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FF00:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0
			
			NSLog(@"[net] 0200::/7");
			//0200::/7
			inet_pton(AF_INET6, "0200::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FE00:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0
			NSLog(@"[net] 0400::/6");
			//0400::/6
			inet_pton(AF_INET6, "0400::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FC00:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0			
			
			
			NSLog(@"[net] 0800::/5");
			//0800::/5
			inet_pton(AF_INET6, "0800::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "F800:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0

			NSLog(@"[net] 1000::/4");
			//1000::/4
			inet_pton(AF_INET6, "1000::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "F000:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0
			NSLog(@"[net] 4000::/3");
			//4000::/3
			inet_pton(AF_INET6, "4000::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "E000:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0
			NSLog(@"[net] 6000::/3");
			//6000::/3
			inet_pton(AF_INET6, "6000::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "E000:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0
			NSLog(@"[net] 8000::/3");
			//8000::/3
			inet_pton(AF_INET6, "8000::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "E000:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0
			NSLog(@"[net] a000::/3");
			//a000::/3
			inet_pton(AF_INET6, "a000::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "E000:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0
			
			NSLog(@"[net] c000::/3");
			//c000::/3
			inet_pton(AF_INET6, "c000::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "E000:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0
			NSLog(@"[net] e000::/4");
			//e000::/4
			inet_pton(AF_INET6, "e000::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "F000:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0			
			NSLog(@"[net] f000::/5");
			//f000::/5
			inet_pton(AF_INET6, "f000::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "F800:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
#if 0
			NSLog(@"[net] f800::/6");
			//f800::/6
			inet_pton(AF_INET6, "f800::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FC00:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif			
#if 0
			NSLog(@"[net] fc00::/7");
			//fc00::/7
			inet_pton(AF_INET6, "fc00::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FE00:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif		
#if 0
			NSLog(@"[net] fe00::/9");
			//fe00::/9
			inet_pton(AF_INET6, "fe00::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FF80:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif			
			NSLog(@"[net] fe80::/10");
			//fe80::/10
			inet_pton(AF_INET6, "fe80::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FFC0:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#if 0
			NSLog(@"[net] fec0::/10");
			//fec0::/10
			inet_pton(AF_INET6, "fec0::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FFC0:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
#endif
			NSLog(@"[net] ff00::/8");
			//ff00::/8
			inet_pton(AF_INET6, "ff00::", &(blacksa6.sin6_addr));
			inet_pton(AF_INET6, "FF00:0000:0000:0000:0000:0000:0000:0000", &(masksa6.sin6_addr));
			memcpy(ipstr2,&blacksa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,&masksa6.sin6_addr,sizeof(struct in6_addr));
			
			if((ipstr1[0] & ipstr3[0]) ==  (ipstr2[0] & ipstr3[0]) &&
			   (ipstr1[1] & ipstr3[1]) ==  (ipstr2[1] & ipstr3[1]) &&
			   (ipstr1[2] & ipstr3[2]) ==  (ipstr2[2] & ipstr3[2]) &&
			   (ipstr1[3] & ipstr3[3]) ==  (ipstr2[3] & ipstr3[3]))
				return -1;
			
			NSLog(@"[net] check gateway");
			//check gateway
#if 0
			inet_pton(AF_INET6, gateaddr, &(gatesa6.sin6_addr));
			//inet_pton(AF_INET, maskaddr, &(masksa6.sin6_addr));
			memcpy(ipstr2,&gatesa6.sin6_addr,sizeof(struct in6_addr));
			memcpy(ipstr3,netmaskint,sizeof(uint32_t) * 4);
			//NSLog(@"[net] ::1/128 [%08x %08x %08x %08x]",ipstr1[0],ipstr1[1],ipstr1[2],ipstr1[3]);
			//NSLog(@"[net] ::1/128 [%08x %08x %08x %08x]",ipstr2[0],ipstr2[1],ipstr2[2],ipstr2[3]);
			//NSLog(@"[net] ::1/128 [%08x %08x %08x %08x]",ipstr3[0],ipstr3[1],ipstr3[2],ipstr3[3]);
			for(i=0;i<4;i++)
			{
				if((ipstr1[i] & ipstr3[i]) !=  (ipstr2[i] & ipstr3[i]))
				{
					NSLog(@"[net] gateway [%08x] [%08x]",(ipstr1[i] & ipstr3[i]), (ipstr2[i] & ipstr3[i]));

					return -1;
				}
			}
#endif
			break;
		default:
			return -1;
	}
	NSLog(@"[net] ip is valid");
	return 0;

}


- (void)getDataFormView:(void *)addr index:(int)index
{
	switch (index) {
		case 0:
		{
		    DEV_TCPIP_SETTINGS data;
			memset(&data, 0, sizeof(DEV_TCPIP_SETTINGS));
			
			data.iIPMode = [ipModelComboBox indexOfSelectedItem];
			
			data.iIPAddressMode = [ipAddressModelComboBox indexOfSelectedItem];
			

			if([ipAddressModelComboBox indexOfSelectedItem] == 4)
			{
				data.dIPAddress[0] = [[ipTextField1 stringValue] intValue];
				data.dIPAddress[1] = [[ipTextField2 stringValue] intValue];
				data.dIPAddress[2] = [[ipTextField3 stringValue] intValue];
				data.dIPAddress[3] = [[ipTextField4 stringValue] intValue];
				
				data.dSubnetMask[0] = [[subnetMaskTextField1 stringValue] intValue];
				data.dSubnetMask[1] = [[subnetMaskTextField2 stringValue] intValue];
				data.dSubnetMask[2] = [[subnetMaskTextField3 stringValue] intValue];
				data.dSubnetMask[3] = [[subnetMaskTextField4 stringValue] intValue];
				
				
				if (data.dIPAddress[0] == 192 &&
					data.dIPAddress[1] == 168 &&
					data.dIPAddress[2] == 186 &&
					data.dSubnetMask[0] == 255 &&
					data.dSubnetMask[1] == 255 &&
					data.dSubnetMask[2] == 255 &&
					data.dSubnetMask[3] == 0
					) {
					resevedDirect = TRUE;
				}
				
				if (devP2PIPData.u8P2P_Address[0] | devP2PIPData.u8P2P_Address[1] | devP2PIPData.u8P2P_Address[2] | devP2PIPData.u8P2P_Address[3]) {
					if ((data.dIPAddress[0] & data.dSubnetMask[0]) == (devP2PIPData.u8P2P_Address[0] & devP2PIPData.u8P2P_SubnetMask[0]) &&
						(data.dIPAddress[1] & data.dSubnetMask[1]) == (devP2PIPData.u8P2P_Address[1] & devP2PIPData.u8P2P_SubnetMask[1]) &&
						(data.dIPAddress[2] & data.dSubnetMask[2]) == (devP2PIPData.u8P2P_Address[2] & devP2PIPData.u8P2P_SubnetMask[2]) &&
						(data.dIPAddress[3] & data.dSubnetMask[3]) == (devP2PIPData.u8P2P_Address[3] & devP2PIPData.u8P2P_SubnetMask[3]) 
						) {
						
						
						NSLog(@"[net] [0]=%d,[1]=%d,[2]=%d,[3]=%d",devP2PIPData.u8P2P_Address[0],devP2PIPData.u8P2P_Address[1],devP2PIPData.u8P2P_Address[2],devP2PIPData.u8P2P_Address[3]);
						collisionDirect = TRUE;
					}
					
				}
				
				
				data.dGatewayAddress[0] = [[gatewayTextField1 stringValue] intValue];
				data.dGatewayAddress[1] = [[gatewayTextField2 stringValue] intValue];
				data.dGatewayAddress[2] = [[gatewayTextField3 stringValue] intValue];
				data.dGatewayAddress[3] = [[gatewayTextField4 stringValue] intValue];
				
				int chk = [self checkVaildIP:[[NSString stringWithFormat:@"%d.%d.%d.%d", data.dIPAddress[0],data.dIPAddress[1],data.dIPAddress[2],data.dIPAddress[3]] cStringUsingEncoding:NSASCIIStringEncoding]  
									maskaddr:[[NSString stringWithFormat:@"%d.%d.%d.%d", data.dSubnetMask[0],data.dSubnetMask[1],data.dSubnetMask[2],data.dSubnetMask[3]] cStringUsingEncoding:NSASCIIStringEncoding]
									gateaddr:[[NSString stringWithFormat:@"%d.%d.%d.%d", data.dGatewayAddress[0],data.dGatewayAddress[1],data.dGatewayAddress[2],data.dGatewayAddress[3]] cStringUsingEncoding:NSASCIIStringEncoding] 
										 ver:4];
				
				
				if(chk<0)
					badIP = YES;
				
				
			}
			

			
			

			
			memcpy(addr, &data, sizeof(DEV_TCPIP_SETTINGS));
		}
			break;
		case 1:
		{
			DEV_TCPIP_SETTINGSV2 data;
			memset(&data, 0, sizeof(DEV_TCPIP_SETTINGSV2));
			
			
			data.u8IPv6UseManualAddress=[ipv6ModelCheckBox state];
			//strcpy(data.u8aIPv6ManualAddress,[[ip6TextField stringValue] cStringUsingEncoding:NSASCIIStringEncoding]);
			
			if([ipv6ModelCheckBox state] == NSOnState )
			{
				struct in_addr dst;
				
				//NSLog(@"[PMTCP] ipv6ModelCheckBox");
				
				if ([[ip6TextField stringValue] cStringUsingEncoding:NSASCIIStringEncoding] != nil || [[ip6TextField stringValue] length] > 0 ) {
					int ret = inet_pton(AF_INET6,[[ip6TextField stringValue] cStringUsingEncoding:NSASCIIStringEncoding], &dst);
					if (ret == 1) {
						strncpy(data.u8aIPv6ManualAddress,[[ip6TextField stringValue] cStringUsingEncoding:NSASCIIStringEncoding],40);
						//NSLog(@"[PMTCP] u8aIPv6ManualAddress =[%s]",data.u8aIPv6ManualAddress);
						
					}
					else {
						badIP = YES;
						NSLog(@"[net] invaild ipv6 address");
					}
				}else {
					badIP = YES;
				}
				
				
				
				
				
				
				data.u32IPv6ManualMask=[ip6PrefixTextField intValue];
				NSLog(@"[PMTCP] u32IPv6ManualMask =[%i]",data.u32IPv6ManualMask);
			
					if([[gateway6TextField stringValue] cStringUsingEncoding:NSASCIIStringEncoding] != nil)
					{
					//	NSCharacterSet *Nums = [NSCharacterSet decimalDigitCharacterSet];
					//	NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:[gateway6TextField stringValue]];
						
						int ret = inet_pton(AF_INET6,[[gateway6TextField stringValue] cStringUsingEncoding:NSASCIIStringEncoding], &dst);
						if (ret == 1) {
							
							
							strcpy(data.u8aIPv6ManualGatewayAddress,[[NSString stringWithFormat:@"%@/%d",[gateway6TextField stringValue],[ip6PrefixTextField intValue]] cStringUsingEncoding:NSASCIIStringEncoding]);
							
							
						}
						else
						{
							badGate = YES;
						}
					}
					else {
						badGate = YES;
					}
					
		
				int chk = [self checkVaildIP:[[NSString stringWithFormat:@"%@", [ip6TextField stringValue]] cStringUsingEncoding:NSASCIIStringEncoding]
									maskaddr:[[NSString stringWithFormat:@"%d", [ip6PrefixTextField intValue]] cStringUsingEncoding:NSASCIIStringEncoding]
									gateaddr:[[NSString stringWithFormat:@"%@", [gateway6TextField stringValue]] cStringUsingEncoding:NSASCIIStringEncoding]   
										 ver:6];
				
				//NSLog(@"[net] chk %d,badIP %d ",chk,badIP);
				if(chk<0)
					badIP = YES;
				
			}
			

			
			
			memcpy(addr, &data, sizeof(DEV_TCPIP_SETTINGSV2));
			
		}
			break;
			
		default:
			break;
	}
	
	
}

- (IBAction)checkButtonAction:(id)sender
{
	
	if(isDone == FALSE)
		return;
	
	if (startDetectChangeEvent == YES)
    {
		isChanged = YES;
        [applyButton setEnabled:YES];
        [restartButton setEnabled:YES];
		
		
		
		
		
		if([ipv6ModelCheckBox state] == NSOnState){
			
			[ip6PrefixTextField setEnabled:YES];
			[ip6TextField setEnabled:YES];
			[gateway6TextField setEnabled:YES];
		}else {
			[ip6PrefixTextField setEnabled:NO];
			[ip6TextField setEnabled:NO];
			[gateway6TextField setEnabled:NO];
		}
		
		
		
        [devciePropertyList removeAllObjects];
        [devciePropertyList addObject:[[[TCPIPSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[TCPIPSettingsV2 alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WirelessDirectIP alloc] init] autorelease]];
    }
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
	if(isDone == FALSE)
		return;
	
    if (startDetectChangeEvent == YES)
    {
        isChanged = YES;
        [applyButton setEnabled:YES];
        [restartButton setEnabled:YES];
        
		if([ipModelComboBox indexOfSelectedItem] == 1){
			
			//[ip6PrefixTextField setEnabled:YES];
			//[ip6TextField setEnabled:YES];
			//[gateway6TextField setEnabled:YES];
			
			//[ipv6ModelCheckBox setState:NSOnState];
			[ipv6ModelCheckBox setEnabled:YES];
			
		}else {
			
			[ipv6ModelCheckBox setState:NSOffState];
			[ipv6ModelCheckBox setEnabled:NO];
			//[ip6PrefixTextField setEnabled:NO];
			//[ip6TextField setEnabled:NO];
			//[gateway6TextField setEnabled:NO];
		}
		
		
		if ([ipAddressModelComboBox indexOfSelectedItem] == 4)
        {
            [self enableIPInput:YES];
        }
        else
        {
            [self enableIPInput:NO];
        }
        
		
		
		
        [devciePropertyList removeAllObjects];
        [devciePropertyList addObject:[[[TCPIPSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[TCPIPSettingsV2 alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WirelessDirectIP alloc] init] autorelease]];
    }
}

-(void)controlTextDidEndEditing:(NSNotification *)obj
{
	if(isDone == FALSE)
		return;
	
    if (startDetectChangeEvent == YES)
    { 
		if([[obj object] isKindOfClass:[NSTextField class]])
		{
			if([obj object] != ip6TextField && [obj object] != gateway6TextField)
			{
				if ([[[obj object] stringValue] length] == 0) {
					[[obj object] setStringValue:@"0"];
				}
			}
		}
		
        isChanged = YES;
        [applyButton setEnabled:YES];
        [restartButton setEnabled:YES];
        
        [devciePropertyList removeAllObjects];
        [devciePropertyList addObject:[[[TCPIPSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[TCPIPSettingsV2 alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WirelessDirectIP alloc] init] autorelease]];
		
    }
}




- (void)enableIPInput:(BOOL)enable
{
    [ipTextField1 setEnabled:enable];
    [ipTextField2 setEnabled:enable];
    [ipTextField3 setEnabled:enable];
    [ipTextField4 setEnabled:enable];
    
    [subnetMaskTextField1 setEnabled:enable];
    [subnetMaskTextField2 setEnabled:enable];
    [subnetMaskTextField3 setEnabled:enable];
    [subnetMaskTextField4 setEnabled:enable];
    
    [gatewayTextField1 setEnabled:enable];
    [gatewayTextField2 setEnabled:enable];
    [gatewayTextField3 setEnabled:enable];
    [gatewayTextField4 setEnabled:enable];
	
	//[ip6TextField setEnabled:enable];
	//[gateway6TextField setEnabled:enable];
}


- (void)inputTextFieldResign
{
    [ipTextField1 resignFirstResponder];
    [ipTextField2 resignFirstResponder];
    [ipTextField3 resignFirstResponder];
    [ipTextField4 resignFirstResponder];
    
    [subnetMaskTextField1 resignFirstResponder];
    [subnetMaskTextField2 resignFirstResponder];
    [subnetMaskTextField3 resignFirstResponder];
    [subnetMaskTextField4 resignFirstResponder];
	
    //[self becomeFirstResponder];
	
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

- (void)showResevedDirectAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
    [alert setInformativeText:NSLocalizedString(@"IP subnet 192.168.186.x is reserved for Wi-Fi Direct.", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
	
	resevedDirect = FALSE;
    
    if([alert runModal] == NSAlertFirstButtonReturn)
    {
        [alert release];
		
    }
    else
    {
        [alert release];
    }
}


- (void)showCollisionDirectAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
    [alert setInformativeText:NSLocalizedString(@"This IP subnet can not be used in same section with Wi-Fi Direct.", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
	
	collisionDirect = FALSE;
    
    if([alert runModal] == NSAlertFirstButtonReturn)
    {
        [alert release];
		
    }
    else
    {
        [alert release];
    }
}


- (void)showBadIPAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
    [alert setInformativeText:NSLocalizedString(@"IDS_THE_SET_IP_ADDRESS_IS_ILLEGAL", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
	
	badIP	= FALSE;
    badGate	= FALSE;
    if([alert runModal] == NSAlertFirstButtonReturn)
    {
        [alert release];
		
    }
    else
    {
        [alert release];
    }
}

- (void)showBadGateAlert
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
    [alert setInformativeText:NSLocalizedString(@"IDS_THE_SET_GATEWAY_ADDRESS_IS_ILLEGAL", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
	
	badIP	= FALSE;
    badGate	= FALSE;
    
    if([alert runModal] == NSAlertFirstButtonReturn)
    {
        [alert release];
		
    }
    else
    {
        [alert release];
    }
}




- (void)restartPrinter
{
	if(isDone == FALSE)
		return;
	
	NSLog(@"[net] restartPrinter");
    [devciePropertyList removeAllObjects];    
    [devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x06 needRestart:YES] autorelease]];
    isRestarting = YES;
    [self sendInfoToDevice];
}

@end
