//
//  PMWirelessSetupViewController.h
//  PrinterSettingUtility
//
//  Created by Wang Kun on 12/24/13.
//  Copyright (c) 2013 Wang Kun. All rights reserved.
//

#import "SettingsController.h"

@interface PMWirelessSetupViewController : SettingsController <NSComboBoxDelegate, NSTextFieldDelegate>
{
    IBOutlet NSTextField *wifiLable;
    IBOutlet NSButton *wifiCheckButton;
    
    IBOutlet NSTextField *selelctModeLabel;
    IBOutlet NSComboBox *selectModeComboBox;
    
    IBOutlet NSTextField *ssidLabel;
    IBOutlet NSTextField *ssidTextField;
    
    IBOutlet NSTextField *encryptionLabel;
    IBOutlet NSComboBox *encryptionComboBox;
    
    IBOutlet NSTextField *passwordLabel;
    IBOutlet NSSecureTextField *passwordTextField;
    IBOutlet NSButton *passwordCheckButton;
    
    IBOutlet NSTextField *transmitLabel;
    IBOutlet NSComboBox *transmitComboBox;
    
    IBOutlet NSTextField *directSetupLabel;
    IBOutlet NSButton *directSetupCheckButton;
    
    IBOutlet NSButton *applyButton;
    IBOutlet NSButton *restartButton;
    
    BOOL isShowRestartAlert;
    BOOL isNeedRestart;
    BOOL isRestarting;
    
    BOOL passwordWrong;
    BOOL ssidWrong;
}

- (IBAction)applyButtonAction:(id)sender;
- (IBAction)restartButtonAction:(id)sender;
- (IBAction)checkButtonAction:(id)sender;

@end
