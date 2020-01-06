//
//  PMDensityAdjustmentViewController.h
//  PrinterSettingUtility
//
//  Created by Wang Kun on 12/18/13.
//  Copyright (c) 2013 Wang Kun. All rights reserved.
//

#import "SettingsController.h"

@interface PMDensityAdjustmentViewController : SettingsController
{
    IBOutlet NSTextField *textField;
    IBOutlet NSComboBox *comboBox;
    IBOutlet NSButton *applyButton;
}

- (IBAction)applyButtonAction:(id)sender;

@end
