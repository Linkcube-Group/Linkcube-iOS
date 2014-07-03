//
//  Config.h
//  huizon
//
//  Created by yang Eric on 3/2/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    PatternStateShake=0,
    PatternStatePosture=1,
    PatternStateVoice
}PatternState;


@interface Config : NSObject
+ (MusicItem *)musicDefaul1;
+ (MusicItem *)musicDefaul2;
@end
