//
//  KNSemiModalViewController.m
//  KNSemiModalViewController
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UILabel+Extension.h"
#import "UIColor+Extension.h"
#import "UIImage+Extension.h"
#import "UIFont+Extension.h"
#import "UIView+Extension.h"
#import "UIViewController+Extension.h"

@implementation UIViewController (Extension)

/**
 用于推出视图的导航
 */
-(IBAction)btBack_PopNav:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
/**
 用于消除模态视图的导航
 */
-(IBAction)btBack_DisModal:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}
/**
 执行自定义过程的导航
 */
-(IBAction)btBack_Block:(dispatch_block_t)block
{
    block();
}

/**
 取消当前控制器中所有的异步图片下载
 
 此方法会遍历所有的子视图（递归遍历）
 */
-(void)cancelCurrentAllImageDownload
{
    [UIView cancelSubviewImageDownloadinView:self.view];
}
@end
