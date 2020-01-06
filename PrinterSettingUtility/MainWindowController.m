//
//  MainWindowController.m
//  MachineSetup
//
//  Created by Wang Kun on 10/29/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//


#import "MainWindowController.h"
#import "TargetVersion.h"
#import "AppDelegate.h"


@implementation MainWindowController

- (void)dealloc
{
    [super dealloc];
}

- (void)windowDidLoad
{
	
    [super windowDidLoad];
    
	[[self window] center];

	
    [[self window] setDelegate:self];
    [titleImageView setImage:[NSImage imageNamed:TITLE_IMAGE]];
    [[[self window] standardWindowButton:NSWindowZoomButton] setHidden:YES];
    
    [helpButton setTitle:NSLocalizedString(@"Help", nil)];
    
    NSMenu *mainMenu = [NSApp mainMenu];
    NSMenuItem *aboutItem = [mainMenu itemAtIndex:0];

    NSMenu *aboutSubMeun = [aboutItem submenu];
    [aboutSubMeun setTitle:NSLocalizedString(@"Printer Setting Utility", nil)];
    NSString *tmp = [NSString stringWithString:NSLocalizedString(@"Printer Setting Utility", nil)];
    NSString *itemTitle0 = [[NSString stringWithString:NSLocalizedString(@"About", nil)] stringByAppendingFormat:@" %@", tmp];
    NSString *itemTitle1 = [[NSString stringWithString:NSLocalizedString(@"Quit", nil)] stringByAppendingFormat:@" %@", tmp];
    [[aboutSubMeun itemAtIndex:0] setTitle:itemTitle0];
    [[aboutSubMeun itemAtIndex:1] setTitle:itemTitle1];

	
	NSMenuItem *editItem = [mainMenu itemAtIndex:1];
	NSMenu *editSubMeun = [editItem submenu];
    [editSubMeun setTitle:NSLocalizedString(@"IDS_EDIT", nil)];

    NSString *editItemTitle1 = [NSString stringWithString:NSLocalizedString(@"IDS_COPY", nil)];
	NSString *editItemTitle2 = [NSString stringWithString:NSLocalizedString(@"IDS_PASTE", nil)];
	NSString *editItemTitle3 = [NSString stringWithString:NSLocalizedString(@"IDS_SELECT_ALL", nil)];
	[[editSubMeun itemAtIndex:3] setTitle:editItemTitle1];
    [[editSubMeun itemAtIndex:4] setTitle:editItemTitle2];
	[[editSubMeun itemAtIndex:5] setTitle:editItemTitle3];

}
#if 1
- (BOOL)windowShouldClose:(id)sender
{
    if (unSupported) {
		isClosed = TRUE;
        return YES;
	}
	

	
	
	NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
    [alert setInformativeText:NSLocalizedString(@"Are you sure you want to exit Printer Setting Utility?", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", nil)];
    [alert addButtonWithTitle:NSLocalizedString(@"Cancel", nil)];
    
    if([alert runModal] == NSAlertFirstButtonReturn)
    {
        [alert release];
		
		if (isChanged)
		{
			NSAlert *canLeaveAlert = [[NSAlert alloc] init];
			[canLeaveAlert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
			[canLeaveAlert setInformativeText:NSLocalizedString(@"The setting has been changed. Do you want to cancel the settings?", NULL)];
			[canLeaveAlert addButtonWithTitle:NSLocalizedString(@"OK", NULL)];
			[canLeaveAlert addButtonWithTitle:NSLocalizedString(@"Cancel", NULL)];
			
			if( [canLeaveAlert runModal] == NSAlertSecondButtonReturn)
			{
				[canLeaveAlert release];
				return NO;  //When NO, this method will be invoked again.
			}
			
			[canLeaveAlert release];
		}
		
		isClosed = TRUE;
        return YES;
    }
    else
    {
        [alert release];
    }
    

	
	
    return NO;


}
#endif
- (IBAction)helpButtonAction:(id)sender
{
    
}

@end
