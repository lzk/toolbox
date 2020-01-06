//
//  SettingsController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "SettingsController.h"
//#import "ProgressController.h"
#import "DeviceCommunicator.h"
#import "AppDelegate.h"
#import "PrinterSelectorController.h"

#define USB_TYPE     1
#define NET_TYPE     2

@implementation SettingsController
@synthesize ID_PrinterSettings;
@synthesize contentTitle;
@synthesize SettingsName;
//@synthesize isEnalbeControllers;

- (id)init
{
    self = [super init];
    if (self) {
        
        if(nil == devciePropertyList)
        {
            devciePropertyList = [[NSMutableArray alloc]init];
            isNeedCheckPanelPassword = TRUE;
            isChanged = NO;
			isNotReflesh = NO;
            startDetectChangeEvent = NO;
        }
    }
    
    return self;
}

- (void)dealloc
{
    if(nil != progressController)
    {
        [progressController release];
        progressController = nil;
    }

    
    if(nil != devciePropertyList)
        [devciePropertyList release];
    
    [super dealloc];
}
- (void)awakeFromNib
{
    [applyNewSettingsButton setTitle:NSLocalizedString(@"Apply New Settings", NULL)];     
}

- (NSView *)view;
{
    return [super view];
}
+ (NSString *)description
{
    return @"SettingsController";
}

-(void)showProgressWindow:(NSNotification *)inNotification
{
    [progressController showProgressWindow:YES];
}

-(void)hideProgressWindow:(NSNotification *)inNotification
{
    [progressController showProgressWindow:NO];
}

-(void)UpdateProgressStatus:(NSString *)string
{
    //NSLog(@"<------ UpdateProgressStatus start  --------->");
    if(nil != string)
    {
        //NSLog(@"----- %@ -----", string);
        [progressController setProgressDescription:string];
    }
    [progressController gotoNextProgress];
    //NSLog(@"<------ UpdateProgressStatus end --------->");
}

- (void)updatePrinterStatus:(NSNumber *)status
{
    AppDelegate *app = [NSApp delegate];
    [app updatePrinterStatus:status];
}

- (void)progressThread:(id)inObject 
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    int result = DEV_ERROR_SUCCESS;
    
    location = [inObject objectAtIndex:0];
    NSMutableArray *propertyList = [inObject objectAtIndex:1];
    NSNumber *direction = [inObject objectAtIndex:2];
    NSRecursiveLock  *threadLock = [inObject objectAtIndex:3];
    NSString *printerID = [inObject objectAtIndex:4];
    
	

	
    while([threadLock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:100000]] == NO)
    {
        //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
        
		
		//  NSLog(@"progressThread tryLock fail");
		result = DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
		[self performSelectorOnMainThread:@selector(hideProgressWindow:) withObject:nil waitUntilDone:NO];
		[progressController release];
		NSArray *param = [NSArray arrayWithObjects:direction, [NSNumber numberWithInt:result], nil];
		[self performSelectorOnMainThread:@selector(UpdatePrinterPropertyToView:) withObject: param waitUntilDone:YES];
		
		[pool release];
		
		return ;
        
        //continue;
    }
	

    [self performSelectorOnMainThread:@selector(showProgressWindow:) withObject:nil waitUntilDone:NO];     
    
    NSString *description = nil;
    if(OPERATION_GET == [direction intValue])
    {
        description = NSLocalizedString(@"Get Printer Information.", nil);
			NSLog(@"threadLock locked [Get Printer Information]");
    }
    else if(OPERATION_SET == [direction intValue])
    {
        description = NSLocalizedString(@"Set Printer Information.", nil);
		NSLog(@"threadLock locked [Set Printer Information.]");
    }
    else
    {
        description = NSLocalizedString(@"Send Printer Information.", nil);
		NSLog(@"threadLock locked [Send Printer Information.]");
    }
    [self performSelectorOnMainThread:@selector(UpdateProgressStatus:) withObject:NSLocalizedString(description,NULL) waitUntilDone:NO];

    int i = 0;

	
    //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    communicator = [[DeviceCommunicator alloc]init];
    UInt32 status;
    [communicator printerStatus:&status CurrentPrinterID:printerID IsNeedWait:YES];
    NSLog(@"p thread status = %x", status);
    [self performSelectorOnMainThread:@selector(updatePrinterStatus:)
          withObject:[NSNumber numberWithInt:status] waitUntilDone:YES];
    
    result = [communicator canCommunicateWithPrinterID:printerID Status:status];
    if (result != DEV_ERROR_SUCCESS)
    {
        NSLog(@"Status wrong");
    }
    else
    {
		NSLog(@"setConnectResult");

        [communicator setConnectResult];
        //[NSThread detachNewThreadSelector:@selector(connectToPrinter) toTarget:self withObject:nil];
		NSLog(@"connectToPrinter");

		[self connectToPrinter];
       // [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
		

        result = [communicator getConnectResulet];
		NSLog(@"getConnectResulet=%d", result);

		if (result == DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED)
        {
            NSLog(@"Connect printer failed");
        }
        
        if(DEV_ERROR_SUCCESS == result)
        {
            [self performSelectorOnMainThread:@selector(UpdateProgressStatus:) withObject:nil waitUntilDone:NO];
            
            if(nil != propertyList)
            {
				
				NSMutableArray *propertyListCopy = [propertyList mutableCopy];
                int i;
                for(i = 0; i < [propertyListCopy count]; i++)
                {
						result = [communicator communicateInfo: [propertyListCopy objectAtIndex:i] Direction:[direction intValue]];
                    
                    /*if ([[[propertyList objectAtIndex:i] commandName] isEqualToString:@"PrinterInformation2"])
                    {
                        if (result == DEV_ERROR_SUCCESS)
                        {
                            [[propertyList objectAtIndex:i] setPrinterInformation2Available:YES];
                            break;     //Get printer information has two command structure, if 2 failed, send 1

                        }
                        else
                        {
                            continue;
                        }
                    }*/
                    
                    
                    if(DEV_ERROR_SUCCESS != result)
                    {
                        NSLog(@"[net] Communicate with printer failed");
                        break;
                    } 
                    
                    [self performSelectorOnMainThread:@selector(UpdateProgressStatus:) withObject:nil waitUntilDone:NO];
                    
                }
                [propertyListCopy release];
                
            }

        }
        
        [communicator closePrinter];
    }

    [communicator release];
    
    //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [self performSelectorOnMainThread:@selector(UpdateProgressStatus:) withObject:nil waitUntilDone:NO];
    
  
    //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [self performSelectorOnMainThread:@selector(hideProgressWindow:) withObject:nil waitUntilDone:NO];
    
    NSArray * param = [NSArray arrayWithObjects:direction, [NSNumber numberWithInt:result], nil];
    [self performSelectorOnMainThread:@selector(UpdatePrinterPropertyToView:) withObject: param waitUntilDone:YES];
	[progressController release];
	progressController = nil;
    [threadLock unlock];
	
	

    NSLog(@"threadLock unlocked]");
    [pool release];
	NSLock  *tabLock = [[NSApp delegate] tabLock];
	[tabLock tryLock];
	[tabLock unlock];
	
}

- (void)connectToPrinter
{
    [communicator connectPrinter:location];
}

- (void)DisableAllControllers:(id)aView
{
    NSArray *array = [aView subviews];

	
    int i;
    for(i = 0; i < [array count]; i++)
    {
        id controller = [array objectAtIndex:i];
        
        if([controller isKindOfClass:[NSControl class]])
        {
			//[controller setDelegate:nil];
            [controller setEnabled:NO];
			//[controller setDelegate:controller];
        }
        else if([controller isKindOfClass:[NSView class]])
        {
            [self DisableAllControllers:controller];
        }
    }
    
}

- (BOOL)getInfoFromDevice
{
    NSLog(@"getInfor");
    [self DisableAllControllers:[self view]];
    //[self performSelectorOnMainThread:@selector(showProgressWindow:) withObject:nil waitUntilDone:NO];     


    if(nil != progressController)
    {
        [progressController release];
        progressController = nil;
    }
    AppDelegate *app = [NSApp delegate];
    
    NSString *location = [app connectedTo];
    
    if(nil == location)
    {
        return FALSE;
    }

    NSString *printerID = [app printerID];
    
    
    if(nil == printerID)
    {
        return FALSE;
    }
    
	
	NSLock  *tabLock = [[NSApp delegate] tabLock];
	[tabLock tryLock];
	
    progressController = [[ProgressController alloc] init];

    
    
    NSNumber *direction = [NSNumber numberWithInt:OPERATION_GET];
    
    NSRecursiveLock  *threadLock = [app lockThread];
    NSArray * param = [NSArray arrayWithObjects:location, devciePropertyList, direction, threadLock, printerID, nil];


	
    [NSThread detachNewThreadSelector:@selector(progressThread:) toTarget:self withObject:param];

	
    return YES;
   

}

- (BOOL)setInfoToDevice
{
    NSLog(@"setInfor");
    if(nil != progressController)
    {
        [progressController release];
        progressController = nil;
    }
    AppDelegate *app = [NSApp delegate];
    
    NSString *location = [app connectedTo];
    
    if(nil == location)
    {
        return FALSE;
    }
    
    NSString *printerID = [app printerID];
    
    
    if(nil == printerID)
    {
        return FALSE;
    }
	NSLock  *tabLock = [[NSApp delegate] tabLock];
	[tabLock tryLock];
	
    progressController = [[ProgressController alloc] init];
    
    NSNumber *direction = [NSNumber numberWithInt:OPERATION_SET];
    
    NSRecursiveLock  *threadLock = [app lockThread];
    
    NSArray * param = [NSArray arrayWithObjects:location, devciePropertyList, direction, threadLock, printerID, nil];
    
    [NSThread detachNewThreadSelector:@selector(progressThread:)
							 toTarget:self		// we are the target
						   withObject:param];
    

    return YES;

}

- (BOOL)sendInfoToDevice
{
    if(nil != progressController)
    {
        [progressController release];
        progressController = nil;
    }
    AppDelegate *app = [NSApp delegate];
    
    NSString *location = [app connectedTo];
    
    if(nil == location)
    {
        return FALSE;
    }
    
    NSString *printerID = [app printerID];
    
    
    if(nil == printerID)
    {
        return FALSE;
    }
    
	NSLock  *tabLock = [[NSApp delegate] tabLock];
	[tabLock tryLock];
	
    progressController = [[ProgressController alloc] init];
    
    NSNumber *direction = [NSNumber numberWithInt:OPERATION_SEND];
    
    NSRecursiveLock  *threadLock = [app lockThread];
    
    NSArray * param = [NSArray arrayWithObjects:location, devciePropertyList, direction, threadLock, printerID, nil];
    
    [NSThread detachNewThreadSelector:@selector(progressThread:)
							 toTarget:self		// we are the target
						   withObject:param];
    
    
    return YES;
    
}

- (NSMutableArray*)devciePropertyList
{
    return devciePropertyList;
}


- (void)EnableAllControllersExceptApplyBtns:(id)aView
{
	//if(aView == nil)
	//	return;
	
    NSArray *array = [aView subviews];

    int i;
    for(i = 0; i < [array count]; i++)
    {
        id controller = [array objectAtIndex:i];
        
        if(controller == applyNewSettingsButton)
        {
            [controller setEnabled:NO];
        }
        else if([controller isKindOfClass:[NSControl class]])
        {
			//[controller setDelegate:nil];
            [controller setEnabled:YES];
			//[controller setDelegate:controller];
            
        }
        else if([controller isKindOfClass:[NSView class]])
        {
            [self EnableAllControllersExceptApplyBtns:controller];
        }
    }
   
}

- (void)showErrorMsg:(id)result
{
    int error = [result intValue];
    NSString *stringID = nil;
    
    switch(error)
    {
        case DEV_ERROR_ACQUIRE_INFORMATION_FAILED:
            stringID = @"Failed to acquire the information.";
            break;
        case DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED:
            stringID = @"Communication with printer failed.";
            break;
        case DEV_ERROR_INFOR_NOT_ACQUIRE_PRINTER_IS_RUNNING:
            stringID = @"Information was not acquired because the Status Monitor was running.";
            break;
        case DEV_ERROR_INFOR_NOT_TRANSMIT_PRINTER_IS_RUNNING:
            stringID = @"Information was not transmitted because the Status Monitor was running.";
            break;
        case DEV_ERROR_PRINTER_PAPER_SIZE_ERROR:
            stringID = @"It is not possible to print with the paper set in the tray. \rPlease set A4 or the Letter size paper in the tray, and click on a button again. ";
            break;
        case DEV_ERROR_WIFI_FAILED:
            stringID = @"Failed to connect Access Point.";  
    }
    
    if(stringID != nil)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:NSLocalizedString(@"Printer Setting Utility", nil)];
        [alert setInformativeText:NSLocalizedString(stringID, nil)];
        [alert runModal];
		
	
    }
    
}

- (BOOL)canLeave
{
    return !isChanged;
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{

    NSNumber *direction = [directionWithResult objectAtIndex:0];
    NSNumber *result = [directionWithResult objectAtIndex:1];
    
	NSLog(@"[net] direction = %i , result = %i",[direction intValue],[result intValue]);
	

    if(DEV_ERROR_SUCCESS == [result intValue])
    {
        //isEnalbeControllers = YES;
       
		if(isNotReflesh == NO)
		{
			
			[self EnableAllControllersExceptApplyBtns:[self view]];
			isChanged = FALSE;	
		}
    }
    else
    {
        int iResult = [result intValue];
        
        if(OPERATION_GET == [direction intValue])
        {
			if(isNotReflesh == NO)
				[self DisableAllControllers:[self view]];
            
            
            if(DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED == iResult)
            {
                iResult = DEV_ERROR_ACQUIRE_INFORMATION_FAILED;
            }
            else if(DEV_ERROR_PRINTER_RUNNING == iResult)
            {
                iResult = DEV_ERROR_INFOR_NOT_ACQUIRE_PRINTER_IS_RUNNING;
            }
        }
        else
        {
            if(DEV_ERROR_PRINTER_RUNNING == iResult)
            {
                iResult = DEV_ERROR_INFOR_NOT_TRANSMIT_PRINTER_IS_RUNNING;
            }
        }
        
        NSNumber *otherResult = [NSNumber alloc];
        
        [self showErrorMsg:[otherResult initWithInt:iResult]];
        
        
        [otherResult release];
        otherResult = nil;
        
    }
}

- (void)comboBoxSelectionDidChange:(NSNotification *)notification
{
    if(startDetectChangeEvent)
    {
        isChanged = YES;
        [applyNewSettingsButton setEnabled:YES];
    }
}

- (void)systemSettingsSleepRangeMode1_Max:(int *)maxValue Min:(int *)minValue Default:(int *)defaultValue
{
    *maxValue = 5;
    *minValue = 30;
    *defaultValue = 30;
}

- (void)systemSettingsSleepRangeMode2_Max:(int *)maxValue Min:(int *)minValue Default:(int *)defaultValue
{
    *maxValue = 1;
    *minValue = 6;
    *defaultValue = 6;
}

- (int)traySettingsMinY
{
    return 127;
}

- (void)traySettingsPaperTypeList:(NSMutableArray *)list
{

//    
//    [list addObject:NSLocalizedString(@"Plain", NULL)];
//    [list addObject:NSLocalizedString(@"Lightweight &Cardstock", NULL)];
//    [list addObject:NSLocalizedString(@"Labels", NULL)];
//    [list addObject:NSLocalizedString(@"Envelope", NULL)];
//    [list addObject:NSLocalizedString(@"Recycled", NULL)];
}

- (void)traySettingsPaperSizeList:(NSMutableArray *)list
{

   
//    [list addObject:NSLocalizedString(@"A4", NULL)];
//    [list addObject:NSLocalizedString(@"A5", NULL)];
//    [list addObject:NSLocalizedString(@"B5", NULL)];
//    [list addObject:NSLocalizedString(@"8.5X11\", NULL)];
//    [list addObject:NSLocalizedString(@"8.5X13\"", NULL)];
//    [list addObject:NSLocalizedString(@"8.5X14\"", NULL)];
//    [list addObject:NSLocalizedString(@"7.25X10.5\"", NULL)];
//    [list addObject:NSLocalizedString(@"Commercial 10 Envelope", NULL)];
//    [list addObject:NSLocalizedString(@"Monarch Envelope", NULL)];
//    [list addObject:NSLocalizedString(@"Monarch Envelope Landscape", NULL)];
//    [list addObject:NSLocalizedString(@"Statement", NULL)];
//    [list addObject:NSLocalizedString(@"C5", NULL)];
//    [list addObject:NSLocalizedString(@"DL", NULL)];
//    [list addObject:NSLocalizedString(@"DL Landscape", NULL)];
//    [list addObject:NSLocalizedString(@"Custom Size", NULL)];
}
@end
