//
//  MachineSetupAppDelegate.m
//  MachineSetup
//
//  Created by Helen Liu on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "TargetVersion.h"
#import "DeviceCommunicator.h"
#import "AboutController.h"


#import <stdlib.h>
#import <sys/types.h>
#import <unistd.h>



@implementation AppDelegate

@synthesize modelNameNoVersion;
@synthesize supportedList;
@synthesize printerState;
@synthesize modelName;
@synthesize devIP;

- (void)reflushPrinterStatus
{



    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [libraryDirectory stringByAppendingPathComponent:STATUS_MONITOR_PATH];
    NSString *smonPath = [finalPath stringByAppendingPathComponent:SMON];
    NSTask *aTask = [[NSTask alloc] init];
    [aTask setLaunchPath:smonPath];
    [aTask setArguments:[NSArray arrayWithObject:@"reflush"]];
    [aTask launch];
    [aTask waitUntilExit];
    [aTask release];
}

- (void)launchStatusMonitor
{

    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    


#ifdef MACHINESETUP_IBG


	
	NSString * oldPID = 
	[NSString stringWithContentsOfFile:@"/tmp/FXPrinterTbx.pid" 
							  encoding:NSASCIIStringEncoding 
								 error:NULL];
	
#endif
#ifdef MACHINESETUP_XC

	

	
	NSString * oldPID = 
	[NSString stringWithContentsOfFile:@"/tmp/XCPrinterTbx.pid" 
							  encoding:NSASCIIStringEncoding 
								 error:NULL];
	
#endif

	
	
	if (oldPID) {
		kill([oldPID intValue],SIGKILL);
	}
	
	
	NSProcessInfo *processInfo = [NSProcessInfo processInfo];
	NSString *processName = [processInfo processName];
	int processID = [processInfo processIdentifier];
	NSLog(@"Process Name: '%@' Process ID:'%d'", processName, processID);
	


	NSString * newPID = [[NSString alloc]init];
	newPID = [newPID stringByAppendingFormat:@"%d\n",processID];

#ifdef MACHINESETUP_IBG
	
	[newPID writeToFile:@"/tmp/FXPrinterTbx.pid" 
		   atomically:YES 
			 encoding:NSASCIIStringEncoding error:NULL]; 
#endif
	
#ifdef MACHINESETUP_XC
	
	[newPID writeToFile:@"/tmp/XCPrinterTbx.pid" 
			 atomically:YES 
			   encoding:NSASCIIStringEncoding error:NULL]; 
#endif	
	
	
	//system("killall \"Printer Setting Utility\"");
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [libraryDirectory stringByAppendingPathComponent:STATUS_MONITOR_PATH];
    NSString *devmonPath = [finalPath stringByAppendingPathComponent:STATUSSMON];
    //NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    //[workspace launchApplication:devmonPath];
    NSLog(@"statussom path = %@", devmonPath);
    
    statusMonTask = [[NSTask alloc] init];
    [statusMonTask setLaunchPath:devmonPath];
    [statusMonTask launch];
    
    /*
    const char *cPath = [devmonPath cStringUsingEncoding:NSASCIIStringEncoding];
    pid_t pid;
    pid = fork();
    if (pid == 0)
    {
        statusMonPid = getpid();
        execl(cPath, cPath, 0);
    }
    */
    [pool release];

}

- (void)setStatusMonitorToReady
{
    isStatusMonitorReady = YES;
}

- (BOOL)isStatusMonitorReady
{
    return isStatusMonitorReady;
}

- (void)applicationWillFinishLaunching:(NSNotification *)aNotification
{
    isStatusMonitorReady = NO;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    
    supportedList = [[NSArray alloc] initWithObjects:SUPPORTED_PRINTERS, nil];
    NSLog(@"supported printers = %@", supportedList);
    
    mainWindowC = [[MainWindowController alloc] initWithWindowNibName:@"MainWindow"];
    [[mainWindowC window] makeKeyAndOrderFront:nil];
    
    //[[controllerMainTab tabViewMain] setAutoresizingMask:NSViewHeightSizable];
    //[NSBundle loadNibNamed:@"MainMenu" owner:NSApp];
}

- (BOOL)isSupportedPrinter:(NSString *)aName
{
    int i;
    int n = [supportedList count];
    for (i = 0; i < n; i++)
    {
        if ([aName isEqualToString:[supportedList objectAtIndex:i]])
        {
            return YES;
        }
    }
    
    return NO;
}

- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
	if(unSupported)
	{
		isClosed = TRUE;
        return YES;
	
	}
	if(isClosed)
	{
		
#ifdef MACHINESETUP_IBG
		system("ipcrm -M0x52029884");
		system("ipcrm -M0x520281f8");
		
		
#endif
#ifdef MACHINESETUP_XC
		system("ipcrm -M0x52029883");
		system("ipcrm -M0x520281f7");
		
		
		
		
#endif
		NSError *error=nil;
#ifdef MACHINESETUP_IBG
		[[NSFileManager defaultManager] removeItemAtPath:@"/tmp/FXPrinterTbx.pid" error:&error];
#endif
#ifdef MACHINESETUP_XC		
		[[NSFileManager defaultManager] removeItemAtPath:@"/tmp/XCPrinterTbx.pid" error:&error];
#endif
		if (error.code != NSFileNoSuchFileError) {
			NSLog(@"[PID] %@", error);
		}
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
		
#ifdef MACHINESETUP_IBG
		system("ipcrm -M0x52029884");
		system("ipcrm -M0x520281f8");
		
		
#endif
#ifdef MACHINESETUP_XC
		system("ipcrm -M0x52029883");
		system("ipcrm -M0x520281f7");
		
		
		
		
#endif
		
		NSError *error=nil;
#ifdef MACHINESETUP_IBG
		[[NSFileManager defaultManager] removeItemAtPath:@"/tmp/FXPrinterTbx.pid" error:&error];
#endif
#ifdef MACHINESETUP_XC		
		[[NSFileManager defaultManager] removeItemAtPath:@"/tmp/XCPrinterTbx.pid" error:&error];
#endif
		if (error.code != NSFileNoSuchFileError) {
			NSLog(@"[PID] %@", error);
		}

		
        return YES;
    }
    else
    {
        [alert release];
    }
    
	
	
	
    return NO;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
	return YES;
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if(printerName != nil)
    {
        [printerName release];
    }
    if(modelName != nil)
    {
        [modelName release];
    }
    if(connectedTo != nil)
    {
        [connectedTo release];
    }
    if(printerID != nil)
    {
        [printerID release];
    }
    
    if(nil != threadLock)
    {
        [threadLock release];
    }
	

    /*
    NSString *killStatusMon = [NSString stringWithFormat:@"/bin/kill -15 %d", statusMonPid];
    const char *cKillStatusMon = [killStatusMon cStringUsingEncoding:NSASCIIStringEncoding];
    system(cKillStatusMon);*/
    
    [statusMonTask terminate];
}

- (void) updateTitle
{
    NSString *port;
    
    port = [NSString stringWithString:connectedTo];
    NSString *string = [NSString stringWithFormat:@"%@ - %@", printerName, port];
    [[mainWindowC window] setTitle:string];
}

- (IBAction)onAbout:(id)sender
{
    AboutController *about = [[AboutController alloc] init];
    
    [about showAbout];
    
    [about close];
    [about release];
    about = nil;
    
}

- (void) setPrinterName:(NSString *)name ModalName:(NSString *)modal ConnectTo:(NSString*)location PrinterID:(NSMutableString *)ID
{
    if(nil == printerName)
    {
        printerName = [[NSMutableString alloc] initWithCapacity:1];
    }
    if(nil == modelName)
    {
        modelName = [[NSMutableString alloc] initWithCapacity:1];
    }
    if(nil == connectedTo)
    {
        connectedTo = [[NSMutableString alloc] initWithCapacity:1];
    }
    if(nil == printerID)
    {
        printerID = [[NSMutableString alloc] initWithCapacity:1];
    }
    
    if(nil != name)
        [printerName setString:name];
    
    if(nil != modal)
        [modelName setString:modal];
    
    if(nil != location)
        [connectedTo setString:location];
    
    if(nil != ID)
        [printerID setString:ID];
    
    [self updateTitle];
    
}

- (int)getSelectedDevType
{
    return devType;
}

- (void)setSelectedDevType:(int)type
{
    devType = type;
}

- (NSString*)connectedTo
{
    return connectedTo;
}

- (NSString*)printerID
{
    return printerID;
}
- (NSString*)printerName
{
    return printerName;
}
- ( NSRecursiveLock  *)lockThread
{
    if(nil == threadLock)
    {
        threadLock = [[NSRecursiveLock alloc]init];
    }
    
    return threadLock;
}

- ( NSLock  *)tabLock
{
    if(nil == tabLock)
    {
        tabLock = [[NSLock alloc]init];
    }
    
    return tabLock;
}
/*
 - (BOOL)canClose
 {
 if(NO == [controllerMainTab canClose])
 {
 return NO;
 }
 
 if(nil == threadLock)
 {
 return YES;
 }
 
 int i = 0;
 while(NO == [threadLock tryLock])
 {
 [NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
 i++;
 
 if(i > 10)
 break;
 continue;
 }
 
 [threadLock unlock];
 
 
 return YES;
 }
 */
- (void)updatePrinterStatus:(NSNumber *)status
{
    [controllerMainTab updatePrinterStatus:status];
}

-(IBAction)clickHelp:(id)sender
{
    //Add help file ......
}
@end

