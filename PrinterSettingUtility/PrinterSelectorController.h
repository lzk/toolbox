//
//  PrinterSelectorController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

@interface PrinterSelectorController : NSWindowController {
@private
    
    IBOutlet NSTextField *selectPrinterTextField;
    
    IBOutlet NSButton *closeButton;
    
    IBOutlet NSTableColumn *printerNameColumn;
    
    IBOutlet NSTableColumn *connectedToColumn;
    IBOutlet NSTableColumn *modelNameColumn;
    IBOutlet NSArrayController *printerInfoArrayController;
    
    NSMutableArray *printerInfoList;
    NSMutableDictionary *selectedPrinterInfo;

}
- (IBAction)onStopButton:(id)sender;



- (BOOL)printerInfo_printerName:(NSMutableString*)printerName modelName:(NSMutableString*) modelName connectedTo:(NSMutableString*)connectedTo printerID:(NSMutableString*) printerID;

-(void)makeList;

@end
