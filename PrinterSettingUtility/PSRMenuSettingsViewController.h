//
//  PSRMenuSettingsViewController.h
//  MachineSetup
//
//  Created by Wang Kun on 11/18/13.
//
//

#import "SettingsController.h"

@interface PSRMenuSettingsViewController : SettingsController <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSScrollView *scrollview;
    
    IBOutlet NSTextField *textField1;
    IBOutlet NSTextField *textField2;
    IBOutlet NSTextField *textField3;
    IBOutlet NSTextField *textField4;
    IBOutlet NSTextField *textField5;
    IBOutlet NSTextField *textField6;
    IBOutlet NSTextField *textField7;
    IBOutlet NSTextField *textField8;
    //IBOutlet NSTextField *textField9;
    
    IBOutlet NSTableView *tableView1;
    IBOutlet NSTableView *tableView2;
    IBOutlet NSTableView *tableView3;
    IBOutlet NSTableView *tableView4;
    IBOutlet NSTableView *tableView5;
    IBOutlet NSTableView *tableView6;
    IBOutlet NSTableView *tableView7;
    IBOutlet NSTableView *tableView8;
    //IBOutlet NSTableView *tableView9;

    IBOutlet NSScrollView *tableView8ScrollView;
    
    NSMutableArray *firstColumnItems1;
    NSMutableArray *firstColumnItems2;
    NSMutableArray *firstColumnItems3;
    NSMutableArray *firstColumnItems4;
    NSMutableArray *firstColumnItems5;
    NSMutableArray *firstColumnItems6;
    NSMutableArray *firstColumnItems7;
    NSMutableArray *firstColumnItems8;
    //NSMutableArray *firstColumnItems9;
    
    NSMutableArray *secondColumnItems1;
    NSMutableArray *secondColumnItems2;
    NSMutableArray *secondColumnItems3;
    NSMutableArray *secondColumnItems4;
    NSMutableArray *secondColumnItems5;
    NSMutableArray *secondColumnItems6;
    NSMutableArray *secondColumnItems7;
    NSMutableArray *secondColumnItems8;
    //NSMutableArray *secondColumnItems9;
    
}

@end
