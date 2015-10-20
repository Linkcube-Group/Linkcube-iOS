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
    mItem.musicName = @"My Humps";
    mItem.musicPath = _S(@"%@/1.mp3",HomeMyPath);//  [[NSBundle mainBundle] pathForResource:@"1" ofType:@"mp3"];
    mItem.author = @"Black Eyed Peas";
    return mItem;
}
+ (MusicItem *)musicDefaul2
{
    MusicItem *mItem1 = [[MusicItem alloc] init];
    mItem1.musicName = @"Having fun together";
    mItem1.author = @"Raimond Lap";
    mItem1.musicPath = _S(@"%@/2.mp3",HomeMyPath);//[[NSBundle mainBundle] pathForResource:@"2" ofType:@"mp3"];
    return mItem1;
}

+ (MusicItem *)musicDefaul3
{
    MusicItem *mItem1 = [[MusicItem alloc] init];
    mItem1.musicName = @"Something";
    mItem1.author = @"Girl's Day";
    mItem1.musicPath = _S(@"%@/3.mp3",HomeMyPath);//[[NSBundle mainBundle] pathForResource:@"3" ofType:@"mp3"];
    return mItem1;
}
+ (MusicItem *)musicDefaul4
{
    MusicItem *mItem1 = [[MusicItem alloc] init];
    mItem1.musicName = @"Poker Face";
    mItem1.author = @"Lady GaGa";
    mItem1.musicPath = _S(@"%@/4.mp3",HomeMyPath);//[[NSBundle mainBundle] pathForResource:@"4" ofType:@"mp3"];
    return mItem1;
}
@end
