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
    //    PCSEQVisualizer* eq;
    
    //    int stopCount;
    BOOL    isOpen;
    
    int currentCmd;
}
@property (strong,nonatomic) IBOutlet UIImageView *imgStrength;
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
    DLog(@"---dealloc VoicViewController");
    
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
    
    [[SoundControls soundSingleton] stopSoundListener];
    
    [[LeDiscovery sharedInstance] sendCommand:kBluetoothClose];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    currentCmd = 0;
    //    stopCount = 0;
    isOpen = NO;
    
    if (iPhone5) {
        [self.view.layer setContents:(id)[IMG_FILE(_S(@"%@/%@", [[NSBundle mainBundle] resourcePath],@"play_bg_2.png")) CGImage]];
    }
    else{
        [self.view.layer setContents:(id)[IMG_FILE(_S(@"%@/%@", [[NSBundle mainBundle] resourcePath],@"play_bg.png")) CGImage]];
    }
    
    self.imgVoice.center = CGPointMake(160, theApp.window.frame.size.height/2);
    
    self.navigationController.navigationBar.hidden = YES;
    
    topView = [[TopControlView alloc] initWithFrame:CGRectMake(0, 27, 320, 44) nibNameOrNil:nil];
    topView.baseController = self;
    
    
    [self.view addSubview:topView];
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTop) name:kNotificationTop object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshTop) name:CBConnectPeripheralOptionNotifyOnDisconnectionKey object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopAllAction) name:kNotificationStopBlue object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (IBAction)voiceAction:(id)sender
{
    isOpen = !isOpen;
    if (isOpen) {
        [self.imgVoice setImage:IMG(@"mode-voice_s.png") forState:UIControlStateNormal];
    }
    else{
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
    isOpen = YES;
    [self.imgVoice setImage:IMG(@"mode-voice_s.png") forState:UIControlStateNormal];
    [self refreshTop];
    
    [[SoundControls soundSingleton] startSoundListener];
    IMP_BLOCK_SELF(VoiceViewController)
    [SoundControls soundSingleton].soundHandler = ^(id acc){
        float degree = abs([acc floatValue]);
        
        
        int voiceDegree = abs(degree)+1;
        voiceDegree = kMaxBlueToothNum-voiceDegree;
        
        
        voiceDegree = voiceDegree<0?0:voiceDegree;
        
        if (currentCmd!=voiceDegree) {
            currentCmd = voiceDegree;
            
            DLog(@"---|%d",voiceDegree);
            NSString * myComm = [kBluetoothSpeeds objectAtIndex:voiceDegree];
            ///如果游戏开始，把控制命令发给对方
            if (theApp.currentGamingJid!=nil) {
                if (isOpen) {
                    [theApp sendControlCode:myComm];
                    if (voiceDegree<1) {
                        [block_self.imgStrength setImage:IMG(@"strength-0.png")];
                    }
                    else{
                        int level = voiceDegree/6+1;
                        level = level>8?8:level;
                        [block_self.imgStrength setImage:IMG(_S(@"strength-%d.png",level))];
                    }
                }
                else{
                    [theApp sendControlCode:kBluetoothClose];
                    [block_self.imgStrength setImage:IMG(@"strength-0.png")];
                }
                
            }
            else{
                if (isOpen) {
                    [[LeDiscovery sharedInstance] sendCommand:myComm];
                    if (voiceDegree<1) {
                        [block_self.imgStrength setImage:IMG(@"strength-0.png")];
                    }
                    else{
                        int level = voiceDegree/6+1;
                        level = level>8?8:level;
                        [block_self.imgStrength setImage:IMG(_S(@"strength-%d.png",level))];
                    }
                }
                else{
                    [[LeDiscovery sharedInstance] sendCommand:kBluetoothClose];
                    [block_self.imgStrength setImage:IMG(@"strength-0.png")];
                }
                
                
            }
        }
        
        
    };
    
    
    
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
