//
//  IMControls.m
//  huizon
//  提供即时聊天的接口
//  Created by yang Eric on 2/12/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "IMControls.h"
#import "XMPPvCardTemp.h"

#define NOTICES_RECEIVE_ADDFRIEND_COUNT_NEW [self createPath:@"notifices_receive_count_new"]

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

- (NSString *)createPath:(NSString *)path
{
    if(theApp.isXmppAuthenticated)
        return [NSString stringWithFormat:@"%@/%@", theApp.xmppvCardUser.nickname, path];
    return nil;
}

#pragma mark
#pragma mark - 收到新消息

-(void)receiveNewNoticesWithNotiType:(NotificationType)type
{
    if(type == NotificationTypeAddfriend)
    {
        NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:NOTICES_RECEIVE_ADDFRIEND_COUNT_NEW];
        count++;
        [[NSUserDefaults standardUserDefaults] setInteger:count forKey:NOTICES_RECEIVE_ADDFRIEND_COUNT_NEW];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

#pragma mark
#pragma mark - 获取新消息数

-(NSInteger)getNewNoticesCountWithType:(NotificationType)type
{
    if(type == NotificationTypeAddfriend)
    {
#warning ????crash
        NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:NOTICES_RECEIVE_ADDFRIEND_COUNT_NEW];
        return count>99?99:count;
    }
    return 0;
}

#pragma mark
#pragma mark - 新消息数减1

-(NSInteger)deleteOneNoticeCountWithType:(NotificationType)type
{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:NOTICES_RECEIVE_ADDFRIEND_COUNT_NEW];
    if(count>0)
        count--;
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:NOTICES_RECEIVE_ADDFRIEND_COUNT_NEW];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return count;
}

#pragma mark
#pragma mark - 清空消息数

-(void)clearNewNoticesCountWithType:(NotificationType)type
{
    if(type == NotificationTypeAddfriend)
    {
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:NOTICES_RECEIVE_ADDFRIEND_COUNT_NEW];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

#pragma mark
#pragma mark - 收到新聊天

-(void)receiveNewMessageWithJidStr:(NSString *)jid
{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:[self createPath:jid]];
    count++;
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:[self createPath:jid]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark
#pragma mark - 获取新聊天数

-(NSInteger)getNewMessageCountWithJidStr:(NSString *)jid
{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:[self createPath:jid]];
    return count>99?99:count;
}

#pragma mark
#pragma mark - 新聊天数减1

-(NSInteger)deleteOneMessageCountWithJidStr:(NSString *)jid
{
    NSInteger count = [[NSUserDefaults standardUserDefaults] integerForKey:[self createPath:jid]];
    if(count>0)
        count--;
    [[NSUserDefaults standardUserDefaults] setInteger:count forKey:[self createPath:jid]];
    [[NSUserDefaults standardUserDefaults] synchronize];
    return count;
}

#pragma mark
#pragma mark - 清空聊天数

-(void)clearNewMessageCountWithJidStr:(NSString *)jid
{
    [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:[self createPath:jid]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
