#import "LeDiscovery.h"


@interface LeDiscovery () <CBCentralManagerDelegate, CBPeripheralDelegate> {
	CBCentralManager    *centralManager;
	BOOL				pendingInit;

}
@end


@implementation LeDiscovery

@synthesize foundPeripherals;
@synthesize connectedServices;
@synthesize discoveryDelegate;
@synthesize peripheralDelegate;
@synthesize alarmService;


#define BLUE_NAME1 @"Mars"
#define BLUE_NAME2 @"Venus"
#define BLUE_LINK  @"linkcube"

#pragma mark -
#pragma mark Init
/****************************************************************************/
/*									Init									*/
/****************************************************************************/
+ (id) sharedInstance
{
	static LeDiscovery	*this	= nil;

	if (!this)
		this = [[LeDiscovery alloc] init];

	return this;
}


- (id) init
{
    self = [super init];
    if (self) {
        self.alarmService = nil;
		pendingInit = YES;
		centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:dispatch_get_main_queue()];

		foundPeripherals = [[NSMutableArray alloc] init];
		connectedServices = [[NSMutableArray alloc] init];
	}
    return self;
}

- (CBCentralManagerState) bluetoothState
{
    if (centralManager) {
        return [centralManager state];
    }
    
    return CBCentralManagerStateUnknown;
}


- (void) dealloc
{
    // We are a singleton and as such, dealloc shouldn't be called.
    assert(NO);
}

#pragma mark -
#pragma mark Action
- (void) sendCommand:(NSString *)command
{
    [self.alarmService sendHexCommand:command];
}


#pragma mark -
#pragma mark Restoring
/****************************************************************************/
/*								Settings									*/
/****************************************************************************/
/* Reload from file. */
- (void) loadSavedDevices
{
	NSArray	*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];

	if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"No stored array to load");
        return;
    }
     
    for (id deviceUUIDString in storedDevices) {
        
        if (![deviceUUIDString isKindOfClass:[NSString class]])
            continue;
        
        CFUUIDRef uuid = CFUUIDCreateFromString(NULL, (CFStringRef)deviceUUIDString);
        if (!uuid)
            continue;
        
        [centralManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:(__bridge id)uuid]];
        CFRelease(uuid);
    }

}


- (void) addSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;

	if (![storedDevices isKindOfClass:[NSArray class]]) {
        NSLog(@"Can't find/create an array to store the uuid");
        return;
    }

    newDevices = [NSMutableArray arrayWithArray:storedDevices];
    
    uuidString = CFUUIDCreateString(NULL, uuid);
    if (uuidString) {
        [newDevices addObject:(__bridge NSString*)uuidString];
        CFRelease(uuidString);
    }
    /* Store */
    [[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void) removeSavedDevice:(CFUUIDRef) uuid
{
	NSArray			*storedDevices	= [[NSUserDefaults standardUserDefaults] arrayForKey:@"StoredDevices"];
	NSMutableArray	*newDevices		= nil;
	CFStringRef		uuidString		= NULL;

	if ([storedDevices isKindOfClass:[NSArray class]]) {
		newDevices = [NSMutableArray arrayWithArray:storedDevices];

		uuidString = CFUUIDCreateString(NULL, uuid);
		if (uuidString) {
			[newDevices removeObject:(__bridge NSString*)uuidString];
            CFRelease(uuidString);
        }
		/* Store */
		[[NSUserDefaults standardUserDefaults] setObject:newDevices forKey:@"StoredDevices"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
}


- (void) centralManager:(CBCentralManager *)central didRetrieveConnectedPeripherals:(NSArray *)peripherals
{
	CBPeripheral	*peripheral;
	
	/* Add to list. */
	for (peripheral in peripherals) {
		[central connectPeripheral:peripheral options:nil];
	}
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didRetrievePeripheral:(CBPeripheral *)peripheral
{
	[central connectPeripheral:peripheral options:nil];
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didFailToRetrievePeripheralForUUID:(CFUUIDRef)UUID error:(NSError *)error
{
	/* Nuke from plist. */
	[self removeSavedDevice:UUID];
}



#pragma mark -
#pragma mark Discovery
/****************************************************************************/
/*								Discovery                                   */
/****************************************************************************/
- (void) startScanningForUUIDString:(NSString *)uuidString
{
    @try {
        if (!TARGET_IPHONE_SIMULATOR) {
            [foundPeripherals removeAllObjects];
            [discoveryDelegate discoveryDidRefresh];
//#warning 这里可能是iphone4s
            [centralManager scanForPeripheralsWithServices:nil options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(YES)}];
        }
        
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
	
}


- (void) stopScanning
{
    if (!TARGET_IPHONE_SIMULATOR) {
        [centralManager stopScan];
    }

}


- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{

    if ([peripheral.name isEqualToString:BLUE_NAME1] ||
        [peripheral.name isEqualToString:BLUE_NAME2] ||
        [peripheral.name isEqualToString:BLUE_LINK]){
        
        if (![foundPeripherals containsObject:peripheral]) {
            [foundPeripherals addObject:peripheral];
            [discoveryDelegate discoveryDidRefresh];
        }
        
    }

}



#pragma mark -
#pragma mark Connection/Disconnection
/****************************************************************************/
/*						Connection/Disconnection                            */
/****************************************************************************/
- (void) connectPeripheral:(CBPeripheral*)peripheral
{
	//if (![peripheral isConnected])
    {
        [centralManager cancelPeripheralConnection:peripheral];
		[centralManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnConnectionKey : @(YES)}];
	}
}


- (void) disconnectPeripheral:(CBPeripheral*)peripheral
{
	[centralManager cancelPeripheralConnection:peripheral];
}


- (void) centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
	if ([peripheral.name isEqualToString:BLUE_NAME1]){
        theApp.blueConnType = 1;
    }
    else if ([peripheral.name isEqualToString:BLUE_NAME2]) {
        theApp.blueConnType = 2;
    }
    else if ([peripheral.name isEqualToString:BLUE_LINK]){
        theApp.blueConnType = 2;
    }
    else{
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTop object:nil userInfo:nil];
    #warning 这里可能是iphone4s
	/* Create a service instance. */
    if (self.alarmService==nil) {
        self.alarmService = [[LeTemperatureAlarmService alloc] initWithPeripheral:peripheral controller:peripheralDelegate];
    }
    else{
        [self.alarmService updatePeripheral:peripheral controller:peripheralDelegate];
    }
    
	[self.alarmService start];
	

    BOOL contained = NO;

    for (int i=0; i<[connectedServices count]; i++) {
        LeTemperatureAlarmService *server = [connectedServices objectAtIndex:i];
        if (server.peripheral == peripheral) {
            contained = YES;
            break;
        }
        
    }
    
	if (!contained)
		[connectedServices addObject:self.alarmService];


	if ([foundPeripherals containsObject:peripheral])
		[foundPeripherals removeObject:peripheral];

    [peripheralDelegate alarmServiceDidChangeStatus:self.alarmService];
	[discoveryDelegate discoveryDidRefresh];
}


- (void) centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    NSLog(@"Attempted connection to peripheral %@ failed: %@", [peripheral name], [error localizedDescription]);
}


- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
	LeTemperatureAlarmService	*service	= nil;

	for (service in connectedServices) {
		if ([service peripheral] == peripheral) {
			[connectedServices removeObject:service];
            [peripheralDelegate alarmServiceDidChangeStatus:service];
			break;
		}
	}

	[discoveryDelegate discoveryDidRefresh];
    theApp.blueConnType = 0;
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTop object:nil userInfo:nil];
}


- (void) clearDevices
{
    LeTemperatureAlarmService	*service;
    [foundPeripherals removeAllObjects];
    
    for (service in connectedServices) {
        [service reset];
    }
    [connectedServices removeAllObjects];
}


- (void) centralManagerDidUpdateState:(CBCentralManager *)central
{
    static CBCentralManagerState previousState = -1;
    
	switch ([centralManager state]) {
		case CBCentralManagerStatePoweredOff:
		{
            [self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
            
			/* Tell user to power ON BT for functionality, but not on first run - the Framework will alert in that instance. */
//            if (previousState != -1) {
//                [discoveryDelegate discoveryStatePoweredOff];
//            }
			break;
		}
            
		case CBCentralManagerStateUnauthorized:
		{
			/* Tell user the app is not allowed. */
			break;
		}
            
		case CBCentralManagerStateUnknown:
		{
			/* Bad news, let's wait for another event. */
			break;
		}
            
		case CBCentralManagerStatePoweredOn:
		{
			pendingInit = NO;
			//[self loadSavedDevices];
			//[centralManager retrieveConnectedPeripherals];
			[discoveryDelegate discoveryDidRefresh];
			break;
		}
            
		case CBCentralManagerStateResetting:
		{
			[self clearDevices];
            [discoveryDelegate discoveryDidRefresh];
            [peripheralDelegate alarmServiceDidReset];
            
			pendingInit = YES;
			break;
		}
	}
    
    previousState = [centralManager state];
}
@end
