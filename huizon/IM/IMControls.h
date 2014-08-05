//
//  IMControls.h
//  huizon
//
//  Created by yang Eric on 2/12/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    NotificationTypeAddfriend = 0, //收到加好友的通知
    NotificationTypeOther          //其他
}NotificationType;

@interface IMControls : NSObject

+(IMControls *)defaultControls;

//收到新消息
-(void)receiveNewNoticesWithNotiType:(NotificationType)type;

//获取新消息数
-(NSInteger)getNewNoticesCountWithType:(NotificationType)type;

//新消息数减1
-(NSInteger)deleteOneNoticeCountWithType:(NotificationType)type;

//清空消息数
-(void)clearNewNoticesCountWithType:(NotificationType)type;



//收到新聊天
-(void)receiveNewMessageWithJidStr:(NSString *)jid;

//获取新聊天数
-(NSInteger)getNewMessageCountWithJidStr:(NSString *)jid;

//新聊天数减1
-(NSInteger)deleteOneMessageCountWithJidStr:(NSString *)jid;

//清空聊天数
-(void)clearNewMessageCountWithJidStr:(NSString *)jid;

@end
