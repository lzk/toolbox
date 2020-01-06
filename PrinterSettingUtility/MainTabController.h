//
//  MainTabController.h
//  MachineSetup
//
//  Created by Helen Liu on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "ProgressController.h"
#import "SettingsController.h"

BOOL canExit;


@interface MainTabController : NSObject {
@private
    IBOutlet NSTabView *tabViewMain;
    
    IBOutlet NSTextField *textFieldPrinterStatus;
    IBOutlet NSBox *boxLine;
    IBOutlet NSView *viewContiner;
    IBOutlet NSImageView *imageViewLogo;
    
    IBOutlet NSTextFieldCell *currentSettingsTitleText;
    IBOutlet NSTabView *tabViewSettingsDlgContiner;
    IBOutlet NSTableView *tableViewSettingsType;
    //NSMutableArray *arrayTabPSRContents;
    //NSMutableArray *arrayTabPMContents;
    //NSMutableArray *arrayTabDiagnosisContents;
    NSMutableArray *arrayCurrentContents;
    
    int   indexDefaultTabViewItem;
    int   indexDefaultSettingsType;
    
    //ProgressController *progressController;
    
    NSThread *progressThread;
    
//    NSMutableString *printerName ;
//    NSMutableString *modelName ;
//    NSMutableString *connectedTo ;
    //CFMutableStringRef printerID;
    SettingsController *currentPrinterView;
    BOOL init;
    NSAlert *canLeaveAlert;
    
   
}

//- (void) frameDidChange:(NSNotification *)notification;
//- (void) setPrinterName:(NSString *)name ModalName:(NSString *)modal ConnectTo:(NSString*)location;
- (BOOL)canClose;
- (void)updatePrinterStatus:(NSNumber *)status;
- (BOOL) startDetectPrinterInfomation;
@property (readonly) IBOutlet NSTabView *tabViewMain;

@end
