//
//  CleanDeveloperController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"

@interface CleanDeveloperController : SettingsController {
@private
    IBOutlet NSTextField *cleanDeveloperTextField;
    
    IBOutlet NSButton *startButton;
}
- (IBAction)onStartButton:(id)sender;

@end
