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
}
@property (strong,nonatomic) IBOutlet UIImageView *imgShake;
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
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[ShakeControls shakeSingleton] stopShakeAction];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    if (iPhone5) {
        [self.view.layer setContents:(id)[IMG(@"play_bg_2.png") CGImage]]; 
    }
    else{
        [self.view.layer setContents:(id)[IMG(@"play_bg.png") CGImage]];
    }
    
    self.imgShake.center = CGPointMake(160, theApp.window.frame.size.height/2);
    
    self.navigationController.navigationBar.hidden = YES;
    
    topView = [[TopControlView alloc] initWithFrame:CGRectMake(0, 27, 320, 44) nibNameOrNil:nil];
    
    [self.view addSubview:topView];
    [topView refreshTitleName];
    [[ShakeControls shakeSingleton] startShakeAction];
    [ShakeControls shakeSingleton].shakeHandler = ^(id acc){
        float degree = abs([acc intValue]);
//        degree *= shakeLevel;
        int shakeDegree = degree*10;
        shakeDegree = shakeDegree>39?39:shakeDegree;
        NSString * myComm = [kBluetoothSpeeds objectAtIndex:shakeDegree];
        ///如果游戏开始，把控制命令发给对方
        if (theApp.currentGamingJid!=nil) {
            [theApp sendControlCode:myComm];
        }
        else{
            [[LeDiscovery sharedInstance] sendCommand:myComm];
        }
    
    };
    
    eq = [[PCSEQVisualizer alloc]initWithNumberOfBars:15];
    
    //position eq in the middle of the view
    CGRect frame = eq.frame;
    frame.origin.x = (self.view.frame.size.width - eq.frame.size.width)/2;
    frame.origin.y = theApp.window.frame.size.height-55-frame.size.height;
    eq.frame = frame;
    
    [self.view addSubview:eq];
    
    [eq start];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTop) name:kNotificationTop object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTop) name:CBConnectPeripheralOptionNotifyOnDisconnectionKey object:nil];
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self refreshTop];
}

- (void)refreshTop
{
    [topView refreshTitleName];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [eq stop];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
