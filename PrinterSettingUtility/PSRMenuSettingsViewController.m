//
//  PSRMenuSettingsViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/18/13.
//
//

#import "PSRMenuSettingsViewController.h"
#import "DataStructure.h"
#import "DeviceProperty.h"

@interface PSRMenuSettingsViewController ()

@end

@implementation PSRMenuSettingsViewController

- (void)dealloc
{
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"Menu Settings", nil);
        [self initFirstColumnItems];
        [self initSecondColumnItems];
        
        [self initWithNibName:@"PSRMenuSettingsViewController" bundle:nil];
        
        [devciePropertyList addObject:[[[SystemSettings alloc] init] autorelease]];
        [devciePropertyList addObject:[[[BillingMeters alloc] init] autorelease]];
        [devciePropertyList addObject:[[[PaperDensity alloc] init] autorelease]];
        [devciePropertyList addObject:[[[AdjustBTR alloc] init] autorelease]];
        [devciePropertyList addObject:[[[AdjustFuser alloc] init] autorelease]];
        [devciePropertyList addObject:[[[AdjustAltitude alloc] init] autorelease]];
        [devciePropertyList addObject:[[[BTRRefresh alloc] init] autorelease]];

#ifdef MACHINESETUP_XC
        //[devciePropertyList addObject:[[DensityAdjustment alloc] init]];
#endif
#ifdef MACHINESETUP_IBG
        [devciePropertyList addObject:[[NonGenToner alloc] init]];
#endif
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Menu Settings", nil);
}

- (void)awakeFromNib
{
    [textField1 setStringValue:NSLocalizedString(@"System Settings", nil)];
#ifdef MACHINESETUP_XC
    [textField2 setStringValue:NSLocalizedString(@"Billing Meters", nil)];
#endif
#ifdef MACHINESETUP_IBG
    [textField2 setStringValue:NSLocalizedString(@"Meter Readings", nil)];
#endif
    [textField3 setStringValue:NSLocalizedString(@"Adjust Paper Type", nil)];
    [textField4 setStringValue:NSLocalizedString(@"Adjust BTR", nil)];
    [textField5 setStringValue:NSLocalizedString(@"Adjust Fusing Unit", nil)];
    [textField6 setStringValue:NSLocalizedString(@"Adjust Altitude", nil)];
    [textField7 setStringValue:NSLocalizedString(@"BTR Refresh Mode", nil)];
#ifdef MACHINESETUP_XC
    //[textField7 setStringValue:NSLocalizedString(@"Density Adjustment", nil)];
    //[textField7 setStringValue:NSLocalizedString(@"BTR Refresh Mode", nil)];
    [textField8 removeFromSuperview];
    //[tableView8 removeFromSuperview];
    [tableView8ScrollView removeFromSuperview];
    
#endif
#ifdef MACHINESETUP_IBG
    //[textField7 setStringValue:NSLocalizedString(@"BTR Refresh Mode", nil)];
    [textField8 setStringValue:NSLocalizedString(@"Non-Genuine Mode", nil)];
#endif
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    switch (tableView.tag) {
        case 1:
            return [firstColumnItems1 count];
            break;
        case 2:
            return [firstColumnItems2 count];
            break;
        case 3:
            return [firstColumnItems3 count];
            break;
        case 4:
            return [firstColumnItems4 count];
            break;
        case 5:
            return [firstColumnItems5 count];
            break;
        case 6:
            return [firstColumnItems6 count];
            break;
        case 7:
            return [firstColumnItems7 count];
            break;
#ifdef MACHINESETUP_IBG
        case 8:
            return [firstColumnItems8 count];
            break;
#endif
        default:
            return 0;
            break;
    }
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSString *identifier = [tableColumn identifier];
    NSString *value1 = nil;
    NSString *value2 = nil;
    
    switch (tableView.tag) {
        case 1:
            value1 = [firstColumnItems1 objectAtIndex:row];
            value2 = [secondColumnItems1 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 2:
            value1 = [firstColumnItems2 objectAtIndex:row];
            value2 = [secondColumnItems2 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 3:
            value1 = [firstColumnItems3 objectAtIndex:row];
            value2 = [secondColumnItems3 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 4:
            value1 = [firstColumnItems4 objectAtIndex:row];
            value2 = [secondColumnItems4 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 5:
            value1 = [firstColumnItems5 objectAtIndex:row];
            value2 = [secondColumnItems5 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 6:
            value1 = [firstColumnItems6 objectAtIndex:row];
            value2 = [secondColumnItems6 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
        case 7:
            value1 = [firstColumnItems7 objectAtIndex:row];
            value2 = [secondColumnItems7 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
#ifdef MACHINESETUP_IBG
        case 8:
            value1 = [firstColumnItems8 objectAtIndex:row];
            value2 = [secondColumnItems8 objectAtIndex:row];
            return [identifier isEqualToString:@"First"] ? value1 : value2;
            break;
#endif
        default:
            return nil;
            break;
    }
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
    [super UpdatePrinterPropertyToView:directionWithResult];
    
    NSNumber *result = [directionWithResult objectAtIndex:1];
    if([result intValue] != DEV_ERROR_SUCCESS)
    {
        [[scrollview verticalScroller] setEnabled:YES];
        return;
    }
    
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];

        if ([aCommond isKindOfClass:[SystemSettings class]])
        {
            [self updataSecondColumnItems1:[aCommond deviceData]];
            //[tableView1 reloadData];
        }
        else if ([aCommond isKindOfClass:[BillingMeters class]])
        {
            [self updataSecondColumnItems2:[aCommond deviceData]];
            //[tableView2 reloadData];
        }
        else if ([aCommond isKindOfClass:[PaperDensity class]])
        {
            [self updataSecondColumnItems3:[aCommond deviceData]];
            //[tableView3 reloadData];
        }
        else if ([aCommond isKindOfClass:[AdjustBTR class]])
        {
            [self updataSecondColumnItems4:[aCommond deviceData]];
            [tableView4 reloadData];
        }
        else if ([aCommond isKindOfClass:[AdjustFuser class]])
        {
            [self updataSecondColumnItems5:[aCommond deviceData]];
            [tableView5 reloadData];
        }
        else if ([aCommond isKindOfClass:[AdjustAltitude class]])
        {
            [self updataSecondColumnItems6:[aCommond deviceData]];
            [tableView6 reloadData];
        }
        /*
        else if ([aCommond isKindOfClass:[DensityAdjustment class]])
        {
            [self updataSecondColumnItems7:[aCommond deviceData]];
            [tableView7 reloadData];
        }*/
        else if ([aCommond isKindOfClass:[BTRRefresh class]])
        {
            [self updataSecondColumnItems7:[aCommond deviceData]];
            [tableView7 reloadData];
        }
#ifdef MACHINESETUP_IBG
        else if ([aCommond isKindOfClass:[NonGenToner class]])
        {
            [self updataSecondColumnItems8:[aCommond deviceData]];
            [tableView8 reloadData];
        }
#endif
    }
}

- (void)updataSecondColumnItems1:(id)data
{
    DEV_SYSTEM_SETTINGS *devData = (DEV_SYSTEM_SETTINGS *)data;
    NSString *string = nil;
    NSString *unit = nil;
    
    unit = NSLocalizedString(@"minutes", nil);
	NSString *unit1 = NSLocalizedString(@"seconds", nil);
    string = [[NSString alloc] initWithFormat:@"%d %@", devData->iPowerSaverTimerMode1, unit];
    if ([string length])
    {
        [secondColumnItems1 replaceObjectAtIndex:0 withObject:string];
        [string release];
        string = nil;
    }
    
    string = [[NSString alloc] initWithFormat:@"%d %@", devData->iPowerSaverTimerMode2, unit];
    if ([string length])
    {
        [secondColumnItems1 replaceObjectAtIndex:1 withObject:string];
        [string release];
        string = nil;
    }
    
    /*
    //NSString *unit1 = NSLocalizedString(@"seconds", nil);
    //NSString *unit2 = NSLocalizedString(@"IDS_MINUTE", nil);
    NSString *unit3 = NSLocalizedString(@"minutes", nil);
     
    switch (devData->iAutoReset) {
        case 0:
            string = [[NSString alloc] initWithFormat:@"%d %@", 45, unit1];
            break;
        case 1:
            string = [[NSString alloc] initWithFormat:@"%d %@", 1, unit2];
            break;
        case 2:
            string = [[NSString alloc] initWithFormat:@"%d %@", 2, unit3];
            break;
        case 3:
            string = [[NSString alloc] initWithFormat:@"%d %@", 3, unit3];
            break;
        case 4:
            string = [[NSString alloc] initWithFormat:@"%d %@", 4, unit3];
            break;
        default:
            break;
    }
    if ([string length])
    {
        [secondColumnItems1 replaceObjectAtIndex:2 withObject:string];
        [string release];
        string = nil;
    }
    */
    
    string = [[NSString alloc] initWithFormat:@"%d %@", EndianU16_NtoL(devData->iTimeOut), unit1];
    if ([string length])
    {
        [secondColumnItems1 replaceObjectAtIndex:2 withObject:string];
        [string release];
        string = nil;
    }
    /*
    string = [[NSString alloc] initWithFormat:@"%d %@", EndianU16_NtoL(devData->iFaultTimeOut), unit];
    if ([string length])
    {
        [secondColumnItems1 replaceObjectAtIndex:3 withObject:string];
        [string release];
        string = nil;
    }*/
    /*
    switch (devData->iMMorInch) {
        case 0:
            unit = NSLocalizedString(@"millimeter (mm)", nil);
            string = [[NSString alloc] initWithString:unit];
            break;
        case 1:
            unit = NSLocalizedString(@"inch (\")", nil);
            string = [[NSString alloc] initWithString:unit];
            break;
        default:
            break;
    }
    if (string)
    {
        [secondColumnItems1 replaceObjectAtIndex:4 withObject:string];
        [string release];
        string = nil;
    }
    */
    switch (devData->reserved[0]) {
        case 0:
            string = [[NSString alloc] initWithString:NSLocalizedString(@"Off", nil)];
            break;
        case 1:
            string = [[NSString alloc] initWithString:NSLocalizedString(@"On", nil)];
            break;
        default:
            break;
    }
    if (string)
    {
        [secondColumnItems1 replaceObjectAtIndex:3 withObject:string];
        [string release];
        string = nil;
    }

//#ifdef MACHINESETUP_IBG
    switch (devData->reserved[2]) {
        case 0:
            string = [[NSString alloc] initWithString:NSLocalizedString(@"Off", nil)];
            break;
        case 1:
            string = [[NSString alloc] initWithString:NSLocalizedString(@"On", nil)];
            break;
        case 2:
            string = [[NSString alloc] initWithString:NSLocalizedString(@"On (except A4/Ltr)", nil)];
            break;
        default:
            break;
    }
    if (string)
    {
        [secondColumnItems1 replaceObjectAtIndex:4 withObject:string];
        [string release];
        string = nil;
    }
//#endif
    
#ifdef MACHINESETUP_XC
    switch (devData->iPanelLanguage) {
        case 0:
            string = [[NSString alloc] initWithString:NSLocalizedString(@"English", nil)];
            break;
        case 1:
            string = [[NSString alloc] initWithString:NSLocalizedString(@"French", nil)];
            break;
        case 9:
            string = [[NSString alloc] initWithString:NSLocalizedString(@"Russion", nil)];
            break;
        default:
            break;
    }
    if (string)
    {
        [secondColumnItems1 replaceObjectAtIndex:5 withObject:string];
        [string release];
        string = nil;
    }
#endif
    

}

- (void)updataSecondColumnItems2:(id)data
{
    DEV_BILLING_METERS *devData = (DEV_BILLING_METERS *)data;
    NSString *string = nil;
    
    string = [[NSString alloc] initWithFormat:@"%ld", EndianU32_NtoL(devData->uiMeter1)];
    if (string)
    {
        [secondColumnItems2 replaceObjectAtIndex:0 withObject:string];
        [string release];
        string = nil;
    }
    
    string = [[NSString alloc] initWithFormat:@"%ld", EndianU32_NtoL(devData->uiMeter2)];
    if (string)
    {
        [secondColumnItems2 replaceObjectAtIndex:1 withObject:string];
        [string release];
        string = nil;
    }
    
    string = [[NSString alloc] initWithFormat:@"%ld", EndianU32_NtoL(devData->uiMeter4)];
    if (string)
    {
        [secondColumnItems2 replaceObjectAtIndex:2 withObject:string];
        [string release];
        string = nil;
    }
  
#ifdef MACHINESETUP_IBG
    string = [[NSString alloc] initWithFormat:@"%ld", EndianU32_NtoL(devData->uiMeter4)];
    if (string)
    {
        [secondColumnItems2 replaceObjectAtIndex:3 withObject:string];
		[secondColumnItems2 replaceObjectAtIndex:2 withObject:@"--"];
        [string release];
        string = nil;
    }
#endif
    
}

- (void)updataSecondColumnItems3:(id)data
{
    DEV_PAPER_DENSITY *devData = (DEV_PAPER_DENSITY *)data;
    NSString *string = nil;
    
    switch (devData->iPlain) {
        case 0:
            string = NSLocalizedString(@"Lightweight", nil);
            break;
        case 1:
            string = NSLocalizedString(@"Heavyweight", nil);
        default:
            break;
    }
    [secondColumnItems3 replaceObjectAtIndex:0 withObject:string];
    
    switch (devData->iLabel) {
        case 0:
            string = NSLocalizedString(@"Lightweight", nil);
            break;
        case 1:
            string = NSLocalizedString(@"Heavyweight", nil);
            break;
        default:
            break;
    }
    [secondColumnItems3 replaceObjectAtIndex:1 withObject:string];
}

- (void)updataSecondColumnItems4:(id)data
{
    DEV_ADJUST_BTR *devData = (DEV_ADJUST_BTR *)data;
    NSString *string = nil;
    
    string = [[NSString alloc] initWithFormat:@"%d", (devData->iPlain - 3)];
    [secondColumnItems4 replaceObjectAtIndex:0 withObject:string];
    [string release];
    
    string = [[NSString alloc] initWithFormat:@"%d", (devData->iBond - 3)];
    [secondColumnItems4 replaceObjectAtIndex:1 withObject:string];
    [string release];

    string = [[NSString alloc] initWithFormat:@"%d", (devData->iCardStock - 3)];
    [secondColumnItems4 replaceObjectAtIndex:2 withObject:string];
    [string release];

    string = [[NSString alloc] initWithFormat:@"%d", (devData->iLightGlossyStock - 3)];
    [secondColumnItems4 replaceObjectAtIndex:3 withObject:string];
    [string release];

    string = [[NSString alloc] initWithFormat:@"%d", (devData->iLabel - 3)];
    [secondColumnItems4 replaceObjectAtIndex:4 withObject:string];
    [string release];

    string = [[NSString alloc] initWithFormat:@"%d", (devData->iEnvelope - 3)];
    [secondColumnItems4 replaceObjectAtIndex:5 withObject:string];
    [string release];

    string = [[NSString alloc] initWithFormat:@"%d", (devData->iRecycled - 3)];
    [secondColumnItems4 replaceObjectAtIndex:6 withObject:string];
    [string release];
}

- (void)updataSecondColumnItems5:(id)data
{
    DEV_ADJUST_FUSER *devData = (DEV_ADJUST_FUSER *)data;
    NSString *string = nil;
    
    string = [[NSString alloc] initWithFormat:@"%d", (devData->iPlain - 3)];
    [secondColumnItems5 replaceObjectAtIndex:0 withObject:string];
    [string release];
    
    string = [[NSString alloc] initWithFormat:@"%d", (devData->iBond - 3)];
    [secondColumnItems5 replaceObjectAtIndex:1 withObject:string];
    [string release];
    
    string = [[NSString alloc] initWithFormat:@"%d", (devData->iCardStock - 3)];
    [secondColumnItems5 replaceObjectAtIndex:2 withObject:string];
    [string release];
    
    string = [[NSString alloc] initWithFormat:@"%d", (devData->iLightGlossyStock - 3)];
    [secondColumnItems5 replaceObjectAtIndex:3 withObject:string];
    [string release];
    
    string = [[NSString alloc] initWithFormat:@"%d", (devData->iLabel - 3)];
    [secondColumnItems5 replaceObjectAtIndex:4 withObject:string];
    [string release];
    
    string = [[NSString alloc] initWithFormat:@"%d", (devData->iEnvelope - 3)];
    [secondColumnItems5 replaceObjectAtIndex:5 withObject:string];
    [string release];
    
    string = [[NSString alloc] initWithFormat:@"%d", (devData->iRecycled - 3)];
    [secondColumnItems5 replaceObjectAtIndex:6 withObject:string];
    [string release];
}

- (void)updataSecondColumnItems6:(id)data
{
    DEV_ADJUST_ALTITUDE *devData = (DEV_ADJUST_ALTITUDE *)data;
    NSString *string = nil;
    
    switch (devData->iAdjustAltitude) {
        case 0:
            string = NSLocalizedString(@"0 meter", nil);
            break;
        case 1:
            string = NSLocalizedString(@"1000 meters", nil);
            break;
        case 2:
            string = NSLocalizedString(@"2000 meters", nil);
            break;
        case 3:
            string = NSLocalizedString(@"3000 meters", nil);
        default:
            break;
    }
    [secondColumnItems6 replaceObjectAtIndex:0 withObject:string];
}

- (void)updataSecondColumnItems7:(id)data
{
    DEV_BTR_REFRESH *devData = (DEV_BTR_REFRESH *)data;
    NSString *string = nil;
    
    switch (devData->iBTRRefresh) {
        case 0:
            string = NSLocalizedString(@"Off", nil);
            break;
        case 1:
            string = NSLocalizedString(@"On", nil);
            break;
        default:
            break;
    }

    [secondColumnItems7 replaceObjectAtIndex:0 withObject:string];
}

- (void)updataSecondColumnItems8:(id)data
{
    DEV_NON_GEN_TONER *devData = (DEV_NON_GEN_TONER *)data;
    NSString *string = nil;
    
    switch (devData->iNonGenToner) {
        case 0:
            string = NSLocalizedString(@"Off", nil);
            break;
        case 1:
            string = NSLocalizedString(@"On", nil);
            break;
        default:
            break;
    }
    [secondColumnItems8 replaceObjectAtIndex:0 withObject:string];
}

- (void)initFirstColumnItems
{
    firstColumnItems1 = [[NSMutableArray alloc] init];
    firstColumnItems2 = [[NSMutableArray alloc] init];
    firstColumnItems3 = [[NSMutableArray alloc] init];
    firstColumnItems4 = [[NSMutableArray alloc] init];
    firstColumnItems5 = [[NSMutableArray alloc] init];
    firstColumnItems6 = [[NSMutableArray alloc] init];
    firstColumnItems7 = [[NSMutableArray alloc] init];
    firstColumnItems8 = [[NSMutableArray alloc] init];

#ifdef MACHINESETUP_IBG
    [firstColumnItems1 addObject:NSLocalizedString(@"Low Power Timer", nil)];
    [firstColumnItems1 addObject:NSLocalizedString(@"Sleep Timer", nil)];
#endif
#ifdef MACHINESETUP_XC
    [firstColumnItems1 addObject:NSLocalizedString(@"Power Saver Mode 1 ", nil)];
    [firstColumnItems1 addObject:NSLocalizedString(@"Power Saver Mode 2", nil)];
#endif
    [firstColumnItems1 addObject:NSLocalizedString(@"Job Timeout", nil)];
    //[firstColumnItems1 addObject:NSLocalizedString(@"Fault Timeout", nil)];
    //[firstColumnItems1 addObject:NSLocalizedString(@"mm/inch", nil)];
    [firstColumnItems1 addObject:NSLocalizedString(@"Low Toner Alert Message", nil)];
    [firstColumnItems1 addObject:NSLocalizedString(@"Show Paper Size Error", nil)];
#ifdef MACHINESETUP_XC
    [firstColumnItems1 addObject:NSLocalizedString(@"Report Language", nil)];
#endif


#ifdef MACHINESETUP_IBG
    [firstColumnItems2 addObject:NSLocalizedString(@"Meter 1", nil)];
    [firstColumnItems2 addObject:NSLocalizedString(@"Meter 2", nil)];
    [firstColumnItems2 addObject:NSLocalizedString(@"Meter 3", nil)];
    [firstColumnItems2 addObject:NSLocalizedString(@"Meter 4", nil)];
#endif
#ifdef MACHINESETUP_XC
    [firstColumnItems2 addObject:NSLocalizedString(@"Color Impression", nil)];
    [firstColumnItems2 addObject:NSLocalizedString(@"Black Impression", nil)];
    [firstColumnItems2 addObject:NSLocalizedString(@"Total Impression", nil)];
#endif
        
    [firstColumnItems3 addObject:NSLocalizedString(@"Plain Paper", nil)];
    [firstColumnItems3 addObject:NSLocalizedString(@"Labels", nil)];
    
    [firstColumnItems4 addObject:NSLocalizedString(@"Plain", nil)];
    [firstColumnItems4 addObject:NSLocalizedString(@"Bond", nil)];
    [firstColumnItems4 addObject:NSLocalizedString(@"Lightweight Cardstock", nil)];
    [firstColumnItems4 addObject:NSLocalizedString(@"Lightweight Glossy Cardstock", nil)];
    [firstColumnItems4 addObject:NSLocalizedString(@"Labels", nil)];
    [firstColumnItems4 addObject:NSLocalizedString(@"Envelope", nil)];
    [firstColumnItems4 addObject:NSLocalizedString(@"Recycled", nil)];
    
    [firstColumnItems5 addObject:NSLocalizedString(@"Plain", nil)];
    [firstColumnItems5 addObject:NSLocalizedString(@"Bond", nil)];
    [firstColumnItems5 addObject:NSLocalizedString(@"Lightweight Cardstock", nil)];
    [firstColumnItems5 addObject:NSLocalizedString(@"Lightweight Glossy Cardstock", nil)];
    [firstColumnItems5 addObject:NSLocalizedString(@"Labels", nil)];
    [firstColumnItems5 addObject:NSLocalizedString(@"Envelope", nil)];
    [firstColumnItems5 addObject:NSLocalizedString(@"Recycled", nil)];
    
    [firstColumnItems6 addObject:NSLocalizedString(@"Adjust Altitude", nil)];
    [firstColumnItems7 addObject:NSLocalizedString(@"BTR Refresh Mode", nil)];
    [firstColumnItems8 addObject:NSLocalizedString(@"Non-Genuine Mode", nil)];
#ifdef MACHINESETUP_XC
    //[firstColumnItems7 addObject:NSLocalizedString(@"Density Adjustment", nil)];
#endif
#ifdef MACHINESETUP_IBG
    //[firstColumnItems8 addObject:NSLocalizedString(@"Non-Genuine Mode", nil)];
#endif
}

- (void)initSecondColumnItems
{
    secondColumnItems1 = [[NSMutableArray alloc] init];
    secondColumnItems2 = [[NSMutableArray alloc] init];
    secondColumnItems3 = [[NSMutableArray alloc] init];
    secondColumnItems4 = [[NSMutableArray alloc] init];
    secondColumnItems5 = [[NSMutableArray alloc] init];
    secondColumnItems6 = [[NSMutableArray alloc] init];
    secondColumnItems7 = [[NSMutableArray alloc] init];
    secondColumnItems8 = [[NSMutableArray alloc] init];
    
    int i;
    for (i = 0; i < [firstColumnItems1 count]; i++)
    {
        [secondColumnItems1 addObject:@"--"];
    }
    
    for (i = 0; i < [firstColumnItems2 count]; i++)
    {
        [secondColumnItems2 addObject:@"--"];
    }
    
    for (i = 0; i < [firstColumnItems3 count]; i++)
    {
        [secondColumnItems3 addObject:@"--"];
    }
    
    for (i = 0; i < [firstColumnItems4 count]; i++)
    {
        [secondColumnItems4 addObject:@"--"];
    }
    
    for (i = 0; i < [firstColumnItems5 count]; i++)
    {
        [secondColumnItems5 addObject:@"--"];
    }
    
    for (i = 0; i < [firstColumnItems6 count]; i++)
    {
        [secondColumnItems6 addObject:@"--"];
    }
    
    for (i = 0; i < [firstColumnItems7 count]; i++)
    {
        [secondColumnItems7 addObject:@"--"];
    }

    for (i = 0; i < [firstColumnItems8 count]; i++)
    {
        [secondColumnItems8 addObject:@"--"];
    }

}


@end
