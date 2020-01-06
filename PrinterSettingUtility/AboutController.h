//
//  AboutController.h
//  MachineSetup
//
//  Created by Helen Liu on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface AboutController : NSWindowController {
@private
    
    IBOutlet NSButton *okButton;
    
    IBOutlet NSTextField *trademarkTextField;
    IBOutlet NSTextField *copyrightTextField;
    IBOutlet NSTextField *versionTextField;
    IBOutlet NSTextField *nameTextField;
    IBOutlet NSImageView *imageViewBackgrd;
    IBOutlet NSTextField *noticeTextField;
}

-(void)showAbout;
- (IBAction)onOK:(id)sender;

@end
