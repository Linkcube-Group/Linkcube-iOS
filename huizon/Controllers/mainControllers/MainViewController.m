//
//  MainViewController.m
//  huizon
//
//  Created by Yang on 14-2-26.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "MainViewController.h"
#import "BluetoothSetController.h"
#import "LeDiscovery.h"

#import "TSLibraryImport.h"
#import "ShakeControls.h"
#import "VoiceControls.h"
#import "PostureScrollView.h"
#import "UserViewController.h"
#import "SettingViewController.h"

#import "MediaViewController.h"

@interface MainViewController ()<PostureDelegate>
{
    int currentPattern;
    int currentLevel;
    
    int shakeLevel;
}
@end

#define ControlPattern [NSArray arrayWithObjects:@(PatternStateShake),@(PatternStatePosture),nil]

@implementation MainViewController

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
    
    currentPattern = 0;
    currentLevel = 0;
    shakeLevel = 0;
    PostureScrollView *scrollView = [[PostureScrollView alloc] initWithFrame:CGRectMake(0, theApp.window.height-55-200, 320, 200) Count:3];
    scrollView._delegate = self;
    [self.view addSubview:scrollView];
    [scrollView beginPosture];
    
 
    
  
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillAppear:(BOOL)animated
{
//    self.navigationController.navigationBarHidden = YES;
}

#pragma mark -
#pragma mark Delegate
- (void)viewScrollToPage:(int)index
{
    currentPattern = index;
    shakeLevel = 0;
    switch (index) {
        case 0:
        {
            [[VoiceControls voiceSingleton] stopMusic];
            [[ShakeControls shakeSingleton] startShakeAction];
            [ShakeControls shakeSingleton].shakeHandler = ^(id acc){
                    float degree = abs([acc intValue]);
                    degree *= shakeLevel;
                    int shakeDegree = degree*10;
                    shakeDegree = shakeDegree>39?39:shakeDegree;
                    NSString * myComm = [kBluetoothSpeeds objectAtIndex:shakeDegree];
                    [[LeDiscovery sharedInstance] sendCommand:myComm];

                
            };
        }
            break;
        case 1:
        {
            [[ShakeControls shakeSingleton] stopShakeAction];
            [[VoiceControls voiceSingleton] stopMusic];
            
        }
            break;
        case 2:
        {
            [[ShakeControls shakeSingleton] stopShakeAction];
            [[VoiceControls voiceSingleton] playMusicAction];
            [VoiceControls voiceSingleton].voiceHandler = ^(id acc){
                
                    
                    float degree = abs([acc floatValue]);
                    int voiceDegree = abs(degree)+1;
                    voiceDegree = 40-voiceDegree;
                if (currentLevel>0) {
                                    voiceDegree /=currentLevel;
                }
                else{
                    currentLevel = 0;
                }

                
                    voiceDegree = voiceDegree<0?0:voiceDegree;
                    NSString * myComm = [kBluetoothSpeeds objectAtIndex:voiceDegree];
                    NSLog(@"cmd===%@",myComm);
                    [[LeDiscovery sharedInstance] sendCommand:myComm];

                
            };
        }
            break;
        default:
            break;
    }
    
    if (iPhone5) {
        [self.view.layer setContents:(id)[IMG(_S(@"main_bg_s_%d.png",index)) CGImage]];
    }
    else{
        [self.view.layer setContents:(id)[IMG(_S(@"main_bg_%d.png",index)) CGImage]];
    }
}
- (void)patternCommand:(NSString *)command
{
    if ([command length]<10) {
        int level = [command intValue];
        shakeLevel = level;
        if (currentPattern==2 && shakeLevel==1) {
            [self selectAudio];
        }
        return;
    }
    
    [[LeDiscovery sharedInstance] sendCommand:command];
}


#pragma mark -
#pragma mark Action
- (IBAction)openBluetooth:(id)sender
{
        self.navigationController.navigationBarHidden = NO;
    BluetoothSetController *bvc = [[BluetoothSetController alloc] init];
    [self.navigationController pushViewController:bvc animated:YES];
}
- (IBAction)settingAction:(id)sender
{
    self.navigationController.navigationBarHidden = NO;
    SettingViewController *svc = [[SettingViewController alloc] init];

    [self.navigationController pushViewController:svc animated:YES];
}

- (IBAction)resetAction:(id)sender
{
    
}

- (IBAction)loginAction:(id)sender
{
    if (![theApp isXmppAuthenticated]) {
        [self.navigationController hidesBottomBarWhenPushed];
        UserViewController *uvc = [[UserViewController alloc] init];
        [self presentViewController:uvc animated:YES completion:nil];
    }
   
}

- (IBAction)postureAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    int tag = (int)btn.tag;
    tag -= 1;
    NSString *order = [kBluetoothPostures objectAtIndex:tag];
    NSLog(@"---%@---",order);
    
    [[LeDiscovery sharedInstance] sendCommand:order];
    
}

- (IBAction)sendAction:(id)sender
{
    UISlider *st = (UISlider *)sender;
    NSLog(@"%f",st.value);
    
    int levet = (int)st.value;
    
    // currentLevel += tag;
    if (currentLevel<0) {
        currentLevel = 0;
    }
    else if (currentLevel>39){
        currentLevel = 39;
    }
    
    
    NSString *order = nil;
    if (levet<=0) {
        order = kBluetoothClose;
    }
    else if(levet<40)
    {
        //        levet = 39;
        order = [kBluetoothSpeeds objectAtIndex:levet];
    }
    
    NSLog(@"---%@---",order);
    
    [[LeDiscovery sharedInstance] sendCommand:order];
}


#pragma mark -
#pragma mark AudioSelect
- (void)selectAudio
{
    MPMediaPickerController *picker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeMusic];
    
    picker.delegate = self;
    picker.allowsPickingMultipleItems = NO;
    picker.prompt = NSLocalizedString (@"Select songs to play", "Prompt in media item picker");
    [self presentViewController:picker animated:YES completion:nil];
    
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
  
	if ([mediaItemCollection count] < 1) {
		return;
	}
    
	MPMediaItem *song = [[mediaItemCollection items] objectAtIndex:0];
    NSURL *audioURL = [song valueForProperty:MPMediaItemPropertyAssetURL];


    
    NSString *fullPathToFile = [NSHomeDirectory() stringByAppendingPathComponent:@"/tmp/audio.mp3"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:fullPathToFile])
	{
        [[NSFileManager defaultManager] removeItemAtPath:fullPathToFile error:nil];
    }
    NSURL* destinationURL = [NSURL fileURLWithPath:fullPathToFile]; //file URL for the location you'd like to import the asset to.
    TSLibraryImport* tsimport = [[TSLibraryImport alloc] init];
    
    [tsimport importAsset:audioURL toURL:destinationURL completionBlock:^(TSLibraryImport *import) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[VoiceControls voiceSingleton] startMusic:destinationURL];
            [[VoiceControls voiceSingleton] playMusicAction];
        });
    }];


     [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
