//
//  ChatWithOtherViewController.h
//  huizon
//
//  Created by apple on 14-8-1.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"

@interface ChatWithOtherViewController : UIViewController<UIBubbleTableViewDataSource>

@property (nonatomic,strong) XMPPJID *xmppFriendJID;
@property (nonatomic,strong) NSString *xmppFriendNickname;

@end
