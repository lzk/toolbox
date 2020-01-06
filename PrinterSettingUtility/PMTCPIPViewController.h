//
//  PMTCPIPViewController.h
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "SettingsController.h"

@interface PMTCPIPViewController : SettingsController <NSComboBoxDelegate, NSTextFieldDelegate>
{
    IBOutlet NSScrollView *scrollView;
	
	IBOutlet NSTextField *ipModeLabel;
    IBOutlet NSComboBox *ipModelComboBox;
    
    IBOutlet NSBox *box;
    IBOutlet NSBox *box6;
	
    IBOutlet NSTextField *ipAddressModeLabel;
    IBOutlet NSComboBox *ipAddressModelComboBox;
    
    IBOutlet NSTextField *ipAddressLabel;
    IBOutlet NSTextField *ipTextField1;
    IBOutlet NSTextField *ipTextField2;
    IBOutlet NSTextField *ipTextField3;
    IBOutlet NSTextField *ipTextField4;
    IBOutlet NSTextField *ipDotTextField1;
    IBOutlet NSTextField *ipDotTextField2;
    IBOutlet NSTextField *ipDotTextField3;
    
	
	IBOutlet NSTextField *ipv6ModeLabel;
    IBOutlet NSButton *ipv6ModelCheckBox;
	
	IBOutlet NSTextField *ip6AddressLabel;
    IBOutlet NSTextField *ip6TextField;
	IBOutlet NSTextField *ip6PrefixTextField;
	IBOutlet NSTextField *ip6PrefixText;
	IBOutlet NSTextField *gateway6Label;
	IBOutlet NSTextField *gateway6TextField;
	
    IBOutlet NSTextField *subnetMaskLabel;
    IBOutlet NSTextField *subnetMaskTextField1;
    IBOutlet NSTextField *subnetMaskTextField2;
    IBOutlet NSTextField *subnetMaskTextField3;
    IBOutlet NSTextField *subnetMaskTextField4;
    IBOutlet NSTextField *subnetMaskDotTextField1;
    IBOutlet NSTextField *subnetMaskDotTextField2;
    IBOutlet NSTextField *subnetMaskDotTextField3;
    
    IBOutlet NSTextField *gatewayLabel;
    IBOutlet NSTextField *gatewayTextField1;
    IBOutlet NSTextField *gatewayTextField2;
    IBOutlet NSTextField *gatewayTextField3;
    IBOutlet NSTextField *gatewayTextField4;
    IBOutlet NSTextField *gatewayDotTextField1;
    IBOutlet NSTextField *gatewayDotTextField2;
    IBOutlet NSTextField *gatewayDotTextField3;
    
    IBOutlet NSButton *applyButton;
    IBOutlet NSButton *restartButton;
    
    BOOL isShowRestartAlert;
    BOOL isNeedRestart;
    BOOL isRestarting;
	BOOL isDone,isApply;
	
	BOOL resevedDirect,collisionDirect,badIP,badGate;
	DEV_WIFI_P2P_IP devP2PIPData;
	
}

- (IBAction)applyButtonAction:(id)sender;
- (IBAction)restartButtonAction:(id)sender;
- (IBAction)checkButtonAction:(id)sender;

@end
