//
//  DeviceCommunicator.m
//  MachineSetup
//
//  Created by Helen Liu on 7/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DeviceCommunicator.h"
#import "USBDevice.h"
#import "NetDevice.h"
#import "NetPrinter.h"
#import "DeviceProperty.h"
#import "AppDelegate.h"
#import "ProgressController.h"

#define USB_TYPE     1
#define NET_TYPE     2

@implementation DeviceCommunicator

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		m_nToken = 0;
		m_bLogin = NO;
	}
	
	return self;
}

- (void)dealloc
{
	[self closePrinter];
	[device release];
	device = nil;
	
	[super dealloc];
}


- (int)connectPrinter:(NSString *)printerURI
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
	NSLog(@"connectPrinter printerURI=%@", printerURI);

    pURI = printerURI;
    
    if(nil == printerURI)
    {
        return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
    }
	
	if ([[NSApp delegate] getSelectedDevType] == USB_TYPE)
	{
		[device release];
		device = nil;
		device = [[USBDevice alloc] init];
        devType = USB_TYPE;
        
		NSLog(@"connetToUSBDevice start");

		if(TRUE == [device USBConnect:printerURI])
        {
            contectResult = DEV_ERROR_SUCCESS;
            return DEV_ERROR_SUCCESS;
        }
	}
    else if ([[NSApp delegate] getSelectedDevType] == NET_TYPE)
    {
        [device release];
        device = nil;
        device = [[NetDevice alloc] init];
        devType = NET_TYPE;
        
		NSLog(@"connetToNetDevice start");

        if ([device connetToNetDevice:printerURI])
        {
            contectResult = DEV_ERROR_SUCCESS;
            return DEV_ERROR_SUCCESS;
        }
        
    }
	
    return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;	
    
    [pool release];
}

- (void)setConnectResult
{
    contectResult = DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
}

- (int)getConnectResulet
{
    return contectResult;
}

- (void) closePrinter
{
    if (device != nil)
	{
        if (devType == USB_TYPE)
        {
            [device USBDisconnect];
        }
        else if (devType == NET_TYPE)
        {
            [device closeSocket];
        }
	}
}

- (BOOL) isPrinterOpen
{
	return [device isPrinterOpen];
}

- (int)currentDevicePaperSize:(UInt *)paperSize
{
    int iResult = DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
	
    
    if(FALSE == [self isPrinterOpen])
    {
        return iResult;
    }
	
    
    *paperSize = 0;
	
    TraySettings *command = [[TraySettings alloc]init];
    
    iResult = [self communicateInfo:command Direction:OPERATION_GET];
    
    if(iResult == DEV_ERROR_SUCCESS)
    {
        DEV_TRAY_SETTINGS *settings = (void*)[command deviceData];
        
        *paperSize = settings->iPaperSize;
    }
    
    [command release];
    
    return iResult;
}


- (int)chartPrint:(DeviceCommond *)aCommand
{
	int iResult = DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
    
    UInt paperSize;
    iResult = [self currentDevicePaperSize:&paperSize];
    
    if(iResult != DEV_ERROR_SUCCESS)
    {
        return iResult;
    }
    
    if(PAPER_SIZE_LETTER != paperSize && PAPER_SIZE_A4 != paperSize)
    {
        return DEV_ERROR_PRINTER_PAPER_SIZE_ERROR;
    }
    
    
    NSMutableString *prnFile = [[NSMutableString alloc]initWithCapacity:1];
    BOOL isColor=NO;
	
	NSString *docuString;
	
    switch([aCommand CodeID])
    {
        case DEV_CMD_CODE_ID_CHART_PRINT_PITCH_CONF:
            [prnFile setString:@"CONF"];
			docuString = [NSString stringWithFormat:@"@PJL SET JOBATTR=DOCU:%@",@"Pitch Configuration Chart"];
			isColor=YES;
            break;
        case DEV_CMD_CODE_ID_CHART_PRINT_GHOST_CONF:
            [prnFile setString:@"Ghost"];
			docuString = [NSString stringWithFormat:@"@PJL SET JOBATTR=DOCU:%@",@"Ghost Configuration Chart"];
			isColor=YES;
            break;
        case DEV_CMD_CODE_ID_CHART_PRINT_FOUR_COLORS_CONF:
            [prnFile setString:@"COLOR"];
			docuString = [NSString stringWithFormat:@"@PJL SET JOBATTR=DOCU:%@",@"4 Colors Configuration Chart"];
			isColor=YES;
            break;
        case DEV_CMD_CODE_ID_CHART_PRINT_MQ:
            [prnFile setString:@"MQ"];
			docuString = [NSString stringWithFormat:@"@PJL SET JOBATTR=DOCU:%@",@"MQ Chart"];
			isColor=YES;
            break;
        case DEV_CMD_CODE_ID_CHART_PRINT_ALIGNMENT:
            [prnFile setString:@"Align"];
			docuString = [NSString stringWithFormat:@"@PJL SET JOBATTR=DOCU:%@",@"Alignment Chart"];
            break;
        case DEV_CMD_CODE_ID_CHART_PRINT_DRUM_REFRESH_CONF:
            [prnFile setString:@"PHD"];
			docuString = [NSString stringWithFormat:@"@PJL SET JOBATTR=DOCU:%@",@"Drum Refresh Configuration Chart"];
			isColor=YES;
            break;
        case DEV_CMD_CODE_ID_CHART_PRINT_GRID2:
            [prnFile setString:@"Grid2"];
			docuString = [NSString stringWithFormat:@"@PJL SET JOBATTR=DOCU:%@",@"Grid 2 Chart"];
			isColor=YES;
            break;
        case DEV_CMD_CODE_ID_CHART_PRINT_TONER_PALETTE_CHECK:
            [prnFile setString:@"Toner"];
			docuString = [NSString stringWithFormat:@"@PJL SET JOBATTR=DOCU:%@",@"Toner Palette Check"];
			isColor=YES;
            break;
        case DEV_CMD_CODE_ID_CHART_PRINT_DEMO_PAGE:
            [prnFile setString:@"Demo"];
			docuString = [NSString stringWithFormat:@"@PJL SET JOBATTR=DOCU:%@",@"Demo Page"];
			isColor=YES;
            break;
    }

    
    if(PAPER_SIZE_LETTER == paperSize)
    {
        [prnFile appendString:@"_LT"];
    }
    else 
    {
        [prnFile appendString:@"_A4"];
    }
	
	
    //**************
    //Note: if it is network connect, 
    //before write prn files, must disconnect the socket, then reconnect a new socket again.
    //***************
    if(FALSE == [self isPrinterOpen])
    {
        return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:prnFile ofType:@"prn"];
    NSData *data = [[NSData alloc]initWithContentsOfFile:filePath];
    
    int filesize = [data length];
    
    if(filesize <= 0)
    {
        return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
    }
    
   	// We will change Document name in PRN, but Hostname/UserName must be blank as AR requested to be same as other reports. 
	
	NSDate *currentTime = [NSDate date];
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"HH:mm:ss"];
	NSString *timeString = [NSString stringWithFormat:@"@PJL SET JOBATTR=TIME:%@",[dateFormatter stringFromDate: currentTime]];
	
	[dateFormatter setDateFormat:@"MM/dd/yyyy"];
	NSString *yearString = [NSString stringWithFormat:@"@PJL SET JOBATTR=DATE:%@",[dateFormatter stringFromDate: currentTime]];
	
	
	
	
	NSString *PJLString;
	
	if(isColor)
	{
		
		PJLString = [NSString stringWithFormat:@"%s\r\n%s\r\n%s\r\n%s\r\n%@\r\n%s\r\n%s\r\n%s\r\n%s\r\n%s\r\n%s\r\n%s\r\n",
					 "\033%-12345X@PJL JOB NAME=PRINTER",
					 "@PJL SET JOBATTR=HOST:",
					 "@PJL SET JOBATTR=OWNR:",
					 "@PJL SET JOBATTR=USER:",
					 docuString,
					 "@PJL SET RESOLUTION=600",
					 "@PJL SET RENDERMODE=COLOR",
					 "@PJL SET BITSPERPIXEL=2",
					 "@PJL SET JOBATTR=MMSI:OFF",
					 "@PJL SET JOBATTR=MMTY:2",
					 "@PJL SET COPIES=1",
					 "@PJL ENTER LANGUAGE=HBPL"];
		
	}
	else {
		PJLString = [NSString stringWithFormat:@"%s\r\n%s\r\n%s\r\n%s\r\n%@\r\n%s\r\n%s\r\n%s\r\n%s\r\n%s\r\n%s\r\n%s\r\n",
					 "\033%-12345X@PJL JOB NAME=PRINTER",
					 "@PJL SET JOBATTR=HOST:",
					 "@PJL SET JOBATTR=OWNR:",
					 "@PJL SET JOBATTR=USER:",
					 docuString,
					 "@PJL SET RESOLUTION=600",
					 //timeString,
					 //yearString,
					 "@PJL SET RENDERMODE=GRAYSCALE",
					 "@PJL SET BITSPERPIXEL=2",
					 "@PJL SET JOBATTR=MMSI:OFF",
					 "@PJL SET JOBATTR=MMTY:2",
					 "@PJL SET COPIES=1",
					 "@PJL ENTER LANGUAGE=HBPL"];
		
	}
	
	
	
	NSMutableData *newData = [[PJLString dataUsingEncoding:NSASCIIStringEncoding] mutableCopy];
	
	NSLog(@"[chart] PJL = [%@]",PJLString);
	
	[newData appendData:data];
	filesize = [newData length];
#if 0
	NSString *docsDir;
	NSArray *dirPaths;
	
	dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	docsDir = [dirPaths objectAtIndex:0];
	NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"foo.prn"]];
	NSString *databasePath1 = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:@"foo_ori.prn"]];
	[newData writeToFile:databasePath atomically:YES];
	[data writeToFile:databasePath1 atomically:YES];
#endif
	void* bytes = [newData bytes];
    
    if ([[NSApp delegate] getSelectedDevType] == DEV_TYPE_USB)
    {
        IOResult ioresult = [device USBWrite:bytes bufferLength:filesize];
        
        if ((ioresult.err != kIOReturnSuccess) || (ioresult.readOrWriteBytes != filesize))
        {
            return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
        }
    }
    
    if ([[NSApp delegate] getSelectedDevType] == DEV_TYPE_NET)
    {
		[device closeSocket];
        [device release];
		device = nil;
        device = [[NetDevice alloc] init];
		
		NSLog(@"connetToNetDevice start1");

        if ([device connetToNetDevice:pURI] == FALSE)
        {
            return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
        }
        
        if ([device wirteToNetDevice:bytes length:filesize] == -1)
        {
            return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
        }
		
    }
    //[docuString release];
    [data release];
	[newData release];
    [prnFile release];
    
    return DEV_ERROR_SUCCESS;
	
}


- (int)communicateInfo:(DeviceCommond *)aCommond Direction:(int)cmdDirection
{
	//if(aCommond == nil)
	//	return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
	
    NSLog(@"[net] cominfor1");
    int iResult = DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
    IOResult ioresult;
    
    UInt8 groupID_Set;
    UInt8 groupID_Get;
    [aCommond GroupID_Get:&groupID_Get ID_Set:&groupID_Set];
    NSLog(@"[net] cominfor2 [command ID: %x] ",[aCommond IDCode]);
	
    if(DEV_CMD_GROUP_ID_CHART_PRINT == groupID_Set)
    {
        return [self chartPrint:aCommond];
    }
    
    if(FALSE == [self isPrinterOpen])
    {
        NSLog(@"Printer isn't open");
        return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
    }
    
    DEV_RESPONSE response;
    Byte buffer[1024];
    Byte resPayloadBuffer[1024];
    Byte temp[1024];
    memset(&response, 0, sizeof(DEV_RESPONSE));
    memset(buffer, 0, sizeof(buffer));
    memset(resPayloadBuffer, 0, sizeof(resPayloadBuffer));
    memset(temp, 0, sizeof(temp));
    UInt32 commandSize = 0;
    UInt32 responseSize = 0;
    
    BOOL isToGet = TRUE;
    if(OPERATION_GET != cmdDirection)
    {
        isToGet = FALSE;
    }
    NSLog(@"cominfor3");
	
    [aCommond commandData:(void*)buffer size:&commandSize isToGet:isToGet responseDataSize:&responseSize];
    NSLog(@"cominfor4");
	
    DEV_COMMAND command;
    memcpy(&command, buffer, sizeof(DEV_COMMAND));
    //NSLog(@"command = %@", command);
	
    if (devType == USB_TYPE)
    {
        ioresult = [device USBWrite:buffer bufferLength:commandSize];
        NSLog(@"cominfor5");
		
        if ((ioresult.err != kIOReturnSuccess) || (ioresult.readOrWriteBytes != commandSize))
        {
            NSLog(@"USB write wrong");
            return iResult;
        }
        
        ioresult = [device USBRead:buffer bufferLength:responseSize];
        NSLog(@"cominfor6");
		
        if ((ioresult.err != kIOReturnSuccess) || (ioresult.readOrWriteBytes != responseSize))
        {
			
			
			
			
			
            NSLog(@"USB read wrong [%x] except len = [%i] actully = [%i]",err_get_code(ioresult.err), responseSize,ioresult.readOrWriteBytes);
			
			memcpy(&response, buffer, sizeof(DEV_RESPONSE));
			NSLog(@"%x, %x, %x, %x", response.rsp_mark, response.errors_code, response.cmd_group_mark, response.cmd_code_mark);
			NSLog(@"payloadsize = %lu", response.payload_size);
			
            return iResult; //Wifi V2 didn't support GET before SET.
			
        }
        
    }
    else if (devType == NET_TYPE)
    {
        if ([device wirteToNetDevice:buffer length:commandSize] == -1)
        {
			NSLog(@"[net] wirteToNetDevice");
            return iResult;
        }
        
        if ([device readFromNetDevice:buffer length:sizeof(DEV_RESPONSE)] == -1)
        {
			NSLog(@"[net] read DEV_RESPONSE");
            return iResult;
        }
        
        if([device readFromNetDevice:resPayloadBuffer length:(responseSize-sizeof(DEV_RESPONSE))] == -1)
        {
			NSLog(@"[net] read data");
            return iResult;
        }
    }
    
	
    memcpy(&response, buffer, sizeof(DEV_RESPONSE));
    NSLog(@"[net] %x, %x, %x, %x", response.rsp_mark, response.errors_code, response.cmd_group_mark, response.cmd_code_mark);
    NSLog(@"[net] payloadsize = %lu", response.payload_size);
    
    if ([aCommond isNeedRestart])
    {
        return DEV_ERROR_SUCCESS;
    }
    
	
	if (response.rsp_mark != 28 ||  response.payload_size != (responseSize-sizeof(DEV_RESPONSE)))
	{
		//NSLog(@"[net] %x, %x, %x, %x", response.rsp_mark, response.errors_code, response.cmd_group_mark, response.cmd_code_mark);
		return iResult;
	
	}
	if([aCommond IDCode] != DEV_CMD_CODE_ID_GET_WIRELESS_SETTINGS && [aCommond IDCode] != DEV_CMD_CODE_ID_GET_WIRELESSDIRECT_SETTINGS ){
		if (response.errors_code != 0 ){
			
			
			NSLog(@"response error = %d", response.errors_code);
			
			NSLog(@"Response error code != 0");
			return iResult;
			
			
		}
		
	}

	
	
	else {
		
		if (response.errors_code == 5 && response.cmd_group_mark == DEV_CMD_GROUP_ID_SET) {
			
			
			
		}
		
		else if (response.errors_code == 1 && response.cmd_group_mark == DEV_CMD_GROUP_ID_SET) {
			
			NSLog(@"[net] wifi set response error = %d", response.errors_code);
			
			return iResult;
			
			
		}
		
		else if (response.errors_code == 0 && response.cmd_group_mark == DEV_CMD_GROUP_ID_SET) {
			
			NSLog(@"[net] wifi set response error = %d", response.errors_code);
			iResult = DEV_ERROR_WIFI_FAILED;
			return iResult;
			
			
		}
		else if(response.errors_code != 5 && response.cmd_group_mark == DEV_CMD_GROUP_ID_SET){
			NSLog(@"[net] wifi set response error = %d", response.errors_code);
			iResult = DEV_ERROR_WIFI_FAILED;
			
			return iResult;
		}
		else
		{
			if(response.errors_code != 0)
			{
				NSLog(@"[net] response error = %d", response.errors_code);
				//iResult = DEV_ERROR_WIFI_FAILED;
				
				return iResult;
				
			}
			
		}
		
		
	}
	
	
    
    if(response.payload_size > 1024)
    {
        UInt32 *size_ = (UInt32 *)(buffer + sizeof(DEV_RESPONSE) - sizeof(UInt32));
        response.payload_size = EndianU32_NtoL(*size_);
    }
    
    if (response.cmd_group_mark == DEV_CMD_GROUP_ID_GET && 
        (response.payload_size == 0 || response.payload_size > 1024))
    {
        NSLog(@"Get paylaod_size wrong");
        NSLog(@"payload_size = %lu", response.payload_size);
        return iResult;
    }
    
    if(response.payload_size > 0)
    {
        if (devType == USB_TYPE)
        {
			[aCommond setDeviceData:(id)(buffer + sizeof(DEV_RESPONSE)) dataSize:response.payload_size];
        }
        else if (devType == NET_TYPE)
        {
            [aCommond setDeviceData:(id)resPayloadBuffer dataSize:response.payload_size];
        }
    }
    
    iResult = DEV_ERROR_SUCCESS;
    
    return iResult;
}

- (void) getPrinterStatusFromSmon:(UInt32 *)status Index:(int)iIndex IsNeedWait:(BOOL)isNeedWait
{
    *status = T_PRINTER_STATUS_UNKNOWN;
    
	
	
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [libraryDirectory stringByAppendingPathComponent:STATUS_MONITOR_PATH];
    NSString *smonPath = [finalPath stringByAppendingPathComponent:SMON];
    NSTask *aTask = [[NSTask alloc] init];
    NSPipe *taskPipe = [[NSPipe alloc]init];
    [aTask setStandardError:taskPipe];
    [aTask setStandardOutput:taskPipe];
    [aTask setLaunchPath:smonPath];
	[aTask setArguments:[NSArray arrayWithObjects: @"unlock",[NSString stringWithFormat:@"%d", iIndex], nil]];
    [aTask launch];	
	
	if(isNeedWait == YES)
    {
        [aTask waitUntilExit];
    }
    [taskPipe release];
	[aTask release];
	
	
    aTask = [[NSTask alloc] init];
    taskPipe = [[NSPipe alloc]init];
    [aTask setStandardError:taskPipe];
    [aTask setStandardOutput:taskPipe];
    [aTask setLaunchPath:smonPath];
    [aTask setArguments:[NSArray arrayWithObjects:[NSString stringWithFormat:@"%d", iIndex], @"data", nil]];
    [aTask launch];
    
    if(isNeedWait == YES)
    {
        [aTask waitUntilExit];
    }
    
    NSFileHandle *readHandle = [taskPipe fileHandleForReading];
    NSData *inData = [readHandle availableData];
    if(inData != nil)
    {
        int length = [inData length];
        if([inData length])
        {
            NSString *stringStatus = [[NSString alloc] initWithBytes:[inData bytes] length:length encoding:NSUTF8StringEncoding];
            NSLog(@"stringStauts = %@",stringStatus);
            NSArray *listItems = [stringStatus componentsSeparatedByString:@";"];
            if([listItems count] >= 2)
            {
				
				*status = [[listItems objectAtIndex:1] intValue];
				
				
            }
            
            [stringStatus release];
        }
    }
    
    [taskPipe release];
    [aTask release];
}

- (BOOL)isCurrentPrinter:(int)iIndex currentPrinterID:(NSString *)printerID IsNeedWait:(BOOL)isNeedWait
{
    BOOL isSame = NO;
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [libraryDirectory stringByAppendingPathComponent:STATUS_MONITOR_PATH];
    NSString *smonPath = [finalPath stringByAppendingPathComponent:SMON];
    NSTask *aTask = [[NSTask alloc] init];
    NSPipe *taskPipe = [[NSPipe alloc]init];
    [aTask setStandardOutput:taskPipe];
    [aTask setLaunchPath:smonPath];
    [aTask setArguments:[NSArray arrayWithObject:[NSString stringWithFormat:@"%d", iIndex]]];
    [aTask launch];
    
    if(isNeedWait == YES)
    {
        [aTask waitUntilExit];
    }
    
    NSData *inData;
    NSFileHandle *readHandle = [taskPipe fileHandleForReading];
    inData = [readHandle availableData];

    if(nil != inData)
    {
        int length = [inData length];
        if(length)
        {
            NSString *stringName = [[NSString alloc]initWithBytes:[inData bytes] length:length encoding:NSUTF8StringEncoding];
			NSLog(@"stringName = %@, inData=%@", stringName, inData);

            if([stringName isEqualToString:printerID])
            {
                isSame = YES;
            }
            
            [stringName release];
        }
    }
	else {
		NSLog(@"nil == inData");
	}

    
    [aTask release];
    [taskPipe release];
    
    return isSame; 
}

- (void)setStatusMonitorTimeout:(NSString *)timeout
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [libraryDirectory stringByAppendingPathComponent:STATUS_MONITOR_PATH];
    NSString *smonPath = [finalPath stringByAppendingPathComponent:SMON];
    NSTask *aTask = [[NSTask alloc] init];
    [aTask setLaunchPath:smonPath];
    [aTask setArguments:[NSArray arrayWithObjects:@"rftimer", timeout, nil]];
    [aTask launch];
    [aTask release];
}

- (int)getStatusMonitorTimeout
{
    int tiemout = 5;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [libraryDirectory stringByAppendingPathComponent:STATUS_MONITOR_PATH];
    NSString *smonPath = [finalPath stringByAppendingPathComponent:SMON];
    NSPipe *taskPipe = [[NSPipe alloc]init];
    NSTask *aTask = [[NSTask alloc] init];
    [aTask setStandardError:taskPipe];
    [aTask setStandardOutput:taskPipe];
    [aTask setLaunchPath:smonPath];
    [aTask setArguments:[NSArray arrayWithObjects:@"printRfTimer", nil]];
    [aTask launch];
    [aTask waitUntilExit];
	
    NSFileHandle *readHandle = [taskPipe fileHandleForReading];
    NSData *inData = [readHandle availableData];
    if(inData)
    {
        int length = [inData length];
        if(length)
        {
            NSString *string = [[NSString alloc] initWithBytes:[inData bytes] length:length encoding:NSUTF8StringEncoding];
            tiemout = [string intValue];
            //NSLog(@"get timeout = %d", tiemout);
            [string release];
        }
    }
    
    [aTask release];    
    [taskPipe release];
	
    return tiemout;
}

- (int)printerStatus:(UInt32 *)status CurrentPrinterID:(NSString *)printerID IsNeedWait:(BOOL)isNeedWait
{
    *status = T_PRINTER_STATUS_UNKNOWN;
	
    //int timeoutBak = [self getStatusMonitorTimeout];
    //[self setStatusMonitorTimeout:@"0"];
    //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
    [[NSApp delegate] reflushPrinterStatus];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSLocalDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *finalPath = [libraryDirectory stringByAppendingPathComponent:STATUS_MONITOR_PATH];
    NSString *smonPath = [finalPath stringByAppendingPathComponent:SMON];
    NSTask *aTask = [[NSTask alloc] init];
    NSPipe *taskPipe = [[NSPipe alloc]init];
    [aTask setStandardError:taskPipe];
    [aTask setStandardOutput:taskPipe];
    [aTask setLaunchPath:smonPath];
    [aTask setArguments:[NSArray arrayWithObject:@"size"]];
    [aTask launch];
    
    if(isNeedWait == YES)
    {
        [aTask waitUntilExit];
    }
    
    NSFileHandle *readHandle = [taskPipe fileHandleForReading];
    NSData *inData = [readHandle availableData];
    if(inData != nil)
    {
        int length = [inData length];
        if(length)
        {
            NSString *string = [[NSString alloc] initWithBytes:[inData bytes] length:length encoding:NSUTF8StringEncoding];
            int n = [string intValue];
            NSLog(@"smon size = %d, inData=%@, string=%@, printerID=%@", n, inData,string, printerID);
            [string release];
            
            BOOL ret = NO;
            int i;
            for(i = 0; i < n; i++)
            {
                NSLog(@"i = %d", i);
                
                ret = [self isCurrentPrinter:i currentPrinterID:printerID IsNeedWait:isNeedWait];
                if(ret == YES)
                {
                    //[[NSApp delegate] reflushPrinterStatus];
                    [self setStatusMonitorTimeout:@"6"];
                    
                    UInt32 tmp = 0;
                    int j;
                    for(j = 0; j < 3; j++)
                    {
                        [self getPrinterStatusFromSmon:&tmp Index:i IsNeedWait:isNeedWait];
                        if(tmp != 0 )
                        {
                            *status = tmp;
                            NSLog(@"Get status from statusMon success! status=%d", tmp);
                            break;
                        }
                        else
                        {
                            NSLog(@"Can't get status from statusMon");
                        }
                    }
                    
                    break;
                }
                else
                {
					NSLog(@"Priners of statusMon don't include current printer");
                }
            }
        }
    }
    
	
    //[self setStatusMonitorTimeout:[NSString stringWithFormat:@"%d", timeoutBak]];
    [aTask release];
    [taskPipe release];
    
    return DEV_ERROR_SUCCESS;
}

- (BOOL)isPrinterReadyStatus:(UInt32)status
{
#if 0	
    switch(status)
    {
        case T_PRINTER_STATUS_READY:
        case T_PRINTER_STATUS_PAUSE:
        case T_PRINTER_STATUS_TONER_LOW:
        case T_PRINTER_STATUS_DOOR_OPEN:
        case T_PRINTER_STATUS_NO_TONER:
        case T_PRINTER_STATUS_USER_INTERVENTION_REQUIRED:
        case T_PRINTER_STATUS_POWER_SAVE_MODE:
        case T_PRINTER_STATUS_PAPER_PROBLEM:
        case T_PRINTER_STATUS_MANUAL_FEED_REQUIRED:
        case T_PRINTER_STATUS_PAPER_JAM:
        case T_PRINTER_STATUS_OUT_OF_MEMORY:
        case T_PRINTER_STATUS_OUT_OF_PAPER:
        case T_PRINTER_STATUS_PAGE_ERROR:
        case T_PRINTER_STATUS_OUTPUT_BIN_FULL:
        case T_PRINTER_ADF_COVER_OPEN:
        case T_PRINTER_ADF_PAPER_JAM:
			
            return YES;
        default:
            return NO;
    }
#endif
    return YES;
}

-(BOOL)isPrintQueuePrinting:(NSString *)strPrinterID
{
    const char *buffer = [strPrinterID UTF8String];
    
    CFStringRef printerID = CFStringCreateWithCString(NULL, buffer, kCFStringEncodingUTF8);
    
    if(printerID == NULL)
        return NO;
    
    PMPrinter printer = PMPrinterCreateFromPrinterID(printerID);
    
    PMPrinterState printerState;
    PMPrinterGetState(printer, &printerState);
	
    BOOL isPrinting = NO;
    
    switch(printerState)
    {
        case kPMPrinterIdle: 
            break;
            
        case kPMPrinterProcessing:
            isPrinting = YES;
            break;
            
        case kPMPrinterStopped: 
            break;
            
        default:
            break;
    };
	
    
    PMRelease(printer);
    CFRelease(printerID);
    
    return isPrinting;
    
}

- (int)getDevType
{
    return devType;
}

- (void)relDevice
{
    [device closeSocket];
    [device release];
    device = nil;
}

- (int)canCommunicateWithPrinterID:(NSString *)strPrinterID Status:(UInt32)status
{
   // AppDelegate *app = [NSApp delegate];
    
    /*if(NO == [app isStatusMonitorReady])
	 {
	 return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
	 }*/
    
    if(YES == [self isPrintQueuePrinting:strPrinterID])
    {
        return DEV_ERROR_PRINTER_RUNNING;
    }
    
	
    
    if([self isPrinterReadyStatus:status])
    {
        return DEV_ERROR_SUCCESS;
    }
    
    switch(status)
    {
        case T_PRINTER_STATUS_PRINTING:
        case T_PRINTER_STATUS_WARMING_UP:
        case T_PRINTER_STATUS_PENDING_DELETION:
        case T_PRINTER_STATUS_WAITING:
        case T_PRINTER_STATUS_PROCESSING:
        case T_PRINTER_STATUS_BUSY:
        case T_PRINTER_STATUS_INITIALIZING:
        case T_PRINTER_STATUS_ACTIVE:
			return DEV_ERROR_PRINTER_RUNNING;
            
        case T_PRINTER_STATUS_NOT_AVAILABLE:
        case T_PRINTER_STATUS_NOT_SUPPORT:
        case T_PRINTER_STATUS_POWER_OFF:
        case T_PRINTER_STATUS_OFFLINE:
        case T_PRINTER_STATUS_ERROR:
        case T_PRINTER_STATUS_UNKNOWN:
        default:
            return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
            
    }
    
    return DEV_ERROR_COMMUNICATE_WITH_PRINTER_FAILED;
}
@end
