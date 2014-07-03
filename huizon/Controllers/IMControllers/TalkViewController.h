//
//  TalkViewController.h
//  huizon
//
//  Created by Yang on 14-3-3.
//  Modified by Meng on 14-3-22
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//  Talk and Multi Game
//

#import <UIKit/UIKit.h>
#import "UIBubbleTableViewDataSource.h"


@interface TalkViewController : UIViewController<UIBubbleTableViewDataSource>

@property (nonatomic,strong) XMPPJID *xmppFriendJID;
@property (nonatomic,strong) NSString *xmppFriendNickname;
@end
