//
//  UIGestureRecognizer+Extension.m
//  iOSShare
//
//  Created by wujin on 13-7-3.
//  Copyright (c) 2013年 wujin. All rights reserved.
//

#import "UIGestureRecognizer+Extension.h"

@implementation UIGestureRecognizer (Extension)

-(void)cancel
{
    BOOL __enable=self.enabled;
    self.enabled=NO;
    self.enabled=__enable;
}
@end
