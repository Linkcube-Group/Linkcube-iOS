#import <Foundation/Foundation.h>

#import "BluetoothSetController.h"
#import "LeDiscovery.h"
#import "LeTemperatureAlarmService.h"



@interface BluetoothSetController ()  <LeDiscoveryDelegate, LeTemperatureAlarmProtocol, UITableViewDataSource, UITableViewDelegate>
@property (retain, nonatomic) LeTemperatureAlarmService *currentlyDisplayingService;
@property (retain, nonatomic) NSMutableArray            *connectedServices;

@property (retain, nonatomic) IBOutlet UITableView      *sensorsTable;

@end



@implementation BluetoothSetController


@synthesize currentlyDisplayingService;
@synthesize connectedServices;
@synthesize sensorsTable;



#pragma mark -
#pragma mark View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        // Custom initialization
    }
    return self;
}

/****************************************************************************/
/*								View Lifecycle                              */
/****************************************************************************/
- (void) viewDidLoad
{
    [super viewDidLoad];
    
    connectedServices = [NSMutableArray new];
    
	[[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[LeDiscovery sharedInstance] setPeripheralDelegate:self];
    [[LeDiscovery sharedInstance] startScanningForUUIDString:kDeviceServiceUUIDString];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startBluetoothScan) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"蓝牙设置"];
    
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(backAction:)];
}

#pragma mark -
#pragma mark Action

- (void)backAction:(id)sender
{
        self.navigationController.navigationBarHidden = YES;
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)startBluetoothScan
{
    [[LeDiscovery sharedInstance] startScanningForUUIDString:kDeviceServiceUUIDString];
}

- (void) viewDidUnload
{
    [self setSensorsTable:nil];
    [self setConnectedServices:nil];
    [self setCurrentlyDisplayingService:nil];
    
    [[LeDiscovery sharedInstance] stopScanning];
    
}


- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[LeDiscovery sharedInstance] stopScanning];
}


- (IBAction)scanAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark LeTemperatureAlarm Interactions
/****************************************************************************/
/*                  LeTemperatureAlarm Interactions                         */
/****************************************************************************/
- (LeTemperatureAlarmService*) serviceForPeripheral:(CBPeripheral *)peripheral
{
    for (LeTemperatureAlarmService *service in connectedServices) {
        if ( [[service peripheral] isEqual:peripheral] ) {
            return service;
        }
    }
    
    return nil;
}


/** Peripheral connected or disconnected */
- (void) alarmServiceDidChangeStatus:(LeTemperatureAlarmService*)service
{
    if ( [[service peripheral] state]==CBPeripheralStateConnected ) {
        NSLog(@"Service (%@) connected", service.peripheral.name);
        if (![connectedServices containsObject:service]) {
            [connectedServices addObject:service];
        }
    }
    
    else {
        NSLog(@"Service (%@) disconnected", service.peripheral.name);
        if ([connectedServices containsObject:service]) {
            [connectedServices removeObject:service];
        }
    }
}


/** Central Manager reset */
- (void) alarmServiceDidReset
{
    [connectedServices removeAllObjects];
}



#pragma mark -
#pragma mark TableView Delegates
/****************************************************************************/
/*							TableView Delegates								*/
/****************************************************************************/
- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell	*cell;
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];
    static NSString *cellID = @"DeviceList";
    
	cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	if (!cell)
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID];
    
	if ([indexPath section] == 0) {
		devices = [[LeDiscovery sharedInstance] connectedServices];
        peripheral = [(LeTemperatureAlarmService*)[devices objectAtIndex:row] peripheral];
        
	} else {
		devices = [[LeDiscovery sharedInstance] foundPeripherals];
        peripheral = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
    if ([[peripheral name] length])
        [[cell textLabel] setText:[peripheral name]];
    else
        [[cell textLabel] setText:@"未知蓝牙设备"];
    
    BOOL isConnect = NO;
    if ([peripheral respondsToSelector:@selector(isConnected)]) {
        isConnect = ([peripheral state]==CBPeripheralStateConnected?YES:NO);
    }
    else{
        isConnect = [peripheral state]==CBPeripheralStateConnected;
    }
    cell.detailTextLabel.text = isConnect?@"已连接":@"";
    
	return cell;
}


- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return 2;
}


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	NSInteger	res = 0;
    
	if (section == 0)
		res = [[[LeDiscovery sharedInstance] connectedServices] count];
	else
		res = [[[LeDiscovery sharedInstance] foundPeripherals] count];
    
	return res;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	CBPeripheral	*peripheral;
	NSArray			*devices;
	NSInteger		row	= [indexPath row];
	
	if ([indexPath section] == 0) {
		devices = [[LeDiscovery sharedInstance] connectedServices];
        peripheral = [(LeTemperatureAlarmService*)[devices objectAtIndex:row] peripheral];
	} else {
		devices = [[LeDiscovery sharedInstance] foundPeripherals];
    	peripheral = (CBPeripheral*)[devices objectAtIndex:row];
	}
    
    BOOL isConnect = NO;
    if ([peripheral respondsToSelector:@selector(isConnected)]) {
        isConnect = ([peripheral state]==CBPeripheralStateConnected?YES:NO);
    }
    else{
        isConnect = [peripheral state]==CBPeripheralStateConnected;
    }
	if (!isConnect) {
		[[LeDiscovery sharedInstance] connectPeripheral:peripheral];
    }
	else {
        currentlyDisplayingService = [self serviceForPeripheral:peripheral];
    }
}


#pragma mark -
#pragma mark LeDiscoveryDelegate
/****************************************************************************/
/*                       LeDiscoveryDelegate Methods                        */
/****************************************************************************/
- (void) discoveryDidRefresh
{
    [sensorsTable reloadData];
}

- (void) discoveryStatePoweredOff
{
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to use LE";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];

}


@end
