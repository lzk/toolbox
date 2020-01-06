//
//  ProgressController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgressController.h"

BOOL g_bDoing = NO;
@implementation ProgressController


- (id)init
{
    self = [super init];
    
    if (self) {
        self = [self initWithWindowNibName:@"Progress"];
    }
    
    return self;
}

- (void)dealloc
{
    g_bDoing = NO;

    [super dealloc];
}

- (void)awakeFromNib
{
    g_bDoing = YES;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    NSString *verStr = [[NSProcessInfo processInfo] operatingSystemVersionString];
    char d = [verStr characterAtIndex:11];

    if(d > '5')
    {
        NSWindow *window = [self window];
        [window setStyleMask:NSBorderlessWindowMask];
    }
    
}
- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent
{

}

- (void)keyUp:(NSEvent *)theEvent
{
    
}
- (BOOL)acceptsFirstResponder {
    return YES;
}


    
- (void)showProgressWindow:(BOOL)isShow
{
    if(YES == isShow)
    {
        NSWindow* window = [self window];
        [progressDescriptionText setStringValue:@""];
        [progressLevelIndicator setDoubleValue:0];
        
		//[window center];
		[window makeKeyAndOrderFront:window];
		
        [NSApp runModalForWindow:window];
    }
    else
    {
        [self gotoFinalProgress];
        [NSApp stopModal];
        [[self window] orderOut:self];
		[[self window] close];
    }
}

- (void)setProgressDescription:(NSString*)string
{
    //NSLog(@"setProgressDescription start");
    if(nil != progressDescriptionText)
    {
        //NSLog(@"%@", string);
        [progressDescriptionText setStringValue:string];
    }
    //NSLog(@"setProgressDescription end");
}
- (void)gotoNextProgress
{
    progressNumber ++;
    
    //NSLog(@"<------ gotoNextProgress:%f %@--------->", progressNumber, progressLevelIndicator);
    if(progressLevelIndicator != nil)
    {
        [progressLevelIndicator setDoubleValue:progressNumber];
    }
}

- (void)gotoFinalProgress
{
    double maxValue = [progressLevelIndicator maxValue];
    if(progressNumber < maxValue  && progressLevelIndicator != nil)
    {
        [progressLevelIndicator setDoubleValue:maxValue];
        
    }
    g_bDoing = NO;
}

@end
