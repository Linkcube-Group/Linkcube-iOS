//
//  NotificationCell.h
//  huizon
//
//  Created by apple on 14-7-28.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

//消息的类型
typedef enum {
    NotificationTypeNone = 0,
    NotificationTypeFrom,
    NotificationTypeTo,
    NotificationTypeBoth
}NotificationType;

@interface NotificationCell : UITableViewCell

@property (nonatomic) NotificationType notiType;
@property (nonatomic, strong) UIImageView * headerImageView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic) NSString * temp;
@property (nonatomic, strong) XMPPJID * jid;

@end
