//
//  traySettingsController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "traySettingsController.h"


@implementation traySettingsController

- (void)layoutTabViewItem
{
    NSRect rectTableFrame = [settingsTableView frame];
    NSRect rectScroll = [[settingsTableView enclosingScrollView] frame];
    NSRect rectRow = [settingsTableView rectOfRow:0];
    float height = NSWidth(rectScroll) - NSWidth(rectTableFrame) + NSHeight(rectRow) * [settingsTableView numberOfRows];
    
    float yTopLeft = rectScroll.origin.y += rectScroll.size.height;
    rectScroll.size.height = height;
    rectScroll.origin.y = yTopLeft - rectScroll.size.height;
    
    
    [[settingsTableView enclosingScrollView] setFrame:rectScroll];
    [[settingsTableView enclosingScrollView] setNeedsDisplay:YES];
    
    
}


- (void)awakeFromNib
{
	if(!itemStringIDList)
    {
        itemStringIDList = [[NSMutableArray alloc]init];
        itemStringList = [[NSMutableArray alloc]init];
        
        int iCount = 0;
        [itemStringIDList addObject:NSLocalizedString(@"Paper Type", NULL)];
        iCount++;
        [itemStringIDList addObject:NSLocalizedString(@"Paper Size", NULL)];
        iCount++;
        [itemStringIDList addObject:NSLocalizedString(@"Custom Size - Y", NULL)];
        iCount++;
        [itemStringIDList addObject:NSLocalizedString(@"Custom Size - X", NULL)];
        iCount++;
        [itemStringIDList addObject:NSLocalizedString(@"Displsy Screen", nil)];
        iCount++;
        
        int i;
        for(i = 0; i < iCount; i++)
        {
            [itemStringList addObject:[[NSMutableString alloc]initWithString:@"--"]];
        }
       
    }
    
    [self layoutTabViewItem ];
	
}
- (id)init
{
    self = [super init];
    
    if (self) {
        NSString * nibName = [self NIBName];
        self = [self initWithNibName:nibName bundle:nil];
        
        ID_PrinterSettings = ID_PSR_TRAY_SETTINGS;
       contentTitle= NSLocalizedString(@"Tray Settings", NULL);
        SettingsName = NSLocalizedString(@"Tray Settings", NULL);
        
        if(nil != devciePropertyList)
        {
            [devciePropertyList addObject:[[[TraySettings alloc] init] autorelease]];
            
        }
    }
    
    return self;
}
+ (NSString *)description
{
    return NSLocalizedString(@"Tray Settings", NULL);
}
- (void)dealloc
{
    [itemStringIDList release];
    
    [itemStringList release];
    
    [super dealloc];
}

- (NSString *)NIBName
{
    return @"TraySettings";
}
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(!itemStringIDList)
    {
        return 0;
    }
    
    return [itemStringIDList count];  
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(int)rowIndex
{
    
    if(itemStringIDList && rowIndex < [itemStringIDList count])
    {
        if(itemTitleColumn == aTableColumn)
        {
            NSString * stringType = [itemStringIDList objectAtIndex:rowIndex];
            
            return stringType;
        }
        else
        {
            NSString * stringType = [itemStringList objectAtIndex:rowIndex];
            
            return stringType;
        }
    }
    
    return nil;
    
}

- (void)UpdateItemStrings:(id)deviceData
{
    DEV_TRAY_SETTINGS *info = (DEV_TRAY_SETTINGS *)deviceData;
    int index = 0;
    
    //"PAPER TYPE"
    switch(info->iPaperType)
    {
        case PAPER_TYPE_PLAIN:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"Plain", NULL)];
            break;
        case PAPER_TYPE_LW_CARDSTOCK:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"Lightweight &Cardstock", NULL)];
            break;
        case PAPER_TYPE_LABELS:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"Labels", NULL)];
            break;
        case PAPER_TYPE_ENVELOPE:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"Envelope", NULL)];
            break;
        case PAPER_TYPE_RECYCLED:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"Recycled", NULL)];
            break;
        default:
            [[itemStringList objectAtIndex:index]setString:@"--"];
            break;
    }
    
    //"PAPER Size"
    index++;
    switch(info->iPaperSize)
    {
        case PAPER_SIZE_A4:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"A4", NULL)];
            break;
        case PAPER_SIZE_A5:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"A5", NULL)];
            break;
        case PAPER_SIZE_B5:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"B5", NULL)];
            break;
        case PAPER_SIZE_LETTER:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"8.5X11\"", NULL)];
            break;
        case PAPER_SIZE_FOLIO:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"8.5X13\"", NULL)];
            break;
        case PAPER_SIZE_LEGAL:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"8.5X14\"", NULL)];
            break;
        case PAPER_SIZE_EXECUTIVE:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"7.25X10.5\"", NULL)];
            break;
        case PAPER_SIZE_NO_10:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"Commercial 10 Envelope", NULL)];
            break;
        case PAPER_SIZE_MONARCH_ENVELOPE:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"Monarch Envelope", NULL)];
            break;
        case PAPER_SIZE_STATEMENT:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"Statement", NULL)];
            break;
        case PAPER_SIZE_C5:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"C5", NULL)];
            break;
        case PAPER_SIZE_DL:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"DL", NULL)];
            break;
        case PAPER_SIZE_DL_L:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"DL Landscape", NULL)];
            break;
        case PAPER_SIZE_MONARCH_L:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"Monarch Envelope Landscape", NULL)];
            break;
        case PAPER_SIZE_CUSTOM_SIZE:
            [[itemStringList objectAtIndex:index]setString:NSLocalizedString(@"Custom Size", NULL)];
            break;
        default:
            [[itemStringList objectAtIndex:index]setString:@"--"];
            break;
    }
    
    if (info->iPaperSize != PAPER_SIZE_CUSTOM_SIZE)
    {
        index++;
        [[itemStringList objectAtIndex:index] setString:@"--"];
        
        index++;
        [[itemStringList objectAtIndex:index] setString:@"--"];
    }
    else
    {
        NSString *size = nil;
        NSString *unit = nil;
        
        if (info->iMMorInch)
        {
            unit = NSLocalizedString(@"mm", nil);
        }
        else
        {
            unit = NSLocalizedString(@"Inch", nil);
        }
        
        index++;
        size = [[NSString alloc] initWithFormat:@"%d %@", EndianU16_NtoL(info->iCustomSizeY), unit];
        [[itemStringList objectAtIndex:index] setString:size];
        
        index++;
        size = [[NSString alloc] initWithFormat:@"%d %@", EndianU16_NtoL(info->iCustomSizeX), unit];
        [[itemStringList objectAtIndex:index] setString:size];
    }
    
    index++;
    if (info->iDisplayPopup)
    {
        [[itemStringList objectAtIndex:index] setString:NSLocalizedString(@"On", nil)];
    }
    else
    {
        [[itemStringList objectAtIndex:index] setString:NSLocalizedString(@"Off", nil)];
    }
    

    [settingsTableView reloadData];
   
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
    //NSNumber *direction = [directionWithResult objectAtIndex:0];
    NSNumber *result = [directionWithResult objectAtIndex:1];
    
    [super UpdatePrinterPropertyToView:directionWithResult];
    
    if(DEV_ERROR_SUCCESS != [result intValue])
    {
        return;
    }
    
    if(nil == devciePropertyList)
    {
        return;
    }
    int i;
    for(i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *aCommond = [devciePropertyList objectAtIndex:i];
        [self UpdateItemStrings:[aCommond deviceData]];
    }
}
@end
