//
//  VoiceViewController.m
//  huizon
//
//  Created by yang Eric on 7/13/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "VoiceViewController.h"
#import "LeDiscovery.h"

#import "SoundControls.h"

#import "PCSEQVisualizer.h"
#import "TopControlView.h"


@interface VoiceViewController ()
{
    TopControlView  *topView;
    PCSEQVisualizer* eq;
    
    int stopCount;
    BOOL    isOpen;
}
@property (strong,nonatomic) IBOutlet UIButton *imgVoice;
@end

@implementation VoiceViewController

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
    [[LeDiscovery sharedInstance] sendCommand:kBluetoothClose];
    isOpen = NO;
    [eq stop];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[SoundControls soundSingleton] stopSoundListener];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    stopCount = 0;
    isOpen = NO;
    
    if (iPhone5) {
        [self.view.layer setContents:(id)[IMG(@"play_bg_2.png") CGImage]];
    }
    else{
        [self.view.layer setContents:(id)[IMG(@"play_bg.png") CGImage]];
    }
    
    self.imgVoice.center = CGPointMake(160, theApp.window.frame.size.height/2);
    
    self.navigationController.navigationBar.hidden = YES;
    
    topView = [[TopControlView alloc] initWithFrame:CGRectMake(0, 27, 320, 44) nibNameOrNil:nil];
    topView.baseController = self;
    
    
    [self.view addSubview:topView];
    [topView refreshTitleName];
    [[SoundControls soundSingleton] startSoundListener];
    [SoundControls soundSingleton].soundHandler = ^(id acc){
        float degree = abs([acc floatValue]);
        

        int voiceDegree = abs(degree)+1;
        voiceDegree = 40-voiceDegree;
     
        
        voiceDegree = voiceDegree<0?0:voiceDegree;

                DLog(@"---|%d",voiceDegree);
        NSString * myComm = [kBluetoothSpeeds objectAtIndex:voiceDegree];
        ///如果游戏开始，把控制命令发给对方
        if (theApp.currentGamingJid!=nil) {
            if (isOpen) {
                [theApp sendControlCode:myComm];
                if (voiceDegree<1) {
                    stopCount++;
                    if (stopCount>30 && [eq isStart]) {
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
                if (voiceDegree<1) {
                    stopCount++;
                    if (stopCount>30 && [eq isStart]) {
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
    
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)shakeAction:(id)sender
{
    isOpen = !isOpen;
    if (isOpen) {
        [eq start];
        [self.imgVoice setImage:IMG(@"mode-voice_s.png") forState:UIControlStateNormal];
    }
    else{
        [eq stop];
        if (theApp.currentGamingJid!=nil) {
            [theApp sendControlCode:kBluetoothClose];
        }
        else{
            [[LeDiscovery sharedInstance] sendCommand:kBluetoothClose];
        }
        
        [self.imgVoice setImage:IMG(@"mode-voice.png") forState:UIControlStateNormal];
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