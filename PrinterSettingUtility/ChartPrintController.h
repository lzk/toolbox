//
//  ChartPrintController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/18/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsController.h"

id selfID;

@interface ChartPrintController : SettingsController {
@private
    IBOutlet NSButton *pitchConfigurationChartButton;
    
    IBOutlet NSButton *ghostConfigurationChartButton;
    
    IBOutlet NSButton *FourColorsConfigurationChartButton;
    
    IBOutlet NSButton *mqChartButton;
    
    IBOutlet NSButton *alignmentChartButton;
    
    IBOutlet NSButton *drumRefreshConfigurationChartButton;
    
    IBOutlet NSButton *grid2ChartButton;
    
    IBOutlet NSButton *tonerPaletteCheckButton;
	
	NSButton *CEChartToggleButton;

    
   
}
- (IBAction)pitchConfigurationChartButtonAction:(id)sender;
- (IBAction)ghostConfigurationChartButtonAction:(id)sender;
- (IBAction)FourColorsConfigurationChartButtonAction:(id)sender;
- (IBAction)mqChartButtonAction:(id)sender;
- (IBAction)alignmentChartButtonAction:(id)sender;
- (IBAction)drumRefreshConfigurationChartButtonAction:(id)sender;
- (IBAction)grid2ChartButton:(id)sender;
- (IBAction)tonerPaletterChenkButton:(id)sender;




@end
