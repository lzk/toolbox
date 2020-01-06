//
//  PSRTCPIPViewController.h
//  MachineSetup
//
//  Created by Wang Kun on 11/15/13.
//
//

#import "SettingsController.h"


@interface PSRTCPIPViewController : SettingsController <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSTableView *tableView;
    
    IBOutlet NSTextField *ipModeLabel;
    IBOutlet NSTextField *ipv4Label;
	IBOutlet NSTextField *ipv6Label;
	
	
    NSMutableArray *tableView1firstColumnItems;
    NSMutableArray *tableView2firstColumnItems;
	NSMutableArray *tableView3firstColumnItems;

	
    NSMutableArray *tableView1secondColumnItems;
    NSMutableArray *tableView2secondColumnItems;
	NSMutableArray *tableView3secondColumnItems;
	


	
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult;

@end
