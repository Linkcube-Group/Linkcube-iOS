//
//  Constants.h
//  huizon
//
//  Created by Yang on 13-11-8.
//  Copyright (c) 2013年 zhaopin. All rights reserved.
//

/*
  在project,targe修改 project Name "new name", 单击target的名称后，可以修改
 */
#ifndef zhaopin_Constants_h
#define zhaopin_Constants_h

///打印日志，发布时关闭
//#define DEBUG_CONSOLE 1
//#define DEBUG_FILE  1
///判断是否是ios7
#define isIOS7 (DeviceSystemMajorVersion()< 7 ? NO:YES)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define theApp ((AppDelegate *)[[UIApplication sharedApplication] delegate])


static int const kPageTag = 9011;
static int const kPageButtonTag = 8923;

static NSString *const kXMPPmyJID = @"kXMPPmyJID";
static NSString *const kXMPPmyPassword = @"kXMPPmyPassword";

static NSString * const kXMPPmyServer = @"112.124.22.252";//@"server1.linkcube.me";

static NSString * const kXMPPmyDomain = @"server1";//@"server1";

//static NSString * const kXMPPwmDomain = @"www.meng.co.in";


///app setting
///应用的appid
static NSString * const kAPPID=@"488033535";

///xmpp通知
static NSString * const kXMPPNotificationDidAuthen = @"kXMPPNotificationDidAuthen";
static NSString * const kXMPPNotificationDidSendMessage=@"kXMPPNotificationDidSendMessage";
static NSString * const KXMPPNotificationDidReceiveMessage=@"KXMPPNotificationDidReceiveMessage";

static NSString * const kXMPPNotificationDidReceivePresence=@"kXMPPNotificationDidReceivePresence";

static NSString * const kXMPPNotificationDidAskFriend=@"kXMPPNotificationDidAskFriend";


//其他通知
///音乐参数
static NSString * const kMusicLocalSetting = @"kMusicLocalSetting";
static NSString * const kMusicLocalKey = @"kMusicLocalKey";

///setting
static NSString * const kSettingBugLink = @"http://www.dreamore.com/projects/12606.html";

static NSString * const kSettingUmeng = @"5319cc6956240b080f02958c";

///刷新顶部状态
static NSString * const kNotificationTop = @"kNotificationTop";

///蓝牙断开
static NSString * const kNotificationDisConnect = @"kNotificationDisConnect";
#endif