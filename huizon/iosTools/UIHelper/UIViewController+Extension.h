//
//  KNSemiModalViewController.h
//  KNSemiModalViewController
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//


@interface UIViewController (Extension)

/**
 用于推出视图的导航
 */
-(IBAction)btBack_PopNav:(id)sender;
/**
 用于消除模态视图的导航
 */
-(IBAction)btBack_DisModal:(id)sender;
/**
 执行自定义过程的导航
 */
-(IBAction)btBack_Block:(dispatch_block_t)block;

/**
 取消当前控制器中所有的异步图片下载
 
 此方法会遍历所有的子视图（递归遍历）
 */
-(void)cancelCurrentAllImageDownload;
@end