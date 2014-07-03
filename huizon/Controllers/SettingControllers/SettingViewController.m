//
//  SettingViewController.m
//  huizon
//
//  Created by yang Eric on 3/11/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "SettingViewController.h"
#import "PersonSettingController.h"
#import "IntroductViewController.h"
#import "UMFeedbackViewController.h"

#import "UserViewController.h"

@interface SettingViewController ()
{
    IBOutlet UIButton   *btnLogin;
}

@property (strong,nonatomic) IBOutlet UILabel *testLabel;
@end

@implementation SettingViewController



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //    self.testLabel.backgroundColor = [UIColor redColor];
    
    // Do any additional setup after loading the view from its nib.
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if ([theApp isXmppAuthenticated]) {
        [btnLogin setBackgroundImage:IMG(@"red_button") forState:UIControlStateNormal];
        [btnLogin setBackgroundImage:IMG(@"red_button_s") forState:UIControlStateHighlighted];
        [btnLogin setTitle:@"退  出" forState:UIControlStateNormal];
    }
    else{//not login
        [btnLogin setBackgroundImage:IMG(@"blue_button") forState:UIControlStateNormal];
        [btnLogin setBackgroundImage:IMG(@"blue_button_s") forState:UIControlStateHighlighted];
        [btnLogin setTitle:@"登录/注册" forState:UIControlStateNormal];
    }
    
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"设置"];
//    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(backAction:)];
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Action
- (IBAction)markAction:(id)sender
{
    NSString *markurl=_S(@"itms-apps://ax.itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@",kAPPID);
    if (isIOS7) {
        markurl=_S(@"itms-apps://itunes.apple.com/app/id%@",kAPPID);
    }
    [[UIApplication sharedApplication] openURL:URL(markurl)];
}
- (IBAction)updateAction:(id)sender
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    if (![version isEqualToString:@"1.0"]) {
        CTAlertView *alert = [[CTAlertView alloc] initWithTitle:nil message:@"现在有最新的版本，马上去更新" DelegateBlock:^(UIAlertView *alert, int index) {
            if (index==1) {
                [[UIApplication sharedApplication] openURL:URL(_S(@"itms-apps://itunes.apple.com/app/id%@",kAPPID))];
            }
        } cancelButtonTitle:@"以后再说" otherButtonTitles:@"立即更新"];
        [alert show];
    }
    else{
        showCustomAlertMessage(@"已经是最新版本了");
    }
}

- (IBAction)personAction:(id)sender
{
    if ([theApp isXmppAuthenticated]){
        PersonSettingController *pvc = [[PersonSettingController alloc] init];
        [self.navigationController pushViewController:pvc animated:YES];
    }
    else{
        showCustomAlertMessage(@"请您先登录");
    }
}

- (IBAction)buyAction:(id)sender
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:kSettingBugLink]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kSettingBugLink]];
    }
}

- (IBAction)guideAction:(id)sender
{
    IntroductViewController *ivc = [[IntroductViewController alloc] init];
    [self.navigationController pushViewController:ivc animated:YES];
}

- (IBAction)suggestAction:(id)sender
{
    UMFeedbackViewController *controller = [[UMFeedbackViewController alloc] initWithNibName:nil bundle:nil];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)loginAction:(id)sender
{
    if ([theApp isXmppAuthenticated]) {
        [theApp logouXmppAuthenticated];
        [btnLogin setBackgroundImage:IMG(@"blue_button") forState:UIControlStateNormal];
        [btnLogin setBackgroundImage:IMG(@"blue_button_s") forState:UIControlStateHighlighted];
        [btnLogin setTitle:@"登录/注册" forState:UIControlStateNormal];
    }
    else{
        UserViewController *uvc = [[UserViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:uvc];
        [self presentViewController:nav animated:YES completion:nil];
    }
}
@end
