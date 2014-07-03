//
//  Config.m
//  huizon
//
//  Created by yang Eric on 3/2/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "Config.h"


@implementation Config
+ (MusicItem *)musicDefaul1
{
    MusicItem *mItem = [[MusicItem alloc] init];
    mItem.musicName = @"Apolize";
    mItem.musicPath = [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"];
    mItem.author = @"Black Street";
    return mItem;
}
+ (MusicItem *)musicDefaul2
{
    MusicItem *mItem1 = [[MusicItem alloc] init];
    mItem1.musicName = @"Helle world";
    mItem1.author = @"Baby";
    mItem1.musicPath = [[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp3"];
    return mItem1;
}
@end
