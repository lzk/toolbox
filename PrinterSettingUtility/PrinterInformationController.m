//
//  PrinterInformationController.m
//  MachineSetup
//
//  Created by Helen Liu on 7/5/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PrinterInformationController.h"
//#import "ProgressController.h"

@implementation PrinterInformationController

- (void)layoutTabViewItem
{
    NSRect rectTableFrame = [printerInformationTableView frame];
    NSRect rectScroll = [[printerInformationTableView enclosingScrollView] frame];
    NSRect rectRow = [printerInformationTableView rectOfRow:0];
    float height = NSWidth(rectScroll) - NSWidth(rectTableFrame) + NSHeight(rectRow) * [printerInformationTableView numberOfRows];
    
    float yTopLeft = rectScroll.origin.y += rectScroll.size.height;
    rectScroll.size.height = height;
    rectScroll.origin.y = yTopLeft - rectScroll.size.height;
    
    
    [[printerInformationTableView enclosingScrollView] setFrame:rectScroll];
    [[printerInformationTableView enclosingScrollView] setNeedsDisplay:YES];
 
    
}


- (void)awakeFromNib
{
	if(!itemStringIDList)
    {
        itemStringIDList = [NSMutableArray new];
        itemStringList = [NSMutableArray new];
        
        int iCount = 0;
        [itemStringIDList addObject:NSLocalizedString(@"Printer Serial Number", NULL)];
        iCount++;
        
        [itemStringIDList addObject:NSLocalizedString(@"Printer Type", NULL)];
        iCount++;

        [itemStringIDList addObject:NSLocalizedString(@"Memory Capacity", NULL)];
        iCount++;

        
        [itemStringIDList addObject:NSLocalizedString(@"Processor Speed", NULL)];
        iCount++;

        [itemStringIDList addObject:NSLocalizedString(@"Firmware Version", NULL)];
        iCount++;
        
        [itemStringIDList addObject:NSLocalizedString(@"Network Firmware Version", NULL)];
        iCount++;

        [itemStringIDList addObject:NSLocalizedString(@"MCU Firmware Version", NULL)];
        iCount++;
        
        [itemStringIDList addObject:NSLocalizedString(@"Printing Speed (Color)", NULL)];
        iCount++;

        [itemStringIDList addObject:NSLocalizedString(@"Printing Speed (Monochrome)", NULL)];
        iCount++;

        [itemStringIDList addObject:NSLocalizedString(@"Boot Code Version", NULL)];
        iCount++;
        
        [itemStringIDList addObject:NSLocalizedString(@"Color Table Version", NULL)];
        iCount++;
        
        [itemStringIDList addObject:NSLocalizedString(@"Network Message", NULL)];
        iCount++;

        int i;
        for(i = 0; i < iCount; i++)
        {
            [itemStringList addObject:[[[NSMutableString alloc] initWithString:@"--"] autorelease]];
        }
        
    }
    
    //[self layoutTabViewItem ];
    
    
    //[self communicateWithDevice];
    
	
}
- (id)init
{
    self = [super init];
    
    if (self) {
        NSString * nibName = [self NIBName];
        self = [self initWithNibName:nibName bundle:nil];
        
       ID_PrinterSettings = ID_PSR_PRINTER_INFORMATION;
       contentTitle= NSLocalizedString(@"Printer Information", NULL);
        SettingsName = NSLocalizedString(@"Printer Information", NULL);
        
        if(nil != devciePropertyList)
        {
            //[devciePropertyList addObject:[[PrinterInformation2 alloc] init]];
            [devciePropertyList addObject:[[[PrinterInformation2 alloc] init] autorelease]];
        }
    }
    
    return self;
}
+ (NSString *)description
{
    return NSLocalizedString(@"Printer Information", NULL);
}
- (void)dealloc
{
    [itemStringList release];
    [itemStringIDList release];
    [super dealloc];
}

- (NSString *)NIBName
{
    return @"PrinterInformation";
}
- (int)numberOfRowsInTableView:(NSTableView *)aTableView
{
    if(!itemStringIDList)
        
        return 0;
    
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
            NSString * string = [itemStringList objectAtIndex:rowIndex];
            
            return string;
        }
    }
    
    return nil;
    
}


- (void)UpdateItemStrings:(id)deviceData
{
    DEV_PSR_PRINTERINFORMATION_2 *info;
    if ([[devciePropertyList objectAtIndex:0] printerInformation2Available])
    {
        info = (DEV_PSR_PRINTERINFORMATION_2 *)deviceData;
    }
    else
    {
        info = (DEV_PSR_PRINTERINFORMATION_2 *)deviceData;
    }
    

    //"Printer Serial Number"
    int index = 0;
    NSString *string = [[NSString alloc ]initWithUTF8String:info->cPrinterSerialNumber];
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
    [string release];
    string = nil;
   
    //"Printer Type"
    index++;
    string = [[NSString alloc ]initWithUTF8String:info->cPrinterType];
    
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
   
    [string release];
    string = nil;
    
    //"Memory Capacity"
    index++;
    string = [[NSString alloc ]initWithUTF8String:info->cMemoryCapacity];
    
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
  
    [string release];
    string = nil;
    
    //"Processor Speed"
    index++;
    string = [[NSString alloc ]initWithUTF8String:info->cProcessorSpeed];
    
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
   
    [string release];
    string = nil;
    
    //"Firmware Version"
    index++;
    string = [[NSString alloc ]initWithUTF8String:info->cFirmwareVersion];
    
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
    
    [string release];
    string = nil;
    
    //"Net Firmware Version"
    index++;
    string = [[NSString alloc ]initWithUTF8String:info->cNetworkFirmwareVersion];
    
    if([string length])
    {
        [[itemStringList objectAtIndex:index]setString:string];

    }

    [string release];
    string = nil;
    
    
    //"MCU Firmware Version"
    index++;
    string = [[NSString alloc ]initWithUTF8String:info->cMCUFirmwareVersion];
    
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
   
    [string release];
    string = nil;
    
    //"Printing Speed(Color)"
    index++;
    string = [[NSString alloc ]initWithUTF8String:info->cPrintingSpeedColor];
    
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
    
    [string release];
    string = nil;

    
    //"Printing Speed (Monochrome)"
    index++;
    string = [[NSString alloc ]initWithUTF8String:info->cPrintingSpeedMonochrome];
    
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
    else
    {
        [[itemStringList objectAtIndex:index]setString:@"--"];
    }
    [string release];
    string = nil;
    
    
     //"Boot Code Version"
     index++;
     string = [[NSString alloc ]initWithUTF8String:info->cBootCodeVersion];
     
     if(string != nil)
     {
     [[itemStringList objectAtIndex:index]setString:string];
     }
     else
     {
     [[itemStringList objectAtIndex:index]setString:@"--"];
     }
     [string release];
     string = nil;
     
    
    //"Color Table Version"
    index++;
    string = [[NSString alloc ]initWithUTF8String:info->cColorTableVersion];
    
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
    else
    {
        [[itemStringList objectAtIndex:index]setString:@"--"];
    }
    [string release];
    string = nil;
    
    
   // "Network Message"
    index++;
    if ([[devciePropertyList objectAtIndex:0] printerInformation2Available])
    {
        string = [[NSString alloc] initWithUTF8String:info->cNetworkMessageVersion];
    }
    else
    {
         string = [[NSString alloc] initWithUTF8String:info->cNetworkMessageVersion];
    }
    
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
    else
    {
        [[itemStringList objectAtIndex:index]setString:@"--"];
    }
    [string release];
    string = nil;
    
    /*
    "Boot Code Version" 
    index++;
    string = [[NSString alloc ]initWithUTF8String:info->cBootCodeVersion];
    
    if(string != nil)
    {
        [[itemStringList objectAtIndex:index]setString:string];
    }
    else
    {
        [[itemStringList objectAtIndex:index]setString:@"--"];
    }
    [string release];
    string = nil;
    */
    
    [printerInformationTableView reloadData];
    
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
