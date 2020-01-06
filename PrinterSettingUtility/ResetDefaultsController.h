//
//  ResetDefaultsController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/17/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"

@interface ResetDefaultsController : SettingsController {
@private
    
    IBOutlet NSButton *systemSectionButton;
}
- (IBAction)onSystemSection:(id)sender;


@end
