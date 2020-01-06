//
//  MainTabController.m
//  MachineSetup
//
//  Created by Helen Liu on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "AppDelegate.h"
#import "DataStructure.h"
#import "MainTabController.h"
#import "PrinterInformationController.h"
#import "traySettingsController.h"
#import "InformationPagesController.h"
#import "SystemSettingsController.h"
#import "AdjustBTR.h"
#import "AdjustFuser.h"
#import "AdjustAltitudeController.h"
#import "ResetDefaultsController.h"
#import "ChartPrintController.h"
#import "CleanDeveloperController.h"
#import "RefreshModeController.h"
#import "DeviceCommunicator.h"
#import "PrinterSelectorController.h"
#import "PSRMenuSettingsViewController.h"
#import "PSRTCPIPViewController.h"
#import "PMAdjustPaperTypeViewController.h"
#import "PMDensityAdjustmentViewController.h"
#import "PMRegistrationAdjustmentViewController.h"
#import "PMNonGenuineModeViewController.h"
#import "PMBTRRefreshModeViewController.h"
#import "PMTCPIPViewController.h"
#import "PMTraySettingsViewController.h"
#import "PMInternetServicesViewController.h"
#import "PMMachineLifeViewController.h"
#import "PMSecuritySettingsViewController.h"
#import "DEnvironmentSensorInforViewController.h"
#import "PMNetwrokSettingsViewController.h"
#import "PMWirelessSetupViewController.h"
#import "PSRNetworkSettingViewController.h"
#import "PSRWirelessSetupViewController.h"

#define keyPrinterName @"PrinterName"
#define keyModelName @"ModelName"
#define keyConnectedTo @"ConnectedTo"

@implementation MainTabController

@synthesize tabViewMain;

enum 
{
    ID_TabPSR = 0,
    ID_TabPM,
    ID_TabDiag
};

- (void)initSettingsType:(int)TabID
{
    if(nil == arrayCurrentContents)
    {
        arrayCurrentContents = [[NSMutableArray alloc]init];
    }
    else
    {
        [arrayCurrentContents removeAllObjects];
    }
    if(ID_TabPSR == TabID)
    {
        [arrayCurrentContents addObject:[PrinterInformationController class]];
        [arrayCurrentContents addObject:[PSRMenuSettingsViewController class]];
        [arrayCurrentContents addObject:[InformationPagesController class]];
        [arrayCurrentContents addObject:[PSRTCPIPViewController class]];
        [arrayCurrentContents addObject:[PSRNetworkSettingViewController class]];
       // [arrayCurrentContents addObject:[PSRWirelessSetupViewController class]]; //merge to network
#ifdef MACHINESETUP_AIRPRINT
		[arrayCurrentContents addObject:[traySettingsController class]];
#endif
    }
    
    if(ID_TabPM == TabID)
    {
  
        [arrayCurrentContents addObject:[SystemSettingsController class]];
        [arrayCurrentContents addObject:[PMAdjustPaperTypeViewController class]];
        [arrayCurrentContents addObject:[AdjustBTRController class]];
        [arrayCurrentContents addObject:[AdjustFuserController class]];
//#ifdef MACHINESETUP_IBG
        [arrayCurrentContents addObject:[PMRegistrationAdjustmentViewController class]];
//#endif
//#ifdef MACHINESETUP_XC
        //[arrayCurrentContents addObject:[PMDensityAdjustmentViewController class]];
//#endif
        [arrayCurrentContents addObject:[AdjustAltitudeController class]];
        [arrayCurrentContents addObject:[ResetDefaultsController class]];
#ifdef MACHINESETUP_IBG
        [arrayCurrentContents addObject:[PMNonGenuineModeViewController class]];
#endif
        [arrayCurrentContents addObject:[PMBTRRefreshModeViewController class]];
        [arrayCurrentContents addObject:[PMNetwrokSettingsViewController class]];
       // [arrayCurrentContents addObject:[PMWirelessSetupViewController class]]; //merge to network sector
        [arrayCurrentContents addObject:[PMTCPIPViewController class]];
#ifdef MACHINESETUP_AIRPRINT
        [arrayCurrentContents addObject:[PMTraySettingsViewController class]];
#endif
        [arrayCurrentContents addObject:[PMInternetServicesViewController class]];
        [arrayCurrentContents addObject:[PMMachineLifeViewController class]];
		//[arrayCurrentContents addObject:[PMSecuritySettingsController class]];
    }
    
    if(ID_TabDiag == TabID)
    {
        [arrayCurrentContents addObject:[ChartPrintController class]];
        [arrayCurrentContents addObject:[DEnvironmentSensorInforViewController class]];
        [arrayCurrentContents addObject:[CleanDeveloperController class]];
        [arrayCurrentContents addObject:[RefreshModeController class]];

    }
    
}

- (id)init
{
    self = [super init];
    
    arrayCurrentContents = nil;
    indexDefaultTabViewItem = ID_TabPSR;
    indexDefaultSettingsType = 0;
    canLeaveAlert = nil;
    
    if (self) {
		
#ifdef MACHINESETUP_IBG
		system("ipcrm -M0x52029884");
		system("ipcrm -M0x520281f8");
		
		
#endif
#ifdef MACHINESETUP_XC
		system("ipcrm -M0x52029883");
		system("ipcrm -M0x520281f7");
		
		
		
		
#endif
        [self initSettingsType:indexDefaultTabViewItem];
        //progressController = [[ProgressController alloc] init];
        currentPrinterView = nil;
    }
    
    return self;
}

- (void)dealloc
{    
    [arrayCurrentContents release];
    [progressThread release];
    
    if(nil != currentPrinterView)
    {
        [currentPrinterView release];
    }
    
    
    [super dealloc];
}

- (void)awakeFromNib
{
	

	
	
    PrinterSelectorController *printerSelector= [[PrinterSelectorController alloc] init];
    
    NSMutableString *printerName = [[NSMutableString alloc] initWithCapacity:1];
    NSMutableString *modelName = [[NSMutableString alloc]  initWithCapacity:1];
    NSMutableString *connectedTo = [[NSMutableString alloc]  initWithCapacity:1];
    NSMutableString *printerID = [[NSMutableString alloc]  initWithCapacity:1];

    BOOL code = [printerSelector printerInfo_printerName:printerName modelName:modelName
                 connectedTo:connectedTo printerID:printerID];
    
    [printerSelector close];
    [printerSelector release];
    
    if(NO == code)
    {
        [printerName release];
        [modelName release];
        [connectedTo release];
        [printerID release];
        
        printerName = nil;
        modelName = nil;
        connectedTo = nil;
        printerID = nil;
		
        unSupported = YES;
        [NSApp terminate:nil];
        return;
    }
    else
    {
        AppDelegate *app = [NSApp delegate];
        
        [app setPrinterName:printerName ModalName:modelName ConnectTo:connectedTo PrinterID:printerID];
        
        [printerName release];
        [modelName release];
        [connectedTo release];
        [printerID release];
        
        printerName = nil;
        modelName = nil;
        connectedTo = nil;
        printerID = nil;

    }
    
    NSURL *url = [NSURL URLWithString:[[NSApp delegate] connectedTo]];
    NSLog(@"url = %@", url);
	NSString *scheme = [url scheme];	
	if ([scheme compare:@"usb" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [[NSApp delegate] setSelectedDevType:DEV_TYPE_USB];
    }
    else if ([scheme compare:@"socket" options:NSCaseInsensitiveSearch] == NSOrderedSame ||  
             [scheme compare:@"lpd" options:NSCaseInsensitiveSearch] == NSOrderedSame    ||
             [scheme compare:@"ipp" options:NSCaseInsensitiveSearch] == NSOrderedSame    ||
             [scheme compare:@"dnssd" options:NSCaseInsensitiveSearch] == NSOrderedSame)
    {
        [[NSApp delegate] setSelectedDevType:DEV_TYPE_NET];
    }
    
    NSString *tmp = [[[[NSApp delegate] modelName] componentsSeparatedByString:@" v"] objectAtIndex:0];
    [[NSApp delegate] setModelNameNoVersion:tmp];

  //  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showProgressWindow:)
  //                                        name:@"PROGRESSNOTIFY" object:NULL];
    
    NSTabViewItem *tab = [tabViewMain tabViewItemAtIndex:ID_TabPSR];
    [tab setView:viewContiner];
	[tab setLabel:NSLocalizedString(@"IDS_SETTING_REPORT",NULL)];
  
    tab = [tabViewMain tabViewItemAtIndex:ID_TabPM];
    [tab setView:viewContiner];
    [tab setLabel:NSLocalizedString(@"Printer Maintenance", NULL)];
    
    tab = [tabViewMain tabViewItemAtIndex:ID_TabDiag];
    [tab setView:viewContiner];
    [tab setLabel:NSLocalizedString(@"Diagnosis", NULL)];
    [viewContiner setAutoresizingMask:NSViewHeightSizable];
    [boxLine setAutoresizingMask:NSViewMaxYMargin];
    [textFieldPrinterStatus setAutoresizingMask:NSViewMaxYMargin];

#ifdef MACHINESETUP_IBG
    NSImage *imageLogo = [NSImage imageNamed:@"IBG.png"];
#endif
#ifdef MACHINESETUP_XC
    NSImage *imageLogo = [NSImage imageNamed:@"XC.png"];
#endif

    [imageViewLogo setImage:imageLogo];
    
    [textFieldPrinterStatus setStringValue:NSLocalizedString(@"Printer Status: Unknown",NULL)];
    
     AppDelegate *app = [NSApp delegate];
    [app launchStatusMonitor];
    
    [self startDetectPrinterInfomation];
    


    if(ID_TabPSR != indexDefaultTabViewItem)
    {
        [tabViewMain selectTabViewItemAtIndex:indexDefaultTabViewItem];// could call shouldSelectedTabView..
    }
    else
    {
        [self tabView:tabViewMain shouldSelectTabViewItem:[tabViewMain tabViewItemAtIndex:0]];
        //[self setupCurrentTab:indexDefaultTabViewItem];
    }
    
    indexDefaultSettingsType = 0;
    indexDefaultTabViewItem = 0;
   
}

- (BOOL)tabView:(NSTabView *)tabViewFrom shouldSelectTabViewItem:(NSTabViewItem *)tabViewItem
{
	//NSLock  *tabLock = [[NSApp delegate] tabLock];
	
    if(tabViewFrom != tabViewMain)
        return NO;
    
		
    if (currentPrinterView)
    {
        if ([currentPrinterView canLeave] == NO )
        {  
		
			canExit = NO;
            canLeaveAlert = [[NSAlert alloc] init];
            [canLeaveAlert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
            [canLeaveAlert setInformativeText:NSLocalizedString(@"The setting has been changed. Do you want to cancel the settings?", NULL)];
            [canLeaveAlert addButtonWithTitle:NSLocalizedString(@"OK", NULL)];
            [canLeaveAlert addButtonWithTitle:NSLocalizedString(@"Cancel", NULL)];
            
            if( [canLeaveAlert runModal] == NSAlertSecondButtonReturn)
            {
                return NO;
            }
            else
            {
                //[currentPrinterView release];
                currentPrinterView = nil;
            }
        }
		else {
			canExit = YES;
		}

		
    }
    

	
    int indexTab = [tabViewFrom indexOfTabViewItem:tabViewItem];
    [self setupCurrentTab:indexTab];
    
    [tableViewSettingsType selectRowIndexes:[NSIndexSet indexSetWithIndex:indexDefaultSettingsType] byExtendingSelection:NO];
    
    [self tableView:tableViewSettingsType shouldSelectRow:indexDefaultSettingsType];
    
    return YES;
    
}


- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(!arrayCurrentContents)
        
        return 0;
    
    return [arrayCurrentContents count];  
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    
    if(arrayCurrentContents && rowIndex < [arrayCurrentContents count])
    {
        NSString * stringType = [[arrayCurrentContents objectAtIndex:rowIndex] description];
        
        return stringType;
    }
    
    return nil;
  
}

- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(int)rowIndex
{
	 NSLock  *tabLock = [[NSApp delegate] tabLock];


	
	//NSLog(@"[tabLock tryLock] = %i",[tabLock tryLock]);
    if(g_bDoing)
        return NO;
	
	// g_bDoing = YES;
	
    if(arrayCurrentContents == nil)
        return NO;
    
    if(rowIndex < 0 || rowIndex >= [arrayCurrentContents count])
        return NO;
    
	
	if([tabLock tryLock] == NO)
		return NO;
	
	
    if(nil != currentPrinterView)  
    {
        if ([currentPrinterView canLeave] == NO )
        {
            if (canLeaveAlert == nil)
            {
                canLeaveAlert = [[NSAlert alloc] init];
                [canLeaveAlert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
                [canLeaveAlert setInformativeText:NSLocalizedString(@"The setting has been changed. Do you want to cancel the settings?", NULL)];
                [canLeaveAlert addButtonWithTitle:NSLocalizedString(@"OK", NULL)];
                [canLeaveAlert addButtonWithTitle:NSLocalizedString(@"Cancel", NULL)];
                
                if( [canLeaveAlert runModal] == NSAlertSecondButtonReturn)
                {
					[tabLock tryLock];
					[tabLock unlock];
                    return NO;  //When NO, this method will be invoked again.
                }
            }
            else
            {
                [canLeaveAlert release];
                canLeaveAlert = nil;
				[tabLock tryLock];
				[tabLock unlock];
                return NO;
            }
        }
    }
    
    if (canLeaveAlert != nil)
    {
        [canLeaveAlert release];
        canLeaveAlert = nil;
    }
    
	
    [currentPrinterView release];
    currentPrinterView = nil;

	
    Class aClass = [[arrayCurrentContents objectAtIndex:rowIndex] autorelease];
    currentPrinterView = [[aClass alloc] init]; 
    
    
    NSView * view = [currentPrinterView view];
    

	
	
	
    NSTabViewItem *tabContiner = [tabViewSettingsDlgContiner tabViewItemAtIndex:0]; 
    
	
	
    [tabContiner setView:view];
    

	
    [currentSettingsTitleText setStringValue:[currentPrinterView contentTitle]];
    

	
    [self communicateWithDevice];
	//[tabLock unlock];
    return YES; 
    
}


- (void)layoutTabViewItem
{
    NSRect rectTableFrame = [tableViewSettingsType frame];
    NSRect rectScroll = [[tableViewSettingsType enclosingScrollView] frame];
    NSRect rectRow = [tableViewSettingsType rectOfRow:0];
    float height = NSWidth(rectScroll) - NSWidth(rectTableFrame) + NSHeight(rectRow) * [tableViewSettingsType numberOfRows];
    
    float yTopLeft = rectScroll.origin.y + rectScroll.size.height;
    rectScroll.size.height = height;
    rectScroll.origin.y = yTopLeft - rectScroll.size.height;
    
    //rectTableFrame.size.height = NSHeight(rectRow) * [tableViewSettingsType numberOfRows];

    //[[tableViewSettingsType enclosingScrollView] setAutoresizesSubviews:YES];
    
    [[tableViewSettingsType enclosingScrollView] setFrame:rectScroll];
    [[tableViewSettingsType enclosingScrollView] setNeedsDisplay:YES];
//    [tableViewSettingsType setFrame:rectTableFrame];
//    [tableViewSettingsType setNeedsDisplay:YES];
    
    NSRect rectLogo = [imageViewLogo frame];
    
    rectLogo.origin.y = rectScroll.origin.y - 30 - rectLogo.size.height;
    [imageViewLogo setFrame:rectLogo];
    [imageViewLogo setNeedsDisplay:YES];
  
}


-(void)setupCurrentTab:(int)indexTab
{
    [self initSettingsType:indexTab];
    
    [tableViewSettingsType reloadData];
    
    [self layoutTabViewItem];
}


- (BOOL)communicateWithDevice
{
    if(nil == currentPrinterView)
    {
        return FALSE;
    }
    
    
    [currentPrinterView getInfoFromDevice];
    return TRUE; 
}

- (void) setPrinterInfo:(NSMutableDictionary *)dict
{
    NSString *stringPrinterName = [[NSString alloc]initWithFormat:@"%@", [dict valueForKey:keyPrinterName]];
    NSString *stringLocation =[[NSString alloc]initWithFormat:@"%@", [dict valueForKey:keyConnectedTo]];
    
    AppDelegate *app = [NSApp delegate];
    [app setPrinterName:stringPrinterName ModalName:nil ConnectTo:stringLocation PrinterID:nil];
    
    [stringPrinterName release];
    stringPrinterName = nil;
    [stringLocation release];
    stringLocation = nil;
}

- (void)closeAPP
{
	
    [NSApp terminate:nil];
}


- (void)setStatusMonitorToReady
{
    NSLog(@"set Mon");
    AppDelegate *app = [NSApp delegate];
    [app setStatusMonitorToReady];
}

- (void) detectPrinterInfomation:(id)inObject 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    NSString *strPrinterID = [inObject objectAtIndex:0];
    NSRecursiveLock  *threadLock = [inObject objectAtIndex:1];
    const char *buffer = [strPrinterID UTF8String];
    CFStringRef printerID = CFStringCreateWithCString(NULL, buffer, kCFStringEncodingUTF8);
    if(printerID == nil)
    {
        return;
    }
    
    BOOL isFirstCycle = YES;
    while(1)
    {
        while([threadLock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:100000]] == NO)
        {
            NSLog(@"detectPrinterInfomation thread lock fail");
            //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            //continue;
        }
        
        NSAutoreleasePool *subpool = [[NSAutoreleasePool alloc] init];
        DeviceCommunicator *communicator = [[DeviceCommunicator alloc]init];
        UInt32 status;
        
        if(isFirstCycle)
        {
            [communicator printerStatus:&status CurrentPrinterID:strPrinterID IsNeedWait:YES];
            [self performSelectorOnMainThread:@selector(setStatusMonitorToReady) withObject:nil waitUntilDone:YES];
            //isFirstCycle = NO;
        }
        else
        {
            [communicator printerStatus:&status CurrentPrinterID:strPrinterID IsNeedWait:NO];
        }
        NSLog(@"d thread status = %x", status);
        
        [self performSelectorOnMainThread:@selector(updatePrinterStatus:) withObject:[NSNumber numberWithInt:status] waitUntilDone:YES];
        [communicator release];
        communicator = nil;
        
        PMPrinter printer = NULL;
        int i;
        for(i = 0; i < 30; i++)
        {
            printer = PMPrinterCreateFromPrinterID(printerID);
            
            if(printer != NULL)
                break;
            
            //usleep(1000 * 1000);
        }
        
        if(printer == NULL)
        {
            NSLog(@"dThread, current printer has already not exist");
			isClosed = YES;
            [self performSelectorOnMainThread:@selector(closeAPP) withObject:nil waitUntilDone:NO];
            [subpool release];
            [threadLock unlock];
            break;
        }
                    
        //	Find out its name
        CFStringRef printerName = PMPrinterGetName(printer);
        if (printerName == NULL)
        {
            PMRelease(printer);
            [subpool release];
            [threadLock unlock];
            continue;
        }
        
        // Get the URI (Uniform Resource Identifier).
        // A URI is much like an URL, as it defines the location and protocol of a device.
        CFURLRef printerURI;
        PMPrinterCopyDeviceURI(printer, &printerURI);
        if (printerURI == NULL)
        {
            PMRelease(printer);
            [subpool release];
            [threadLock unlock];
            continue;
        }
        
        // Add our printer info dictionary to the array
        NSMutableDictionary *dict = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     (NSString *)printerName, keyPrinterName,
                                     (NSString *)CFURLGetString(printerURI),keyConnectedTo, nil];
        [self performSelectorOnMainThread:@selector(setPrinterInfo:) withObject:dict waitUntilDone:YES];
        
        PMRelease(printer);
        //CFRelease(printerName);
        CFRelease(printerURI);
        [threadLock unlock];
       // [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        [subpool release];
    }
    
    CFRelease(printerID);
    [pool release];
}

- (BOOL) startDetectPrinterInfomation
{
    AppDelegate *app = [NSApp delegate];
    NSString *printerID = [app printerID];
    if(printerID == nil)
    {
        return NO;
    }
    
    NSRecursiveLock *threadLock = [app lockThread];
    NSArray *param = [NSArray arrayWithObjects:printerID, threadLock, nil];
    [NSThread detachNewThreadSelector:@selector(detectPrinterInfomation:) toTarget:self withObject:param];
    
    return YES;
}
/*
- (BOOL)canClose
{
    if(nil != currentPrinterView)
    {
        if(NO == [currentPrinterView canLeave])
        {
            return NO;
        }
    }
    
    return YES;
}
- (BOOL)windowShouldClose:(id)sender
{
    if(NO == [self canClose])
        return NO;
    
    return YES;
}

- (BOOL)shouldCloseDocument
{
    return YES;
}
*/
- (void)updatePrinterStatus:(NSNumber *)status
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
        
    NSString *stringID = nil;
    int iStatus = [status intValue];
    
    switch(iStatus)
    {
        case T_PRINTER_STATUS_READY:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Ready"];
            break;
        case T_PRINTER_STATUS_PRINTING:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Printing"];
            break;
        case T_PRINTER_STATUS_POWER_SAVE_MODE:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Power Saver Mode"];
            break; 
        case T_PRINTER_STATUS_WARMING_UP:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Warming Up"];
            break;
        case T_PRINTER_STATUS_PENDING_DELETION:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Job is Pending Deletion"];
            break;
        case T_PRINTER_STATUS_PAUSE:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Pause"];
            break;
        case T_PRINTER_STATUS_WAITING:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Waiting"];
            break;
        case T_PRINTER_STATUS_PROCESSING:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Processing"];
            break;
        case T_PRINTER_STATUS_BUSY:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Busy"];
            break;
        case T_PRINTER_STATUS_OFFLINE:
            //stringID = [[NSString alloc]initWithString:@"Printer Status: Offline"];
            stringID = [[NSString alloc]initWithString:@"Printer Status: Unknown"];    //11.19 modify to same as Windows
            break;
        case T_PRINTER_STATUS_TONER_LOW:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Toner Low"];
            break;
        case T_PRINTER_STATUS_INITIALIZING:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Initializing"];
            break;
        case T_PRINTER_STATUS_UNKNOWN:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Unknown"];
            break;
        case T_PRINTER_STATUS_ACTIVE:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Active"];
            break;
        case T_PRINTER_STATUS_MANUAL_FEED_REQUIRED:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Manual Feed Required"];
            break;
        case T_PRINTER_STATUS_PAPER_JAM:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Paper Jam"];
            break;
        case T_PRINTER_STATUS_DOOR_OPEN:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Cover is Open"];
            break;
        case T_PRINTER_STATUS_OUT_OF_MEMORY:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Out of Memory"];
            break;
        case T_PRINTER_STATUS_OUT_OF_PAPER:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Out of Paper"];
            break;
        case T_PRINTER_STATUS_PAPER_PROBLEM:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Paper Problem"];
            break;
        case T_PRINTER_STATUS_NO_TONER:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Out of Toner"];
            break;
        case T_PRINTER_STATUS_PAGE_ERROR:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Page Error"];
            break;
        case T_PRINTER_STATUS_NOT_AVAILABLE:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Not Available"];
            break;
        case T_PRINTER_STATUS_NOT_SUPPORT:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Not Supported"];
            break;
        case T_PRINTER_STATUS_USER_INTERVENTION_REQUIRED:
            stringID = [[NSString alloc]initWithString:@"Printer Status: User Intervention Required"];
            break;
        case T_PRINTER_ADF_COVER_OPEN:
            stringID = [[NSString alloc]initWithString:@"Printer Status: ADF Cover Open"];
            break;
        case T_PRINTER_ADF_PAPER_JAM:
            stringID = [[NSString alloc]initWithString:@"Printer Status: ADF Paper Jam"];
            break;
        case T_PRINTER_STATUS_POWER_OFF:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Power Off"];
            break;
        case T_PRINTER_STATUS_ERROR:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Error"];
            break;
        default:
            stringID = [[NSString alloc]initWithString:@"Printer Status: Unknown"];
    }
    
    [textFieldPrinterStatus setStringValue:NSLocalizedString(stringID, NULL)];
    [[NSApp delegate] setPrinterState:stringID];
    [stringID release];
    stringID = nil;
    
    [pool release];
}


//------MING ------ 
-(BOOL)tableView:(NSTableView *)tableView shouldTypeSelectForEvent:(NSEvent *)event withCurrentSearchString:(NSString *)searchString
{
    return NO;
}//----------------
@end
