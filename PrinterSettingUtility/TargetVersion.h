//
//  TargetVersion.h
//  MachineSetup
//
//  Created by Wang Kun on 10/22/13.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#ifndef _TARGET_VERSION_H
#define _TARGET_VERSION_H


	
#ifdef MACHINESETUP_XC

#define SUPPORTED_PRINTERS         @"Xerox Phaser 6020"
#define TITLE_IMAGE                @"Title_XC1.bmp"
#define ABOUT_IMAGE                @"About_XC1.bmp"
#define STATUS_MONITOR_PATH        @"Printers/Xerox/StatusService_LE2"
#define STATUSSMON                 @"xrstatussmon"
#define SMON                       @"xrsmon"
#define IDS_CAUTION                @"IDS_CAUTION_X"
#define IDS_SUBNET				   @"IDS_Network Mask"
#define IDS_LPD					   @"LPR"
#define IDS_CopyRight              @"IDS_COPYRIGHT_X"
#define IDS_CopyRightH             @"IDS_COPYRIGHTH_X"

#endif


#ifdef MACHINESETUP_IBG

#define SUPPORTED_PRINTERS         @"FX DocuPrint CP115/118 w",   \
                                   @"FX DocuPrint CP116/119 w"        
#define TITLE_IMAGE                @"Title_IBG.bmp"
#define ABOUT_IMAGE                @"About_IBG.bmp"
#define STATUS_MONITOR_PATH        @"Printers/FujiXerox/StatusSevice_CType"
#define STATUSSMON                 @"fxstatussmon"
#define SMON                       @"fxsmon"
#define IDS_CAUTION                @"IDS_CAUTION_I"
#define IDS_SUBNET				   @"Subnet Mask"
#define IDS_LPD					   @"LPD"
#define IDS_CopyRight              @"IDS_COPYRIGHT_I"
#define IDS_CopyRightH             @"IDS_COPYRIGHTH_I"
#endif



#endif





