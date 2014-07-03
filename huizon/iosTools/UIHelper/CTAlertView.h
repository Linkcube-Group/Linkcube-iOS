//
//  CTAlertView.h
//  huizon
//
//  Created by Yang on 13-11-8.
//  Copyright (c) 2013年 zhaopin. All rights reserved.
//

#import <Foundation/Foundation.h>


//使用标题和消息显示一个AlertView
#define AlertShowWithTitleAndMessage(title,msg) [CTAlertView AlertShow:title message:msg]
//使用指定消息显示一个AlertView
#define AlertShowWithMessage(msg) [CTAlertView AlertShow:msg]

#define kMessageOkButtonTitle @"确认"

typedef     void (^ClickButtonAtIndex)(UIAlertView* alert,int index);

@interface CTAlertView : UIAlertView<UIAlertViewDelegate>
{
    __block int index;
}

@property (nonatomic,copy) ClickButtonAtIndex clickButtonAtIndex;
//使用块语句初始化一个alertView
-(id)initWithTitle:(NSString *)title message:(NSString *)message DelegateBlock:(void(^)(UIAlertView *alert,int index))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles;

+(void)AlertShow:(NSString*)title message:(NSString *)message DelegateBlock:(void(^)(UIAlertView *alert,int index))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles;

+(void)AlertShow:(NSString*)message;

+(void)AlertShow:(NSString*)title message:(NSString*)message;

+(void)AlertShow:(NSString *)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle;

+(void)AlertShow:(NSString *)title message:(NSString*)message cancelButtonTitle:(NSString*)cancelButtonTitle otherButtonTitle:(NSString*)otherButtonTitle;

@end