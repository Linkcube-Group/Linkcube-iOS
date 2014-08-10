//
//  ChatViewManager.h
//  huizon
//
//  Created by yuyang on 14-8-11.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>

//几种键盘
typedef enum {
    chatKeyboardTypeNormal = 0,    //不弹出任何键盘
    chatKeyboardTypeKeyboard,      //弹出正常键盘
    chatKeyboardTypeApply,         //发起游戏按钮键盘和等待游戏
    chatKeyboardTypeYesNo,         //拒绝接受按钮键盘
    chatKeyboardTypeGameKind,      //游戏种类键盘
    chatKeyboardTypeFaces,         //表情键盘
    chatKeyboardTypeFunction,      //其他功能键盘 如视频，图片，语音及时聊天，视频聊天等
    chatKeyboardTypeOther          //其他
}ChatKeyboardType;

//输入框类型
typedef enum {
    inputTextViewTypeText = 0,    //文字
    inputTextViewTypeSpeech,      //语音
    inputTextViewTypeGame,        //游戏
    inputTextViewTypeOther,       //其他
}InputTextViewType;

@interface ChatViewManager : NSObject

@property(nonatomic)ChatKeyboardType chatKeyboardType;           //键盘类型
@property(nonatomic)InputTextViewType inputTextViewType;         //输入框类型
@property(nonatomic)BOOL isWaitingReply;                           //正在等待答复
@property(nonatomic)BOOL isGamePlaying;                            //正在游戏中
@property(nonatomic,strong)UIImage * avatarOfMe;                   //自己的头像
@property(nonatomic,strong)UIImage * avatarOfOther;                //对方头像

+(ChatViewManager *)defaultManager;        //单例
-(void)clearData;                          //清空数据

@end
