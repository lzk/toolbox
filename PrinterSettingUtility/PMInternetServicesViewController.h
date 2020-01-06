//
//  PMInternetServicesViewController.h
//  MachineSetup
//
//  Created by Wang Kun on 11/20/13.
//
//

#import "SettingsController.h"

@interface PMInternetServicesViewController : SettingsController
{
    IBOutlet NSTextField *printServerSettingsLabel;
    IBOutlet NSTextField *DisplayofCISLabel;
    
    IBOutlet NSButton *displayButton;
    IBOutlet NSButton *checkButton;
    
    IBOutlet NSButton *applyButton;
    IBOutlet NSButton *restartButton;
    
    BOOL isShowRestartAlert;
    BOOL isNeedRestart;
    BOOL isRestarting;
}

- (IBAction)displayButtonAction:(id)sender;
- (IBAction)checkButtonAction:(id)sender;
- (IBAction)applyButtonAction:(id)sender;
- (IBAction)restartButtonAction:(id)sender;

@end
