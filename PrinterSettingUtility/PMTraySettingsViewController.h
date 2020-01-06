//
//  PMTraySettingsViewController.h
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "SettingsController.h"

@interface PMTraySettingsViewController : SettingsController <NSComboBoxDelegate>
{
    IBOutlet NSTextField *papeTypeTextField;
    IBOutlet NSTextField *paperSizeTextField;
    IBOutlet NSTextField *customSizeYTextField;
    IBOutlet NSTextField *customSizeXTextField;
    IBOutlet NSTextField *displayScreenTextField;
    
    IBOutlet NSComboBox *papeTypeComboBox;
    IBOutlet NSComboBox *paperSizeComboBox;
    IBOutlet NSComboBox *customSizeYComboBox;
    IBOutlet NSComboBox *customSizeXComboBox;
    IBOutlet NSButton *displayScreenButton;
    
    IBOutlet NSTextField *yUnitTextField;
    IBOutlet NSTextField *xUnitTextField;
    
    IBOutlet NSButton *applyButton;
}

- (IBAction)applyButtonAction:(id)sender;
- (IBAction)checkButtonAction:(id)sender;

@end
