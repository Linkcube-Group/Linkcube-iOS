//
//  ChangePwdController.m
//  huizon
//
//  Created by yang Eric on 3/11/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "ChangePwdController.h"

@interface ChangePwdController ()
{
    IBOutlet UITextField  *textOldPwd;
    IBOutlet UITextField  *textNewPwd;
    IBOutlet UITextField  *textNewPwd2;
}
@end

@implementation ChangePwdController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"修改密码"];
     self.navigationItem.rightBarButtonItem=[[Theam currentTheam] navigationBarRightButtonItemWithImage:Nil Title:@"确定" Target:self Selector:@selector(btnCommitTap:)];
    
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(backAction:)];
}

#pragma mark -
#pragma mark Action
- (void)btnCommitTap:(id)sender
{
    if (StringIsNullOrEmpty(textOldPwd.text)) {
        showCustomAlertMessage(@"旧密码不能为空");
        return;
    }
    if (StringIsNullOrEmpty(textNewPwd.text)) {
        showCustomAlertMessage(@"新密码不能为空");
        return;
    }
    if (StringIsNullOrEmpty(textNewPwd2.text)) {
        showCustomAlertMessage(@"确认密码不能为空");
        return;
    }
    if (![textNewPwd2.text isEqualToString:textNewPwd.text]) {
        showCustomAlertMessage(@"两次输入的密码不同");
        return;
    }
    
    if (![textOldPwd.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:kXMPPmyPassword]]) {
        showCustomAlertMessage(@"您的旧密码不正确");
        return;
    }
    
    NSString *pwd = IsValidPWD([textNewPwd.text UTF8String]);
    if (pwd==nil) {
        if([textNewPwd.text length]<6 || [textNewPwd.text length]>25)
        {
            showCustomAlertMessage(@"密码格式错误，请输入6-25位字母、数字、下划线");
            return;
        }
	}else{
		showCustomAlertMessage(pwd);
		return;
	}
    
    [theApp changePassword:textNewPwd.text];
    [self backAction:nil];
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

@end
