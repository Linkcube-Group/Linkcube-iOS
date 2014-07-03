//
//  VoiceControls.h
//  huizon
//
//  Created by Yang on 14-2-25.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MediaPlayer/MediaPlayer.h>

@interface VoiceControls : NSObject<AVAudioPlayerDelegate>
{
    AVAudioRecorder *recorder;
    double lowPassResults;
    
    AVAudioPlayer *audioPlayer;
    
    MPMoviePlayerController *moviePlayer;
    
    AVPlayer *_avPlayer;
    AVPlayerLayer *_avPlayerLayer;
    

    
}
@property (strong,nonatomic)AVAudioPlayer *audioPlayer;
@property (nonatomic,copy) EventHandler voiceHandler;
@property (nonatomic,copy) EventHandler controllHandler;
+ (VoiceControls *)voiceSingleton;

- (void)startMusic:(NSURL *)audioURL;
- (void)playMusicAction;
- (void)stopMusic;
- (void)pauseMusic;
- (double)musicDuration;
- (double)musicCurrentTime;
- (void)setPlayTime:(double)time;
@end
