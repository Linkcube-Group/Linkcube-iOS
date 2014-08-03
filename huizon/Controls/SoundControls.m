//
//  SoundControls.m
//  huizon
//
//  Created by yang Eric on 7/13/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "SoundControls.h"
#import "TheAmazingAudioEngine.h"
#import "AERecorder.h"

@interface SoundControls()

@property (nonatomic, strong) AEAudioController *audioController;

@property (nonatomic, strong) AERecorder *recorder;

@property (nonatomic, strong) AEAudioFilePlayer *player;

@property (nonatomic,strong)    NSTimer *stepTimer;
@end
@implementation SoundControls

- (id)init
{
    self = [super init];
    if (self) {

        self.audioController = [[AEAudioController alloc]
                                initWithAudioDescription:[AEAudioController nonInterleaved16BitStereoAudioDescription]
                                inputEnabled:YES];
        
        self.audioController.preferredBufferDuration = 0.005;

        self.audioController.useMeasurementMode = YES;

    }
    return self;
}

+ (SoundControls *)soundSingleton
{
    static SoundControls *voiceControl;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        voiceControl = [[SoundControls alloc] init];
    });
    
    return voiceControl;
}


- (void)startSoundListener
{
    if (self.recorder==nil) {
        [self.audioController start:NULL];
        self.recorder = [[AERecorder alloc] initWithAudioController:self.audioController];
        NSArray *documentsFolders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[documentsFolders objectAtIndex:0] stringByAppendingPathComponent:@"Recording.aiff"];
        NSError *error = nil;
        if ( ![self.recorder beginRecordingToFileAtPath:path fileType:kAudioFileAIFFType error:&error] ) {
            showCustomAlertMessage(@"没有权限，无法启动录音");
            self.recorder = nil;
            return;
        }
        

        
        [self.audioController addOutputReceiver:self.recorder];
        [self.audioController addInputReceiver:self.recorder];
    }
   
   
    if (self.stepTimer && [self.stepTimer isValid]) {
        [self.stepTimer invalidate];
    }
    self.stepTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
}

- (void)levelTimerCallback:(NSTimer *)timer {

    Float32 inputAvg, inputPeak, outputAvg, outputPeak;
    [self.audioController inputAveragePowerLevel:&inputAvg peakHoldLevel:&inputPeak];
    [self.audioController outputAveragePowerLevel:&outputAvg peakHoldLevel:&outputPeak];
   
    int degree = inputAvg+inputPeak;
    
    BlockCallWithOneArg(self.soundHandler, @(degree))
    
}

- (void)stopSoundListener
{
    if ([self.stepTimer isValid]) {
        [self.stepTimer invalidate];
    }

    [self.audioController stop];
    if ( self.recorder ) {
        [self.recorder finishRecording];
        [self.audioController removeOutputReceiver:self.recorder];
        [self.audioController removeInputReceiver:self.recorder];
        self.recorder = nil;
        
    }
}



@end
