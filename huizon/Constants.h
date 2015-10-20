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
//#define DEBUG_REVEL 1
//#define DEBUG_CONSOLE 1
//#define DEBUG_FILE  1
///判断是否是ios7
#define isIOS7 (DeviceSystemMajorVersion()< 7 ? NO:YES)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define HomeAudioPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/mp3/"]
#define HomeMyPath [NSHomeDirectory() stringByAppendingPathComponent:@"/Documents/my/"]

#define theApp ((AppDelegate *)[[UIApplication sharedApplication] delegate])

//收到加好友消息通知的缓存路径
#define XMPP_RECEIVE_ADDFRIEND_IQ ([NSString stringWithFormat:@"%@_receive_addFriend_IQ",theApp.xmppStream.myJID])

#define XMPP_RECEIVE_MESSAGE_COUNT [NSString stringWithFormat:@"%@_receive_message_count",theApp.xmppStream.myJID]

//最大蓝牙数50
static int const kMaxBlueToothNum = 50;

static int const kPageTag = 9011;
static int const kPageButtonTag = 8923;

static NSString *const kXMPPmyJID = @"kXMPPmyJID";
static NSString *const kXMPPmyPassword = @"kXMPPmyPassword";

static NSString * const kXMPPmyServer = @"115.29.175.17";//@"112.124.22.252";//@"115.29.175.17";

static NSString * const kXMPPmyDomain = @"lcserver";//@"server1";

//static NSString * const kXMPPwmDomain = @"www.meng.co.in";


///app setting
///应用的appid
static NSString * const kAPPID=@"909639496";

///xmpp通知
static NSString * const kXMPPNotificationDidAuthen = @"kXMPPNotificationDidAuthen";
static NSString * const kXMPPNotificationDidSendMessage=@"kXMPPNotificationDidSendMessage";
static NSString * const KXMPPNotificationDidReceiveMessage=@"KXMPPNotificationDidReceiveMessage";

static NSString * const kXMPPNotificationDidReceivePresence=@"kXMPPNotificationDidReceivePresence";

static NSString * const kXMPPNotificationDidAskFriend=@"kXMPPNotificationDidAskFriend";


//其他通知
///音乐参数
static NSString * const kMusicLocalSetting1 = @"kMusicLocalSetting1";
static NSString * const kMusicLocalKey = @"kMusicLocalKey";

///setting
static NSString * const kSettingBugLink = @"http://www.dreamore.com/projects/12606.html";

static NSString * const kSettingUmeng = @"53d91ac6fd98c5548d00ac45";

///刷新顶部状态
static NSString * const kNotificationTop = @"kNotificationTop";

///蓝牙断开
static NSString * const kNotificationDisConnect = @"kNotificationDisConnect";

///停止蓝牙发送
static NSString * const kNotificationStopBlue = @"kNotificationStopBlue";


///准备注册的nickname
static NSString * const KSignNickName = @"KSignNickName";
static NSString * const KSignSex = @"KSignSex";
static NSString * const KSignDate = @"KSignDate";

#endif