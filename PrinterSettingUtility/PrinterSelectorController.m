//
//  PrinterSelectorController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrinterSelectorController.h"
#import "AppDelegate.h"
#import "DataStructure.h"
#import "TargetVersion.h"

#define keyPrinterName @"PrinterName"
#define keyModelName @"ModelName"
#define keyConnectedTo @"ConnectedTo"
#define keyPrinterID @"PrinterID"

@implementation PrinterSelectorController


- (id)init
{
    self = [super init];
    if (self) {
		
#ifdef MACHINESETUP_XC
		system("killall xrstatussmon");
		system("rm -Rf /tmp/XeorxStatusService.lock");
		
#endif
		
#ifdef MACHINESETUP_IBG
		system("killall fxstatussmon");
		system("rm -Rf /tmp/FXStatusService.lock");
#endif
		
        self = [self initWithWindowNibName:@"PrinterSelector"];
        printerInfoList = [[NSMutableArray alloc]init];
        [self makeList];
    }
    return self;
}

- (void)dealloc
{
    [printerInfoList release];
    
    [super dealloc];
}

- (void)awakeFromNib
{
    [[self window] setTitle:NSLocalizedString(@"Printer Setting Utility", NULL)]; 
    [selectPrinterTextField setStringValue:NSLocalizedString(@"Select Printer:", NULL)]; 
    [[printerNameColumn headerCell] setStringValue:NSLocalizedString(@"Printer Name", NULL)];
    [[modelNameColumn headerCell] setStringValue:NSLocalizedString(@"Model Name", NULL)];
    [[connectedToColumn headerCell] setStringValue:NSLocalizedString(@"Connected To", NULL)];
    [closeButton setTitle:NSLocalizedString(@"Close", NULL)];
}


-(void)makeList
{	
	//	First, grab a list of available printers
	CFArrayRef printerList;
	
	// Don't forget to check for errors in production code!
    PMServerCreatePrinterList(kPMServerLocal, &printerList);
	
    UInt32 numberOfPrinters = CFArrayGetCount(printerList);
    UInt32 printerIndex;

    //	For each printer in the list
    for(printerIndex = 0; printerIndex < numberOfPrinters; printerIndex++)
    {       
        //	Get a reference to the printer
        PMPrinter printer =(PMPrinter)CFArrayGetValueAtIndex(printerList, printerIndex);
		
		// Model Number?
		CFStringRef makeAndModel;
		PMPrinterGetMakeAndModelName(printer,&makeAndModel);
		if (makeAndModel == NULL)
		{
			continue;
		}
        
        NSString *modelName = [[(NSString *)makeAndModel componentsSeparatedByString:@" v"] objectAtIndex:0];
		if ([[NSApp delegate] isSupportedPrinter:modelName] == NO)
		{
			continue;
		}
		
        //	Find out its name
        CFStringRef printerName = PMPrinterGetName(printer);
		if (printerName == NULL)
		{
			continue;
		}

        // Get the URI (Uniform Resource Identifier).
        // A URI is much like an URL, as it defines the location and protocol of a device.
        
        CFURLRef printerURI;
        PMPrinterCopyDeviceURI(printer, &printerURI);
        
		if (printerURI == NULL)
		{
			continue;
		}
        

//        CFRelease(printerURI); // lead to 10.4 10.5 cannot run.
        
        CFStringRef printerID = PMPrinterGetID(printer);
         
        // Add our printer info dictionary to the array
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     (NSString *)printerName, keyPrinterName,
                                     (NSString *)makeAndModel,keyModelName,
                                     CFURLGetString(printerURI),keyConnectedTo, 
                                     (NSString *)printerID,keyPrinterID,
                                     nil];
        
       // NSString * str2 = [[NSString alloc] initWithFormat:@"%@", dict];
        
        [printerInfoList addObject: dict];
        NSLog(@"dic = %@", dict);
        
    }
    
	CFRelease(printerList);
}


- (void)inspect:(NSArray *)selectedObjects
{
	// handle user double-click
	
	// this is an example of inspecting each selected object in the selection
	int index;
	int numItems = [selectedObjects count];
    
    if(numItems <= 0)
        return;
    
	for (index = 0; index < numItems; index++)
	{
		NSMutableDictionary *objectDict = [selectedObjects objectAtIndex:index];
		if (objectDict != nil)
		{
//			//NSLog(@"inspect item: {%@ %@, %@}",
//				  [objectDict valueForKey:keyPrinterName],
//				  [objectDict valueForKey:keyModelName],
//				  [objectDict valueForKey:keyConnectedTo]);
            
            selectedPrinterInfo = objectDict;

            
		}
	}
	

    
    [NSApp stopModalWithCode:YES];
    
    //[self close];
}

- (IBAction)onStopButton:(id)sender {
    isClosed = TRUE;
    [NSApp stopModalWithCode:NO];
    
    //[self close];
    
}

- (BOOL)printerInfo_printerName:(NSMutableString*)printerName modelName:(NSMutableString*) modelName connectedTo:(NSMutableString*)connectedTo printerID:(NSMutableString*) printerID
{
    int printerCount = [printerInfoList count];
    if(printerCount < 1)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
        [alert setInformativeText:NSLocalizedString(@"Supported printers are not installed in the system.", nil)];
        [alert runModal];
        isClosed = TRUE;
        return NO;
    }
    else if(printerCount == 1)
    {
        NSMutableDictionary *objectDict = [printerInfoList objectAtIndex:0];
        
        NSString *string = [[NSString alloc]initWithFormat:@"%@", [objectDict valueForKey:keyPrinterName]];
        [printerName setString:string];
        [string release];
        string = nil;
        
        string = [[NSString alloc]initWithFormat:@"%@", [objectDict valueForKey:keyModelName]];
        [modelName setString:string];
        [string release];
        string = nil;
        
        string =[[NSString alloc]initWithFormat:@"%@", [objectDict valueForKey:keyConnectedTo]];
        [connectedTo setString:string];
        [string release];
        string = nil;
        
        string =[[NSString alloc]initWithFormat:@"%@", [objectDict valueForKey:keyPrinterID]];
        [printerID setString:string];
        [string release];
        string = nil;
        
        return YES;
    }
    
    
    
    NSMenu *rootMenu = [NSApp mainMenu];
    //[rootMenu removeAllItems];
    
    if(YES == [NSApp runModalForWindow:[self window]])
    {        
        NSString *string = [[NSString alloc]initWithFormat:@"%@", [selectedPrinterInfo valueForKey:keyPrinterName]];
        [printerName setString:string];
        [string release];
        string = nil;
        
        string = [[NSString alloc]initWithFormat:@"%@", [selectedPrinterInfo valueForKey:keyModelName]];
        [modelName setString:string];
        [string release];
        string = nil;
        
        string =[[NSString alloc]initWithFormat:@"%@", [selectedPrinterInfo valueForKey:keyConnectedTo]];
        [connectedTo setString:string];
        [string release];
        string = nil;
        
        string =[[NSString alloc]initWithFormat:@"%@", [selectedPrinterInfo valueForKey:keyPrinterID]];
        [printerID setString:string];
        [string release];
        string = nil;
        
        return YES;
    }
    
    return NO;
}

//- (void)windowDidLoad
//{
//    [super windowDidLoad];
//    
//    NSWindow *window = [self window];
//    [window setStyleMask:NSBorderlessWindowMask];
//    //[window setAlphaValue:0.5f];
//    //[window setMovableByWindowBackground:YES];
//    
//}

@end