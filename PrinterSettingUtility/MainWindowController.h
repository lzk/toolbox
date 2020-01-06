//
//  MainWindowController.h
//  MachineSetup
//
//  Created by Wang Kun on 10/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MainWindowController : NSWindowController <NSWindowDelegate>
{
    IBOutlet NSImageView *titleImageView;
    IBOutlet NSButton *helpButton;
}

- (IBAction)helpButtonAction:(id)sender;

@end
