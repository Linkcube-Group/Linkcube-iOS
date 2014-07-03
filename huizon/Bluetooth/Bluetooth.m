//
//  Bluetooth.m
//  huizon
//  提供蓝牙打开，扫描，配对，发送信息等接口
//  Created by yang Eric on 2/12/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "Bluetooth.h"
#import "UUID.h"

@interface Bluetooth()
{
    CBCentralManager *manager;
    CBPeripheral     *connPeripheral;
    CBCharacteristic    *transferCharacteristic;
    NSMutableArray   *deviceArray;
}

@end

@implementation Bluetooth
@synthesize deviceHandler,connectHandler;

+ (Bluetooth *)bluetoothSingleton
{
    static dispatch_once_t pred;
    
    static Bluetooth *sharedSingleton;
    
    dispatch_once(&pred,^{sharedSingleton=[[self alloc] initSingleton];} );
    
    return sharedSingleton;
}

- (id)initSingleton
{
    if(self=[super init]){
        connPeripheral = nil;
        manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
        deviceArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

#pragma mark -
#pragma mark OpenAPI
///开始蓝牙扫描
- (void)startBluetoothScan
{
    connPeripheral = nil;
    manager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    deviceArray = [[NSMutableArray alloc] init];
}

///停止蓝牙扫描
- (void)stopBluetoothScan
{
    [manager stopScan];
}

///连接蓝牙设备
- (void)connectBluetooth:(CBPeripheral *)peripheral
{
    [manager connectPeripheral:peripheral options:nil];  //connect to device
}

///断开蓝牙设备
- (void)disConnectBluetooth:(CBPeripheral *)peripheral
{
    [manager cancelPeripheralConnection:peripheral];
}

///修改玩具名称
- (void)renameBluetooth:(NSString *)name
{
    [self sendCommand:name];
}

///发送命令到电机
- (BOOL)sendCommand:(NSString *)command
{
    if (command) {
        NSData *sendData = [self hexStringToData:command];
        [connPeripheral writeValue:sendData forCharacteristic:transferCharacteristic type:CBCharacteristicWriteWithoutResponse];
        return YES;
    }
    
    return NO;
}

#pragma mark -
#pragma mark ManagerDelegate
- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    if ([self isLECapableHardware]) {
        [manager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey:@YES}];
        [deviceArray removeAllObjects];
    }
    else{
        BlockCallWithOneArg(connectHandler, @"Bluetooth is not open")
        showCustomAlertMessage(@"您的设备蓝牙没有启动，请先打开您的蓝牙");
    }
}

/*
 Uses CBCentralManager to check whether the current platform/hardware supports Bluetooth LE. An alert is raised if Bluetooth LE is not enabled or is not supported.
 */
- (BOOL) isLECapableHardware
{
    NSString * state = nil;
    
    switch ([manager state])
    {
        case CBCentralManagerStateUnsupported:
            state = @"The platform/hardware doesn't support Bluetooth Low Energy.";
            break;
        case CBCentralManagerStateUnauthorized:
            state = @"The app is not authorized to use Bluetooth Low Energy.";
            break;
        case CBCentralManagerStatePoweredOff:
            state = @"Bluetooth is currently powered off.";
            break;
        case CBCentralManagerStatePoweredOn:
            DLog(@"Bluetooth power on");
            break;
        case CBCentralManagerStateUnknown:
        default:
            state = @"Bluetooth state unknow";
    }
    
    DLog("Central manager state: %@", state);
    
    return manager.state==CBCentralManagerStatePoweredOn?YES:NO;
}

/*
 Invoked when the central discovers heart rate peripheral while scanning.
 */
- (void) centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)aPeripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    DLog(@"<---------\n[CBController] didDiscoverPeripheral, %@, count=%u, RSSI=%d, count=%d", aPeripheral.name, [advertisementData count], [RSSI intValue], [deviceArray count]);
    
    NSArray *advDataArray = [advertisementData allValues];
    NSArray *advValueArray = [advertisementData allKeys];
    for (int i=0; i < [advertisementData count]; i++)
    {
        DLog(@"adv data=%@, %@ ", [advDataArray objectAtIndex:i], [advValueArray objectAtIndex:i]);
    }
    DLog(@"-------->");
    
    [self addDiscoverPeripheral:aPeripheral advName:[advertisementData valueForKey:CBAdvertisementDataLocalNameKey]];
}

- (void)addDiscoverPeripheral:(CBPeripheral *)aPeripheral advName:(NSString *)advName{
//    MyPeripheral *myPeripheral = nil;
//    for (uint8_t i = 0; i < [devicesList count]; i++) {
//        myPeripheral = [devicesList objectAtIndex:i];
//        if (myPeripheral.peripheral == aPeripheral) {
//            myPeripheral.advName = advName;
//            break;
//        }
//        myPeripheral = nil;
//    }
//    if (myPeripheral == nil) {
//        [aPeripheral retain];
//        myPeripheral = [[MyPeripheral alloc] init];
//        myPeripheral.peripheral = aPeripheral;
//        myPeripheral.advName = advName;
//        [devicesList addObject:myPeripheral];
//    }
    //NSLog(@"[CBController] deviceList count = %d", [devicesList count]);
   // [self updateDiscoverPeripherals];
    [deviceArray addObject:aPeripheral];
    BlockCallWithOneArg(deviceHandler, deviceArray);
}

/*
 Invoked when the central manager retrieves the list of known peripherals.
 Automatically connect to first known peripheral
 */
- (void)centralManager:(CBCentralManager *)central didRetrievePeripherals:(NSArray *)peripherals
{
    NSLog(@"Retrieved peripheral: %u - %@", [peripherals count], peripherals);
    if([peripherals count] >=1)
    {
        [self connectBluetooth:[peripherals objectAtIndex:0]];
    }
}

/*
 Invoked whenever a connection is succesfully created with the peripheral.
 Discover available services on the peripheral
 */
- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)aPeripheral
{
    NSLog(@"[CBController] didConnectPeripheral, uuid=%@", aPeripheral.description);
    
    [self stopBluetoothScan];
    
    [aPeripheral setDelegate:self];
    
   // [self storeMyPeripheral:aPeripheral];
    
  //  isISSCPeripheral = FALSE;
    NSMutableArray *uuids = [[NSMutableArray alloc] initWithObjects:[CBUUID UUIDWithString:UUIDSTR_DEVICE_INFO_SERVICE], [CBUUID UUIDWithString:UUIDSTR_ISSC_PROPRIETARY_SERVICE], nil];
//    if (_transServiceUUID)
//    [uuids addObject:_transServiceUUID];
    [aPeripheral discoverServices:uuids];

}

/*
 Invoked whenever an existing connection with the peripheral is torn down.
 Reset local variables
 */
- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"[CBController] didDisonnectPeripheral uuid = %@, error msg:%d, %@, %@", aPeripheral.description, error.code ,[error localizedFailureReason], [error localizedDescription]);
    
     BlockCallWithOneArg(connectHandler, @"Disconnect Bluetooth")
}

/*
 Invoked whenever the central manager fails to create a connection with the peripheral.
 */
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)aPeripheral error:(NSError *)error
{
    NSLog(@"[CBController] Fail to connect to peripheral: %@ with error = %@", aPeripheral, [error localizedDescription]);
    BlockCallWithOneArg(connectHandler, @"Failed to Connect Bluetooth")
}


/** The Transfer Service was discovered
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering services: %@", [error localizedDescription]);
        return;
    }
    
    // Discover the characteristic we want...
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
    for (CBService *service in peripheral.services) {
        [peripheral discoverCharacteristics:nil forService:service];
    }
}

/** The Transfer characteristic was discovered.
 *  Once this has been found, we want to subscribe to it, which lets the peripheral know we want the data it contains
 */
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    // Deal with errors (if any)
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    // Again, we loop through the array, just in case.
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        // And check if it's the right one
        if ([characteristic.UUID isEqual:[CBUUID UUIDWithString:connPeripheral.identifier.UUIDString]]) {

            transferCharacteristic = characteristic;
            
            // If it is, subscribe to it
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
        }
    }
    
    // Once this is complete, we just need to wait for the data to come in.
}


/** This callback lets us know more data has arrived via notification on the characteristic
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error discovering characteristics: %@", [error localizedDescription]);
        return;
    }
    
    NSString *stringFromData = [[NSString alloc] initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    
    // Have we got everything we need?
    if ([stringFromData isEqualToString:@"EOM"]) {
        
    }
    
    // Log it
    NSLog(@"Received: %@", stringFromData);
}


/** The peripheral letting us know whether our subscribe/unsubscribe happened or not
 */
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        NSLog(@"Error changing notification state: %@", error.localizedDescription);
    }
    
    // Exit if it's not the transfer characteristic
//    if (![characteristic.UUID isEqual:[CBUUID UUIDWithString:TRANSFER_CHARACTERISTIC_UUID]]) {
//        return;
//    }
    
    // Notification has started
    if (characteristic.isNotifying) {
        NSLog(@"Notification began on %@", characteristic);
    }
    
    // Notification has stopped
    else {
        // so disconnect from the peripheral
        NSLog(@"Notification stopped on %@.  Disconnecting", characteristic);
        //[self.centralManager cancelPeripheralConnection:peripheral];
    }
}


#pragma mark -
#pragma mark Tools
- (NSData *)hexStringToData:(NSString *)hexString
{
    // NSString *hexString = @"3e435fab9c34891f"; //16进制字符串
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
    DLog(@"newData=%@",newData);
    
    return newData;
}
@end
