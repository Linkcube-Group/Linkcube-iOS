//
//  PlayViewController.h
//  huizon
//
//  Created by yang Eric on 5/17/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    PlayTypeSingle=0,//单曲
    PlayTypeCircle,
    PlayTypeRandom
}PlayType;

@interface PlayViewController : UIViewController

@property (strong,nonatomic) MusicItem *musicInfo;
@end
