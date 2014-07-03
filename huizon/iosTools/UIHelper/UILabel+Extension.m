//
//  UILabel+Extension.m
//  iTrends
//
//  Created by wujin on 12-6-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "UILabel+Extension.h"
#import "UIFont+Extension.h"
#import "NSString+Extension.h"

@implementation UILabel (Extension)


//将此文本标签垂直居中
-(void)verticalAlignmentCerter
{
    CGFloat height=[NSString heightForString:self.text Size:CGSizeMake(self.frame.size.width, 333333) Font:self.font Lines:self.numberOfLines].size.height;
    self.frame=CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

-(void)verticalAlignmentTop
{
    CGFloat height=[NSString heightForString:self.text Size:CGSizeMake(self.frame.size.width, 333333) Font:self.font Lines:self.numberOfLines].size.height;
    CGRect rect=self.frame;
    if (rect.size.height>height) {
        rect.size.height=height;
    }
    self.frame=rect;
}

-(void)verticalAlignmentBottom
{
    CGFloat height=[NSString heightForString:self.text Size:CGSizeMake(self.frame.size.width, 333333) Font:self.font Lines:self.numberOfLines].size.height;
    CGRect rect=self.frame;
    if (rect.size.height>height) {
        rect.origin.y+=(rect.size.height-height);
        rect.size.height=height;
    }
    self.frame=rect;
}
@end
