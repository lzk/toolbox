//
//  PMNetwrokSettingsViewController.h
//  PrinterSettingUtility
//
//  Created by Wang Kun on 12/23/13.
//  Copyright (c) 2013 Wang Kun. All rights reserved.
//

#import "SettingsController.h"

@interface PMNetwrokSettingsViewController : SettingsController <NSComboBoxDelegate, NSTextFieldDelegate>
{
    IBOutlet NSScrollView *scrollView;
    
    IBOutlet NSTextField *ethernetLabel;
    IBOutlet NSComboBox *ethernetComboBox;
	
	IBOutlet NSBox *networkSettingsBox;   
    IBOutlet NSBox *protocolsBox;
    IBOutlet NSTextField *lpdLabel;
    IBOutlet NSTextField *port9100Label;
    IBOutlet NSTextField *ippLabel;
    IBOutlet NSTextField *wsdLabel;
    IBOutlet NSTextField *snmpLabel;
    IBOutlet NSTextField *statusLabel;
    IBOutlet NSTextField *internetLabel;
    IBOutlet NSTextField *bonjourLabel;
    
    IBOutlet NSButton *lpdCheckButton;
    IBOutlet NSButton *port9100CheckButton;
    IBOutlet NSButton *ippCheckButton;
    IBOutlet NSButton *wsdCheckButton;
    IBOutlet NSButton *snmpCheckButton;
    IBOutlet NSButton *statusCheckButton;
    IBOutlet NSButton *internetCheckButton;
    IBOutlet NSButton *bonjourCheckButton;

    IBOutlet NSBox *ipFilter1Box;
    IBOutlet NSTextField *ipFilter1AddressLabel;
    IBOutlet NSTextField *ipFilter1AddrTextField1;
    IBOutlet NSTextField *ipFilter1AddrTextField2;
    IBOutlet NSTextField *ipFilter1AddrTextField3;
    IBOutlet NSTextField *ipFilter1AddrTextField4;
    IBOutlet NSTextField *ipFilter1SubnetMaskLabel;
    IBOutlet NSTextField *ipFileer1SubMaskTextField1;
    IBOutlet NSTextField *ipFileer1SubMaskTextField2;
    IBOutlet NSTextField *ipFileer1SubMaskTextField3;
    IBOutlet NSTextField *ipFileer1SubMaskTextField4;
    IBOutlet NSTextField *ipFilter1ModeLabel;
    IBOutlet NSComboBox *ipFilter1ModeComboBox;
    
    IBOutlet NSBox *ipFilter2Box;
    IBOutlet NSTextField *ipFilter2AddressLabel;
    IBOutlet NSTextField *ipFilter2AddrTextField1;
    IBOutlet NSTextField *ipFilter2AddrTextField2;
    IBOutlet NSTextField *ipFilter2AddrTextField3;
    IBOutlet NSTextField *ipFilter2AddrTextField4;
    IBOutlet NSTextField *ipFilter2SubnetMaskLabel;
    IBOutlet NSTextField *ipFileer2SubMaskTextField1;
    IBOutlet NSTextField *ipFileer2SubMaskTextField2;
    IBOutlet NSTextField *ipFileer2SubMaskTextField3;
    IBOutlet NSTextField *ipFileer2SubMaskTextField4;
    IBOutlet NSTextField *ipFilter2ModeLabel;
    IBOutlet NSComboBox *ipFilter2ModeComboBox;
    
    IBOutlet NSBox *ipFilter3Box;
    IBOutlet NSTextField *ipFilter3AddressLabel;
    IBOutlet NSTextField *ipFilter3AddrTextField1;
    IBOutlet NSTextField *ipFilter3AddrTextField2;
    IBOutlet NSTextField *ipFilter3AddrTextField3;
    IBOutlet NSTextField *ipFilter3AddrTextField4;
    IBOutlet NSTextField *ipFilter3SubnetMaskLabel;
    IBOutlet NSTextField *ipFileer3SubMaskTextField1;
    IBOutlet NSTextField *ipFileer3SubMaskTextField2;
    IBOutlet NSTextField *ipFileer3SubMaskTextField3;
    IBOutlet NSTextField *ipFileer3SubMaskTextField4;
    IBOutlet NSTextField *ipFilter3ModeLabel;
    IBOutlet NSComboBox *ipFilter3ModeComboBox;

    IBOutlet NSBox *ipFilter4Box;
    IBOutlet NSTextField *ipFilter4AddressLabel;
    IBOutlet NSTextField *ipFilter4AddrTextField1;
    IBOutlet NSTextField *ipFilter4AddrTextField2;
    IBOutlet NSTextField *ipFilter4AddrTextField3;
    IBOutlet NSTextField *ipFilter4AddrTextField4;
    IBOutlet NSTextField *ipFilter4SubnetMaskLabel;
    IBOutlet NSTextField *ipFileer4SubMaskTextField1;
    IBOutlet NSTextField *ipFileer4SubMaskTextField2;
    IBOutlet NSTextField *ipFileer4SubMaskTextField3;
    IBOutlet NSTextField *ipFileer4SubMaskTextField4;
    IBOutlet NSTextField *ipFilter4ModeLabel;
    IBOutlet NSComboBox *ipFilter4ModeComboBox;

    IBOutlet NSBox *ipFilter5Box;
    IBOutlet NSTextField *ipFilter5AddressLabel;
    IBOutlet NSTextField *ipFilter5AddrTextField1;
    IBOutlet NSTextField *ipFilter5AddrTextField2;
    IBOutlet NSTextField *ipFilter5AddrTextField3;
    IBOutlet NSTextField *ipFilter5AddrTextField4;
    IBOutlet NSTextField *ipFilter5SubnetMaskLabel;
    IBOutlet NSTextField *ipFileer5SubMaskTextField1;
    IBOutlet NSTextField *ipFileer5SubMaskTextField2;
    IBOutlet NSTextField *ipFileer5SubMaskTextField3;
    IBOutlet NSTextField *ipFileer5SubMaskTextField4;
    IBOutlet NSTextField *ipFilter5ModeLabel;
    IBOutlet NSComboBox *ipFilter5ModeComboBox;

	NSInteger applyIndex;
    IBOutlet NSButton *applyButton1;
    IBOutlet NSButton *applyButton2;
    
	IBOutlet NSTextField *WifiResetLable;
	IBOutlet NSButton *applyWifiResetButton;
	IBOutlet NSButton *applyNetworkResetButton;
	
	IBOutlet NSButton *applyButton3;
    IBOutlet NSButton *applyButton4;
	
	IBOutlet NSButton *applyButton5;
    IBOutlet NSButton *applyButton6;
	
	IBOutlet NSButton *applyButton7;
   // IBOutlet NSButton *restartButton;
    
    NSArray *ipArray;
    NSArray *subnetMaskArray;
    NSArray *checkButtonArray;
    
  //  BOOL isShowRestartAlert;
  //  BOOL isNeedRestart;
  //  BOOL isRestarting;
	

	
	//Wifi Sector
	IBOutlet NSBox *wifiBox;
	IBOutlet NSTextField *wifiLable;
    IBOutlet NSButton *wifiCheckButton;
    
    IBOutlet NSTextField *selelctModeLabel;
    IBOutlet NSComboBox *selectModeComboBox;
    
    IBOutlet NSTextField *ssidLabel;
    IBOutlet NSTextField *ssidTextField;
    
    IBOutlet NSTextField *encryptionLabel;
    IBOutlet NSComboBox *encryptionComboBox;
    
	char cWEPKey[4][28];
	NSString *prefixSSID;
	
    IBOutlet NSTextField *passwordLabel;
    IBOutlet NSSecureTextField *passwordTextField;
	IBOutlet NSTextField *passwordPlainTextField;
    IBOutlet NSButton *passwordCheckButton;
    
    IBOutlet NSTextField *transmitLabel;
    IBOutlet NSComboBox *transmitComboBox;
        

	BOOL isApply;
    
    BOOL isShowRestartAlert;
    BOOL isNeedRestart;
    BOOL isRestarting;
    
    BOOL passwordWrong;
    BOOL ssidWrong;
	
	
	//WPS sector
	IBOutlet NSBox *wpsBox;
	
	IBOutlet NSTextField *wpsSetupLabel;
    IBOutlet NSComboBox *wpsSetupComboBox;
	
	IBOutlet NSTextField *wpsPINCodeLable;
    IBOutlet NSTextField *wpsPINCodeTextField;
	NSString *wpsPINCode;
	
	
	IBOutlet NSTextField *wpsPrintPINLabel;
    IBOutlet NSButton *wpsPrintPINButton;
	
	
	
	
	//wifi direct sector
	IBOutlet NSBox *directBox;
	IBOutlet NSTextField *directSetupLabel;
    IBOutlet NSButton *directSetupCheckButton;
	
	IBOutlet NSTextField *directGroupRoleLabel;
    IBOutlet NSComboBox *directGroupRoleComboBox;
	
	
	IBOutlet NSTextField *directDeviceNameLable;
    IBOutlet NSTextField *directDeviceTextField;
	
	IBOutlet NSTextField *directWPSMethodLabel;
    IBOutlet NSComboBox *directWPSMethodComboBox;
	
	
	
	IBOutlet NSTextField *directPINCodeLable;
    IBOutlet NSTextField *directPINCodeTextField;
	
	
	IBOutlet NSTextField *directPrintPINCodeLabel;
	IBOutlet NSButton *directPrintPINCodeButton;
	
	IBOutlet NSTextField *directResetCodeLabel;
	IBOutlet NSButton *directResetCodeButton;
	
	
	IBOutlet NSTextField *directP2PRoleLabel;
    IBOutlet NSComboBox *directP2PRoleComboBox;
	
	IBOutlet NSTextField *directConnectionStatusLabel;
	IBOutlet NSTextField *directConnectionStatusTextField;
	
	IBOutlet NSTextField *directDisconnectNowLabel;
	IBOutlet NSButton *directDisconnectNowButton;
	
	IBOutlet NSTextField *directDisconnectResetPassphraseLabel;
	IBOutlet NSButton *directDisconnectResetPassphraseButton;
	
	IBOutlet NSTextField *directGroupOwnerLabel;
	//IBOutlet NSTextField *directGroupOwnerTextField;
	
	IBOutlet NSTextField *directsSSIDLable;
	IBOutlet NSTextField *directsSSIDPrefixLable;
    IBOutlet NSTextField *directsSSIDTextField;

	IBOutlet NSTextField *directPassphraseLable;
    IBOutlet NSTextField *directPassphraseTextField;

	IBOutlet NSTextField *directPrintPassphraseLabel;
	IBOutlet NSButton *directPrintPassphraseButton;
	
	IBOutlet NSTextField *directResetPassphraseLabel;
	IBOutlet NSButton *directResetPassphraseButton;
	
	
	IBOutlet NSTextField *directsIPAddressLable;
    IBOutlet NSTextField *directsIPAddressTextField;
	
	IBOutlet NSTextField *directsSubnetMaskLable;
    IBOutlet NSTextField *directsSubnetMaskTextField;
	

	

	


	
	IBOutlet NSTextField *directDhcpsDevList1NameLable;
    IBOutlet NSTextField *directDhcpsDevList1TextField;
	
	IBOutlet NSTextField *directDhcpsDevList2NameLable;
    IBOutlet NSTextField *directDhcpsDevList2TextField;
	
	IBOutlet NSTextField *directDhcpsDevList3NameLable;
    IBOutlet NSTextField *directDhcpsDevList3TextField;
	
	IBOutlet NSTextField *directDhcpsDevList4NameLable;
    IBOutlet NSTextField *directDhcpsDevList4TextField;
	
	BOOL	isDone,needDisableApply;
	

	
	
}

- (IBAction)directSetupButtonAction:(id)sender;
- (IBAction)applyButtonAction:(id)sender;
- (IBAction)resetWifiButtonAction:(id)sender;
- (IBAction)resetNetworkButtonAction:(id)sender;
- (IBAction)printPINCodeButtonAction:(id)sender;
- (IBAction)wpsPrintPINCodeButtonAction:(id)sender;
- (IBAction)wpsConfigButtonAction:(id)sender;
- (IBAction)resetCodeButtonAction:(id)sender;
- (IBAction)disconnectNowButtonAction:(id)sender;
- (IBAction)disconnectResetPassphraseButtonAction:(id)sender;
- (IBAction)printPassphraseButtonAction:(id)sender;
- (IBAction)resetPassphraseButtonAction:(id)sender;
- (IBAction)checkButtonAction:(id)sender;
- (void)updateView:(id)data index:(int)index;

@end
