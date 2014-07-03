//
//  ViewController.h
//  huizon
//
//  Created by Yang on 13-11-7.
//  Copyright (c) 2013年 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustomTabbar.h"
#import "MainViewController.h"
#import "ChatViewController.h"

@interface ViewController : UITabBarController<CustomTabbarDelegate>
{
    CustomTabbar            *customTabBar;
    
    MainViewController      *mainController;
    ChatViewController      *chatController;

}

@property (strong,nonatomic) MainViewController     *mainController;
@property (strong,nonatomic) ChatViewController     *chatController;


- (void) tabbarDidSelectIndex:(int)index;

@end
