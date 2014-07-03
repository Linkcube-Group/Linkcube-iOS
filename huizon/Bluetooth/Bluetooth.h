//
//  Bluetooth.h
//  huizon
//
//  Created by yang Eric on 2/12/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@interface Bluetooth : NSObject<CBCentralManagerDelegate,CBPeripheralDelegate>

@property (nonatomic,assign) EventHandler deviceHandler;
@property (nonatomic,assign) EventHandler connectHandler;

+ (Bluetooth *)bluetoothSingleton;

- (void)startBluetoothScan;

- (void)stopBluetoothScan;

- (void)connectBluetooth:(CBPeripheral *)peripheral;

- (void)disConnectBluetooth:(CBPeripheral *)peripheral;

- (void)renameBluetooth:(NSString *)name;

- (BOOL)sendCommand:(NSString *)command;
@end
