//
//  SoundControls.h
//  huizon
//
//  Created by yang Eric on 7/13/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <MediaPlayer/MediaPlayer.h>

@interface SoundControls : NSObject<AVAudioRecorderDelegate>
{
    NSURL *recordedTmpFile;

}

@property (nonatomic,copy) EventHandler soundHandler;

+ (SoundControls *)soundSingleton;

- (void)startSoundListener;
- (void)stopSoundListener;
@end
