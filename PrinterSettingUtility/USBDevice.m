//
//  USBDevice.m
//  MachineSetup
//
//  Created by Helen Liu on 7/21/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "USBDevice.h"
#import "DataStructure.h"
#import "AppDelegate.h"
#import <IOKit/IOKitLib.h>
#import <IOKit/IOCFPlugIn.h>

@implementation USBDevice

- (id)init
{
	self = [super init];
	if (self != nil)
	{
	}
	
	return self;
}

- (void)dealloc
{
	[self USBDisconnect];
	[super dealloc];
}

- (BOOL) dealWithPipes:(IOUSBInterfaceInterface300 **)intf
{
	BOOL				bRet = FALSE;
	
    int					i;
    IOReturn			err;
    UInt8				direction, number, transferType, interval;
    UInt16				maxPacketSize;
    UInt8				numPipes;
	
	if (intf == NULL)
	{
		return bRet;
	}
	
	err = (*intf)->GetNumEndpoints(intf, &numPipes);
    if (err)
    {
		return bRet;
    }
    
    if (numPipes == 0)
    {
		// try alternate setting 1
		err = (*intf)->SetAlternateInterface(intf, 1);
		if (err)
		{
			return bRet;
		}
		
		err = (*intf)->GetNumEndpoints(intf, &numPipes);
		if (err)
		{
			return bRet;
		}
		
		numPipes = 13;  		// workaround. GetNumEndpoints does not work after SetAlternateInterface
    }
	
    
    // pipes are one based, since zero is the default control pipe
    for (i=1; i <= numPipes; i++)
    {
		err = (*intf)->GetPipeProperties(intf, i, &direction, &number, &transferType, &maxPacketSize, &interval);
		if (err)
		{
			return bRet;
		}
		
        if (transferType == kUSBBulk && direction == kUSBIn && !inPipeRef)
        {
            // grabbing BULK IN pipe index i
            inPipeRef = i;
            maxInPacketSize = maxPacketSize;
            continue;
        }
        
        if (transferType == kUSBBulk && direction == kUSBOut && !outPipeRef)
        {
            // grabbing BULK OUT pipe index i
            outPipeRef = i;
            maxOutPacketSize = maxPacketSize;
            continue;
        }
    }
	
	return TRUE;
}

- (NSString*) findStringFromDeviceID:(NSString*) deviceID prefix:(NSString*) prefix
{
	NSString *str;
	
	NSRange range = [deviceID rangeOfString:prefix options:NSCaseInsensitiveSearch];
	str = [deviceID substringFromIndex:(range.location + range.length)];
	
	range = [str rangeOfString:@";" options:NSCaseInsensitiveSearch];
	str = [str substringToIndex:range.location];
	
	range.location = 0;
	range.length = 0;
	for (range.length = 0; range.length < [str length]; range.length++)
	{
		if ([str characterAtIndex: range.length] != 0x20)
		{
			break;
		}
	}
	
	if (range.length > 0)
	{
		str = [str substringFromIndex:(range.location + range.length)];
	}
	
	return str;
}

- (BOOL) compareInterface:(IOUSBInterfaceInterface300**)intf withVendorName:(NSString*)vendor interfaceName:(NSString*)name
{
	IOUSBDevRequest			req;
	IOReturn				err;
	
	Byte					buf[1024];
	UInt16					stringLen = 1024;
	UInt8					intfNumber;
	
	err = (*intf)->GetInterfaceNumber(intf, &intfNumber);
	if (err != kIOReturnSuccess)
	{
		return FALSE;
	}
	
	req.bmRequestType = USBmakebmRequestType(kUSBIn, kUSBClass, kUSBInterface);//0xa1;//USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice);
	req.bRequest = 0x0;
	req.wValue = 0x0;
	req.wIndex = (intfNumber << 8) | 0x0;
	req.wLength = stringLen;
	req.pData = buf;
	
	memset(buf, 0, stringLen);
	
	err = (*intf)->ControlRequest(intf, 0, &req);
	if (err != kIOReturnSuccess || stringLen == 0)
	{
		return FALSE;
	}
	
	NSString *intfName;
	NSString *mfg;
	NSString *deviceID = [NSString stringWithCString:(const char*)(buf+2) encoding:NSASCIIStringEncoding];
	
	// vendor name
	mfg = [self findStringFromDeviceID:deviceID prefix:@"MFG:"];
	
	// product name
	intfName = [self findStringFromDeviceID:deviceID prefix:@"MDL:"];
	
	return ((NSOrderedSame == [name compare:intfName options:NSCaseInsensitiveSearch]) &&
			(NSOrderedSame == [vendor compare:mfg options:NSCaseInsensitiveSearch]));/*([name isEqual:intfName] && [vendor isEqual:mfg]);*/
}

- (IOUSBInterfaceInterface300**) openInterfaceInterface:(io_service_t) usbInterfaceRef
{
    IOReturn					err;
    IOCFPlugInInterface 		**iodev;		// requires <IOKit/IOCFPlugIn.h>
    IOUSBInterfaceInterface300 	**intf;
    SInt32						score;
	
    err = IOCreatePlugInInterfaceForService(usbInterfaceRef, kIOUSBInterfaceUserClientTypeID, kIOCFPlugInInterfaceID, &iodev, &score);
    if (err || !iodev)
    {
		return NULL;
    }
    err = (*iodev)->QueryInterface(iodev, CFUUIDGetUUIDBytes(kIOUSBInterfaceInterfaceID300), (LPVOID)&intf);
	IODestroyPlugInInterface(iodev);				// done with this
	
    if (err || !intf)
    {
		return NULL;
    }
	
    err = (*intf)->USBInterfaceOpen(intf);
    if (err != kIOReturnSuccess && err != kIOReturnExclusiveAccess)
    {
		return NULL;
    }
	
	return  intf;
}

- (void) closeInterfaceInterface:(IOUSBInterfaceInterface300**)intf
{
    IOReturn	err;
	
	if (intf == NULL)
	{
		return;
	}
	
    err = (*intf)->USBInterfaceClose(intf);
	if (err)
	{
		return;
	}
	
	err = (*intf)->Release(intf);
	if (err)
	{
		return;
	}
}

- (BOOL) compareDevice:(io_service_t) usbDeviceRef serialNumber:(NSString*) serial
{
	BOOL							bRet = FALSE;
	
    IOReturn						err;
    IOCFPlugInInterface				**iodev;		// requires <IOKit/IOCFPlugIn.h>
    IOUSBDeviceInterface300			**dev;
    SInt32							score;
    
    err = IOCreatePlugInInterfaceForService(usbDeviceRef, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &iodev, &score);
    if (err || !iodev)
    {
		return FALSE;
    }
    err = (*iodev)->QueryInterface(iodev, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID300), (LPVOID)&dev);
	IODestroyPlugInInterface(iodev);				// done with this
	
    if (err || !dev)
    {
		return FALSE;
    }
	
    err = (*dev)->USBDeviceOpen(dev);
    if (err != kIOReturnSuccess && err != kIOReturnExclusiveAccess)
	{
        (*dev)->Release(dev);
		return FALSE;
	}
	
	IOUSBDevRequestTO			req;
	
	UInt8					descIndex = 0;
	UInt16					wIndex = 0x0409;
	
	Byte					buf[256];
	
	err = (*dev)->USBGetSerialNumberStringIndex(dev, &descIndex);
	if (err != kIOReturnSuccess)
	{
		return FALSE;
	}
	
	req.bmRequestType = USBmakebmRequestType(kUSBIn, kUSBStandard, kUSBDevice);
	req.bRequest = kUSBRqGetDescriptor;
	req.wValue = (kUSBStringDesc << 8) | descIndex;
	req.wIndex = wIndex;
	req.pData = buf;
	req.wLength = 256;
	
	NSBundle * bundle = [NSBundle mainBundle];
	NSString * timeout = [bundle objectForInfoDictionaryKey:@"USBTimeout"];
	if(timeout)
	{
		req.noDataTimeout = [timeout intValue];
		req.completionTimeout = [timeout intValue];
	}
	else {
		req.noDataTimeout = 5000;
		req.completionTimeout = 5000;
	}


	
	err = (*dev)->DeviceRequestTO(dev, &req);
	if (err != kIOReturnSuccess)
	{
        (*dev)->USBDeviceClose(dev);
        (*dev)->Release(dev);
		return FALSE;
	}
	
	int i;
	int length = (((Byte *)buf)[0] - 2) / 2;
	SInt16 *pTemp = (SInt16*)(buf+2);
	for (i = 0; i < length; i++)
	{
		pTemp[i] = EndianU16_LtoN(pTemp[i]);
	}
	
	NSString *serialFromDevice = [NSString stringWithCharacters:(const unichar *)(buf+2) length:length];//[NSString stringWithCString:(const char*)(buf+2) encoding:NSUnicodeStringEncoding];
	
	bRet = (NSOrderedSame == [serial compare:serialFromDevice options:NSCaseInsensitiveSearch]);
    
    err = (*dev)->USBDeviceClose(dev);
    if (err)
    {
		(*dev)->Release(dev);
		return bRet;
    }
    err = (*dev)->Release(dev);
    if (err)
    {
		return bRet;
    }
	
	return bRet;
}

-(BOOL)dealWithDevice:(io_service_t) usbDeviceRef deviceID:(NSString*) deviceID vendorName:(NSString*) vendor serialNumber:(NSString*)serial
{
	IOReturn						err;
	IOCFPlugInInterface				**iodev;		// requires <IOKit/IOCFPlugIn.h>
	SInt32							score;
	//UInt8							numConf;
	//IOUSBConfigurationDescriptorPtr	confDesc;
	IOUSBFindInterfaceRequest		interfaceRequest;
	io_iterator_t					iterator;
	io_service_t					usbInterfaceRef;
    
    
    IOUSBInterfaceInterface300	**intf;
    UInt8					intfClass;
    BOOL					bRet = FALSE;
    
    
	err = IOCreatePlugInInterfaceForService(usbDeviceRef, kIOUSBDeviceUserClientTypeID, kIOCFPlugInInterfaceID, &iodev, &score);
	if (err || !iodev)
	{
        
		printf("dealWithDevice: unable to create plugin. ret = %08x, iodev = %p\n", err, iodev);
		return FALSE;
	}
	err = (*iodev)->QueryInterface(iodev, CFUUIDGetUUIDBytes(kIOUSBDeviceInterfaceID300), (LPVOID*)&devPrinter);
	IODestroyPlugInInterface(iodev);				// done with this
    
	if (err || !devPrinter)
	{
        
		printf("dealWithDevice: unable to create a device interface. ret = %08x, dev = %p\n", err, devPrinter);
		return FALSE;
	}
	err = (*devPrinter)->USBDeviceOpen(devPrinter);
	if (err)
	{
        
		printf("dealWithDevice: unable to open device. ret = %08x\n", err);
        (*devPrinter)->Release(devPrinter);
		devPrinter = 0;
		return FALSE;
	}
    
    
    
	interfaceRequest.bInterfaceClass = kIOUSBFindInterfaceDontCare;		// requested class
	interfaceRequest.bInterfaceSubClass = kIOUSBFindInterfaceDontCare;		// requested subclass
	interfaceRequest.bInterfaceProtocol = kIOUSBFindInterfaceDontCare;		// requested protocol
	interfaceRequest.bAlternateSetting = kIOUSBFindInterfaceDontCare;		// requested alt setting
    
	err = (*devPrinter)->CreateInterfaceIterator(devPrinter, &interfaceRequest, &iterator);
	if (err)
	{
		printf("dealWithDevice: unable to create interface iterator\n");
		(*devPrinter)->USBDeviceClose(devPrinter);
		(*devPrinter)->Release(devPrinter);
		devPrinter = 0;
		return FALSE;
	}
    
	//int index=0;
	while ( (usbInterfaceRef = IOIteratorNext(iterator)) )
	{
        NSLog(@"iterator2");
        intf = [self openInterfaceInterface:usbInterfaceRef];
		
		if (intf != NULL)
		{
			err = (*intf)->GetInterfaceClass(intf, &intfClass);
			if (err == kIOReturnSuccess && intfClass == kUSBPrintingClass)
			{
				bRet = [self compareInterface:(IOUSBInterfaceInterface300**)intf withVendorName:vendor interfaceName:deviceID];
				if (bRet && serial != nil && [serial isEqual:@""] == NO)
				{
					err = (*intf)->GetDevice(intf, &usbDeviceRef);
					if (err == kIOReturnSuccess)
					{
						bRet = [self compareDevice:usbDeviceRef serialNumber: serial];
					}
				}
                
				if (bRet && [self dealWithPipes: intf])
				{
					intfPrinter = intf;
					IOObjectRelease(usbInterfaceRef);
					break;
				}
				else
				{
					[self closeInterfaceInterface:intf];
					intf = NULL;
				}
			}
		}
        
		IOObjectRelease(usbInterfaceRef);				// no longer need this reference
        
	}
    
	IOObjectRelease(iterator);
	iterator = 0;
    return bRet;
    
}

- (BOOL) openInterfaceWithDeviceId:(NSString*) deviceID vendorName:(NSString*) vendor serialNumber:(NSString*)serial
{
	BOOL					bRet = FALSE;
    kern_return_t			err;
    CFMutableDictionaryRef 	matchingDictionary = 0;		// requires <IOKit/IOKitLib.h>
    io_iterator_t			iterator = 0;
    io_service_t			usbIntfRef;
	//io_service_t			usbDeviceRef;
    CFNumberRef				numberRef;
	//SInt8					idIntfClass = 0x07;
	
    mach_port_t				masterPort;
    
    SInt32  idVendor;
    SInt32  idProduct;
    
#ifdef MACHINESETUP_XC
    idVendor = USB_VENDER_ID_6020;
    idProduct = USB_PRODUCT_ID_6020;
#endif
	
#ifdef MACHINESETUP_IBG
    NSString *sTmp = [[NSApp delegate] modelNameNoVersion];
    NSArray *aTmp = [[NSApp delegate] supportedList];
    
    if ([sTmp isEqualToString:[aTmp objectAtIndex:0]])
    {
        idVendor = USB_VENDER_ID_CP115;
        idProduct = USB_PRODUCT_ID_CP115;
    }
    else if ([sTmp isEqualToString:[aTmp objectAtIndex:1]])
    {
        idVendor = USB_VENDER_ID_CP116;
        idProduct = USB_PRODUCT_ID_CP116;
    }
#endif
    
	err = IOMasterPort(MACH_PORT_NULL, &masterPort);
	if (err)
	{
        NSLog(@"err = %@", err);
		return FALSE;
	}
	
    //NSLog(@"%d", __LINE__);
	matchingDictionary = IOServiceMatching(kIOUSBDeviceClassName);
	if (!matchingDictionary)
	{
		printf("USBSimpleExample: could not create matching dictionary\n");
		return FALSE;
	}
	numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &idVendor);
	if (!numberRef)
	{
		printf("USBSimpleExample: could not create CFNumberRef for vendor\n");
		return FALSE;
	}
	CFDictionaryAddValue(matchingDictionary, CFSTR(kUSBVendorID), numberRef);
	CFRelease(numberRef);
	numberRef = 0;
	numberRef = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &idProduct);
	if (!numberRef)
	{
		printf("USBSimpleExample: could not create CFNumberRef for product\n");
		return FALSE;
	}
	CFDictionaryAddValue(matchingDictionary, CFSTR(kUSBProductID), numberRef);
	CFRelease(numberRef);
	numberRef = 0;
    //NSLog(@"%d", __LINE__);
	err = IOServiceGetMatchingServices(masterPort, matchingDictionary, &iterator);
    NSLog(@"%d", err);
	matchingDictionary = 0;			// this was consumed by the above call
    
    
    //NSLog(@"%d", __LINE__);
    while ((usbIntfRef = IOIteratorNext(iterator)) )
    {
        NSLog(@"iterator1");
        // NSLog(@"%d", __LINE__);
        //usbIntfRef = IOIteratorNext(iterator);
        
        bRet = [self dealWithDevice:usbIntfRef deviceID:deviceID vendorName:vendor serialNumber:serial];
        
		IOObjectRelease(usbIntfRef);			// no longer need this reference
        
        if(bRet)
            break;
    }
    //NSLog(@"%d", __LINE__);
    IOObjectRelease(iterator);
    iterator = 0;
	
	mach_port_deallocate(mach_task_self(), masterPort);
	
	return bRet;
}

- (BOOL) USBConnect:(NSString*) printerURI
{
	NSURL *url = [NSURL URLWithString:printerURI];
	
	NSString *scheme = [url scheme];
	
	[self USBDisconnect];
	
	if ([scheme compare:@"usb" options:NSCaseInsensitiveSearch] == NSOrderedSame)
	{
		NSString *vendor;
		NSString *product;
		NSString *serial;
		
		// vendor
		vendor = [url host];
		// Product Name
		NSString *path = [url path];
		NSRange range = [path rangeOfString:@"/"];
		
		if (range.length > 0)
		{
			product = [path substringFromIndex:(range.location+range.length)];
			//product = [path stringByReplacingCharactersInRange:range withString:@""];
		}
		else
		{
			product = path;
		}
        
		NSString *query = [url query];
		range = [query rangeOfString:@"serial=" options:NSCaseInsensitiveSearch];
		if (range.length > 0)
		{
			serial = [query substringFromIndex:(range.location+range.length)];
			//serial = [query stringByReplacingCharactersInRange:range withString:@""];
		}
		
		return [self openInterfaceWithDeviceId:product vendorName:vendor serialNumber:serial];
	}
	
	return FALSE;
}

- (void) USBDisconnect
{
	[self closeInterfaceInterface:intfPrinter];
    
    if(devPrinter)
	{
		(*devPrinter)->USBDeviceClose(devPrinter);
		(*devPrinter)->Release(devPrinter);
		devPrinter = 0;
	}
    
	intfPrinter = NULL;
	
    outPipeRef = 0;
    inPipeRef = 0;
    maxOutPacketSize = 0;
    maxInPacketSize = 0;
    
}

- (BOOL) isPrinterOpen
{
	return (intfPrinter != NULL);
}

IOResult MakeIOResult(kern_return_t err, int readOrWriteBytes)
{
    IOResult result;
    result.err = err;
    result.readOrWriteBytes = readOrWriteBytes;
    return result;
}

- (IOResult) USBRead:(LPVOID) buffer bufferLength:(UInt32) length
{
	IOReturn	ret;
	UInt32		size = length;
	
	if (buffer == NULL || size == 0)
	{
		return MakeIOResult(kIOReturnSuccess, 0);
	}
	else if (intfPrinter == NULL || (*intfPrinter) == NULL)
	{
		return MakeIOResult(kIOReturnNoDevice, 0);
	}
	else
	{
		int noDataTimeout = 5000;
		int completionTimeout = 5000;
		NSBundle * bundle = [NSBundle mainBundle];
		NSString * timeout = [bundle objectForInfoDictionaryKey:@"USBTimeout"];
		if(timeout)
		{
			noDataTimeout = [timeout intValue];
			completionTimeout = [timeout intValue];
		}

		
		ret = (*intfPrinter)->ReadPipeTO(intfPrinter, inPipeRef, buffer, &size,noDataTimeout,completionTimeout);
		
		if (ret == kIOReturnSuccess)
		{
			//NSDate *today = [NSDate date];
			////NSLog(@"%@, read data from printer, %d bytes:\r\n\r\n", [today description], size);
			//[Log writeDebugDataLog:buffer bufferSize:size];
			//[Log writeDebugTextLog:"\r\n"];
		}
		
		return MakeIOResult(ret, size);
	}
}

- (IOResult) USBWrite:(LPVOID) buffer bufferLength:(UInt32) length
{
	IOReturn	ret;
	UInt32		size = length;
	
	if (buffer == NULL || size == 0)
	{
		return MakeIOResult(kIOReturnSuccess, 0);
	}
	else if (intfPrinter == NULL || (*intfPrinter) == NULL)
	{
		return MakeIOResult(kIOReturnNoDevice, 0);
	}
	else
	{
		int noDataTimeout = 5000;
		int completionTimeout = 5000;
		NSBundle * bundle = [NSBundle mainBundle];
		NSString * timeout = [bundle objectForInfoDictionaryKey:@"USBTimeout"];
		if(timeout)
		{
			noDataTimeout = [timeout intValue];
			completionTimeout = [timeout intValue];
		}
		
		
		ret = (*intfPrinter)->WritePipeTO(intfPrinter, outPipeRef, buffer, size,noDataTimeout,completionTimeout);
		
		if (ret == kIOReturnSuccess)
		{
			NSDate *today = [NSDate date];
			//[Log writeDebugLogWithFormat:"%s, write data to printer, %d bytes:\r\n\r\n", [today description], size];
			//[Log writeDebugDataLog:buffer bufferSize:size];
			//[Log writeDebugTextLog:"\r\n"];
		}
		
		return MakeIOResult(ret, size);
	}	
}

@end
