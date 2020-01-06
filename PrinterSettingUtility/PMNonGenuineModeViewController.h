//
//  PMNonGenuineModeViewController.h
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "SettingsController.h"

@interface PMNonGenuineModeViewController : SettingsController
{
    IBOutlet NSTextField *textField;
    IBOutlet NSTextView * textView;
    IBOutlet NSButton *checkButton;
    IBOutlet NSButton *applyButton;
}

- (IBAction)applyButtonAction:(id)sender;
- (IBAction)checkButtonAction:(id)sender;


@end
