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
#import "VoiceViewController.h"

#import "SettingViewController.h"

#import "MenuCell.h"
#import "HeaderView.h"

#import "LeDiscovery.h"
#import "LeTemperatureAlarmService.h"


@interface LeftViewController ()<LeDiscoveryDelegate, LeTemperatureAlarmProtocol, UITableViewDataSource, UITableViewDelegate>
{
    BOOL  blueConn;
    int selectPath;
}

@property (retain, nonatomic) LeTemperatureAlarmService *currentlyDisplayingService;
@property (strong,nonatomic) IBOutlet UITableView  *tbMenu;

@property (strong,nonatomic) NSMutableArray    *connectedBlueArrays;
@property (strong,nonatomic) NSMutableArray    *blueArray;

@property (strong,nonatomic) HeaderView     *headerView;
@end

#define MENU_LIST @[@"",@"蓝牙连接",@"控制",@"音乐控制",@"摇摇控制",@"声音控制",@"经典七式",@"其它",@"设置"]



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
    [super viewWillAppear:animated];
    [[UINavigationBar appearance] setBackgroundImage:IMG(@"navigation-and-status") forBarMetrics:UIBarMetricsDefault];
    //导航条背景
    //	if (isIOS7) {
    //		[[UINavigationBar appearance] setBackgroundImage:IMG(@"bg_title_2.png") forBarMetrics:UIBarMetricsDefault];
    //	}else{
    //		[[UINavigationBar appearance] setBackgroundImage:IMG(@"bg_title.png") forBarMetrics:UIBarMetricsDefault];
    //	}
    
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    selectPath = 1;
    self.headerView = [[[NSBundle mainBundle]loadNibNamed:@"HeaderView"
                                                    owner:self
                                                  options:nil] lastObject];
    blueConn = NO;
    self.blueArray = [[NSMutableArray alloc] init];
    
    
    [[LeDiscovery sharedInstance] setDiscoveryDelegate:self];
    [[LeDiscovery sharedInstance] setPeripheralDelegate:self];
    
    blueConn = YES;
    
    
    
    self.tbMenu.tableHeaderView = self.headerView;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startBluetoothScan) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshView:) name:kNotificationTop object:nil];
    
    [theApp.sidePanelController addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionNew context:NULL];
    // Do any additional setup after loading the view from its nib.
}

- (void)refreshView:(id)sender
{
    [self.tbMenu reloadData];
}

- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context
{
    
    if ([keyPath isEqual:@"state"] && theApp.sidePanelController.state==JASidePanelLeftVisible) {
        DLog(@"show left menu");
        blueConn = YES;
        [self startBluetoothScan];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationStopBlue object:nil];
    }
    
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
        return 0;
    }
    else if (indexPath.row==1){
        return 38;
    }
    else if (indexPath.row==bcount+2 || indexPath.row==bcount+7){
        return 20;
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
    else if (indexPath.row==bcount+2 || indexPath.row==bcount+7){
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
        [cell setBlueStatu:theApp.blueConnType];
    }
    else if (indexPath.row==bcount+2){
        [cell setLineName:@"控制"];
    }
    else if (indexPath.row==bcount+7){
        [cell setLineName:@"其它"];
    }
    else if (indexPath.row>bcount+2){
        if (indexPath.row==bcount+3) {
            [cell setMenuImage:@"set_play" Name:@"音乐控制" WithSelect:(selectPath==1?YES:NO)];
        }
        else if (indexPath.row==bcount+4){
            [cell setMenuImage:@"set_shake" Name:@"摇摇控制"  WithSelect:(selectPath==2?YES:NO)];
           
        }
        else if (indexPath.row==bcount+5){
            [cell setMenuImage:@"set_voice" Name:@"声音控制" WithSelect:(selectPath==3?YES:NO)];
            
        }
        else if (indexPath.row==bcount+6){
            [cell setMenuImage:@"set_gesture" Name:@"经典七式" WithSelect:(selectPath==4?YES:NO)];
            
        }
        else if (indexPath.row==bcount+8){
            [cell setMenuImage:@"set_setting" Name:@"设置" WithSelect:NO];
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
    selectPath = 0;
    //    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    int bcount = [self.blueArray count];
    if (indexPath.row==1) {
        ///conn bluetooth
        blueConn = YES;
        
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
        selectPath = 1;
        PlayViewController *pvc = [[PlayViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:pvc];
    }
    else if (indexPath.row==bcount+4){
        selectPath = 2;
        ShakeViewController *svc = [[ShakeViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:svc];
    }
    else if (indexPath.row==bcount+5){
        selectPath = 3;
        VoiceViewController *vvc = [[VoiceViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:vvc];
    }
    else if (indexPath.row==bcount+6){
        selectPath = 4;
        GestureViewController *gvc = [[GestureViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:gvc];
    }
    else if (indexPath.row==bcount+8){
        SettingViewController *tvc = [[SettingViewController alloc] init];
        nav = [[UINavigationController alloc] initWithRootViewController:tvc];
        
        [self presentViewController:nav animated:YES completion:nil];
        return;
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
        theApp.blueConnType = 0;
        [self discoveryStatePoweredOff];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTop object:nil userInfo:nil];
        [self.tbMenu reloadData];
        return;
    }
    if (blueConn) {
        [[LeDiscovery sharedInstance] startScanningForUUIDString:kDeviceServiceUUIDString];
    }
    [self.tbMenu reloadData];
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
    theApp.blueConnType = -1;
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
