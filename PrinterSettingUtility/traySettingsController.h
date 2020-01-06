//
//  traySettingsController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"

@interface traySettingsController : SettingsController {
@private
    IBOutlet NSTableView *settingsTableView;
    
    IBOutlet NSTableColumn *itemTitleColumn;
    NSMutableArray * itemStringIDList;
    NSMutableArray * itemStringList;

    
}

@end
