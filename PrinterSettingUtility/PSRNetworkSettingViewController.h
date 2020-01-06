//
//  PSRNetworkSettingViewController.h
//  PrinterSettingUtility
//
//  Created by Wang Kun on 2/24/14.
//  Copyright (c) 2014 Wang Kun. All rights reserved.
//

#import "SettingsController.h"

@interface PSRNetworkSettingViewController : SettingsController <NSTableViewDataSource, NSTableViewDelegate>
{
    IBOutlet NSScrollView *scrollView;
    
    IBOutlet NSTextField *ethernetLabel;
    IBOutlet NSTextField *protocolsLabel;
    IBOutlet NSTextField *filter1Label;
    IBOutlet NSTextField *filter2Label;
    IBOutlet NSTextField *filter3Label;
    IBOutlet NSTextField *filter4Label;
    IBOutlet NSTextField *filter5Label;

    
    NSMutableArray *firstColumnItems1;
    NSMutableArray *firstColumnItems2;
    NSMutableArray *firstColumnItems3;
    NSMutableArray *firstColumnItems4;
    NSMutableArray *firstColumnItems5;
    NSMutableArray *firstColumnItems6;
    NSMutableArray *firstColumnItems7;

    
    NSMutableArray *secondColumnItems1;
    NSMutableArray *secondColumnItems2;
    NSMutableArray *secondColumnItems3;
    NSMutableArray *secondColumnItems4;
    NSMutableArray *secondColumnItems5;
    NSMutableArray *secondColumnItems6;
    NSMutableArray *secondColumnItems7;
	//wifi sector
	
	IBOutlet NSTextField *filter6Label;
	NSMutableArray *firstColumnItems;
    NSMutableArray *secondColumnItems;
	
	//wifi direct sector
	
	IBOutlet NSTextField *filter7Label;
	NSMutableArray *directFirstColumnItems;
    NSMutableArray *directSecondColumnItems;
	
}

@end
