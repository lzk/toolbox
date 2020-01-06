//
//  AdjustAltitudeController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"

@interface AdjustAltitudeController : SettingsController {
@private
    IBOutlet NSComboBox *adjustAltitudeCombo;
    
    IBOutlet NSTextField *adjustAltitudeTextField;
    
    
}
- (IBAction)onApplyNewSettings:(id)sender;

@end
