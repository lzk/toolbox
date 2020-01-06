//
//  InformationPagesController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"

@interface InformationPagesController : SettingsController {
@private
    IBOutlet NSButtonCell *systemSettingsButton;
    IBOutlet NSButtonCell *jobHistoryButton;
    IBOutlet NSButtonCell *panelSettingsButton;
    IBOutlet NSButtonCell *errorHistoryButton;
    IBOutlet NSButtonCell *demoPageButton;
    NSButton *onJobHistory;
}
- (IBAction)onSystemSettings:(id)sender;
- (IBAction)onPanelSettings:(id)sender;
- (IBAction)onJobHistory:(id)sender;
- (IBAction)onErrorHistory:(id)sender;
- (IBAction)onDemoPage:(id)sender;

@end
