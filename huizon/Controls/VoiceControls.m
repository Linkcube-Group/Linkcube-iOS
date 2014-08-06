//
//  VoiceControls.m
//  huizon
//
//  Created by Yang on 14-2-25.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "VoiceControls.h"

@interface VoiceControls()
{
    NSTimer *stepTimer;
}

@property (strong,nonatomic) NSTimer     *stepTimer;

@end

@implementation VoiceControls
@synthesize stepTimer;
@synthesize audioPlayer;
- (id)init
{
    self = [super init];
    if (self) {
        self.audioPlayer = nil;
        NSError *setCategoryError = nil;
        
//        BOOL success = [[AVAudioSession sharedInstance]
//                        setCategory:AVAudioSessionCategoryPlayAndRecord
//                        error: &setCategoryError];
//        [[AVAudioSession sharedInstance] setActive:YES error:nil];
//        

    }
    return self;
}
+ (VoiceControls *)voiceSingleton
{
    static VoiceControls *voiceControl;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        voiceControl = [[VoiceControls alloc] init];
    });
    
    return voiceControl;
}

- (void)playMusicAction
{
    UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(sessionCategory), &sessionCategory);
    
    
    if (self.audioPlayer && ![self.audioPlayer isPlaying]) {
        [self.audioPlayer play];
        
        if ([self.stepTimer isValid]) {
            [self.stepTimer invalidate];
        }
        self.stepTimer = [NSTimer scheduledTimerWithTimeInterval:0.05 target:self selector:@selector(levelTimerCallback:) userInfo:nil repeats:YES];
    }
}
-(void)startMusic:(NSURL *)audioURL
{
    //
   
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:nil];
        self.audioPlayer.delegate = self;
        self.audioPlayer.meteringEnabled = YES;
        self.audioPlayer.numberOfLoops = 0;
        //准备播放
        [self.audioPlayer prepareToPlay];
    
 

}
- (double)musicCurrentTime
{
    if (self.audioPlayer) {
        return [self.audioPlayer currentTime];
    }
    return 0;
}
- (double)musicDuration
{
    if (self.audioPlayer) {
        return [self.audioPlayer duration];
    }
    return 1;
}
- (void)setPlayTime:(double)time
{
    self.audioPlayer.currentTime = time;
}
- (void)levelTimerCallback:(NSTimer *)timer {
	[self.audioPlayer updateMeters];
    if (self.audioPlayer.numberOfChannels>0) {
        BlockCallWithOneArg(self.voiceHandler, @([self.audioPlayer averagePowerForChannel:0]))
        //Log the peak and average power
      //  DLog(@"%d %0.2f %0.2f", 0, [self.audioPlayer peakPowerForChannel:0],[self.audioPlayer averagePowerForChannel:0]);

    }
 
}

- (void)stopMusic
{
    if ([self.stepTimer isValid]) {
        [self.stepTimer invalidate];
    }
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
    }
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
}

- (void)pauseMusic
{
    if ([self.stepTimer isValid]) {
        [self.stepTimer invalidate];
    }
    
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer pause];
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    
    NSLog (@"audioPlayerDidFinishPlaying:");
    BlockCallWithOneArg(self.controllHandler, nil)
}




@end
