//
//  SystemSettingsController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/14/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"

@interface SystemSettingsController : SettingsController {
@private
    

	IBOutlet NSBox *powerSaverTimerBox;
    IBOutlet NSTextField *powerSaverMode1TextField;
    IBOutlet NSTextField *sleepMode2RangeTextField;
    IBOutlet NSTextField *sleepMode1RangeTextField;
    IBOutlet NSTextField *powerSaverMode2TextField;
    IBOutlet NSTextField *jobTimeOutTextField;
    IBOutlet NSTextField *faultTimeOutTextField;
    IBOutlet NSTextField *jobTimeOutRangeTextField;
    IBOutlet NSTextField *faultTimeOutRangeTextField;
    IBOutlet NSTextField *mmInchTextField;
    IBOutlet NSTextField *lowTAMTextField;
    IBOutlet NSTextField *autoRTextField;
    IBOutlet NSTextField *showPaperSizeErrorField;
    IBOutlet NSTextField *reportLanguageField;
    
   
    
    IBOutlet NSComboBox *mmInchCombo;
    IBOutlet NSComboBox *faultTimeOutCombo;
    IBOutlet NSComboBox *jobTimeOutCombo;
    //NSMutableArray * sleepMode1ItemList;
    //NSMutableArray * sleepMode2ItemList;
    //NSMutableArray * jobTimeOutItemList;
    //NSMutableArray * faultTimeOutItemList;
    NSMutableArray * mmInchItemList;
    IBOutlet NSComboBox *sleepMode1Combo;
    IBOutlet NSComboBox *sleepMode2Combo;
    IBOutlet NSComboBox *lowTAMBox;
    IBOutlet NSComboBox *autoRBox;
    IBOutlet NSComboBox *showPaperSizeErrorComboBox;
    IBOutlet NSComboBox *reportLanguageComboBox;
}
- (IBAction)onApplyNewSettings:(id)sender;

@end
