//
//  ShakeViewController.m
//  huizon
//
//  Created by yang Eric on 5/18/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "ShakeViewController.h"
#import "LeDiscovery.h"

#import "ShakeControls.h"

#import "PCSEQVisualizer.h"
#import "TopControlView.h"

@interface ShakeViewController ()
{
    TopControlView  *topView;
    PCSEQVisualizer* eq;
    
    int stopCount;
    BOOL    isOpen;
    
    int currentCmd;
}
@property (strong,nonatomic) IBOutlet UIButton *imgShake;
@end

@implementation ShakeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    DLog(@"dealoc ==== shakviewcontroller");
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self stopAllAction];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)stopAllAction
{
    
    isOpen = NO;
    [eq stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ShakeControls shakeSingleton] stopShakeAction];
    
    [[LeDiscovery sharedInstance] sendCommand:kBluetoothClose];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    stopCount = 0;
    isOpen = NO;
    currentCmd = 0;
    
    if (iPhone5) {
        [self.view.layer setContents:(id)[IMG_FILE(_S(@"%@/%@", [[NSBundle mainBundle] resourcePath],@"play_bg_2.png")) CGImage]];
    }
    else{
        [self.view.layer setContents:(id)[IMG_FILE(_S(@"%@/%@", [[NSBundle mainBundle] resourcePath],@"play_bg.png")) CGImage]];
    }
    
    self.imgShake.center = CGPointMake(160, theApp.window.frame.size.height/2);
    
    self.navigationController.navigationBar.hidden = YES;
    
    topView = [[TopControlView alloc] initWithFrame:CGRectMake(0, 27, 320, 44) nibNameOrNil:nil];
    topView.baseController = self;
    
    
    [self.view addSubview:topView];
    
    
    [[ShakeControls shakeSingleton] startShakeAction];
    
    [ShakeControls shakeSingleton].shakeHandler = ^(id acc){
        float degree = abs([acc intValue]);
        //        degree *= shakeLevel;
        DLog(@"shake ====|%f",degree);
        if (degree>1 && degree<8) {
            degree+=8;
        }
        int shakeDegree = degree/5;
        
        shakeDegree = shakeDegree<0?0:shakeDegree;
        shakeDegree = shakeDegree>9?9:shakeDegree;
        
        int KShakeSpeed[10] = { 0,5,17, 25, 30, 38, 40, 44, 47,49 };
        
        
        
        shakeDegree = KShakeSpeed[shakeDegree];
        DLog(@"shake degree===%d",shakeDegree);
        
        if (currentCmd!=shakeDegree || shakeDegree==0) {
            currentCmd = shakeDegree;
            NSString *myComm = [kBluetoothSpeeds objectAtIndex:shakeDegree];
            ///如果游戏开始，把控制命令发给对方
            if (theApp.currentGamingJid!=nil) {
                if (isOpen) {
                    [theApp sendControlCode:myComm];
                    if (degree<1) {
                        stopCount++;
                        if (stopCount>20 && [eq isStart]) {
                            [eq stop];
                        }
                    }
                    else{
                        stopCount = 0;
                        if ([eq isStart]==NO) {
                            [eq start];
                        }
                    }
                }
                
            }
            else{
                if (isOpen) {
                    [[LeDiscovery sharedInstance] sendCommand:myComm];
                    if (degree<1) {
                        stopCount++;
                        if (stopCount>20 && [eq isStart]) {
                            [eq stop];
                        }
                    }
                    else{
                        stopCount = 0;
                        if ([eq isStart]==NO) {
                            [eq start];
                        }
                    }
                }
                
            }
        }
        
        
    };
    
    
    
    eq = [[PCSEQVisualizer alloc]initWithNumberOfBars:15];
    
    //position eq in the middle of the view
    CGRect frame = eq.frame;
    frame.origin.x = (self.view.frame.size.width - eq.frame.size.width)/2;
    frame.origin.y = theApp.window.frame.size.height-55-frame.size.height;
    eq.frame = frame;
    
    [self.view addSubview:eq];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTop) name:kNotificationTop object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTop) name:CBConnectPeripheralOptionNotifyOnDisconnectionKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAllAction) name:kNotificationStopBlue object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)shakeAction:(id)sender
{
    isOpen = !isOpen;
    if (isOpen) {
        [eq start];
        [self.imgShake setImage:IMG(@"mode_shake_s.png") forState:UIControlStateNormal];
    }
    else{
        [eq stop];
        if (theApp.currentGamingJid!=nil) {
            [theApp sendControlCode:kBluetoothClose];
        }
        else{
            [[LeDiscovery sharedInstance] sendCommand:kBluetoothClose];
        }
        
        [self.imgShake setImage:IMG(@"mode_shake.png") forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    isOpen = NO;
    [self shakeAction:nil];
    [self refreshTop];
    
}

- (void)refreshTop
{
    [topView refreshTitleName];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
