//
//  AboutController.m
//  MachineSetup
//
//  Created by Helen Liu on 9/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AboutController.h"
#import "TargetVersion.h"


@implementation AboutController

- (id)init
{
    self = [super init];
    
    if (self) {
        
        self = [self initWithWindowNibName:@"About"];
        
               
    }
    
    return self;
}

- (void)dealloc
{
   
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [[self window] setTitle:NSLocalizedString(@"About", NULL)];
    NSImage *imageTitle = [NSImage imageNamed:ABOUT_IMAGE];
    [imageViewBackgrd setImage:imageTitle];
    
    [nameTextField setStringValue:NSLocalizedString(@"Printer Setting Utility", NULL)]; 
    
    NSBundle * bundle = [NSBundle mainBundle];
    
    // Version
	NSString * version = NSLocalizedString(@"Version", NULL);
	NSString * retstr = [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];

	NSString *notice = NSLocalizedStringFromTable(IDS_CopyRight, @"CrossVendor_I",nil); 
#ifdef MACHINESETUP_XC
	notice = NSLocalizedStringFromTable(IDS_CopyRight, @"CrossVendor_X",nil);
#endif
	
	NSString * versionstr = [NSString stringWithFormat:@"%@ %@", version, retstr];
	[versionTextField setStringValue:versionstr];
    [noticeTextField setStringValue:notice];
    
  
  	NSString *copyright = NSLocalizedStringFromTable(IDS_CopyRightH, @"CrossVendor_I",nil); 
#ifdef MACHINESETUP_XC
	copyright = NSLocalizedStringFromTable(IDS_CopyRightH, @"CrossVendor_X",nil);
#endif  
	
	[copyrightTextField setStringValue:copyright];
    
    
    [okButton setTitle:NSLocalizedString(@"OK", NULL)];
    
//    [selectPrinterTextField setStringValue:NSLocalizedString(@"Select Printer:", NULL)]; 
//    [[printerNameColumn headerCell] setStringValue:NSLocalizedString(@"Printer Name", NULL)];
//    [[modelNameColumn headerCell] setStringValue:NSLocalizedString(@"Model Name", NULL)];
//    [[connectedToColumn headerCell] setStringValue:NSLocalizedString(@"Connected To", NULL)];
//    [closeButton setTitle:NSLocalizedString(@"Close", NULL)];
}

-(void)showAbout
{
    [NSApp runModalForWindow:[self window]];
}

- (IBAction)onOK:(id)sender {
    
    [NSApp stopModal];
}
@end
