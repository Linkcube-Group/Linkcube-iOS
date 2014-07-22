//
//  AppDelegate.h
//  huizon
//
//  Created by Yang on 13-11-7.
//  Copyright (c) 2013年 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

@protocol ChatDelegate <NSObject>
-(void)receiveMessage:(XMPPMessage *)message;
-(void)friendStatusChangePresence:(XMPPPresence *)presence;
-(void)receiveIQ:(XMPPIQ *)iq;
-(void)friendSubscription:(XMPPPresence *)presence;
@end



@class ViewController;
@class JASidePanelController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    XMPPStream *xmppStream;
    XMPPRoster *xmppRoster;
    XMPPRosterCoreDataStorage *xmppRosterStorage;
    XMPPReconnect *xmppReconnect;
    XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
    XMPPMessageArchiving *xmppMessageArchivingModule;
    XMPPvCardCoreDataStorage *xmppvCardStorage;
    XMPPvCardTempModule *xmppvCardTempModule;
    XMPPvCardAvatarModule *xmppvCardAvatarModule;
    XMPPSearchModule *xmppSearchModule;
}


@property (nonatomic,strong) JASidePanelController *sidePanelController;

///-1 蓝牙没有打开；0-未连接，1-mars，2-varnars
@property (nonatomic) int blueConnType;
///当确定与好友开始游戏后，置为YES，断开游戏后为NO
@property (nonatomic) BOOL   isPlayWithFriend;
//---------------------------------------------------------------------
@property (nonatomic, strong) XMPPStream *xmppStream;
@property (nonatomic, strong) XMPPRosterCoreDataStorage *xmppRosterStorage;
@property (nonatomic, strong) XMPPRoster *xmppRoster;
@property (nonatomic, strong) XMPPReconnect *xmppReconnect;
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *xmppMessageArchivingCoreDataStorage;
@property (nonatomic, strong) XMPPMessageArchiving *xmppMessageArchivingModule;
@property (nonatomic,strong) XMPPvCardCoreDataStorage *xmppvCardStorage;
@property (nonatomic,strong) XMPPvCardTempModule *xmppvCardTempModule;
@property (nonatomic,strong) XMPPvCardAvatarModule *xmppvCardAvatarModule;
@property (nonatomic,strong)  XMPPvCardTemp *xmppvCardUser;
@property (nonatomic,strong)  XMPPSearchModule *xmppSearchModule;

//---------------------------------------------------------------------
//@property (nonatomic) BOOL isRegistration;

- (BOOL)myConnect;
- (void)showAlertView:(NSString *)message;


@property (nonatomic,strong) id<ChatDelegate> chatDelegate;


@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) ViewController *viewController;
//游戏开始后，设置为jid，游戏结束后设置为nil
@property (strong, nonatomic) XMPPJID *currentGamingJid;

- (NSManagedObjectContext *)managedObjectContext_roster;
///xmpp api
- (BOOL)beginRegister:(NSDictionary *)userDict;
- (void)disconnect;
- (BOOL)isXmppAuthenticated;
- (void)XMPPAddFriendSubscribe:(NSString *)name;
- (void)XMPPAddFriendSubscribeWithJid:(NSString *)jidStr;
- (void)getUserCardTemp;
- (void)updateUserCardTemp:(XMPPvCardTemp *)card;
- (void)changePassword:(NSString *)pwd;
- (void)logouXmppAuthenticated;
- (void)sendControlCode:(NSString *)code;

@end
