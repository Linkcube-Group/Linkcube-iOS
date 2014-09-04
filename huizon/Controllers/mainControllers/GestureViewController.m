//
//  GestureViewController.m
//  huizon
//
//  Created by yang Eric on 5/18/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "GestureViewController.h"
#import "LeDiscovery.h"
#import "TopControlView.h"
#import "PCSEQVisualizer.h"

@interface GestureViewController ()
{
    int currentState;
    
    TopControlView  *topView;
}


@property (strong,nonatomic) IBOutlet UIButton *btnControl;

@end

@implementation GestureViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (iPhone5) {
        [self.view.layer setContents:(id)[IMG_FILE(_S(@"%@/%@", [[NSBundle mainBundle] resourcePath],@"play_bg_2.png")) CGImage]];
    }
    else{
        [self.view.layer setContents:(id)[IMG_FILE(_S(@"%@/%@", [[NSBundle mainBundle] resourcePath],@"play_bg.png")) CGImage]];
    }
    self.btnControl.center = CGPointMake(160, theApp.window.frame.size.height/2);
    
    self.navigationController.navigationBar.hidden = YES;
    
    topView = [[TopControlView alloc] initWithFrame:CGRectMake(0, 27, 320, 44) nibNameOrNil:nil];
    topView.baseController = self;
    [self.view addSubview:topView];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTop) name:kNotificationTop object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTop) name:CBConnectPeripheralOptionNotifyOnDisconnectionKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAllAction) name:kNotificationStopBlue object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshTop];
   
    [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(startFirst) userInfo:nil repeats:NO];
}

- (void)startFirst
{
    currentState = 0;
    NSString *cmd = [kBluetoothPostures objectAtIndex:currentState];
    [self patternCommand:cmd];
}

- (void)refreshTop
{
    [topView refreshTitleName];
}




#pragma mark -
#pragma mark Action
- (void)patternCommand:(NSString *)command
{
    ///如果游戏开始，把控制命令发给对方
    if (theApp.currentGamingJid!=nil) {
        [theApp sendControlCode:command];
    }
    else{
        [[LeDiscovery sharedInstance] sendCommand:command];
    }
    
}

- (IBAction)postureAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    int tag = btn.tag - 1000;
    if (tag==7) {
        showCustomAlertMessage(@"多多使用，未来更多震动模式哦！");
        return;
    }
    
    for (int i=0; i<7; i++) {
        UIButton *btn = (UIButton *)[self.view viewWithTag:i+1000];
        if (btn!=nil){
            if(i!=tag) {
                btn.selected = NO;
            }
            else{
                btn.selected = YES;
            }
        }
    }
    
    currentState = tag;
    if (currentState>6) {
        currentState = 6;
    }
    if (currentState<1) {
        currentState = 0;
    }
    NSString *cmd = [kBluetoothPostures objectAtIndex:currentState];
    [self patternCommand:cmd];
    
    
    NSString *imgName = _S(@"posture_%d.png",currentState);
    [self.btnControl setImage:IMG(imgName) forState:UIControlStateNormal];
    
}

- (void)stopAllAction
{
    [[LeDiscovery sharedInstance] sendCommand:kBluetoothClose];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopAllAction];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)dealloc
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
