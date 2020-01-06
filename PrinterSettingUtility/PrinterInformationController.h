//
//  PrinterInformationController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"

@interface PrinterInformationController : SettingsController {
@private
    IBOutlet NSTableView *printerInformationTableView;
    
    IBOutlet NSTableColumn *itemTitleColumn;
    NSMutableArray * itemStringIDList;
    NSMutableArray * itemStringList;
}

@end
