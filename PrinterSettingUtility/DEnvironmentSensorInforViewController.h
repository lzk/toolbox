//
//  DEnvironmentSensorInforViewController.h
//  MachineSetup
//
//  Created by Wang Kun on 11/25/13.
//
//

#import "SettingsController.h"

@interface DEnvironmentSensorInforViewController : SettingsController
{
    IBOutlet NSButton *getInforButton;
    IBOutlet NSTextField *resultTextField;
    IBOutlet NSTextView *textView;
    
    BOOL isUpdataView;
}

- (IBAction)getInforButtonAction:(id)sender;

@end
