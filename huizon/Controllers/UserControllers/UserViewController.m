//
//  UserViewController.m
//  huizon
//
//  Created by Yang on 14-2-26.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "UserViewController.h"
#import "SignViewController.h"
#import "UserEditController.h"
#import "JASidePanelController.h"

@interface UserViewController ()<UITextFieldDelegate>

@property (strong,nonatomic) IBOutlet  UITextField *txtName;
@property (strong,nonatomic) IBOutlet  UITextField *txtPwd;
@end

@implementation UserViewController

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
    if (isIOS7) {
        [[UINavigationBar appearance] setBackgroundImage:IMG(@"bg_title_2.png") forBarMetrics:UIBarMetricsDefault];
    }else{
        [[UINavigationBar appearance] setBackgroundImage:IMG(@"bg_title.png") forBarMetrics:UIBarMetricsDefault];
    }
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didLoginAuthen:) name:kXMPPNotificationDidAuthen object:nil];
   
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"LINKCUBE"];

    self.navigationItem.leftBarButtonItem = [[Theam currentTheam] navigationBarLeftButtonItemWithImage:IMG(@"close_btn.png") Title:nil Target:self Selector:@selector(btBack_DisModal:)];
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([theApp isXmppAuthenticated]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didLoginAuthen:(NSNotification *)noti
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UserEditController *uvc = [[UserEditController alloc] init];
    //[self presentViewController:uvc animated:YES completion:nil];
    [self.navigationController pushViewController:uvc animated:YES];

}

- (void)loadData
{
  
}

#pragma mark -
#pragma mark Action
- (IBAction)loginAction:(id)sender
{
    NSString *name = self.txtName.text;
    
    NSString *nameMsg = IsValidEmail([name UTF8String]);
    if (nameMsg!=nil) {
		showCustomAlertMessage(nameMsg);
		return;
	}
    
    name =[name stringByReplacingOccurrencesOfString:@"@" withString:@"-"];
    NSString *pwd = self.txtPwd.text;
    
    NSString *pwdMsg = IsValidPWD([pwd UTF8String]);
    if (pwdMsg==nil) {
        if([pwd length]<6 || [pwd length]>25)
        {
            showCustomAlertMessage(@"密码长度不符合");
           // return;
        }
	}else{
		showCustomAlertMessage(pwd);
		return;
	}
    
    
    [[NSUserDefaults standardUserDefaults] setObject:name forKey:kXMPPmyJID];
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:kXMPPmyPassword];
    [theApp myConnect];
}

- (IBAction)signAction:(id)sender
{
    SignViewController *svc = [[SignViewController alloc] init];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:svc];
    [self presentViewController:nav animated:YES completion:nil];
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
    
}

-(BOOL)isValidNickname:(NSString*)nickname
{
    NSString *nameRegex=@"[A-Za-z0-9_\u4e00-\u9fa5]{4,10}";
    NSPredicate *nameTest=[NSPredicate predicateWithFormat:@"SELF MATCHES%@",nameRegex];
    return [nameTest evaluateWithObject:nickname];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
