//
//  PMAdjustPaperTypeViewController.h
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "SettingsController.h"

@interface PMAdjustPaperTypeViewController : SettingsController <NSComboBoxDelegate>
{
    IBOutlet NSTextField *pTextField;
    IBOutlet NSTextField *lTextField;
    
    IBOutlet NSComboBox *pBox;
    IBOutlet NSComboBox *lBox;
    
    IBOutlet NSButton *applyButton;
}

- (IBAction)applyButtonAction:(id)sender;

@end
