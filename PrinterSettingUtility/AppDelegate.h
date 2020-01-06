//
//  MachineSetupAppDelegate.h
//  MachineSetup
//
//  Created by Helen Liu on 6/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MainTabController.h"
#import "MainWindowController.h"

NSRecursiveLock  *threadLock;
NSLock	*tabLock;

@interface AppDelegate : NSObject <NSApplicationDelegate> {
@private
    //IBOutlet NSWindow *printerSelectorWindow;
    NSWindow *window;
    MainTabController *controllerMainTab;
    IBOutlet NSImageView *imageViewTitle;
    
    NSMutableString *printerName ;
    NSMutableString *modelName ;
    NSMutableString *connectedTo ;
    NSMutableString *printerID ;
    
    NSString *modelNameNoVersion;
    
    BOOL isStatusMonitorReady;
    
    MainWindowController *mainWindowC;
    int devType;
    NSString *devIP;
	
    
    NSArray *supportedList;
    
    pid_t statusMonPid;
    NSTask *statusMonTask;
    
    NSString *printerState;
    

}

@property (nonatomic, copy) NSString *printerState;
@property (nonatomic, copy) NSString *modelNameNoVersion;
@property (nonatomic, retain) NSArray *supportedList;
@property (nonatomic, copy) NSMutableString *modelName;
@property (nonatomic, copy) NSString *devIP;


- (IBAction)onAbout:(id)sender;
-(IBAction)clickHelp:(id)sender;
- (void) setPrinterName:(NSString *)name ModalName:(NSString *)modal ConnectTo:(NSString*)location PrinterID:(NSMutableString *)ID ;
- (NSString*)connectedTo;
- (NSString*)printerID;
- (NSString*)printerName;
- ( NSRecursiveLock  *)lockThread;
- ( NSLock  *)tabLock;

- (BOOL)canClose;
- (BOOL)isStatusMonitorReady;
- (void)launchStatusMonitor;
- (void)setStatusMonitorToReady;
- (void)updatePrinterStatus:(NSNumber *)status;
- (void)reflushPrinterStatus;

- (int)getSelectedDevType;
- (void)setSelectedDevType:(int)type;
- (BOOL)isSupportedPrinter:(NSString *)aName;

@end

