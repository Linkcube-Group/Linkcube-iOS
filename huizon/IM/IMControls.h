//
//  IMControls.h
//  huizon
//
//  Created by yang Eric on 2/12/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NotificationCountTypeAddfriend = 0, //收到加好友的通知
    NotificationCountTypeOther          //其他
}NotificationCountType;

@interface IMControls : NSObject

+(IMControls *)defaultControls;

//收到新消息
-(void)receiveNewNoticesWithNotiType:(NotificationCountType)type;

//获取新消息数
-(NSInteger)getNewNoticesCountWithType:(NotificationCountType)type;

//新消息数减1
-(NSInteger)deleteOneNoticeCountWithType:(NotificationCountType)type;

//清空消息数
-(void)clearNewNoticesCountWithType:(NotificationCountType)type;



//收到新聊天
-(void)receiveNewMessageWithJidStr:(NSString *)jid;

//获取新聊天数
-(NSInteger)getNewMessageCountWithJidStr:(NSString *)jid;

//新聊天数减1
-(NSInteger)deleteOneMessageCountWithJidStr:(NSString *)jid;

//清空聊天数
-(void)clearNewMessageCountWithJidStr:(NSString *)jid;

@end
