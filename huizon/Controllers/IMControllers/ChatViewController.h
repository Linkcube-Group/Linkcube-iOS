//
//  ChatViewController.h
//  huizon
//
//  Created by yang Eric on 3/2/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//  Display the controll panel
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"


@interface ChatViewController : UIViewController

@property (nonatomic,strong) XMPPUserCoreDataStorageObject *xmppUserObject;

-(void)receiveMessage:(XMPPMessage *)message;
-(void)friendStatusChangePresence:(XMPPPresence *)presence;
-(void)friendSubscription:(XMPPPresence *)presence;
@end
