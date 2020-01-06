//
//  PMMachineLifeViewController.h
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "SettingsController.h"

@interface PMMachineLifeViewController : SettingsController
{
    IBOutlet NSButton *checkButton;
    IBOutlet NSTextView *textView;
    IBOutlet NSButton *applyButton;
}

- (IBAction)applyButtonAction:(id)sender;
- (IBAction)checkButtonAction:(id)sender;

@end
