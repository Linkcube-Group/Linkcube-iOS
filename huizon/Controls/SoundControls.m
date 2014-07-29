//
//  SoundControls.m
//  huizon
//
//  Created by yang Eric on 7/13/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "SoundControls.h"

@interface SoundControls()
{

}
@property (nonatomic,strong)    NSTimer *stepTimer;
@end
@implementation SoundControls

- (id)init
{
    self = [super init];
    if (self) {
        AVAudioSession * audioSession = [AVAudioSession sharedInstance];
        NSError *error;
        [audioSession setCategory:AVAudioSessionCategoryRecord error: &error];
        //Activate the session
        
        [audioSession setActive:YES error: &error];
        
        NSDictionary *recordSetting = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:kAudioFormatLinearPCM], AVFormatIDKey,
                                       [NSNumber numberWithFloat:8000.00], AVSampleRateKey,
                                       [NSNumber numberWithInt:1], AVNumberOfChannelsKey,
                                       [NSNumber numberWithInt:16], AVLinearPCMBitDepthKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsNonInterleaved,
                                       [NSNumber numberWithBool:NO],AVLinearPCMIsFloatKey,
                                       [NSNumber numberWithBool:NO], AVLinearPCMIsBigEndianKey,
                                       nil];
        
        recordedTmpFile = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent: [NSString stringWithFormat: @"%.0f.%@", [NSDate timeIntervalSinceReferenceDate] * 1000.0, @"caf"]]];
        NSLog(@"Using File called: %@",recordedTmpFile);
        //Setup the recorder to use this file and record to it.
        self.recorder = [[AVAudioRecorder alloc] initWithURL:recordedTmpFile settings:recordSetting error:&error];
        
        self.recorder.meteringEnabled = YES;
        [self.recorder setDelegate:self];
        
        [self.recorder prepareToRecord];
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
   
    [self.recorder record];
    
    if (self.stepTimer && [self.stepTimer isValid]) {
        [self.stepTimer invalidate];
    }
    self.stepTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
}

- (void)levelTimerCallback:(NSTimer *)timer {
	[self.recorder updateMeters];

    BlockCallWithOneArg(self.soundHandler, @([self.recorder averagePowerForChannel:0]))
    
}

- (void)stopSoundListener
{
    if ([self.stepTimer isValid]) {
        [self.stepTimer invalidate];
    }
    [self.recorder stop];
}
@end
