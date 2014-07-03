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
    NSError *setCategoryError = nil;
    
   BOOL success = [[AVAudioSession sharedInstance]
                    setCategory:AVAudioSessionCategoryPlayback
                    error: &setCategoryError];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    if (success) {
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:audioURL error:&setCategoryError];
        self.audioPlayer.delegate = self;
        self.audioPlayer.meteringEnabled = YES;
        self.audioPlayer.numberOfLoops = -1;
        //准备播放
        [self.audioPlayer prepareToPlay];
    }
 

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
        NSLog(@"%d %0.2f %0.2f", 0, [self.audioPlayer peakPowerForChannel:0],[self.audioPlayer averagePowerForChannel:0]);

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


/////////////////
- (void)startVideo
{
    NSString* path = [[NSBundle mainBundle] pathForResource:@"sintel" ofType:@"mp4"];
    
    AVAsset *avAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:path]];
    CMTime assetTime = [avAsset duration];
    Float64 duration = CMTimeGetSeconds(assetTime);
    NSLog(@"视频时长 %f\n",duration);

//    moviePlayer = [ [ MPMoviePlayerController alloc]initWithContentURL:[NSURL fileURLWithPath:path]];
//    moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
//    moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
//    [[moviePlayer view] setBounds:CGRectMake(0, 0, 320, 480)];
//    [[moviePlayer view] setCenter:CGPointMake([UIScreen mainScreen].bounds.size.width/2 , [UIScreen mainScreen].bounds.size.height/2)];
//    [[moviePlayer view] setTransform:CGAffineTransformMakeRotation(0)];
//    [self addSubview:moviePlayer.view];
//    [moviePlayer setFullscreen:YES animated:YES];
//    [ moviePlayer play ];
    //[ moviePlayer stop ];
    //[moviePlayer release];
    
    
    
    NSDictionary *settings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat: 44100.0],                 AVSampleRateKey,
                              [NSNumber numberWithInt: kAudioFormatAppleLossless], AVFormatIDKey,
                              [NSNumber numberWithInt: 1],                         AVNumberOfChannelsKey,
                              [NSNumber numberWithInt: AVAudioQualityMax],         AVEncoderAudioQualityKey,
                              nil];
    
    NSURL *url = [NSURL fileURLWithPath:@"/dev/null"];
    
    NSError *error;
    NSError *setCategoryError = nil;
    
  
    NSArray *pathComponents = [NSArray arrayWithObjects:
                               [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                               @"MyAudioMemo.m4a",
                               nil];
    NSURL *outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
    
    AVAudioSession *audioSession =[AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    [audioSession setActive:YES error:nil];
//    
//    BOOL success = [[AVAudioSession sharedInstance]
//                    setCategory: AVAudioSessionCategoryRecord
//                    error: &setCategoryError];
    
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:settings error:&error];
    
    if (recorder) {
        [recorder prepareToRecord];
        recorder.meteringEnabled = YES;
        [recorder record];
        [NSTimer scheduledTimerWithTimeInterval: 0.03 target: self selector: @selector(videoTimerCallback:) userInfo: nil repeats: YES];
    } else
        NSLog([error description]);
    
    _avPlayer = [AVPlayer playerWithURL:[NSURL fileURLWithPath:path]];
    _avPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_avPlayer];
    
//    _avPlayerLayer.frame = self.layer.bounds;
//    [self.layer addSublayer:_avPlayerLayer];
    
    [_avPlayer play];

}
- (void)videoTimerCallback:(NSTimer *)timer {
	[recorder updateMeters];
  
    
    const double ALPHA = 0.05;
    	double peakPowerForChannel = pow(10, (0.05 * [recorder peakPowerForChannel:0]));
    	lowPassResults = ALPHA * peakPowerForChannel + (1.0 - ALPHA) * lowPassResults;
    
    	NSLog(@"Average input: %f Peak input: %f Low pass results: %f", [recorder averagePowerForChannel:0], [recorder peakPowerForChannel:0], lowPassResults);
}


@end
