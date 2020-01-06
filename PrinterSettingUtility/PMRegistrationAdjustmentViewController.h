//
//  PMRegistrationAdjustmentViewController.h
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "SettingsController.h"

@interface PMRegistrationAdjustmentViewController : SettingsController
{
    IBOutlet NSScrollView *scrollview;
    
    IBOutlet NSButton *button1;
    IBOutlet NSButton *button2;
    
    
    IBOutlet NSBox *autoBox;
    IBOutlet NSBox *manualBox;
    IBOutlet NSBox *adjustBox1;
    IBOutlet NSBox *adjustBox2;
    
    
    IBOutlet NSTextField *autoRATextField;
    
    IBOutlet NSTextField *autoCorrectTextField;
    IBOutlet NSTextField *printCRCTextField;
    
    IBOutlet NSTextField *yTextField;
    IBOutlet NSTextField *mTextField;
    IBOutlet NSTextField *cTextField;

    IBOutlet NSTextField *lyTextField;
    IBOutlet NSTextField *lmTextField;
    IBOutlet NSTextField *lcTextField;
    IBOutlet NSTextField *ryTextField;
    IBOutlet NSTextField *rmTextField;
    IBOutlet NSTextField *rcTextField;
    
    
    IBOutlet NSButton *autoRATextButton;
    
    IBOutlet NSButton *autoCorrectButton;
    IBOutlet NSButton *printCRCButton;
    
    IBOutlet NSComboBox *yComoBox;
    IBOutlet NSComboBox *mComoBox;
    IBOutlet NSComboBox *cComoBox;
    
    IBOutlet NSComboBox *lyComoBox;
    IBOutlet NSComboBox *lmComoBox;
    IBOutlet NSComboBox *lcComoBox;
    IBOutlet NSComboBox *ryComoBox;
    IBOutlet NSComboBox *rmComoBox;
    IBOutlet NSComboBox *rcComoBox;
    
    BOOL isUpdateView;
}

- (IBAction)applyButtonAction:(id)sender;
- (IBAction)checkButtonAction:(id)sender;
- (IBAction)autoCorrectButtonAction:(id)sender;
- (IBAction)printCRCButtonAction:(id)sender;

- (void)updateView:(id)data;

@end
