//
//  ProgressController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

extern BOOL g_bDoing;
@interface ProgressController : NSWindowController {
@private
    IBOutlet NSTextField *progressDescriptionText;
    IBOutlet NSLevelIndicator *progressLevelIndicator;
    NSModalSession			session;
    
    //IBOutlet NSView *responderView;
    NSString *descriptionString;
    double    progressNumber;
    BOOL      isFinish;

    //NSThread *progressThread;
}

- (void)showProgressWindow:(BOOL)isShow;
- (void)setProgressDescription:(NSString*)string;
- (void)gotoNextProgress;
- (void)gotoFinalProgress;
@end
