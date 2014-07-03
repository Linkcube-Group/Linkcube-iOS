//
//  LeftViewController.m
//  huizon
//
//  Created by yang Eric on 5/17/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "LeftViewController.h"
#import "JASidePanelController.h"

#import "PlayViewController.h"
#import "ShakeViewController.h"
#import "GestureViewController.h"

#import "SettingViewController.h"

#import "MenuCell.h"

#import "LeDiscovery.h"
#import "LeTemperatureAlarmService.h"


@interface LeftViewController ()<LeDiscoveryDelegate, LeTemperatureAlarmProtocol, UITableViewDataSource, UITableViewDelegate>
{
    BOOL  blueConn;

}
@property (retain, nonatomic) LeTemperatureAlarmService *currentlyDisplayingService;
@property (strong,nonatomic) IBOutlet UITableView  *tbMenu;

@property (strong,nonatomic) NSMutableArray    *connectedBlueArrays;
@property (strong,nonatomic) NSMutableArray    *blueArray;
@end

#define MENU_LIST @[@"",@"蓝牙连接",@"控制",@"音乐控制",@"摇摇控制",@"经典七式",@"其它",@"设置"]



@implementation LeftViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    //导航条背景
	if (isIOS7) {
		[[UINavigationBar appearance] setBackgroundImage:IMG(@"bg_title_2") forBarMetrics:UIBarMetricsDefault];
	}else{
		[[UINavigationBar appearance] setBackgroundImage:IMG(@"bg_title") forBarMetrics:UIBarMetricsDefault];
	}
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    blueConn = NO;
    self.blueArray = [[NSMutableArray alloc] init];
    
  
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startBluetoothScan) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // Do any additional setup after loading the view from its nib.
}



#pragma mark -
#pragma mark UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [MENU_LIST count]+[self.blueArray count];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int bcount = [self.blueArray count];

    if (indexPath.row==0) {
        return 120;
    }
    else if (indexPath.row==1){
        return 30;
    }
    else if (indexPath.row==bcount+2 || indexPath.row==bcount+6){
        return 16;
    }
    else if (indexPath.row>bcount+2){
        return 49;
    }
    return 40;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int bcount = [self.blueArray count];
    
    static NSString *cellIdentifier1 = @"MenuCell";
    static NSString *cellIdentifier2 = @"MenuCellBlue";
    static NSString *cellIdentifier3 = @"MenuCellConn";
    static NSString *cellIdentifier4 = @"MenuCellLine";
    static NSString *cellIdentifier5 = @"MenuCellHead";
    NSString *cellIdentifier = cellIdentifier3;
    if (indexPath.row==0) {
        cellIdentifier = cellIdentifier5;
    }
    else if (indexPath.row==1){
        cellIdentifier = cellIdentifier2;
    }
    else if (indexPath.row==bcount+2 || indexPath.row==bcount+6){
        cellIdentifier = cellIdentifier4;
    }
    else if (indexPath.row>bcount+2){
        cellIdentifier = cellIdentifier1;
    }
  
   
    
    MenuCell *cell = (MenuCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:cellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (indexPath.row==0) {
//        cellIdentifier = cellIdentifier5;///setting top bg
    }
    else if (indexPath.row==1){
        [cell setBlueStatu:(theApp.blueConnType!=0?YES:NO)];
    }
    else if (indexPath.row==bcount+2){
        [cell setLineName:@"控制"];
    }
    else if (indexPath.row==bcount+6){
        [cell setLineName:@"其它"];
    }
    else if (indexPath.row>bcount+2){
        if (indexPath.row==bcount+3) {
            [cell setMenuImage:@"set_play" Name:@"音乐控制"];
        }
        else if (indexPath.row==bcount+4){
            [cell setMenuImage:@"set_shake" Name:@"摇摇控制"];
        }
        else if (indexPath.row==bcount+5){
            [cell setMenuImage:@"set_gesture" Name:@"经典七式"];
        }
        else if (indexPath.row==bcount+7){
            [cell setMenuImage:@"set_setting" Name:@"设置"];
        }
    }
    else{
        CBPeripheral	*peripheral = nil;
        id perObj = [self.blueArray objectAtIndex:indexPath.row-2];
        if ([perObj isKindOfClass:[LeTemperatureAlarmService class]]) {
            peripheral = [(LeTemperatureAlarmService*)perObj peripheral];
        }
        else{
            peripheral = perObj;
        }
        
        
        
        NSString *name =[peripheral name];
        
        
        BOOL isConnect = NO;
        if ([peripheral respondsToSelector:@selector(isConnected)]) {
            isConnect = [peripheral isConnected];
        }
        else{
            isConnect = [peripheral state]==CBPeripheralStateConnected;
        }
        
        [cell setBLueConn:name Status:isConnect];
    }
    
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int bcount = [self.blueArray count];
    if (indexPath.row==1) {
        ///conn bluetooth
        blueConn = YES;
        [[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
        [[LeDiscovery sharedInstance] setPeripheralDelegate:self];
       
        [self startBluetoothScan];
    
        return;
    }
    else if (indexPath.row>1 && indexPath.row<bcount+2){
        CBPeripheral	*peripheral = nil;
        id perObj = [self.blueArray objectAtIndex:indexPath.row-2];
        if ([perObj isKindOfClass:[LeTemperatureAlarmService class]]) {
            peripheral = [(LeTemperatureAlarmService*)perObj peripheral];
        }
        else{
            peripheral = perObj;
        }
        BOOL isConnect = NO;
        if ([peripheral respondsToSelector:@selector(isConnected)]) {
            isConnect = [peripheral isConnected];
        }
        else{
            isConnect = [peripheral state]==CBPeripheralStateConnected;
        }
        if (!isConnect) {
            [[LeDiscovery sharedInstance] connectPeripheral:peripheral];
        }
        else {
            self.currentlyDisplayingService = [self serviceForPeripheral:peripheral];
        }
        return;
    }
    
    UINavigationController *nav = nil;
    
    if (indexPath.row==bcount+3) {
        PlayViewController *pvc = [[PlayViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:pvc];
    }
    else if (indexPath.row==bcount+4){
        ShakeViewController *svc = [[ShakeViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:svc];
    }
    else if (indexPath.row==bcount+5){
        GestureViewController *gvc = [[GestureViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:gvc];
    }
    else if (indexPath.row==bcount+7){
        SettingViewController *tvc = [[SettingViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:tvc];
    }
    
    if (nav) {
        [theApp.sidePanelController setCenterPanel:nav];
    }
   
}



#pragma mark -
#pragma mark BlueSetting
- (void)startBluetoothScan
{
    if ([[LeDiscovery sharedInstance] bluetoothState]!=CBCentralManagerStatePoweredOn) {
        [self discoveryStatePoweredOff];
        theApp.blueConnType = 0;
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTop object:nil userInfo:nil];
        [self.tbMenu reloadData];
        return;
    }
    if (blueConn) {
        
         [[LeDiscovery sharedInstance] startScanningForUUIDString:kDeviceServiceUUIDString];
    }
   
}

- (void) viewDidUnload
{
    [self setCurrentlyDisplayingService:nil];
    
    [[LeDiscovery sharedInstance] stopScanning];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[LeDiscovery sharedInstance] stopScanning];
}


#pragma mark -
#pragma mark LeTemperatureAlarm Interactions
/****************************************************************************/
/*                  LeTemperatureAlarm Interactions                         */
/****************************************************************************/
- (LeTemperatureAlarmService*) serviceForPeripheral:(CBPeripheral *)peripheral
{
    for (LeTemperatureAlarmService *service in self.connectedBlueArrays) {
        if ( [[service peripheral] isEqual:peripheral] ) {
            return service;
        }
    }
    
    return nil;
}


/** Peripheral connected or disconnected */
- (void) alarmServiceDidChangeStatus:(LeTemperatureAlarmService*)service
{
    if ([[service peripheral] isConnected]) {
        NSLog(@"Service (%@) connected", service.peripheral.name);
        
            if (![self.connectedBlueArrays containsObject:service]) {
                [self.connectedBlueArrays addObject:service];
            }
        
       
    }
    else {
        NSLog(@"Service (%@) disconnected", service.peripheral.name);
        if ([self.connectedBlueArrays containsObject:service]) {
            [self.connectedBlueArrays removeObject:service];
        }
    }
}


/** Central Manager reset */
- (void) alarmServiceDidReset
{
    [self.connectedBlueArrays removeAllObjects];
}

#pragma mark -
#pragma mark LeDiscoveryDelegate
/****************************************************************************/
/*                       LeDiscoveryDelegate Methods                        */
/****************************************************************************/
- (void) discoveryDidRefresh
{
    [self.blueArray removeAllObjects];
    [self.blueArray addObjectsFromArray:[[LeDiscovery sharedInstance] connectedServices]];
    [self.blueArray addObjectsFromArray:[[LeDiscovery sharedInstance] foundPeripherals]];
    [self.tbMenu reloadData];
}

- (void) discoveryStatePoweredOff
{
    NSString *title     = @"无法连接";
    NSString *message   = @"请在设置->蓝牙中允许蓝牙服务，才能连接到您的玩具";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
    [alertView show];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[LeDiscovery sharedInstance] stopScanning];
}

@end
