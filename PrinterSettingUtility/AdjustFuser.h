//
//  AdjustFuser.h
//  MachineSetup
//
//  Created by Helen Liu on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"

@interface AdjustFuserController : SettingsController {
@private
    
    IBOutlet NSTextField *plainField;
    IBOutlet NSTextField *bondField;
    IBOutlet NSTextField *lightweightCField;
    IBOutlet NSTextField *lightweightGCField;
    IBOutlet NSTextField *labelField;
    IBOutlet NSTextField *envelopeField;
    IBOutlet NSTextField *recycledField;
    
    IBOutlet NSComboBox *plainBox;
    IBOutlet NSComboBox *bondBox;
    IBOutlet NSComboBox *lightweightCBox;
    IBOutlet NSComboBox *lightweightGCBox;
    IBOutlet NSComboBox *labelBox;
    IBOutlet NSComboBox *envelopeBox;
    IBOutlet NSComboBox *recycledBox;
}
- (IBAction)onApplyNewSettings:(id)sender;

@end
