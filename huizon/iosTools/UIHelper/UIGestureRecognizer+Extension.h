//
//  UIGestureRecognizer+Extension.h
//  iOSShare
//
//  Created by wujin on 13-7-3.
//  Copyright (c) 2013年 wujin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIGestureRecognizer (Extension)

/**
 取消此次手势识别
 将当前手势设置为no,然后再还原为原来的状态
 */
-(void)cancel;
@end
