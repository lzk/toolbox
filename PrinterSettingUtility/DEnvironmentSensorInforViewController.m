//
//  DEnvironmentSensorInforViewController.m
//  MachineSetup
//
//  Created by Wang Kun on 11/25/13.
//
//

#import "DEnvironmentSensorInforViewController.h"
#import "DeviceProperty.h"

@interface DEnvironmentSensorInforViewController ()

@end

@implementation DEnvironmentSensorInforViewController

- (id)init
{
    self = [super init];
    if (self)
    {
        contentTitle = NSLocalizedString(@"Environment Sensor Info", nil);
        [devciePropertyList addObject:[[[PrinterInformation alloc] init] autorelease]];
        
        [self initWithNibName:@"DEnvironmentSensorInforViewController" bundle:nil];
    }
    
    return self;
}

+ (NSString *)description
{
    return NSLocalizedString(@"Environment Sensor Info", nil);
}

- (void)awakeFromNib
{
    [getInforButton setTitle:NSLocalizedString(@"Get Environment Sensor Info", nil)];
    [resultTextField setStringValue:NSLocalizedString(@"Result", nil)];
    [textView setString:@""];
    [textView setEditable:NO];
    
    isUpdataView = NO;
}

- (void)UpdatePrinterPropertyToView:(id)directionWithResult
{
    [super UpdatePrinterPropertyToView:directionWithResult];
    
    NSNumber *result = [directionWithResult objectAtIndex:1];
    if([result intValue] != DEV_ERROR_SUCCESS)
    {
        if (isUpdataView)
        {
            [getInforButton setEnabled:YES];
        }
        return;
    }
    
    int i;
    for (i = 0; i < [devciePropertyList count]; i++)
    {
        DeviceCommond *data = [devciePropertyList objectAtIndex:0];
        [self updateView:[data deviceData]];
    }
}

- (void)updateView:(id)data
{
    if (isUpdataView)
    {
        DEV_ENVIRONMENT_SENSOR_INFO *devData = (DEV_ENVIRONMENT_SENSOR_INFO *)data;
        NSString *s1 = NSLocalizedString(@"Temperature inside the machine", nil);
        NSString *s2 = NSLocalizedString(@"Humidity inside the machine", nil);
        NSString *s3 = [NSString stringWithFormat:@"%d°C/%d°F", devData->uiEnvTemperture,
                                                                (UInt8)(devData->uiEnvTemperture * 1.8 + 32)];
        NSString *s4 = [NSString stringWithFormat:@"%d%\%", devData->uiHumidity];
        NSString *string = [NSString stringWithFormat:@"%@: %@\n%@: %@", s1, s3, s2, s4];
        [textView setString:string];
        
        NSLog(@"%d", devData->uiEnvTemperture);
    }
}


- (IBAction)getInforButtonAction:(id)sender
{
    isUpdataView = YES;
    [devciePropertyList removeAllObjects];
    [devciePropertyList addObject:[[[EnvironmentSensorInfo alloc] init] autorelease]];
    [self getInfoFromDevice];
}

@end
