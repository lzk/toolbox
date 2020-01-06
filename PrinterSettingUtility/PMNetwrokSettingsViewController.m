//
//  PMNetwrokSettingsViewController.m
//  PrinterSettingUtility
//
//  Created by Wang Kun on 12/23/13.
//  Copyright (c) 2013 Wang Kun. All rights reserved.
//

#import "PMNetwrokSettingsViewController.h"
#import "DeviceProperty.h"
#import "CustomTextFieldFormatter.h"

@interface PMNetwrokSettingsViewController ()

@end

@implementation PMNetwrokSettingsViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"Network Settings", nil);
        [devciePropertyList addObject:[[[NetwrokSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WirelessSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WirelessDirectSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WifiFeatures alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WirelessDirectIP alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WifiPIN alloc] init] autorelease]];
        [self initWithNibName:@"PMNetwrokSettingsViewController" bundle:nil];
		isDone == TRUE;
		applyIndex = 0;
		
        NSLog(@"[net] size [%i]",sizeof(DEV_WIFI_DIRECT_SETTINGS));
		
    }
    
    return self;
}

- (void)dealloc
{
	[[[self view] window] makeFirstResponder:nil];
	if(wpsPINCode != nil)
		[wpsPINCode release];
	[super dealloc];
}

+ (NSString *)description
{
    return NSLocalizedString(@"Network Settings", nil);
}

- (void)awakeFromNib
{
	
	
	needDisableApply = YES;
	isApply = NO;
    ipArray = [[NSArray alloc] initWithObjects:ipFilter1AddrTextField1, ipFilter1AddrTextField2,  
			   ipFilter1AddrTextField3, ipFilter1AddrTextField4,
			   ipFilter2AddrTextField1, ipFilter2AddrTextField2,
			   ipFilter2AddrTextField3, ipFilter2AddrTextField4,
			   ipFilter3AddrTextField1, ipFilter3AddrTextField2,
			   ipFilter3AddrTextField3, ipFilter3AddrTextField4,
			   ipFilter4AddrTextField1, ipFilter4AddrTextField2,
			   ipFilter4AddrTextField3, ipFilter4AddrTextField4,
			   ipFilter5AddrTextField1, ipFilter5AddrTextField2,
			   ipFilter5AddrTextField3, ipFilter5AddrTextField4,
			   nil];
    
    subnetMaskArray = [[NSArray alloc] initWithObjects:ipFileer1SubMaskTextField1, ipFileer1SubMaskTextField2,
					   ipFileer1SubMaskTextField3, ipFileer1SubMaskTextField4,
					   ipFileer2SubMaskTextField1, ipFileer2SubMaskTextField2,
					   ipFileer2SubMaskTextField3, ipFileer2SubMaskTextField4,
					   ipFileer3SubMaskTextField1, ipFileer3SubMaskTextField2,
					   ipFileer3SubMaskTextField3, ipFileer3SubMaskTextField4,
					   ipFileer4SubMaskTextField1, ipFileer4SubMaskTextField2,
					   ipFileer4SubMaskTextField3, ipFileer4SubMaskTextField4,
					   ipFileer5SubMaskTextField1, ipFileer5SubMaskTextField2,
					   ipFileer5SubMaskTextField3, ipFileer5SubMaskTextField4,
					   nil];
    
    checkButtonArray = [[NSArray alloc] initWithObjects:lpdCheckButton, port9100CheckButton, ippCheckButton,
						wsdCheckButton, snmpCheckButton, statusCheckButton,
						internetCheckButton, bonjourCheckButton, nil];
	
	int n=0;
	for(n=0;n<[ipArray count];n++)
	{
		[[ipArray objectAtIndex:n] setDelegate:self];
		
	}
	
	for(n=0;n<[subnetMaskArray count];n++)
	{
		[[subnetMaskArray objectAtIndex:n] setDelegate:self];
		
	}
	NSFont *fnt;
	fnt = [NSFont systemFontOfSize:16] ;
	

	
#if 0
    [ethernetLabel setStringValue:NSLocalizedString(@"Ethernet", nil)];
    [ethernetComboBox addItemWithObjectValue:NSLocalizedString(@"Auto", nil)];
    [ethernetComboBox addItemWithObjectValue:NSLocalizedString(@"10BASE-T Half", nil)];
    [ethernetComboBox addItemWithObjectValue:NSLocalizedString(@"10BASE-T Full", nil)];
    [ethernetComboBox addItemWithObjectValue:NSLocalizedString(@"100BASE-T Half", nil)];
    [ethernetComboBox addItemWithObjectValue:NSLocalizedString(@"100BASE-T Full", nil)];
	
    [ethernetComboBox selectItemAtIndex:0];
    [ethernetComboBox setNumberOfVisibleItems:[ethernetComboBox numberOfItems]];
    [ethernetComboBox setEditable:NO];
    [ethernetComboBox setDelegate:self];
#endif	
	
	
	
    [protocolsBox setTitle:NSLocalizedString(@"Protocols", nil)];
	[protocolsBox setTitleFont:fnt];
    [lpdLabel setStringValue:NSLocalizedString(IDS_LPD, nil)];
    [port9100Label setStringValue:NSLocalizedString(@"Port9100", nil)];
    [ippLabel setStringValue:NSLocalizedString(@"IPP", nil)];
    [wsdLabel setStringValue:NSLocalizedString(@"WSD", nil)];
    [snmpLabel setStringValue:NSLocalizedString(@"SNMP v1/v2c", nil)];
#ifdef MACHINESETUP_XC
    [statusLabel setStringValue:NSLocalizedString(@"IDS_E-mail Alert", nil)];
#endif
#ifdef MACHINESETUP_IBG
    [statusLabel setStringValue:NSLocalizedString(@"StatusMessenger", nil)];
#endif
    [internetLabel setStringValue:NSLocalizedString(@"Internet Services", nil)];
    [bonjourLabel setStringValue:NSLocalizedString(@"Bonjour(mDNS)", nil)];






#ifdef MACHINESETUP_XC
    NSString *list = NSLocalizedString(@"Host Access List", nil);
    [ipFilter1Box setTitle:[list stringByAppendingFormat:@" %d", 1]];
    [ipFilter2Box setTitle:[list stringByAppendingFormat:@" %d", 2]];
    [ipFilter3Box setTitle:[list stringByAppendingFormat:@" %d", 3]];
    [ipFilter4Box setTitle:[list stringByAppendingFormat:@" %d", 4]];
    [ipFilter5Box setTitle:[list stringByAppendingFormat:@" %d", 5]];
#endif
#ifdef MACHINESETUP_IBG
	NSString *ipfilter = NSLocalizedString(@"IP Filter", nil);
    [ipFilter1Box setTitle:[ipfilter stringByAppendingFormat:@" %d", 1]];
    [ipFilter2Box setTitle:[ipfilter stringByAppendingFormat:@" %d", 2]];
    [ipFilter3Box setTitle:[ipfilter stringByAppendingFormat:@" %d", 3]];
    [ipFilter4Box setTitle:[ipfilter stringByAppendingFormat:@" %d", 4]];
    [ipFilter5Box setTitle:[ipfilter stringByAppendingFormat:@" %d", 5]];
#endif
	
	[ipFilter1Box setTitleFont:fnt];
	[ipFilter2Box setTitleFont:fnt];
	[ipFilter3Box setTitleFont:fnt];
	[ipFilter4Box setTitleFont:fnt];
	[ipFilter5Box setTitleFont:fnt];
	
    [ipFilter1AddressLabel setStringValue:NSLocalizedString(@"IP Address", nil)];
    [ipFilter1SubnetMaskLabel setStringValue:NSLocalizedString(IDS_SUBNET, nil)];
    [ipFilter1ModeLabel setStringValue:NSLocalizedString(@"Mode", nil)];
    [ipFilter1ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Off", nil)];
    [ipFilter1ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Accept", nil)];
    [ipFilter1ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Reject", nil)];
    [ipFilter1ModeComboBox selectItemAtIndex:0];
    [ipFilter1ModeComboBox setNumberOfVisibleItems:[ipFilter1ModeComboBox numberOfItems]];
    [ipFilter1ModeComboBox setEditable:NO];
	[ipFilter1ModeComboBox setDelegate:self];
	
	
    [ipFilter2AddressLabel setStringValue:NSLocalizedString(@"IP Address", nil)];
    [ipFilter2SubnetMaskLabel setStringValue:NSLocalizedString(IDS_SUBNET, nil)];
    [ipFilter2ModeLabel setStringValue:NSLocalizedString(@"Mode", nil)];
    [ipFilter2ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Off", nil)];
    [ipFilter2ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Accept", nil)];
    [ipFilter2ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Reject", nil)];
    [ipFilter2ModeComboBox selectItemAtIndex:0];
    [ipFilter2ModeComboBox setNumberOfVisibleItems:[ipFilter2ModeComboBox numberOfItems]];
    [ipFilter2ModeComboBox setEditable:NO];
    [ipFilter2ModeComboBox setDelegate:self];
	
	
    [ipFilter3AddressLabel setStringValue:NSLocalizedString(@"IP Address", nil)];
    [ipFilter3SubnetMaskLabel setStringValue:NSLocalizedString(IDS_SUBNET, nil)];
    [ipFilter3ModeLabel setStringValue:NSLocalizedString(@"Mode", nil)];
    [ipFilter3ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Off", nil)];
    [ipFilter3ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Accept", nil)];
    [ipFilter3ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Reject", nil)];
    [ipFilter3ModeComboBox selectItemAtIndex:0];
    [ipFilter3ModeComboBox setNumberOfVisibleItems:[ipFilter3ModeComboBox numberOfItems]];
    [ipFilter3ModeComboBox setEditable:NO];
	[ipFilter3ModeComboBox setDelegate:self];
    
    [ipFilter4AddressLabel setStringValue:NSLocalizedString(@"IP Address", nil)];
    [ipFilter4SubnetMaskLabel setStringValue:NSLocalizedString(IDS_SUBNET, nil)];
    [ipFilter4ModeLabel setStringValue:NSLocalizedString(@"Mode", nil)];
    [ipFilter4ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Off", nil)];
    [ipFilter4ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Accept", nil)];
    [ipFilter4ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Reject", nil)];
    [ipFilter4ModeComboBox selectItemAtIndex:0];
    [ipFilter4ModeComboBox setNumberOfVisibleItems:[ipFilter4ModeComboBox numberOfItems]];
    [ipFilter4ModeComboBox setEditable:NO];
    [ipFilter4ModeComboBox setDelegate:self];
	
    [ipFilter5AddressLabel setStringValue:NSLocalizedString(@"IP Address", nil)];
    [ipFilter5SubnetMaskLabel setStringValue:NSLocalizedString(IDS_SUBNET, nil)];
    [ipFilter5ModeLabel setStringValue:NSLocalizedString(@"Mode", nil)];
    [ipFilter5ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Off", nil)];
    [ipFilter5ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Accept", nil)];
    [ipFilter5ModeComboBox addItemWithObjectValue:NSLocalizedString(@"Reject", nil)];
    [ipFilter5ModeComboBox selectItemAtIndex:0];
    [ipFilter5ModeComboBox setNumberOfVisibleItems:[ipFilter5ModeComboBox numberOfItems]];
    [ipFilter5ModeComboBox setEditable:NO];
    [ipFilter5ModeComboBox setDelegate:self];
	
	
	CustomTextFieldFormatter* numberFormatter = [[CustomTextFieldFormatter alloc] init];
	[numberFormatter setNumberOnly:YES];
	[numberFormatter setMaximumLength:3];
	[numberFormatter setMaximumNumber:255];
	
	
    int i;    
    for (i = 0; i < 20; i++)
    {
		[[[ipArray objectAtIndex:i] cell] setFormatter:numberFormatter];
		[[[subnetMaskArray objectAtIndex:i] cell] setFormatter:numberFormatter];
		
        [[ipArray objectAtIndex:i] setStringValue:@"0"];
        [[subnetMaskArray objectAtIndex:i] setStringValue:@"0"];
		
    }
    [numberFormatter release];
	
	
	CustomTextFieldFormatter* ipAFormatter = [[CustomTextFieldFormatter alloc] init];
	[ipAFormatter setNumberOnly:YES];
	[ipAFormatter setMaximumLength:3];
	[ipAFormatter setIPA:YES];
	[ipAFormatter setMaximumNumber:223];
	[ipFilter1AddrTextField1 setFormatter:ipAFormatter];
	[ipFilter2AddrTextField1 setFormatter:ipAFormatter];
	[ipFilter3AddrTextField1 setFormatter:ipAFormatter];
	[ipFilter4AddrTextField1 setFormatter:ipAFormatter];
	[ipFilter5AddrTextField1 setFormatter:ipAFormatter];
	[ipAFormatter release];
	
	CustomTextFieldFormatter* ipDFormatter = [[CustomTextFieldFormatter alloc] init];
	[ipDFormatter setNumberOnly:YES];
	[ipDFormatter setMaximumLength:3];
	[ipDFormatter setMaximumNumber:254];
	
	[ipFileer1SubMaskTextField4 setFormatter:ipDFormatter];
	[ipFileer2SubMaskTextField4 setFormatter:ipDFormatter];
	[ipFileer3SubMaskTextField4 setFormatter:ipDFormatter];
	[ipFileer4SubMaskTextField4 setFormatter:ipDFormatter];
	[ipFileer5SubMaskTextField4 setFormatter:ipDFormatter];
	[ipDFormatter release];
	
    for (i = 0; i < 8; i++)
    {
        [[checkButtonArray objectAtIndex:i] setTitle:NSLocalizedString(@"Enable", nil)];
    }
    
    isShowRestartAlert = NO;
    isNeedRestart = NO;
    isRestarting = NO;
	
	//wifi sector
	
	
	[wifiBox setTitle:NSLocalizedString(@"IDS_Wi-Fi Setup", nil)];
	
	[wifiBox setTitleFont:fnt];
	
	[wifiLable setStringValue:NSLocalizedString(@"Wi-Fi", nil)];
    [wifiCheckButton setTitle:NSLocalizedString(@"Enable", nil)];
    
    [selelctModeLabel setStringValue:NSLocalizedString(@"Select Mode", nil)];
    [selectModeComboBox addItemWithObjectValue:NSLocalizedString(@"Infrastructure", nil)];
    [selectModeComboBox addItemWithObjectValue:NSLocalizedString(@"Ad-Hoc", nil)];
    [selectModeComboBox selectItemAtIndex:0];
    [selectModeComboBox setNumberOfVisibleItems:[selectModeComboBox numberOfItems]];
    [selectModeComboBox setEditable:NO];
    [selectModeComboBox setDelegate:self];
    
	
    
	CustomTextFieldFormatter* ssidFormatter = [[CustomTextFieldFormatter alloc] init];
	[ssidFormatter setNameAlpha:YES];
	[ssidFormatter setMaximumLength:32];

	
	[ssidLabel setStringValue:NSLocalizedString(@"SSID", nil)];
	[ssidTextField setDelegate:self];
	[ssidTextField setFormatter:ssidFormatter];
	
	[ssidFormatter release];
	
    [encryptionLabel setStringValue:NSLocalizedString(@"Encryption Type", nil)];
    [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
	[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"Mixed mode PSK", nil)];
	[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA2-PSK-AES", nil)];
    [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];
	// [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA-PSK-TKIP", nil)];// remove
    
	
    [encryptionComboBox selectItemAtIndex:0];
    [encryptionComboBox setNumberOfVisibleItems:[encryptionComboBox numberOfItems]];
    [encryptionComboBox setEditable:NO];
    [encryptionComboBox setDelegate:self];
    
	
	CustomTextFieldFormatter* pwdFormatter = [[CustomTextFieldFormatter alloc] init];
	[pwdFormatter setNameAlpha:YES];
	[pwdFormatter setMaximumLength:64];
	
    [passwordLabel setStringValue:NSLocalizedString(@"IDS_directPassphrase", nil)];
    [passwordCheckButton setTitle:NSLocalizedString(@"Display Characters", nil)];
	[passwordTextField setFormatter:pwdFormatter];
	[passwordPlainTextField setFormatter:pwdFormatter];
    [passwordTextField setDelegate:self];
	[passwordPlainTextField setDelegate:self];
    [pwdFormatter release];
	[passwordPlainTextField setHidden:YES];
	[passwordCheckButton setState:NSOffState];
	
    NSString *wepkey = NSLocalizedString(@"", nil);
    [transmitLabel setStringValue:NSLocalizedString(@"Transmit Key", nil)];
    //[transmitComboBox addItemWithObjectValue:NSLocalizedString(@"Auto", nil)];
    [transmitComboBox addItemWithObjectValue:[wepkey stringByAppendingFormat:@"%d",1]];
    [transmitComboBox addItemWithObjectValue:[wepkey stringByAppendingFormat:@"%d",2]];
    [transmitComboBox addItemWithObjectValue:[wepkey stringByAppendingFormat:@"%d",3]];
    [transmitComboBox addItemWithObjectValue:[wepkey stringByAppendingFormat:@"%d",4]];
    [transmitComboBox selectItemAtIndex:0];
    [transmitComboBox setNumberOfVisibleItems:[transmitComboBox numberOfItems]];
    [transmitComboBox setEditable:NO];
    [transmitComboBox setDelegate:self];
    
	
	isShowRestartAlert = NO;
    isNeedRestart = NO;
    isRestarting = NO;
    ssidWrong = NO;
    passwordWrong = NO;
	//WPS sector
	
	[wpsBox setTitle:NSLocalizedString(@"IDS_directWPSSetup", nil)];
	[wpsBox setTitleFont:fnt];
	
	[wpsSetupLabel setStringValue:NSLocalizedString(@"IDS_directWPSSetup", nil)];
	[wpsSetupComboBox addItemWithObjectValue:NSLocalizedString(@"IDS_Push Button Control", nil)];
	[wpsSetupComboBox addItemWithObjectValue:NSLocalizedString(@"IDS_directPINCode", nil)];
	[wpsSetupComboBox selectItemAtIndex:0];
	[wpsSetupComboBox setEditable:NO];
	[wpsSetupComboBox setDelegate:self];
	
	
	[wpsPINCodeLable setStringValue:NSLocalizedString(@"IDS_directPINCode", nil)];
	[wpsPINCodeTextField setEditable:NO];
	[wpsPINCodeTextField setEnabled:NO];
	[wpsPINCodeTextField setDelegate:self]; //read only
	
	//[wpsPrintPINLabel setStringValue:NSLocalizedString(@"IDS_Print PIN Code", nil)];
	[wpsPrintPINButton setTitle:NSLocalizedString(@"IDS_Print PIN Code", nil)];
	[wpsPrintPINButton setEnabled:NO];
	//wifi direct sector
	
	[directBox setTitle:NSLocalizedString(@"Wi-Fi Direct Setup", nil)];
	
	[directBox setTitleFont:fnt];
	
	
    [directSetupLabel setStringValue:NSLocalizedString(@"Wi-Fi Direct", nil)];
    [directSetupCheckButton setTitle:NSLocalizedString(@"Enable", nil)];
	
	[directGroupRoleLabel setStringValue:NSLocalizedString(@"IDS_Group Role", nil)];
	[directGroupRoleComboBox addItemWithObjectValue:NSLocalizedString(@"Auto", nil)];
	[directGroupRoleComboBox addItemWithObjectValue:NSLocalizedString(@"IDS_Group Owner", nil)];
	[directGroupRoleComboBox selectItemAtIndex:0];
	[directGroupRoleComboBox setEditable:NO];
	[directGroupRoleComboBox setDelegate:self];
	
	[directDeviceNameLable setStringValue:NSLocalizedString(@"IDS_directDevice", nil)];
	[directDeviceTextField setEnabled:NO];
	[directDeviceTextField setDelegate:self]; //read only
	
	
	
	[directWPSMethodLabel setStringValue:NSLocalizedString(@"IDS_directWPSSetup", nil)];
	[directWPSMethodComboBox addItemWithObjectValue:NSLocalizedString(@"IDS_Push Button Control", nil)];
	[directWPSMethodComboBox addItemWithObjectValue:NSLocalizedString(@"IDS_directPINCode", nil)];
	[directWPSMethodComboBox selectItemAtIndex:0];
	[directWPSMethodComboBox setDelegate:self];
	
	
	[directPINCodeLable setStringValue:NSLocalizedString(@"IDS_directPINCode", nil)];
	[directPINCodeTextField setEditable:NO];
	[directPINCodeTextField setDelegate:self]; //read only
	
	[directPrintPINCodeLabel setStringValue:NSLocalizedString(@"IDS_Print PIN Code", nil)];
	[directPrintPINCodeButton setTitle:NSLocalizedString(@"IDS_PRINT", nil)];
	
	[directResetCodeLabel setStringValue:NSLocalizedString(@"IDS_Reset Code", nil)];
	[directResetCodeButton setTitle:NSLocalizedString(@"IDS_WIRELESS_RESET", nil)];
	
	
	
	
	[directP2PRoleLabel setStringValue:NSLocalizedString(@"IDS_directP2PRole", nil)];
	[directP2PRoleComboBox addItemWithObjectValue:NSLocalizedString(@"Disable", nil)];
	[directP2PRoleComboBox addItemWithObjectValue:NSLocalizedString(@"IDS_Idle", nil)];
	[directP2PRoleComboBox addItemWithObjectValue:NSLocalizedString(@"IDS_Client", nil)];
	[directP2PRoleComboBox addItemWithObjectValue:NSLocalizedString(@"IDS_Group Owner", nil)];
	[directP2PRoleComboBox addItemWithObjectValue:NSLocalizedString(@"-", nil)];
	[directP2PRoleComboBox selectItemAtIndex:1];
	[directP2PRoleComboBox setEditable:NO];
	[directP2PRoleComboBox setDelegate:self];
	
	[directConnectionStatusLabel setStringValue:NSLocalizedString(@"IDS_Connection Status", nil)];
	[directConnectionStatusTextField setEditable:NO];
	[directConnectionStatusTextField setDelegate:self]; //read only
	
	[directDisconnectNowLabel setStringValue:NSLocalizedString(@"IDS_Disconnect Now", nil)];
	[directDisconnectNowButton setTitle:NSLocalizedString(@"Start", nil)];
	
	[directDisconnectResetPassphraseLabel setStringValue:NSLocalizedString(@"IDS_Disconnect and Reset Passphrase", nil)];
	[directDisconnectResetPassphraseButton setTitle:NSLocalizedString(@"Start", nil)];
	
	[directGroupOwnerLabel setStringValue:NSLocalizedString(@"IDS_Group Owner", nil)];
	//[directGroupOwnerTextField setEditable:NO];
	//[directGroupOwnerTextField setDelegate:self];
	[directGroupOwnerLabel setFont:fnt];
	
	
	CustomTextFieldFormatter* wirelessSSIDFormatter = [[CustomTextFieldFormatter alloc] init];
	[wirelessSSIDFormatter setNameAlpha:YES];
	[wirelessSSIDFormatter setMaximumLength:23];
	
	[directsSSIDLable setStringValue:NSLocalizedString(@"SSID", nil)];
	[directsSSIDTextField setDelegate:self];
	[directsSSIDTextField setFormatter:wirelessSSIDFormatter];
	[wirelessSSIDFormatter release];
	
	
	
	
	
	[directPassphraseLable setStringValue:NSLocalizedString(@"IDS_directPassphrase", nil)];
	[directPassphraseTextField setEditable:NO];
	[directPassphraseTextField setDelegate:self]; //read only
	
	
	[directPrintPassphraseLabel setStringValue:NSLocalizedString(@"IDS_Print Passphrase", nil)];
	[directPrintPassphraseButton setTitle:NSLocalizedString(@"IDS_PRINT", nil)];
	
	
	[directResetPassphraseLabel setStringValue:NSLocalizedString(@"IDS_Reset Passphrase", nil)];
	[directResetPassphraseButton setTitle:NSLocalizedString(@"IDS_WIRELESS_RESET", nil)];
	
	[directsIPAddressLable setStringValue:NSLocalizedString(@"IP Address", nil)];
	[directsIPAddressTextField setEditable:NO];
	[directsIPAddressTextField setDelegate:self]; //read only
	
	[directsSubnetMaskLable setStringValue:NSLocalizedString(IDS_SUBNET, nil)];
	[directsSubnetMaskTextField setEditable:NO];
	[directsSubnetMaskTextField setDelegate:self]; //read only
	
	
	
#if 0	
	[directDhcpsDevList2NameLable setStringValue:NSLocalizedString(@"IDS_directDhcpsDevList2", nil)];
	[directDhcpsDevList2TextField setEditable:NO];
	[directDhcpsDevList2TextField setDelegate:self]; //read only
	
	[directDhcpsDevList3NameLable setStringValue:NSLocalizedString(@"IDS_directDhcpsDevList3", nil)];
	[directDhcpsDevList3TextField setEditable:NO];
	[directDhcpsDevList3TextField setDelegate:self]; //read only
	
	[directDhcpsDevList4NameLable setStringValue:NSLocalizedString(@"IDS_directDhcpsDevList4", nil)];
	[directDhcpsDevList4TextField setEditable:NO];
	[directDhcpsDevList4TextField setDelegate:self]; //read only
#endif
	
	
	[directPassphraseTextField setEnabled:NO];
	[directDeviceTextField setEnabled:NO];
	[directP2PRoleComboBox setEnabled:NO];
	[directGroupRoleComboBox setEnabled:NO];
	[directPINCodeTextField setEnabled:NO];
	[directWPSMethodComboBox setEditable:NO];
	
	[WifiResetLable setStringValue:NSLocalizedString(@"IDS_Reset Wireless", nil)];
	[applyWifiResetButton setTitle:NSLocalizedString(@"IDS_WIRELESS_RESET", nil)];
	[applyButton1 setTitle:NSLocalizedString(@"Apply New Settings", nil)];
    [applyButton2 setTitle:NSLocalizedString(@"Restart printer to apply new settings", nil)];
  	[applyButton3 setTitle:NSLocalizedString(@"Apply New Settings", nil)];
    [applyButton4 setTitle:NSLocalizedString(@"Restart printer to apply new settings", nil)];
	[applyButton5 setTitle:NSLocalizedString(@"Apply New Settings", nil)];
    [applyButton6 setTitle:NSLocalizedString(@"Restart printer to apply new settings", nil)];
	[applyButton7 setTitle:NSLocalizedString(@"IDS_Start Configuration", nil)];
	[applyNetworkResetButton setTitle:NSLocalizedString(@"IDS_Reset Network Setup", nil)];
	
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
	//isNotReflesh = NO;
	
	
	if(![applyButton1 isEnabled] && ![applyButton2 isEnabled] && ![applyButton3 isEnabled] && ![applyButton4 isEnabled] && ![applyButton5 isEnabled] && ![applyButton6 isEnabled] && ![applyButton7 isEnabled])
		isChanged = NO;
	
	if(isApply)
	{
		
		[super UpdatePrinterPropertyToView:directionWithResult];
		
		NSNumber *result = [directionWithResult objectAtIndex:1];
		if([result intValue] != DEV_ERROR_SUCCESS)
		{
			[[scrollView verticalScroller] setEnabled:YES];
			
			return;
		}
		switch (applyIndex) {
			case 1:
			case 2:
				[applyButton1 setEnabled:NO];
				[applyButton2 setEnabled:NO];
				break;
			case 3:
			case 4:
				[applyButton4 setEnabled:NO];
				[applyButton3 setEnabled:NO];
				break;
			case 5:
			case 6:
				[applyButton6 setEnabled:NO];
				[applyButton5 setEnabled:NO];
				break;
			case 7:
				[applyButton7 setEnabled:NO];
			default:
				break;
		}
		
		if(![applyButton1 isEnabled] && ![applyButton2 isEnabled] && ![applyButton3 isEnabled] && ![applyButton4 isEnabled] && ![applyButton5 isEnabled] && ![applyButton6 isEnabled] && ![applyButton7 isEnabled])
			isChanged = NO;
		
		isApply = NO;
		
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
	if (isRestarting)
	{
		isRestarting = NO;
	}
	else{
		
		isDone = FALSE;
		int i;
		for (i = 0; i < [devciePropertyList count]; i++)
		{
			DeviceCommond *data = [devciePropertyList objectAtIndex:i];
			//	DEV_WIFI_DIRECT_SETTINGS *tmp = [data deviceData];
			//tmp = [data deviceData];
			
			[self updateView:[data deviceData] index:i cmdID:[data IDCode]];
			
		}
		
		
		if(needDisableApply)
		{
		[applyButton1 setEnabled:NO];
		[applyButton2 setEnabled:NO];
		[applyButton3 setEnabled:NO];
		[applyButton4 setEnabled:NO];
		[applyButton5 setEnabled:NO];
		[applyButton6 setEnabled:NO];
		[applyButton7 setEnabled:NO];
			needDisableApply = NO;
		}
		isDone = TRUE;
		
		
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
		
		
		
	}
	
	[directPassphraseTextField setEnabled:NO];
	[directDeviceTextField setEnabled:NO];
	[directP2PRoleComboBox setEnabled:NO];
	//[directGroupRoleComboBox setEnabled:NO];
	[directPINCodeTextField setEnabled:NO];
	
	[directConnectionStatusTextField setEnabled:NO];
#if 0
	[directDhcpsDevList2TextField setEnabled:NO];
	[directDhcpsDevList3TextField setEnabled:NO];
	[directDhcpsDevList4TextField setEnabled:NO];
#endif
	[directWPSMethodComboBox setEditable:NO];
	
	
	
	
}

- (void)updateView:(id)data index:(int)index cmdID:(int)aID
{
	
	if(aID == DEV_CMD_CODE_ID_GET_NETWORK_SETTINGS)
		index= 0;
	else if(aID == DEV_CMD_CODE_ID_GET_WIRELESS_SETTINGS)
		index= 1;
	else if(aID == DEV_CMD_CODE_ID_GET_WIRELESSDIRECT_SETTINGS)
		index=2;
	else if(aID == DEV_CMD_CODE_ID_GET_WIFI_FEATURES_SETTINGS)
		index=3;
	else if(aID == DEV_CMD_CODE_ID_GET_WIRELESSDIRECT_IP_SETTINGS)
		index=4;
	else if(aID == DEV_CMD_CODE_ID_GET_WIFI_PIN)
		index=5;

	else 
		return;
	
	
	switch (index) {
		case 0:
			if (isRestarting)
			{
				isRestarting = NO;
			}
			else
			{
				
				DEV_NETWROK_SETTINGS *devData = (DEV_NETWROK_SETTINGS *)data;
				//[ethernetComboBox selectItemAtIndex:devData->u8ConnectSpeed];
				
				[lpdCheckButton setState:devData->u8Protocol_LPD];
				[port9100CheckButton setState:devData->u8Protocol_Port9100];
				[ippCheckButton setState:devData->u8Protocol_IPP];
				[wsdCheckButton setState:devData->u8Protocol_WSD_PRINT];
				[snmpCheckButton setState:devData->u8Protocol_SNMP];
				[statusCheckButton setState:devData->u8Protocol_EAMIL_ALERT];
				[internetCheckButton setState:devData->u8Protocol_CentreWare_IS];
				[bonjourCheckButton setState:devData->u8Protocol_Bonjour];
				
				int i;
				for (i = 0; i < 4; i++)
				{
					[[ipArray objectAtIndex:i] setStringValue:[NSString stringWithFormat:@"%d", devData->u8IPFilter1_Address[i]]];
					[[ipArray objectAtIndex:i+4] setStringValue:[NSString stringWithFormat:@"%d", devData->u8IPFilter2_Address[i]]];
					[[ipArray objectAtIndex:i+8] setStringValue:[NSString stringWithFormat:@"%d", devData->u8IPFilter3_Address[i]]];
					[[ipArray objectAtIndex:i+12] setStringValue:[NSString stringWithFormat:@"%d", devData->u8IPFilter4_Address[i]]];
					[[ipArray objectAtIndex:i+16] setStringValue:[NSString stringWithFormat:@"%d", devData->u8IPFilter5_Address[i]]];
					
					[[subnetMaskArray objectAtIndex:i] setStringValue:[NSString stringWithFormat:@"%d", devData->u8IPFilter1_SubnetMask[i]]];
					[[subnetMaskArray objectAtIndex:i+4] setStringValue:[NSString stringWithFormat:@"%d", devData->u8IPFilter2_SubnetMask[i]]];
					[[subnetMaskArray objectAtIndex:i+8] setStringValue:[NSString stringWithFormat:@"%d", devData->u8IPFilter3_SubnetMask[i]]];
					[[subnetMaskArray objectAtIndex:i+12] setStringValue:[NSString stringWithFormat:@"%d", devData->u8IPFilter4_SubnetMask[i]]];
					[[subnetMaskArray objectAtIndex:i+16] setStringValue:[NSString stringWithFormat:@"%d", devData->u8IPFilter5_SubnetMask[i]]];
				}
				
				[ipFilter1ModeComboBox selectItemAtIndex:devData->u8IPFilter1_Mode];
				[ipFilter2ModeComboBox selectItemAtIndex:devData->u8IPFilter2_Mode];
				[ipFilter3ModeComboBox selectItemAtIndex:devData->u8IPFilter3_Mode];
				[ipFilter4ModeComboBox selectItemAtIndex:devData->u8IPFilter4_Mode];
				[ipFilter5ModeComboBox selectItemAtIndex:devData->u8IPFilter5_Mode];
			}
			
			break;
		case 1:
			if (isRestarting)
			{
				isRestarting = NO;
			}
			else
			{
				DEV_WIRELESS_SETTINGS * devData1 = (DEV_WIRELESS_SETTINGS *)data;
				
				
				[selectModeComboBox selectItemAtIndex:devData1->cNetWorkType];
				if([selectModeComboBox indexOfSelectedItem] == 0 )
				{
					
					[directSetupCheckButton setEnabled:YES];
					[encryptionComboBox setDelegate:nil];
					[encryptionComboBox removeAllItems];
					[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
					[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"Mixed mode PSK", nil)];
					//[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA-PSK-TKIP", nil)];// remove
					[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA2-PSK-AES", nil)];
					[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];
					[encryptionComboBox selectItemAtIndex:0];
					[encryptionComboBox setNumberOfVisibleItems:[encryptionComboBox numberOfItems]];
					[encryptionComboBox setEditable:NO];
					
					[encryptionComboBox setDelegate:self];
					
				}
				else if([selectModeComboBox indexOfSelectedItem] == 1)
				{  
					[directSetupCheckButton setEnabled:NO];
					[directSetupCheckButton setState:NSOffState];
					[encryptionComboBox setDelegate:nil];
					[encryptionComboBox removeAllItems];
					[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
					[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];
					[encryptionComboBox selectItemAtIndex:0];
					[encryptionComboBox setNumberOfVisibleItems:[encryptionComboBox numberOfItems]];
					[encryptionComboBox setEditable:NO];
					
					[encryptionComboBox setDelegate:self];
				}
				
				
				
				[ssidTextField setStringValue:[NSString stringWithCString:devData1->cSSID encoding:NSASCIIStringEncoding]];
				
				if(devData1->cNetWorkType == 0)
				{
					if ((devData1->cAuthMode == 0) && (devData1->cEncryptType == 0))
					{
						[encryptionComboBox selectItemAtIndex:0];
					}
					
					else if ((devData1->cAuthMode == 1) && (devData1->cEncryptType == 3))
					{
						[encryptionComboBox selectItemAtIndex:3];
					}
					
					else if ((devData1->cAuthMode == 8) && (devData1->cEncryptType == 8))
					{
						[encryptionComboBox selectItemAtIndex:2];
					}
					
#if 1
					else if ((devData1->cAuthMode == 12) && (devData1->cEncryptType == 12))
					{
						[encryptionComboBox selectItemAtIndex:1];
					}
					
#endif
					
					
					if ([encryptionComboBox indexOfSelectedItem] == 0)
					{
						[transmitComboBox selectItemAtIndex:0];
						[transmitComboBox setEnabled:NO];
						[passwordTextField setEnabled:NO];
						[passwordPlainTextField setEnabled:NO];
						[passwordCheckButton setEnabled:NO];
					}
					else if ([encryptionComboBox indexOfSelectedItem] == 3)
					{
						[transmitComboBox setEnabled:YES];
						[passwordTextField setEnabled:YES];
						[passwordPlainTextField setEnabled:YES];
						[passwordCheckButton setEnabled:YES];
					}
					else
					{
						[transmitComboBox selectItemAtIndex:0];
						[transmitComboBox setEnabled:NO];
						[passwordTextField setEnabled:YES];
						[passwordPlainTextField setEnabled:YES];
						[passwordCheckButton setEnabled:YES];
					}
					
					
				}
				else {
					if ((devData1->cAuthMode == 0) && (devData1->cEncryptType == 0))
					{
						[encryptionComboBox selectItemAtIndex:0];
					}
					
					else if ((devData1->cAuthMode == 1) && (devData1->cEncryptType == 3))
					{
						[encryptionComboBox selectItemAtIndex:1];
					}
					
					
					if ([encryptionComboBox indexOfSelectedItem] == 0)
					{
						[transmitComboBox selectItemAtIndex:0];
						[transmitComboBox setEnabled:NO];
						[passwordTextField setEnabled:NO];
						[passwordPlainTextField setEnabled:NO];
						[passwordCheckButton setEnabled:NO];
					}
					else if ([encryptionComboBox indexOfSelectedItem] == 1)
					{
						[transmitComboBox setEnabled:YES];
						[passwordTextField setEnabled:YES];
						[passwordPlainTextField setEnabled:YES];
						[passwordCheckButton setEnabled:YES];
					}
					else
					{
						[transmitComboBox selectItemAtIndex:0];
						[transmitComboBox setEnabled:NO];
						[passwordTextField setEnabled:YES];
						[passwordPlainTextField setEnabled:YES];
						[passwordCheckButton setEnabled:YES];
					}
					
				}
				
				
				int k=0;
				for (k=0;k<4;k++)
					strcpy(cWEPKey[k],(char *)devData1->cWEPKey[k]);
				
				
				
				
				
				[transmitComboBox selectItemAtIndex:(devData1->cDefaultKeyld) - 1];
				
				
				/*if (devData1->cNetWorkType == 0)
				 {
				 [encryptionComboBox removeAllItems];
				 [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
				 [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];            
				 }
				 else if (devData1->cNetWorkType == 1)
				 {
				 [encryptionComboBox removeAllItems];
				 [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
				 [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];
				 [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA-PSK-TKIP", nil)];
				 [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA2-PSK-AES", nil)];
				 [encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"Mixed mode PSK", nil)];
				 }
				 [encryptionComboBox setNumberOfVisibleItems:[encryptionComboBox numberOfItems]];
				 [encryptionComboBox selectItemAtIndex:1->cNetWorkType];*/
				
			}
			//wifi sector
			
			
			break;
		case 2:
			if (isRestarting)
			{
				isRestarting = NO;
			}
			else
			{
				DEV_WIFI_DIRECT_SETTINGS * devData2 = (DEV_WIFI_DIRECT_SETTINGS *)data;
				prefixSSID = [[NSString stringWithCString:devData2->cSSID encoding:NSASCIIStringEncoding] substringWithRange:NSMakeRange(0, 9)];
				[directsSSIDPrefixLable setStringValue:prefixSSID];
				
				[directsSSIDTextField setStringValue:[[[NSString stringWithCString:devData2->cSSID encoding:NSASCIIStringEncoding] componentsSeparatedByString:prefixSSID] lastObject]];
				[directPassphraseTextField setStringValue:[NSString stringWithCString:devData2->cPassphrase encoding:NSASCIIStringEncoding]];
				[directDeviceTextField setStringValue:[NSString stringWithCString:devData2->cDeviceName encoding:NSASCIIStringEncoding]];
				
				
				[directGroupRoleComboBox selectItemAtIndex:devData2->cP2PGOEnable];
				
				
				[directP2PRoleComboBox selectItemAtIndex:devData2->cP2PRole];
				[directWPSMethodComboBox selectItemAtIndex:devData2->cWPSMethod];
				if(devData2->cWPSMethod == 1){
					[directPINCodeTextField setStringValue:[NSString stringWithCString:devData2->cPINCode encoding:NSASCIIStringEncoding]];
					[directPrintPINCodeButton setEnabled:YES];
					[directResetCodeButton setEnabled:YES];
					
				}
				else {
					[directPINCodeTextField setStringValue:@""];
					[directPrintPINCodeButton setEnabled:NO];
					[directResetCodeButton setEnabled:NO];
				}
				
				if([[NSString stringWithCString:devData2->cDhcpsDevList[0] encoding:NSASCIIStringEncoding] length] == 0 || devData2->cP2PEnable == 0)
				{
					[directConnectionStatusTextField setStringValue:@"-"];
					[directDisconnectNowButton setEnabled:NO];
					[directDisconnectResetPassphraseButton setEnabled:NO];
					
				}
				else {
					[directConnectionStatusTextField setStringValue:[NSString stringWithCString:devData2->cDhcpsDevList[0] encoding:NSASCIIStringEncoding]];
					[directDisconnectNowButton setEnabled:YES];
					[directDisconnectResetPassphraseButton setEnabled:YES];
				}
				
				
#if 0
				[directDhcpsDevList2TextField setStringValue:[NSString stringWithCString:devData2->cDhcpsDevList[1] encoding:NSASCIIStringEncoding]];
				[directDhcpsDevList3TextField setStringValue:[NSString stringWithCString:devData2->cDhcpsDevList[2] encoding:NSASCIIStringEncoding]];
				[directDhcpsDevList4TextField setStringValue:[NSString stringWithCString:devData2->cDhcpsDevList[3] encoding:NSASCIIStringEncoding]];
#endif
			}
			
			
			
			break;
		case 3:
			if (isRestarting)
			{
				isRestarting = NO;
			}
			else
			{
				DEV_WIFI_FEATURES * devData3 = (DEV_WIFI_FEATURES *)data;
				switch (devData3->WiFi) {
					case 0:
						[wifiCheckButton setState:NSOffState];
						//[wifiCheckButton setEnabled:NO];
						[selectModeComboBox setEnabled:NO];
						[ssidTextField setEnabled:NO];
						[encryptionComboBox setEnabled:NO];
						[passwordTextField setEnabled:NO];
						[passwordPlainTextField setEnabled:NO];
						[passwordCheckButton setEnabled:NO];
						[directSetupCheckButton setEnabled:NO];
						
						//[transmitComboBox setEnabled:NO];
						break;
					case 1:
						[wifiCheckButton setState:NSOnState];
						
						//[wifiCheckButton setEnabled:YES];
						[selectModeComboBox setEnabled:YES];
						[ssidTextField setEnabled:YES];
						[encryptionComboBox setEnabled:YES];
						//[passwordTextField setEnabled:YES];
						//[passwordPlainTextField setEnabled:YES];
						//[passwordCheckButton setEnabled:YES];
						//[transmitComboBox setEnabled:YES];
						break;
					default:
						break;
				}
				NSLog(@"devData3->WiFi_Direct [%i]",devData3->WiFi_Direct);
				switch (devData3->WiFi_Direct) {
					case 0:
						[directSetupCheckButton setState:NSOffState];
						[directP2PRoleComboBox selectItemAtIndex:4];
						[directPassphraseTextField setEnabled:NO];
						[directDeviceTextField setEnabled:NO];
						[directP2PRoleComboBox setEnabled:NO];
						[directPINCodeTextField setEnabled:NO];
						[directGroupRoleComboBox setEnabled:NO];
						[directConnectionStatusTextField setEnabled:NO];
#if 0
						[directDhcpsDevList2TextField setEnabled:NO];
						[directDhcpsDevList3TextField setEnabled:NO];
						[directDhcpsDevList4TextField setEnabled:NO];
#endif
						[directWPSMethodComboBox setEnabled:NO];
						[directsSSIDTextField setEnabled:NO];
						
						//[directP2PEnableCheckButton setEnabled:NO];
						//[directP2PGOEnableCheckButton setEnabled:NO];
						
						
						[directWPSMethodComboBox setEditable:NO];
						
						break;
					case 1:
						[directSetupCheckButton setState:NSOnState];
						
						[directPassphraseTextField setEnabled:YES];
						[directDeviceTextField setEnabled:YES];
						[directP2PRoleComboBox setEnabled:YES];
						[directPINCodeTextField setEnabled:YES];
						[directGroupRoleComboBox setEnabled:YES];
						[directConnectionStatusTextField setEnabled:YES];
#if 0
						[directDhcpsDevList2TextField setEnabled:YES];
						[directDhcpsDevList3TextField setEnabled:YES];
						[directDhcpsDevList4TextField setEnabled:YES];
#endif
						[directWPSMethodComboBox setEnabled:YES];
						[directsSSIDTextField setEnabled:YES];
						
						//[directP2PEnableCheckButton setEnabled:YES];
						//[directP2PGOEnableCheckButton setEnabled:YES];
						
						[directWPSMethodComboBox setEditable:YES];
						
						break;
					default:
						break;
				}
				
			}
			
			break;
		case 4:
		{
			DEV_WIFI_P2P_IP * devData4 = (DEV_WIFI_P2P_IP *)data;
			
			// NSString *ipaddr = NSLocalizedString(@"", nil);
			[directsIPAddressTextField setStringValue:[NSString stringWithFormat:@"%d.%d.%d.%d", devData4->u8P2P_Address[0],devData4->u8P2P_Address[1],devData4->u8P2P_Address[2],devData4->u8P2P_Address[3]]];
			[directsSubnetMaskTextField setStringValue:[NSString stringWithFormat:@"%d.%d.%d.%d", devData4->u8P2P_SubnetMask[0],devData4->u8P2P_SubnetMask[1],devData4->u8P2P_SubnetMask[2],devData4->u8P2P_SubnetMask[3]]];
			
		}
			break;
		case 5:
		{
			DEV_WIFI_PIN * devData5 = (DEV_WIFI_PIN *)data;
			
			if(wpsPINCode != nil)
			{
				[wpsPINCode release];
				wpsPINCode = nil;
			}
			
			
			wpsPINCode = [[NSString stringWithCString:devData5->PINCode encoding:NSASCIIStringEncoding] copy];

			[wpsPrintPINButton setEnabled:NO];
			
		}
			break;
		default:
			return;
	}
	
	
	
	
    
	
	
	
}


- (IBAction)directSetupButtonAction:(id)sender
{
	if ([directSetupCheckButton state] == NSOffState)
	{
		[directsSSIDTextField setEnabled:NO];
		
		//[directP2PEnableCheckButton setEnabled:NO];
		//[directP2PEnableCheckButton setState:NSOffState];
		//[directP2PGOEnableCheckButton setEnabled:NO];
		[directWPSMethodComboBox setEnabled:NO];
	}
	else
	{
		[directsSSIDTextField setEnabled:YES];
		
		//	[directP2PEnableCheckButton setEnabled:YES];
		//	[directP2PGOEnableCheckButton setEnabled:YES];
		[directWPSMethodComboBox setEnabled:YES];
	}
}
- (IBAction)applyButtonAction:(id)sender
{
	isNotReflesh = YES;
	[[[self view] window] makeFirstResponder:nil];
	
    int i;
	DeviceCommond *aCommond;
	DEV_NETWROK_SETTINGS settings;
	DEV_WIRELESS_SETTINGS settings1;
	DEV_WIFI_DIRECT_SETTINGS settings2;
	DEV_WIFI_FEATURES settings3;
	
	if (sender == applyButton1) {
		[devciePropertyList removeAllObjects];
		[devciePropertyList addObject:[[[NetwrokSettings alloc] init] autorelease]];
		i = 0;
		applyIndex = 1;
	}
	else if (sender == applyButton3)
	{
		[devciePropertyList removeAllObjects];
		[devciePropertyList addObject:[[[WirelessSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WifiFeatures alloc] init] autorelease]];
		
		i=1;
		applyIndex = 3;
	}
	else if (sender == applyButton5)
	{
		[devciePropertyList removeAllObjects];
		[devciePropertyList addObject:[[[WirelessDirectSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WifiFeatures alloc] init] autorelease]];
		i=2;
		applyIndex = 5;
	}

	else {
		return;
	}
	
	
	
	switch (i) {
		case 0:
			aCommond = [devciePropertyList objectAtIndex:0];
			
			[self getDataFormView:&settings index:i];
			[aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_NETWROK_SETTINGS)];
			break;
		case 1:
			[passwordTextField resignFirstResponder];
			
			//[devciePropertyList removeAllObjects];
			//[devciePropertyList addObject:[[WirelessSettings alloc] init]];
			aCommond = [devciePropertyList objectAtIndex:0];
			
			
			
			[self getDataFormView:&settings1 index:i];
			if (ssidWrong)
			{
				[self showSsidWrongAlert];
				return;
			}
			if (passwordWrong)
			{
				[self showPasswordWrongAlert];
				return;
			}
			[aCommond setDeviceData:(void *)&settings1 dataSize:sizeof(DEV_WIRELESS_SETTINGS)];
			
			aCommond = [devciePropertyList objectAtIndex:1];
			settings3.WiFi=[wifiCheckButton state];
			settings3.WiFi_Direct=[directSetupCheckButton state];
			[aCommond setDeviceData:(void *)&settings3 dataSize:sizeof(DEV_WIFI_FEATURES)];
			break;
			
		case 2:
			aCommond = [devciePropertyList objectAtIndex:0];
			[self getDataFormView:&settings2 index:i];
			if (ssidWrong)
			{
				[self showSsidWrongAlert];
				return;
			}
			if (passwordWrong)
			{
				[self showPasswordWrongAlert];
				return;
			}
			[aCommond setDeviceData:(void *)&settings2 dataSize:sizeof(DEV_WIFI_DIRECT_SETTINGS)];
			aCommond = [devciePropertyList objectAtIndex:1];
			settings3.WiFi=[wifiCheckButton state];
			settings3.WiFi_Direct=[directSetupCheckButton state];
			[aCommond setDeviceData:(void *)&settings3 dataSize:sizeof(DEV_WIFI_FEATURES)];
			break;
		default:
			break;
	}
	
	
    
	isShowRestartAlert = YES;
	[self setInfoToDevice];
	//isChanged = NO;
	isApply = YES;
	
}

- (IBAction)restartButtonAction:(id)sender
{
	isNotReflesh = YES;
	[[[self view] window] makeFirstResponder:nil];
    int i;
	DeviceCommond *aCommond;
	DEV_NETWROK_SETTINGS settings;
	DEV_WIRELESS_SETTINGS settings1;
	DEV_WIFI_DIRECT_SETTINGS settings2;
	DEV_WIFI_FEATURES settings3;
	
	if (sender == applyButton2) {
		[devciePropertyList removeAllObjects];
		[devciePropertyList addObject:[[[NetwrokSettings alloc] init] autorelease]];
		i = 0;
		applyIndex = 2;
	}
	else if (sender == applyButton4)
	{
		[devciePropertyList removeAllObjects];
		[devciePropertyList addObject:[[[WirelessSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WifiFeatures alloc] init] autorelease]];
		
		i=1;
		applyIndex = 4;
	}
	else if (sender == applyButton6)
	{
		[devciePropertyList removeAllObjects];
		[devciePropertyList addObject:[[[WirelessDirectSettings alloc] init] autorelease]];
		[devciePropertyList addObject:[[[WifiFeatures alloc] init] autorelease]];
		i=2;
		applyIndex = 6;
	}
	else {
		return;
	}
	
	
	
	switch (i) {
		case 0:
			aCommond = [devciePropertyList objectAtIndex:0];
			
			[self getDataFormView:&settings index:i];
			[aCommond setDeviceData:(void*)&settings dataSize:sizeof(DEV_NETWROK_SETTINGS)];
			
			break;
		case 1:
			//[devciePropertyList removeAllObjects];
			//[devciePropertyList addObject:[[WirelessSettings alloc] init]];
			aCommond = [devciePropertyList objectAtIndex:0];
			
			[self getDataFormView:&settings1 index:i];
			if (ssidWrong)
			{
				[self showSsidWrongAlert];
				return;
			}
			if (passwordWrong)
			{
				[self showPasswordWrongAlert];
				return;
			}
			[aCommond setDeviceData:(void *)&settings1 dataSize:sizeof(DEV_WIRELESS_SETTINGS)];
			aCommond = [devciePropertyList objectAtIndex:1];
			settings3.WiFi=[wifiCheckButton state];
			settings3.WiFi_Direct=[directSetupCheckButton state];
			[aCommond setDeviceData:(void *)&settings3 dataSize:sizeof(DEV_WIFI_FEATURES)];
			break;
		case 2:
			aCommond = [devciePropertyList objectAtIndex:0];
			[self getDataFormView:&settings2 index:i];
			if (ssidWrong)
			{
				[self showSsidWrongAlert];
				return;
			}
			if (passwordWrong)
			{
				[self showPasswordWrongAlert];
				return;
			}
			[aCommond setDeviceData:(void *)&settings2 dataSize:sizeof(DEV_WIFI_DIRECT_SETTINGS)];
			aCommond = [devciePropertyList objectAtIndex:1];
			settings3.WiFi=[wifiCheckButton state];
			settings3.WiFi_Direct=[directSetupCheckButton state];
			[aCommond setDeviceData:(void *)&settings3 dataSize:sizeof(DEV_WIFI_FEATURES)];
			break;
		default:
			break;
	}
	
	
	
	isNeedRestart = YES;
	[self setInfoToDevice];
	//isChanged = NO;
	isApply = YES;
}

- (void)getDataFormView:(void *)addr index:(int)index
{
	DEV_NETWROK_SETTINGS data;
	DEV_WIRELESS_SETTINGS data1;
	DEV_WIFI_DIRECT_SETTINGS data2;

	
	switch (index) {
		case 0:
			
			memset(&data, 0, sizeof(DEV_NETWROK_SETTINGS));
			
			//data.u8ConnectSpeed = [ethernetComboBox indexOfSelectedItem];
			
			data.u8Protocol_LPD = [lpdCheckButton state];
			data.u8Protocol_Port9100 = [port9100CheckButton state];
			data.u8Protocol_IPP = [ippCheckButton state];
			data.u8Protocol_WSD_PRINT = [wsdCheckButton state];
			data.u8Protocol_SNMP = [snmpCheckButton state];
			data.u8Protocol_EAMIL_ALERT = [statusCheckButton state];
			data.u8Protocol_CentreWare_IS = [internetCheckButton state];
			data.u8Protocol_Bonjour = [bonjourCheckButton state];
			
			int i;
			for (i = 0; i < 4; i++)
			{
				data.u8IPFilter1_Address[i] = [[ipArray objectAtIndex:i] intValue];
				data.u8IPFilter2_Address[i] = [[ipArray objectAtIndex:i+4] intValue];
				data.u8IPFilter3_Address[i] = [[ipArray objectAtIndex:i+8] intValue];
				data.u8IPFilter4_Address[i] = [[ipArray objectAtIndex:i+12] intValue];
				data.u8IPFilter5_Address[i] = [[ipArray objectAtIndex:i+16] intValue];
				
				data.u8IPFilter1_SubnetMask[i] = [[subnetMaskArray objectAtIndex:i] intValue];
				data.u8IPFilter2_SubnetMask[i] = [[subnetMaskArray objectAtIndex:i+4] intValue];
				data.u8IPFilter3_SubnetMask[i] = [[subnetMaskArray objectAtIndex:i+8] intValue];
				data.u8IPFilter4_SubnetMask[i] = [[subnetMaskArray objectAtIndex:i+12] intValue];
				data.u8IPFilter5_SubnetMask[i] = [[subnetMaskArray objectAtIndex:i+16] intValue];   
			}
			
			data.u8IPFilter1_Mode = [ipFilter1ModeComboBox indexOfSelectedItem];
			data.u8IPFilter2_Mode = [ipFilter2ModeComboBox indexOfSelectedItem];
			data.u8IPFilter3_Mode = [ipFilter3ModeComboBox indexOfSelectedItem];
			data.u8IPFilter4_Mode = [ipFilter4ModeComboBox indexOfSelectedItem];
			data.u8IPFilter5_Mode = [ipFilter5ModeComboBox indexOfSelectedItem];
			
			memcpy(addr, &data, sizeof(DEV_NETWROK_SETTINGS));
			
			break;
		case 1:
			
			memset(&data1, 0, sizeof(DEV_WIRELESS_SETTINGS));
			
			data1.cNetWorkType = [selectModeComboBox indexOfSelectedItem];
			
			NSString *ssid = [ssidTextField stringValue];
			if ([ssid length] > 32 || [ssid length] == 0)
			{
				ssidWrong = YES;
				return;
			}
			
			ssidWrong = NO;
			const char *cSsid = [ssid cStringUsingEncoding:NSASCIIStringEncoding];
			strcpy(data1.cSSID, cSsid);
			const char *cPassword;
			if([selectModeComboBox indexOfSelectedItem] == 0)
			{
				switch ([encryptionComboBox indexOfSelectedItem]) {
					case 0:
						data1.cAuthMode = 0;
						data1.cEncryptType = 0;
						break;
					case 3:
						data1.cAuthMode = 1;
						data1.cEncryptType = 3;
						break;
						/*
						 case 2:
						 data.cAuthMode = 4;
						 data.cEncryptType = 4;
						 break;
						 */
					case 2:
						data1.cAuthMode = 8;
						data1.cEncryptType = 8;
						break;
					case 1:
						data1.cAuthMode = 12;
						data1.cEncryptType = 12;
						break;
					default:
						break;
				}
				
				if ([encryptionComboBox indexOfSelectedItem] == 3)
				{
					NSString *password = [passwordTextField stringValue];
					int len = [password length];
					if (len != 5 && len != 13 && len != 10 && len != 26)
					{
						passwordWrong = YES;
						return;
					}
					
					if (len == 10)
					{
						int i;
						for (i = 0; i < 10; i++)
						{
							char c = [password characterAtIndex:i];
							if (!((c > 47 && c < 58) || (c > 64 && c < 71) || (c > 96 && c < 103)))
							{
								passwordWrong = YES;
								return;
							}
						}
					}
					
					if (len == 26)
					{
						int i;
						for (i = 0; i < 26; i++)
						{
							char c = [password characterAtIndex:i];
							if (!((c > 47 && c < 58) || (c > 64 && c < 71) || (c > 96 && c < 103)))
							{
								passwordWrong = YES;
								return;
							}
						}
					}
					
					//passwordWrong = NO;
					cPassword = [password cStringUsingEncoding:NSASCIIStringEncoding];

					
					data1.cDefaultKeyld = [transmitComboBox indexOfSelectedItem] + 1;
					int k=0;
					for (k=0;k<4;k++)
						strcpy((char *)data1.cWEPKey[k], cWEPKey[k]);
					
					if(data1.cDefaultKeyld != 0)
						strcpy((char *)data1.cWEPKey[(data1.cDefaultKeyld) -1], cPassword);
					
					
				}
				else if ([encryptionComboBox indexOfSelectedItem] < 3 && [encryptionComboBox indexOfSelectedItem] != 0)
				{
					
					NSString *password;
					if([passwordCheckButton state]==NSOffState)
					{
						password = [passwordTextField stringValue];
						
					}else {
						
						password = [passwordPlainTextField stringValue];
						
					}
					
					
					int len = [password length];
					if (len > 64 || len < 8)
					{
						passwordWrong = YES;
						return;
					}
					
					if (len == 64)
					{
						int i;
						for (i = 0; i < 64; i++)
						{
							char c = [password characterAtIndex:i];
							if (!((c > 47 && c < 58) || (c > 64 && c < 71) || (c > 96 && c < 103)))
							{
								passwordWrong = YES;
								return;
							}
						}
						
					}
					
					//passwordWrong = NO;
					cPassword = [password cStringUsingEncoding:NSASCIIStringEncoding];
				
					
		
					
					strcpy((char *)data1.cWPAPSKKey, cPassword);
					
					
				}
				
				
			}
			else {
				switch ([encryptionComboBox indexOfSelectedItem]) {
					case 0:
						data1.cAuthMode = 0;
						data1.cEncryptType = 0;
						break;
					case 1:
						data1.cAuthMode = 1;
						data1.cEncryptType = 3;
						break;
				}
				
				if ([encryptionComboBox indexOfSelectedItem] == 1)
				{
					NSString *password = [passwordTextField stringValue];
					int len = [password length];
					if (len != 5 && len != 13 && len != 10 && len != 26)
					{
						passwordWrong = YES;
						return;
					}
					
					if (len == 10)
					{
						int i;
						for (i = 0; i < 10; i++)
						{
							char c = [password characterAtIndex:i];
							if (!((c > 47 && c < 58) || (c > 64 && c < 71) || (c > 96 && c < 103)))
							{
								passwordWrong = YES;
								return;
							}
						}
					}
					
					if (len == 26)
					{
						int i;
						for (i = 0; i < 26; i++)
						{
							char c = [password characterAtIndex:i];
							if (!((c > 47 && c < 58) || (c > 64 && c < 71) || (c > 96 && c < 103)))
							{
								passwordWrong = YES;
								return;
							}
						}
					}
					
					//passwordWrong = NO;
					cPassword = [password cStringUsingEncoding:NSASCIIStringEncoding];
	
					
					data1.cDefaultKeyld = [transmitComboBox indexOfSelectedItem] + 1;
					int k=0;
					for (k=0;k<4;k++)
						strcpy((char *)data1.cWEPKey[k], cWEPKey[k]);
					
					if(data1.cDefaultKeyld != 0)
						strcpy((char *)data1.cWEPKey[(data1.cDefaultKeyld) -1], cPassword);
					
					
					
					
				}
				
				
				
				
			}
			
			

			
			
			
			memcpy(addr, &data1, sizeof(DEV_WIRELESS_SETTINGS));
			break;
		case 2:
			memset(&data2, 0, sizeof(DEV_WIFI_DIRECT_SETTINGS));
		
			NSString *ssid1 = [prefixSSID stringByAppendingString:[directsSSIDTextField stringValue]];
			if ([[directsSSIDTextField stringValue] length] > 23 || [[directsSSIDTextField stringValue] length] == 0)
			{
				
				
				
				ssidWrong = YES;
				return;
			}else 
			{
				int i;
				for (i = 0; i < [ssid1 length] ; i++)
				{
					char c = [ssid1 characterAtIndex:i];
					if ( c < 0x20 || c > 0x7e )
					{
						ssidWrong = YES;
						return;
					}
				}
			}
			
			
			ssidWrong = NO;
			const char *cSsid1 = [ssid1 cStringUsingEncoding:NSASCIIStringEncoding];
			strcpy(data2.cSSID, cSsid1);
			
			data2.cP2PEnable = [directSetupCheckButton state];
			data2.cP2PGOEnable = [directGroupRoleComboBox indexOfSelectedItem];
			data2.cWPSMethod = [directWPSMethodComboBox indexOfSelectedItem];
			
			
			
			memcpy(addr, &data2, sizeof(DEV_WIFI_DIRECT_SETTINGS));
			break;

		default:
			break;
			
	}
	
}



- (IBAction)checkButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
    isChanged = YES;
	
	if(sender != passwordCheckButton )
	{
		
		if(sender == lpdCheckButton ||
		   sender == port9100CheckButton ||
		   sender == ippCheckButton ||
		   sender == wsdCheckButton ||
		   sender == snmpCheckButton ||
		   sender == statusCheckButton ||
		   sender == internetCheckButton ||
		   sender == bonjourCheckButton ||
		   sender == port9100CheckButton 
		   )
		{
			[applyButton1 setEnabled:YES];
			[applyButton2 setEnabled:YES];
		}
		
		
		if(sender == wifiCheckButton )
		{
			[applyButton3 setEnabled:YES];
			[applyButton4 setEnabled:YES];
		}
		
		if(sender == directSetupCheckButton )
		{
			[applyButton5 setEnabled:YES];
			[applyButton6 setEnabled:YES];
		}
		
		
	}
	
	
	
	
	[directPassphraseTextField setEnabled:NO];
	[directDeviceTextField setEnabled:NO];
	[directP2PRoleComboBox setEnabled:NO];
	[directPINCodeTextField setEnabled:NO];
	
	[directConnectionStatusTextField setEnabled:NO];
#if 0
	[directDhcpsDevList2TextField setEnabled:NO];
	[directDhcpsDevList3TextField setEnabled:NO];
	[directDhcpsDevList4TextField setEnabled:NO];
#endif
	[directWPSMethodComboBox setEditable:NO];
	
	if(sender == wifiCheckButton){
		//isNeedRestart=1;
		switch ([wifiCheckButton state]) {
			case 0:
				//[wifiCheckButton setState:NSOffState];
				//[wifiCheckButton setEnabled:NO];
				[selectModeComboBox setEnabled:NO];
				[ssidTextField setEnabled:NO];
				[encryptionComboBox setEnabled:NO];
				[passwordTextField setEnabled:NO];
				[passwordCheckButton setEnabled:NO];
				[transmitComboBox setEnabled:NO];
				[directSetupCheckButton setEnabled:NO];
				//[directSetupCheckButton setState:NO];
				[directPassphraseTextField setEnabled:NO];
				[directDeviceTextField setEnabled:NO];
				[directP2PRoleComboBox setEnabled:NO];
				[directPINCodeTextField setEnabled:NO];
				
				[directConnectionStatusTextField setEnabled:NO];
#if 0
				[directDhcpsDevList2TextField setEnabled:NO];
				[directDhcpsDevList3TextField setEnabled:NO];
				[directDhcpsDevList4TextField setEnabled:NO];
#endif
				[directWPSMethodComboBox setEditable:NO];
				
				[directsSSIDTextField setEnabled:NO];
				
				//[directP2PEnableCheckButton setEnabled:NO];
				//	[directP2PGOEnableCheckButton setEnabled:NO];
				[directWPSMethodComboBox setEnabled:NO];
				
				break;
			case 1:
				//[directSetupCheckButton setState:NSOnState];
				[directSetupCheckButton setEnabled:YES];
				[directPassphraseTextField setEnabled:NO];
				[directDeviceTextField setEnabled:NO];
				[directP2PRoleComboBox setEnabled:NO];
				[directPINCodeTextField setEnabled:NO];
				
				[directConnectionStatusTextField setEnabled:NO];
#if 0
				[directDhcpsDevList2TextField setEnabled:NO];
				[directDhcpsDevList3TextField setEnabled:NO];
				[directDhcpsDevList4TextField setEnabled:NO];
#endif
				[directWPSMethodComboBox setEditable:NO];
				[directsSSIDTextField setEnabled:NO];
				
				//[directP2PEnableCheckButton setEnabled:NO];
				//[directP2PEnableCheckButton setState:NSOffState];
				//[directP2PGOEnableCheckButton setEnabled:NO];
				[directWPSMethodComboBox setEnabled:NO];
				
				
				//[wifiCheckButton setEnabled:YES];
				[selectModeComboBox setEnabled:YES];
				[ssidTextField setEnabled:YES];
				[encryptionComboBox setEnabled:YES];
				
				if([selectModeComboBox indexOfSelectedItem] == 0)
				{
					if ([encryptionComboBox indexOfSelectedItem] == 0)
					{
						[transmitComboBox selectItemAtIndex:0];
						[transmitComboBox setEnabled:NO];
						[passwordTextField setEnabled:NO];
						[passwordPlainTextField setEnabled:NO];
						[passwordCheckButton setEnabled:NO];
					}
					else if ([encryptionComboBox indexOfSelectedItem] == 3)
					{
						[transmitComboBox setEnabled:YES];
						[passwordTextField setEnabled:YES];
						[passwordPlainTextField setEnabled:YES];
						[passwordCheckButton setEnabled:YES];
					}
					else
					{
						[transmitComboBox selectItemAtIndex:0];
						[transmitComboBox setEnabled:NO];
						[passwordTextField setEnabled:YES];
						[passwordPlainTextField setEnabled:YES];
						[passwordCheckButton setEnabled:YES];
					}
				}
				else {
					if ([encryptionComboBox indexOfSelectedItem] == 0)
					{
						[transmitComboBox selectItemAtIndex:0];
						[transmitComboBox setEnabled:NO];
						[passwordTextField setEnabled:NO];
						[passwordPlainTextField setEnabled:NO];
						[passwordCheckButton setEnabled:NO];
					}
					else if ([encryptionComboBox indexOfSelectedItem] == 1)
					{
						[transmitComboBox setEnabled:YES];
						[passwordTextField setEnabled:YES];
						[passwordPlainTextField setEnabled:YES];
						[passwordCheckButton setEnabled:YES];
					}
					else
					{
						[transmitComboBox selectItemAtIndex:0];
						[transmitComboBox setEnabled:NO];
						[passwordTextField setEnabled:YES];
						[passwordPlainTextField setEnabled:YES];
						[passwordCheckButton setEnabled:YES];
					}
				}
				
				break;
			default:
				break;
		}
	}
	else if (sender == directSetupCheckButton){
		//isNeedRestart=1;
		switch ([directSetupCheckButton state]) {
			case 0:
				//[directSetupCheckButton setState:NSOffState];
				[[[selectModeComboBox menu] itemAtIndex:1] setEnabled:YES];
				[directPassphraseTextField setEnabled:NO];
				[directDeviceTextField setEnabled:NO];
				[directP2PRoleComboBox setEnabled:NO];
				[directPINCodeTextField setEnabled:NO];
				
				[directConnectionStatusTextField setEnabled:NO];
#if 0
				[directDhcpsDevList2TextField setEnabled:NO];
				[directDhcpsDevList3TextField setEnabled:NO];
				[directDhcpsDevList4TextField setEnabled:NO];
#endif
				[directWPSMethodComboBox setEnabled:NO];
				[directGroupRoleComboBox setEnabled:NO];
				[directsSSIDTextField setEnabled:NO];
				
				//[directP2PEnableCheckButton setEnabled:NO];
				//[directP2PGOEnableCheckButton setEnabled:NO];
				[directWPSMethodComboBox setEnabled:NO];
				
				break;
			case 1:
				
				[[[selectModeComboBox menu] itemAtIndex:1] setEnabled:NO];
				[selectModeComboBox selectItemAtIndex:0];
				[directGroupRoleComboBox setEnabled:YES];
				[directWPSMethodComboBox setEnabled:YES];
				[directsSSIDTextField setEnabled:YES];
				
				//[directP2PEnableCheckButton setEnabled:YES];
				//[directP2PGOEnableCheckButton setEnabled:YES];
				//[directWPSMethodComboBox setEnabled:YES];
				
				//[wifiCheckButton setState:NSOffState];
				//[selectModeComboBox setEnabled:NO];
				//[ssidTextField setEnabled:NO];
				//[encryptionComboBox setEnabled:NO];
				//[passwordTextField setEnabled:NO];
				//[passwordCheckButton setEnabled:NO];
				//[transmitComboBox setEnabled:NO];
				
				break;
			default:
				break;
		}
	}
	
	if (sender == passwordCheckButton) {
		
		
		
		if([passwordCheckButton state]==NSOffState)
		{
			[passwordTextField setStringValue:[passwordPlainTextField stringValue]];
		}else {
			
			[passwordPlainTextField setStringValue:[passwordTextField stringValue]];
			
		}
		
		
		[passwordTextField setHidden:![passwordTextField isHidden]];
		[passwordPlainTextField setHidden:![passwordPlainTextField isHidden]];
		
		
		
		
	}
	
	
	
	// [restartButton setEnabled:YES];
#if 1
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[NetwrokSettings alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WirelessSettings alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WirelessDirectSettings alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WifiFeatures alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WirelessDirectIP alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WifiPIN alloc] init] autorelease]];
#endif
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
	
	
	if(isDone == FALSE)
		return;
	
	isChanged = YES;
	
	id sender = [notification object];
	
	if(sender == ipFilter1ModeComboBox ||
	   sender == ipFilter2ModeComboBox ||
	   sender == ipFilter3ModeComboBox ||
	   sender == ipFilter4ModeComboBox ||
	   sender == ipFilter5ModeComboBox
	   )
	{
		[applyButton1 setEnabled:YES];
		[applyButton2 setEnabled:YES];
	}
	
	
	if(sender == selectModeComboBox ||
	   sender == encryptionComboBox ||
	   sender == transmitComboBox
	   )
	{
		[applyButton3 setEnabled:YES];
		[applyButton4 setEnabled:YES];
	}
	
	if(sender == directGroupRoleComboBox ||
	   sender == directWPSMethodComboBox 
	   )
	{
		[applyButton5 setEnabled:YES];
		[applyButton6 setEnabled:YES];
	}
	
	if(sender == wpsSetupComboBox 
	   )
	{
		[applyButton7 setEnabled:YES];
		switch ([wpsSetupComboBox indexOfSelectedItem]) {
			case 0:
				//PBC
				[wpsPINCodeTextField setEnabled:NO];
				[wpsPINCodeTextField setStringValue:@""];
				[wpsPrintPINButton setEnabled:NO];
				break;
			case 1:
				[wpsPINCodeTextField setEnabled:YES];
				[wpsPINCodeTextField setStringValue:wpsPINCode];
				[wpsPrintPINButton setEnabled:YES];
			default:
				break;
		}

	}
	
	//[restartButton setEnabled:YES];
	
	
#if 0
	[directDhcpsDevList2TextField setEnabled:NO];
	[directDhcpsDevList3TextField setEnabled:NO];
	[directDhcpsDevList4TextField setEnabled:NO];
#endif
	[directWPSMethodComboBox setEditable:NO];
	
	
	if([notification object] == encryptionComboBox){
		
		if([selectModeComboBox indexOfSelectedItem] == 0)
		{
			
			if ([encryptionComboBox indexOfSelectedItem] == 0)
			{
				[transmitComboBox selectItemAtIndex:0];
				[transmitComboBox setEnabled:NO];
				[passwordTextField setEnabled:NO];
				[passwordPlainTextField setEnabled:NO];
				[passwordCheckButton setEnabled:NO];
			}
			else if ([encryptionComboBox indexOfSelectedItem] == 3)
			{
				[transmitComboBox setEnabled:YES];
				[passwordTextField setEnabled:YES];
				[passwordPlainTextField setEnabled:YES];
				[passwordCheckButton setEnabled:YES];
			}
			else
			{
				[transmitComboBox selectItemAtIndex:0];
				[transmitComboBox setEnabled:NO];
				[passwordTextField setEnabled:YES];
				[passwordPlainTextField setEnabled:YES];
				[passwordCheckButton setEnabled:YES];
			}
		}
		else
		{
			
			if ([encryptionComboBox indexOfSelectedItem] == 0)
			{
				[transmitComboBox selectItemAtIndex:0];
				[transmitComboBox setEnabled:NO];
				[passwordTextField setEnabled:NO];
				[passwordPlainTextField setEnabled:NO];
				[passwordCheckButton setEnabled:NO];
			}
			else if ([encryptionComboBox indexOfSelectedItem] == 1)
			{
				[transmitComboBox setEnabled:YES];
				[passwordTextField setEnabled:YES];
				[passwordPlainTextField setEnabled:YES];
				[passwordCheckButton setEnabled:YES];
			}
			else
			{
				[transmitComboBox selectItemAtIndex:0];
				[transmitComboBox setEnabled:NO];
				[passwordTextField setEnabled:YES];
				[passwordPlainTextField setEnabled:YES];
				[passwordCheckButton setEnabled:YES];
			}
			
		}
	}
	
	if([notification object] == selectModeComboBox){
		if([selectModeComboBox indexOfSelectedItem] == 0 )
		{
			
			[directSetupCheckButton setEnabled:YES];
			[encryptionComboBox setDelegate:nil];
			[encryptionComboBox removeAllItems];
			[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
			[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"Mixed mode PSK", nil)];
			//[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA-PSK-TKIP", nil)];// remove
			[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WPA2-PSK-AES", nil)];
			[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];
			[encryptionComboBox selectItemAtIndex:0];
			[encryptionComboBox setNumberOfVisibleItems:[encryptionComboBox numberOfItems]];
			[encryptionComboBox setEditable:NO];
			
			[encryptionComboBox setDelegate:self];
			
		}
		else if([selectModeComboBox indexOfSelectedItem] == 1)
		{  
			[directSetupCheckButton setEnabled:NO];
			[directSetupCheckButton setState:NSOffState];
			[encryptionComboBox setDelegate:nil];
			[encryptionComboBox removeAllItems];
			[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"No Security", nil)];
			[encryptionComboBox addItemWithObjectValue:NSLocalizedString(@"WEP", nil)];
			[encryptionComboBox selectItemAtIndex:0];
			[encryptionComboBox setNumberOfVisibleItems:[encryptionComboBox numberOfItems]];
			[encryptionComboBox setEditable:NO];
			
			[encryptionComboBox setDelegate:self];
		}
		
		
		if([selectModeComboBox indexOfSelectedItem] == 0)
		{
			
			if ([encryptionComboBox indexOfSelectedItem] == 0)
			{
				[transmitComboBox selectItemAtIndex:0];
				[transmitComboBox setEnabled:NO];
				[passwordTextField setEnabled:NO];
				[passwordPlainTextField setEnabled:NO];
				[passwordCheckButton setEnabled:NO];
			}
			else if ([encryptionComboBox indexOfSelectedItem] == 3)
			{
				[transmitComboBox setEnabled:YES];
				[passwordTextField setEnabled:YES];
				[passwordPlainTextField setEnabled:YES];
				[passwordCheckButton setEnabled:YES];
			}
			else
			{
				[transmitComboBox selectItemAtIndex:0];
				[transmitComboBox setEnabled:NO];
				[passwordTextField setEnabled:YES];
				[passwordPlainTextField setEnabled:YES];
				[passwordCheckButton setEnabled:YES];
			}
		}
		else
		{
			
			if ([encryptionComboBox indexOfSelectedItem] == 0)
			{
				[transmitComboBox selectItemAtIndex:0];
				[transmitComboBox setEnabled:NO];
				[passwordTextField setEnabled:NO];
				[passwordPlainTextField setEnabled:NO];
				[passwordCheckButton setEnabled:NO];
			}
			else if ([encryptionComboBox indexOfSelectedItem] == 1)
			{
				[transmitComboBox setEnabled:YES];
				[passwordTextField setEnabled:YES];
				[passwordPlainTextField setEnabled:YES];
				[passwordCheckButton setEnabled:YES];
			}
			else
			{
				[transmitComboBox selectItemAtIndex:0];
				[transmitComboBox setEnabled:NO];
				[passwordTextField setEnabled:YES];
				[passwordPlainTextField setEnabled:YES];
				[passwordCheckButton setEnabled:YES];
			}
			
		}
		
		
	}
#if 1	
	
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[NetwrokSettings alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WirelessSettings alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WirelessDirectSettings alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WifiFeatures alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WirelessDirectIP alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WifiPIN alloc] init] autorelease]];
#endif
}




- (void)controlTextDidEndEditing:(NSNotification *)obj
{
	if(isDone == FALSE)
		return;
	isChanged = YES;
	
	id sender = [obj object];
	
	if(sender == ipFilter1AddrTextField1 ||
	   sender == ipFilter1AddrTextField2 ||
	   sender == ipFilter1AddrTextField3 ||
	   sender == ipFilter1AddrTextField4 ||
	   sender == ipFileer1SubMaskTextField1 ||
	   sender == ipFileer1SubMaskTextField2 ||
	   sender == ipFileer1SubMaskTextField3 ||
	   sender == ipFileer1SubMaskTextField4 ||
	   sender == ipFilter2AddrTextField1 ||
	   sender == ipFilter2AddrTextField2 ||
	   sender == ipFilter2AddrTextField3 ||
	   sender == ipFilter2AddrTextField4 ||
	   sender == ipFileer2SubMaskTextField1 ||
	   sender == ipFileer2SubMaskTextField2 ||
	   sender == ipFileer2SubMaskTextField3 ||
	   sender == ipFileer2SubMaskTextField4 ||
	   sender == ipFilter3AddrTextField1 ||
	   sender == ipFilter3AddrTextField2 ||
	   sender == ipFilter3AddrTextField3 ||
	   sender == ipFilter3AddrTextField4 ||
	   sender == ipFileer3SubMaskTextField1 ||
	   sender == ipFileer3SubMaskTextField2 ||
	   sender == ipFileer3SubMaskTextField3 ||
	   sender == ipFileer3SubMaskTextField4 ||
	   sender == ipFilter4AddrTextField1 ||
	   sender == ipFilter4AddrTextField2 ||
	   sender == ipFilter4AddrTextField3 ||
	   sender == ipFilter4AddrTextField4 ||
	   sender == ipFileer4SubMaskTextField1 ||
	   sender == ipFileer4SubMaskTextField2 ||
	   sender == ipFileer4SubMaskTextField3 ||
	   sender == ipFileer4SubMaskTextField4 ||
	   sender == ipFilter5AddrTextField1 ||
	   sender == ipFilter5AddrTextField2 ||
	   sender == ipFilter5AddrTextField3 ||
	   sender == ipFilter5AddrTextField4 ||
	   sender == ipFileer5SubMaskTextField1 ||
	   sender == ipFileer5SubMaskTextField2 ||
	   sender == ipFileer5SubMaskTextField3 ||
	   sender == ipFileer5SubMaskTextField4
	   
	   )
	{	if([[sender stringValue] length] == 0)
	{
		[sender setStringValue:@"0"];
		
	}
		[applyButton1 setEnabled:YES];
		[applyButton2 setEnabled:YES];
	}
	
	
	if(sender == ssidTextField ||
	   sender == passwordTextField ||
	   sender == passwordPlainTextField
	   )
	{
		[applyButton3 setEnabled:YES];
		[applyButton4 setEnabled:YES];
	}
	
	if(sender == directsSSIDTextField 
	   )
	{
		[applyButton5 setEnabled:YES];
		[applyButton6 setEnabled:YES];
	}	
	
	
	if([passwordCheckButton state]==NSOnState)
	{
		[passwordTextField setStringValue:[passwordPlainTextField stringValue]];
	}else {
		
		[passwordPlainTextField setStringValue:[passwordTextField stringValue]];
		
	}
	
	
	//[restartButton setEnabled:YES];
	
	
	
#if 0
	[directDhcpsDevList2TextField setEnabled:NO];
	[directDhcpsDevList3TextField setEnabled:NO];
	[directDhcpsDevList4TextField setEnabled:NO];
#endif
	[directWPSMethodComboBox setEditable:NO];
	
#if 1
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[NetwrokSettings alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WirelessSettings alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WirelessDirectSettings alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WifiFeatures alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WirelessDirectIP alloc] init] autorelease]];
	[devciePropertyList addObject:[[[WifiPIN alloc] init] autorelease]];
#endif
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


- (void)showPasswordWrongAlert
{
	if( [selectModeComboBox indexOfSelectedItem] == 0)
	{
		if ([encryptionComboBox indexOfSelectedItem] == 3) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
			[alert setInformativeText:NSLocalizedString(@"IDS_WIRELESS_PASSWORD_DESCRIPTION", nil)];
			[alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
			
			if([alert runModal] == NSAlertFirstButtonReturn)
			{
				[alert release];
			}
			else
			{
				[alert release];
			}
		}
		else if ([encryptionComboBox indexOfSelectedItem] < 3) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
			[alert setInformativeText:NSLocalizedString(@"IDS_WIRELESS_PASSPHRASE_DESCRIPTION", nil)];
			[alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
			
			if([alert runModal] == NSAlertFirstButtonReturn)
			{
				[alert release];
			}
			else
			{
				[alert release];
			}
		}
	}
	else {
		if ([encryptionComboBox indexOfSelectedItem] == 1) {
			NSAlert *alert = [[NSAlert alloc] init];
			[alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
			[alert setInformativeText:NSLocalizedString(@"IDS_WIRELESS_PASSWORD_DESCRIPTION", nil)];
			[alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
			
			if([alert runModal] == NSAlertFirstButtonReturn)
			{
				[alert release];
			}
			else
			{
				[alert release];
			}
		}
		
	}
	
	passwordWrong = NO;
	
}

- (void)showSsidWrongAlert
{
	NSAlert *alert = [[NSAlert alloc] init];
	[alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
	[alert setInformativeText:NSLocalizedString(@"Incorrect SSID.", nil)];
	[alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
	
	if([alert runModal] == NSAlertFirstButtonReturn)
	{
		[alert release];
	}
	else
	{
		[alert release];
	}
	
	ssidWrong = NO;
	
}


- (IBAction)resetWifiButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
	
	isNotReflesh = YES;
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xE0 CodeID:0x32 needRestart:YES] autorelease]];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x06 needRestart:YES] autorelease]];
	isRestarting = YES;
	[self sendInfoToDevice];
	
}

- (IBAction)resetNetworkButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
	
	isNotReflesh = YES;
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xFF CodeID:0x0F needRestart:YES] autorelease]];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x06 needRestart:YES] autorelease]];
	isRestarting = YES;
	[self sendInfoToDevice];
	
}



- (IBAction)printPINCodeButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
	
	isNotReflesh = YES;
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0x03 CodeID:0x0b needRestart:NO] autorelease]];
	isRestarting = NO;
	[self sendInfoToDevice];
	
}


- (IBAction)wpsPrintPINCodeButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
	
	isNotReflesh = YES;
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0x03 CodeID:0x0D needRestart:NO] autorelease]];
	isRestarting = NO;
	[self sendInfoToDevice];
	
}
- (IBAction)wpsConfigButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
	
	applyIndex = 7;
	isNotReflesh = YES;
	[[[self view] window] makeFirstResponder:nil];
	

	switch ([wpsSetupComboBox indexOfSelectedItem]) {
		case 0:
			isNotReflesh = YES;
			[devciePropertyList removeAllObjects];
			[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xFF CodeID:0x10 needRestart:NO] autorelease]];
			break;
		case 1:
			isNotReflesh = YES;
			[devciePropertyList removeAllObjects];
			[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xFF CodeID:0x11 needRestart:NO] autorelease]];
			break;
		default:
			return;
			break;
	}
	
	//isShowRestartAlert = YES;
	[self setInfoToDevice];
	isApply = YES;
}



- (IBAction)resetCodeButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
	
	isNotReflesh = YES;
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x0C needRestart:NO] autorelease]];
	isRestarting = NO;
	[self sendInfoToDevice];
	
}


- (IBAction)disconnectNowButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
	
	isNotReflesh = YES;
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x0D needRestart:NO] autorelease]];
	isRestarting = NO;
	[self sendInfoToDevice];
	
}


- (IBAction)disconnectResetPassphraseButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
	
	isNotReflesh = YES;
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x0E needRestart:NO] autorelease]];
	isRestarting = NO;
	[self sendInfoToDevice];
	
}


- (IBAction)printPassphraseButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
	
	isNotReflesh = YES;
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0x03 CodeID:0x0c needRestart:NO] autorelease]];
	isRestarting = NO;
	[self sendInfoToDevice];
	
}


- (IBAction)resetPassphraseButtonAction:(id)sender
{
	if(isDone == FALSE)
		return;
	
	isNotReflesh = YES;
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x0B needRestart:NO] autorelease]];
	isRestarting = NO;
	[self sendInfoToDevice];
	
}


- (void)restartPrinter
{
	if(isDone == FALSE)
		return;
	
	isNotReflesh = YES;
	[devciePropertyList removeAllObjects];
	[devciePropertyList addObject:[[[DeviceCommond alloc]initWithGroupID:0xff CodeID:0x06 needRestart:YES] autorelease]];
	isRestarting = YES;
	[self sendInfoToDevice];
	
}

@end