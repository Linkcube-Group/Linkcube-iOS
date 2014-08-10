//
//  ChatViewManager.m
//  huizon
//
//  Created by yuyang on 14-8-11.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "ChatViewManager.h"

static ChatViewManager * defaultManagerInstance = nil;

@implementation ChatViewManager

@synthesize chatKeyboardType = _chatKeyboardType;
@synthesize inputTextViewType = _inputTextViewType;
@synthesize isWaitingReply = _isWaitingReply;
@synthesize isGamePlaying = _isGamePlaying;
@synthesize avatarOfMe = _avatarOfMe;
@synthesize avatarOfOther = _avatarOfOther;

+(ChatViewManager *)defaultManager
{
    @synchronized(self) {
        static dispatch_once_t pred;
        dispatch_once(&pred, ^{
            defaultManagerInstance = [[self alloc] init];
        });
    }
    return defaultManagerInstance;
}

-(id)init
{
    if(self = [super init])
    {
        //init code
        _chatKeyboardType = chatKeyboardTypeNormal;
        _inputTextViewType = inputTextViewTypeText;
        _isWaitingReply = NO;
        _isGamePlaying = NO;
        _avatarOfMe = [[UIImage alloc] init];
        _avatarOfOther = [[UIImage alloc] init];
    }
    return self;
}

-(void)clearData
{
    _chatKeyboardType = chatKeyboardTypeNormal;
    _inputTextViewType = inputTextViewTypeText;
    _isWaitingReply = NO;
    _isGamePlaying = NO;
    _avatarOfMe = [[UIImage alloc] init];
    _avatarOfOther = [[UIImage alloc] init];
}

@end
