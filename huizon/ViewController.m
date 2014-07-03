//
//  ViewController.m
//  huizon
//
//  Created by Yang on 13-11-7.
//  Copyright (c) 2013年 zhaopin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize mainController,chatController;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.mainController = [[MainViewController alloc] init];
    UINavigationController *naviMain = [[UINavigationController alloc] initWithRootViewController:self.mainController];
    [naviMain setNavigationBarHidden:YES];
    
    self.chatController  = [[ChatViewController alloc] init];
    UINavigationController *naviFri = [[UINavigationController alloc] initWithRootViewController:self.chatController];
    [naviFri setNavigationBarHidden:YES];
   
    NSArray *viewControllers = [NSArray arrayWithObjects:naviMain,naviFri, nil];
    self.viewControllers = viewControllers;
    
    customTabBar =  [[CustomTabbar alloc] initWithCustom:CGRectMake(0, 0, theApp.window.bounds.size.width, 45)
                                              imageNames:[NSArray arrayWithObjects:@"tab_main",@"tab_friend",nil]
												  titles:[NSArray arrayWithObjects:@"main",@"friend",nil]];
	customTabBar.delegate = self;
    [self.tabBar addSubview:customTabBar];
    
    [self tabbarDidSelectIndex:0];
    
	// Do any additional setup after loading the view, typically from a nib.
}


#pragma mark -
#pragma mark TabBarDelegate
- (void) tabbarDidSelectIndex:(int)index
{
    UINavigationController *nav = [self.viewControllers objectAtIndex:index];
    if (nav) {
        [nav popToRootViewControllerAnimated:NO];
    }
    [customTabBar setIndex:index];
}

- (void)didSelectedIndex:(int)index
{
	self.selectedIndex = index;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
