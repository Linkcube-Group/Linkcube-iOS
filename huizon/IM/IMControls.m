//
//  IMControls.m
//  huizon
//  提供即时聊天的接口
//  Created by yang Eric on 2/12/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "IMControls.h"

static IMControls * defaultManagerInstance = nil;

@implementation IMControls

+(IMControls *)defaultControls
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
    }
    return self;
}

@end
