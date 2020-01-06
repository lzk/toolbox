//
//  SettingsController.h
//  MachineSetup
//
//  Created by Helen Liu on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DeviceProperty.h"
#import "DataStructure.h"
#import "ProgressController.h"
#import "DeviceCommunicator.h"
#if MAC_OS_X_VERSION_MAX_ALLOWED == MAC_OS_X_VERSION_10_4
#import "NSViewController.h"
#endif
enum
{
	ID_PSR_PRINTER_INFORMATION = 0,
	ID_PSR_MENU_SETTINGS,
	ID_PSR_REPORTS,
	ID_PSR_TCPIP_SETTINGS,
	ID_PSR_TRAY_SETTINGS,
	ID_PSR_DEFAULTS_SETTINGS,
	ID_PSR_FAX_SETTINGS,
};

enum
{
	ID_PM_SYSTEM_SETTINGS = 0,
	ID_PM_DATA_AND_TIME,
	ID_PM_PAPER_DENSITY,
	ID_PM_ADJUST_BTR,
	ID_PM_ADJUST_FUSER,
	ID_PM_DENSITY_ADJUSTMENT,
	ID_PM_REG_ADJUSTMENT,
	ID_PM_ADJUST_ALTITUDE,
	ID_PM_RESET_DEFAULTS,
	ID_PM_NON_GENUINE_MODE,
	ID_PM_BTR_REFRESH_MODE,
	ID_PM_WEB_LINK,
	ID_PM_TCPIP_SETTINGS,
	ID_PM_TRAY_SETTINGS,
	ID_PM_EWS,
	ID_PM_SCAN_DEFAULTS,
	ID_PM_FAX_DEFAULTS,
	ID_PM_COPY_DEFAULTS,
	ID_PM_FAX_SETTINGS,
	ID_PM_RESET_TONER_COUNTER,
	ID_PM_JAM_RECOVERY,
};

enum
{
	ID_DIAGNOSIS_CHART_PRINTER = 0,
	ID_DIAGNOSIS_ENVIRONMENT_SENSOR_INFO,
	ID_DIAGNOSIS_CLEAN_DEVELOPER,
	ID_DIAGNOSIS_REFRESH_MODE,
};

//@class NSViewController;

    BOOL isChanged,isClosed,unSupported,isNotReflesh,ipVer;

@interface SettingsController: NSViewController {
@private
@protected
    int ID_PrinterSettings;
    NSString *contentTitle;
    NSString *SettingsName;
    
    NSMutableArray *devciePropertyList;
    
    IBOutlet NSButton *applyNewSettingsButton;
    
    BOOL isNeedCheckPanelPassword;
    ProgressController *progressController;

 
    BOOL startDetectChangeEvent;
    
    DeviceCommunicator *communicator;
    NSString *location;
    int count;
}

//- (NSString *)NIBName;
- (BOOL)getInfoFromDevice;
- (BOOL)setInfoToDevice;
- (BOOL)sendInfoToDevice;
- (BOOL)canLeave;


- (void)UpdatePrinterPropertyToView:(id)directionWithResult;
- (void)EnableAllControllersExceptApplyBtns:(id)aView;
//- (void)comboBoxSelectionDidChange:(NSNotification *)notification;

- (void)systemSettingsSleepRangeMode1_Max:(int *)maxValue Min:(int *)minValue Default:(int *)defaultValue;
- (void)systemSettingsSleepRangeMode2_Max:(int *)maxValue Min:(int *)minValue Default:(int *)defaultValue;

- (int)traySettingsMinY;
- (void)traySettingsPaperTypeList:(NSMutableArray *)list;
- (void)traySettingsPaperSizeList:(NSMutableArray *)list;
- (void)UpdateProgressStatus:(NSString *)string;

@property(readonly) int ID_PrinterSettings;
@property(readonly, copy) NSString *contentTitle;
@property(readonly) NSString *SettingsName;
//@property(readonly) BOOL isEnalbeControllers;
@end
