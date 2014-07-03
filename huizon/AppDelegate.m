//
//  AppDelegate.m
//  huizon
//
//  Created by Yang on 13-11-7.
//  Copyright (c) 2013年 zhaopin. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "XMPPvCardTemp.h"
#import "XMPPvCardTempModule.h"

#import "NSString+XEP_0106.h"

#import "JASidePanelController.h"

#import "LeftViewController.h"
#import "RightViewController.h"
#import "PlayViewController.h"

#define tag_subcribe_alertView 100

@implementation AppDelegate
@synthesize xmppStream;
@synthesize xmppRoster;
@synthesize xmppRosterStorage;
@synthesize chatDelegate;
@synthesize xmppReconnect;
@synthesize xmppMessageArchivingCoreDataStorage;
@synthesize xmppMessageArchivingModule;
@synthesize xmppvCardStorage;
@synthesize xmppvCardTempModule;
@synthesize xmppvCardAvatarModule;
@synthesize sidePanelController;

@synthesize xmppvCardUser;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.

#ifdef DEBUG_CONSOLE
    //控制台的log信息
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
#endif
#ifdef DEBUG_FILE
    //写入文件的Log信息
    DDLogFileManagerDefault *defaultlog=[[DDLogFileManagerDefault alloc] init];
    DDFileLogger *filelog=[[DDFileLogger alloc] initWithLogFileManager:defaultlog];
    [DDLog addLogger:filelog];

#endif
    
    self.currentGamingJid = NO;
    self.blueConnType = 0;
    
    
    [self loadMusicInfo];
    
    //激活主题系统
    [Theam currentTheam];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    PlayViewController *main =
    [[PlayViewController alloc] initWithNibName:nil
                                                 bundle:nil];
    UINavigationController *nav_main =
    [[UINavigationController alloc]
      initWithRootViewController:main];
    
    LeftViewController *left =
    [[LeftViewController alloc] initWithNibName:nil
                                              bundle:nil];
    RightViewController *right = [[RightViewController alloc] initWithNibName:nil bundle:nil];
    
    JASidePanelController *panel =
    [[JASidePanelController alloc] init];
    
    panel.leftPanel = left;
    panel.rightPanel = right;
    panel.centerPanel = nav_main;
    panel.leftFixedWidth = 270;
    self.sidePanelController = panel;
    
    self.window.rootViewController = panel;
    
    [self.window makeKeyAndVisible];
    
    [self setupStream];
    [self myConnect];
    

    return YES;
}

- (void)loadMusicInfo
{
    BOOL flag = [[NSUserDefaults standardUserDefaults] boolForKey:kMusicLocalSetting];
    if (!flag) {
        MusicList *mList = [[MusicList alloc] init];
        
        [mList addObject:[Config musicDefaul1]];
        
       
        [mList addObject:[Config musicDefaul2]];
        
        [[NSUserDefaults standardUserDefaults] setObject:mList.arrayString forKey:kMusicLocalKey];
       
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kMusicLocalSetting];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
#pragma mark - xmpp
- (void)setupStream{
    self.xmppvCardUser = nil;
    xmppStream = [[XMPPStream alloc]init];
    [xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppStream setHostName:kXMPPmyServer];
    
    xmppReconnect = [[XMPPReconnect alloc]init];
    [xmppReconnect activate:self.xmppStream];
    
    xmppRosterStorage = [[XMPPRosterCoreDataStorage alloc]init];
    xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:xmppRosterStorage];
    xmppRoster.autoFetchRoster = YES;
	xmppRoster.autoAcceptKnownPresenceSubscriptionRequests = YES;
    [xmppRoster activate:self.xmppStream];
    [xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppMessageArchivingCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    xmppMessageArchivingModule = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:xmppMessageArchivingCoreDataStorage];
    [xmppMessageArchivingModule setClientSideMessageArchivingOnly:YES];
    [xmppMessageArchivingModule activate:xmppStream];
    [xmppMessageArchivingModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    xmppvCardStorage=[XMPPvCardCoreDataStorage sharedInstance];
    xmppvCardTempModule=[[XMPPvCardTempModule alloc]initWithvCardStorage:xmppvCardStorage];
    xmppvCardAvatarModule=[[XMPPvCardAvatarModule alloc] initWithvCardTempModule:xmppvCardTempModule];
    [xmppvCardTempModule activate:xmppStream];
    [xmppvCardAvatarModule activate:xmppStream];
    [xmppvCardTempModule addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [xmppvCardAvatarModule addDelegate:self delegateQueue:dispatch_get_main_queue()];

    
}
- (BOOL)myConnect{
    if([xmppStream isConnecting] || [xmppStream isConnected])
    {
        [xmppStream disconnect];
    }
    NSString *jid = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
    NSString *ps = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword];
    if (jid == nil || ps == nil) {
        return NO;
    }
    XMPPJID *myjid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",[jid jidEscapedString],kXMPPmyDomain]];
    NSError *error ;
    [xmppStream setMyJID:myjid];
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&error]) {
        NSLog(@"my connected error : %@",error.description);
        return NO;
    }
    return YES;
}
- (void)disconnect
{
    XMPPPresence *presense=[XMPPPresence presenceWithType:@"unavailable"];
    [xmppStream sendElement:presense];
    [xmppStream disconnect];
}

#pragma mark -
#pragma mark MyRegister
///userDict key:name Value:user email; Key:pwd Value:password
- (BOOL)beginRegister:(NSDictionary *)userDict
{
    if([xmppStream isConnecting] || [xmppStream isConnected])
    {
        [xmppStream disconnect];
    }
    NSError *err;
    NSString *tjid = [[NSString alloc] initWithFormat:@"anonymous@%@", kXMPPmyDomain];
    [xmppStream setMyJID:[XMPPJID jidWithString:tjid]];
    if (![xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err])
    {
        return NO;
    }
    
    [xmppStream setAssociatedObjectRetain:userDict];
    
    return YES;
}

#pragma mark -
#pragma mark AddFriend
//添加好友
#pragma mark 加好友
- (void)XMPPAddFriendSubscribe:(NSString *)name
{
    //XMPPHOST 就是服务器名，  主机名
    XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@", [name jidEscapedString],kXMPPmyDomain]];
    //[presence addAttributeWithName:@"subscription" stringValue:@"好友"];
    //[xmppRoster subscribePresenceToUser:jid];
    XMPPvCardTemp *friednVCard=[xmppvCardTempModule vCardTempForJID:jid shouldFetch:YES];
    [xmppRoster addUser:jid withNickname:friednVCard.nickname];
    
}

#pragma mark 删除好友,取消加好友，或者加好友后需要删除
- (void)removeBuddy:(NSString *)name
{
	XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@@%@",[name jidEscapedString],kXMPPmyDomain]];
	
	[xmppRoster removeUser:jid];
}

#pragma mark 发送，存储信息
-(void)sendMessage:(XMPPMessage *)message
{
    
}


//gaming controll
- (void)sendControlCode:(NSString *)code
{
    XMPPMessage *mes=[XMPPMessage messageWithType:@"chat" to:self.currentGamingJid];
    NSString *controlCode=[NSString stringWithFormat:@"ctl:%@",code];
    [mes addChild:[DDXMLNode elementWithName:@"body" stringValue:controlCode]];
    [theApp.xmppStream sendElement:mes];
}

#pragma mark -
#pragma mark change pwd
- (void)changePassword:(NSString *)pwd
{
    NSString *uname = [[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID] jidEscapedString];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",uname,kXMPPmyDomain]];
    [iq addAttributeWithName:@"id" stringValue:@"change1"];
    

    DDXMLNode *username=[DDXMLNode elementWithName:@"username" stringValue:uname];//不带@后缀
    DDXMLNode *password=[DDXMLNode elementWithName:@"password" stringValue:pwd];//要改的密码
    [query addChild:username];
    [query addChild:password];
    [iq addChild:query];
    [[self xmppStream] sendElement:iq];
    
}

#pragma mark -
#pragma mark otherXMPPAction
- (void)logouXmppAuthenticated
{
    if ([self.xmppStream isConnected]) {
        [self.xmppStream disconnect];
    }
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (BOOL)isXmppAuthenticated
{
    return [self.xmppStream isAuthenticated];
}


- (void)getUserCardTemp
{
    ///登录后获取用户信息
    if ([self isXmppAuthenticated]) {
    
        self.xmppvCardUser = [self.xmppvCardTempModule myvCardTemp];
    }

    
}

- (void)updateUserCardTemp:(XMPPvCardTemp *)card
{
    [self.xmppvCardTempModule updateMyvCardTemp:card];
}

#pragma mark - XMPPStreamDelegate

- (void)xmppStreamWillConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamWillConnect");
}
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidConnect");
    NSDictionary *assocObj = [xmppStream associatedObjectRetain];
    NSString *lid=[assocObj valueForKey:@"lid"];
    NSString *password=[assocObj valueForKey:@"pwd"];
 
    if (assocObj && lid && password)
    {
        
        
        [[NSUserDefaults standardUserDefaults] setObject:lid forKey:kXMPPmyJID];
        [[NSUserDefaults standardUserDefaults] setObject:password forKey:kXMPPmyPassword];
        NSString *jid = [[NSString alloc] initWithFormat:@"%@@%@",[lid jidEscapedString], kXMPPmyDomain];

        //[xmppStream setMyJID:jid];
        [xmppStream setMyJID:[XMPPJID jidWithString:jid]];
        NSError *error=nil;
        if (![xmppStream registerWithPassword:[assocObj valueForKey:@"pwd"] error:&error])
        {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"创建帐号失败"
                                                                message:[error localizedDescription]
                                                               delegate:nil 
                                                      cancelButtonTitle:@"Ok" 
                                                      otherButtonTitles:nil];
            [alertView show];
        }
        
        
        
       

        //XMPPvCardTemp *test=[self.xmppvCardTempModule vCardTempForJID:[xmppStream myJID] shouldFetch:YES];
        //NSLog(@"%@",test.gender);
        return;//上面注册密码后，会在xmppStreamDidRegister里面进行密码确认不能直接执行下面        
    }
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword]) {
        NSError *error ;
        if (![self.xmppStream authenticateWithPassword:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword] error:&error]) {
            NSLog(@"error authenticate : %@",error.description);
        }
    }

    
    //XMPPvCardTemp *test=[self.xmppvCardTempModule vCardTempForJID:[xmppStream myJID] shouldFetch:YES];
    //NSLog(@"%@",test.gender);
}
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidRegister");
    
    if ([[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword]) {
        NSError *error ;
        if (![self.xmppStream authenticateWithPassword:[[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword] error:&error]) {
            NSLog(@"error authenticate : %@",error.description);
        }
        showCustomAlertMessage(@"注册成功");
        //[self myConnect];
    }
}
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(NSXMLElement *)error
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyJID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kXMPPmyPassword];
    [self showAlertView:@"当前用户已经存在"];
}
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"xmppStreamDidAuthenticate");
    XMPPPresence *presence = [XMPPPresence presence];
	[[self xmppStream] sendElement:presence];
    
    NSDictionary *assocObj = [xmppStream associatedObjectRetain];
    if (assocObj) { ///如果此次论证是注册再进行提交其他信息
        //Record the information in vCard after Authentication.
        //NSString *nickname=[assocObj valueForKey:@"name"];
        NSString *lid=[assocObj valueForKey:@"lid"];
        NSString *mail =[lid stringByReplacingOccurrencesOfString:@"-" withString:@"@"];
        //NSString *gender=[assocObj valueForKey:@"gender"];
        if (mail) {
            // store infomation in vcard
            XMPPvCardTemp *xmppvCardTemp=[XMPPvCardTemp vCardTemp];
//            xmppvCardTemp.nickname=nickname;
            xmppvCardTemp.email=mail;
//            xmppvCardTemp.gender=gender;
            [self.xmppvCardTempModule updateMyvCardTemp:xmppvCardTemp];
            [xmppStream setAssociatedObjectRetain:nil];

        }
    }
    else
    {
        self.xmppvCardUser = [self.xmppvCardTempModule myvCardTemp];
    }
    
    
    ///通知告诉其他登录或注册完成
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPPNotificationDidAuthen object:nil];
}
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error
{
    showCustomAlertMessage(@"您的用户名或密码错误");
    NSLog(@"didNotAuthenticate:%@",error.description);
}
- (NSString *)xmppStream:(XMPPStream *)sender alternativeResourceForConflictingResource:(NSString *)conflictingResource
{
    NSLog(@"alternativeResourceForConflictingResource: %@",conflictingResource);
    return @"XMPPIOS";
}
- (BOOL)xmppStream:(XMPPStream *)sender didReceiveIQ:(XMPPIQ *)iq
{
    NSLog(@"didReceiveIQ:\n\n%@\n",iq.description);
    if ([self.chatDelegate respondsToSelector:@selector(receiveIQ:)])
    {
        [self.chatDelegate receiveIQ:iq];
    }
    else if([iq isResultIQ]){
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationTop object:nil userInfo:nil];
    }
    
    return YES;
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"didReceiveMessage: %@",message.description);
    if ([self.chatDelegate respondsToSelector:@selector(receiveMessage:)]) {
        [self.chatDelegate receiveMessage:message];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:KXMPPNotificationDidReceiveMessage object:nil];
}
- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence
{
     NSString *presenceType = [NSString stringWithFormat:@"%@", [presence type]]; //online/offline
    NSLog(@"didReceivePresence:\n\n%@\n",presence.description);
    if (presence.status) {
        if ([self.chatDelegate respondsToSelector:@selector(friendStatusChangePresence:)]) {
            [self.chatDelegate friendStatusChangePresence:presence];
        }
    }
    
    // 接到加好友请求
    if ([presenceType isEqualToString:@"subscribe"])
    {
        if ([self.chatDelegate respondsToSelector:@selector(friendSubscription:)])
        {
            [self.chatDelegate friendSubscription:presence];
        }
    }
    /*
    //这里再次加好友
    if ([presenceType isEqualToString:@"subscribed"]) {
        XMPPJID *jid = [XMPPJID jidWithString:[NSString stringWithFormat:@"%@",[presence from]]];
        [xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    }*/
}
- (void)xmppStream:(XMPPStream *)sender didReceiveError:(NSXMLElement *)error
{
    NSLog(@"didReceiveError: %@",error.description);
}
- (void)xmppStream:(XMPPStream *)sender didSendIQ:(XMPPIQ *)iq
{
    NSLog(@"didSendIQ:\n\n%@\n\n",iq.description);
    if ([iq.type isEqualToString:@"set"]) {
         [[NSNotificationCenter defaultCenter] postNotificationName:kXMPPvCardTempElement object:@(1)];
    }
    
}
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    NSLog(@"didSendMessage:%@",message.description);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPPNotificationDidSendMessage object:nil];
}
- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence
{
    NSLog(@"didSendPresence:\n\n%@\n",presence.description);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendIQ:(XMPPIQ *)iq error:(NSError *)error
{
    NSLog(@"didFailToSendIQ:%@",error.description);
    [[NSNotificationCenter defaultCenter] postNotificationName:kXMPPvCardTempElement object:@(0)];
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    NSLog(@"didFailToSendMessage:%@",error.description);
}
- (void)xmppStream:(XMPPStream *)sender didFailToSendPresence:(XMPPPresence *)presence error:(NSError *)error
{
    NSLog(@"didFailToSendPresence:%@",error.description);
}
- (void)xmppStreamWasToldToDisconnect:(XMPPStream *)sender
{
    NSLog(@"xmppStreamWasToldToDisconnect");
}
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"xmppStreamConnectDidTimeout");
}
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"xmppStreamDidDisconnect: %@",error.description);
}
#pragma mark - XMPPRosterDelegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    /*
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:presence.fromStr message:@"add" delegate:self cancelButtonTitle:@"cancle" otherButtonTitles:@"yes", nil];
    alertView.tag = tag_subcribe_alertView;
    [alertView show];
     */
}

- (NSManagedObjectContext *)managedObjectContext_roster
{
	return [self.xmppRosterStorage mainThreadManagedObjectContext];
}
#pragma mark - XMPPReconnectDelegate
- (void)xmppReconnect:(XMPPReconnect *)sender didDetectAccidentalDisconnect:(SCNetworkReachabilityFlags)connectionFlags
{
    NSLog(@"didDetectAccidentalDisconnect:%u",connectionFlags);
}
- (BOOL)xmppReconnect:(XMPPReconnect *)sender shouldAttemptAutoReconnect:(SCNetworkReachabilityFlags)reachabilityFlags
{
    NSLog(@"shouldAttemptAutoReconnect:%u",reachabilityFlags);
    return YES;
}
#pragma mark - my method
-(void)showAlertView:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:message delegate:self cancelButtonTitle:@"ok" otherButtonTitles:nil, nil];
    [alertView show];
}
#pragma mark - UIAlertView Delegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == tag_subcribe_alertView && buttonIndex == 1) {
        XMPPJID *jid = [XMPPJID jidWithString:alertView.title];
        [[self xmppRoster] acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    
    }
}

@end
