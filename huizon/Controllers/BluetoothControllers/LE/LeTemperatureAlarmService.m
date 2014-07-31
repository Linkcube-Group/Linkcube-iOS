#import "LeTemperatureAlarmService.h"
#import "LeDiscovery.h"

NSString *kDeviceInfoService = @"180A";
NSString *kDeviceIsscProprietaryService = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";
NSString *kDeviceServiceUUIDString = @"49535343-FE7D-4AE5-8FA9-9FAFD205E455";
NSString *kDeviceCharacteristicUUID = @"49535343-8841-43F4-A8D4-ECBE34729BB3";

@interface LeTemperatureAlarmService() <CBPeripheralDelegate> {
@private
    CBPeripheral		*servicePeripheral;
    
    CBService			*temperatureAlarmService;

    CBCharacteristic    *myCharacteristic;
    
    id<LeTemperatureAlarmProtocol>	peripheralDelegate;
}

@property (strong,nonatomic) CBCharacteristic    *myCharacteristic;

@end



@implementation LeTemperatureAlarmService
@synthesize myCharacteristic;

@synthesize peripheral = servicePeripheral;


#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithPeripheral:(CBPeripheral *)peripheral controller:(id<LeTemperatureAlarmProtocol>)controller
{
    self = [super init];
    if (self) {
        servicePeripheral = peripheral;
        [servicePeripheral setDelegate:self];
		peripheralDelegate = controller;
        

	}
    return self;
}

- (void)updatePeripheral:(CBPeripheral *)peripheral controller:(id<LeTemperatureAlarmProtocol>)controller
{
    servicePeripheral = peripheral;
    [servicePeripheral setDelegate:self];
    peripheralDelegate = controller;
}



- (void) dealloc {
	if (servicePeripheral) {
		[servicePeripheral setDelegate:[LeDiscovery sharedInstance]];

		servicePeripheral = nil;
    }
 
}


- (void) reset
{
	if (servicePeripheral) {

		servicePeripheral = nil;
	}
}



#pragma mark -
#pragma mark Service interaction
/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
- (void) start
{
    NSMutableArray *uuids = [[NSMutableArray alloc] initWithObjects:[CBUUID UUIDWithString:kDeviceInfoService], [CBUUID UUIDWithString:kDeviceIsscProprietaryService], nil];
    
    [servicePeripheral discoverServices:uuids];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSArray		*services	= nil;
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
		return ;
	}

	services = [peripheral services];
	if (!services || ![services count]) {
		return ;
	}

	temperatureAlarmService = nil;
    
	for (CBService *service in services) {
		if ([[service UUID] isEqual:[CBUUID UUIDWithString:kDeviceServiceUUIDString]]) {
			temperatureAlarmService = service;
			break;
		}
	}

	if (temperatureAlarmService) {
		[peripheral discoverCharacteristics:nil forService:temperatureAlarmService];
	}
}


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
	NSArray		*characteristics	= [service characteristics];
	CBCharacteristic *characteristic;
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
	
	if (service != temperatureAlarmService) {
		NSLog(@"Wrong Service.\n");
		return ;
	}
    
    if (error != nil) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
	for (characteristic in characteristics) {
        NSLog(@"discovered characteristic %@", [characteristic UUID]);
        
        if ([[characteristic UUID] isEqual:[CBUUID UUIDWithString:kDeviceCharacteristicUUID]]) {
            self.myCharacteristic = characteristic;
        }

	}
}

- (void)sendHexCommand:(NSString *)hexString
{
    if (hexString==nil || [hexString length]!=16) {
        return;
    }
    int j=0;
    Byte bytes[8];  ///3ds key的Byte 数组， 128位
    for(int i=0;i<[hexString length];i++)
    {
        int int_ch;  /// 两位16进制数转化后的10进制数
        
        unichar hex_char1 = [hexString characterAtIndex:i]; ////两位16进制数中的第一位(高位*16)
        int int_ch1;
        if(hex_char1 >= '0' && hex_char1 <='9')
            int_ch1 = (hex_char1-48)*16;   //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch1 = (hex_char1-55)*16; //// A 的Ascll - 65
        else
            int_ch1 = (hex_char1-87)*16; //// a 的Ascll - 97
        i++;
        
        unichar hex_char2 = [hexString characterAtIndex:i]; ///两位16进制数中的第二位(低位)
        int int_ch2;
        if(hex_char2 >= '0' && hex_char2 <='9')
            int_ch2 = (hex_char2-48); //// 0 的Ascll - 48
        else if(hex_char1 >= 'A' && hex_char1 <='F')
            int_ch2 = hex_char2-55; //// A 的Ascll - 65
        else
            int_ch2 = hex_char2-87; //// a 的Ascll - 97
        
        int_ch = int_ch1+int_ch2;

        bytes[j] = int_ch;  ///将转化后的数放入Byte数组里
        j++;
    }
    NSData *newData = [[NSData alloc] initWithBytes:bytes length:8];

    
    if (servicePeripheral && self.myCharacteristic) {
         [servicePeripheral writeValue:newData forCharacteristic:self.myCharacteristic type:CBCharacteristicWriteWithoutResponse];
    }
    else{
        NSLog(@"连接失败，请重新启动应用");
    }
}





- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
	if (peripheral != servicePeripheral) {
		NSLog(@"Wrong peripheral\n");
		return ;
	}

    if ([error code] != 0) {
		NSLog(@"Error %@\n", error);
		return ;
	}

  }

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    [peripheral readValueForCharacteristic:characteristic];
    
   
}
@end
