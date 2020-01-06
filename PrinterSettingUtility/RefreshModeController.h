//
//  RefreshModeController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"

@interface RefreshModeController : SettingsController
{
    IBOutlet NSBox *box;
    IBOutlet NSButton *yButton;
    IBOutlet NSButton *mButton;
    IBOutlet NSButton *cButton;
    IBOutlet NSButton *blackButton;
}

- (IBAction)yButtonAction:(id)sender;
- (IBAction)mButtonAction:(id)sender;
- (IBAction)cButtonAction:(id)sender;
- (IBAction)blackButtonAction:(id)sender;

@end
