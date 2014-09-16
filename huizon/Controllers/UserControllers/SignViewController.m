//
//  SignViewController.m
//  huizon
//
//  Created by yang Eric on 3/2/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "SignViewController.h"
#import "Reachability.h"
#import "ProtocolViewController.h"
#import "UserEditController.h"
#import "ProtocolViewController.h"
@interface SignViewController ()<UITextFieldDelegate>
{
    
}

@property (strong, nonatomic) IBOutlet UITextField *mail;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) IBOutlet UITextField *confirmPassword;

@end

@implementation SignViewController

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
    
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"LINKCUBE"];
    self.navigationItem.leftBarButtonItem = [[Theam currentTheam] navigationBarLeftButtonItemWithImage:IMG(@"close_btn.png") Title:nil Target:self Selector:@selector(btBack_DisModal:)];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    if ([theApp isXmppAuthenticated]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark -
#pragma mark Action
- (IBAction)signAction:(id)sender
{

    NSString *pwd = self.password.text;
    NSString *cpwd = self.confirmPassword.text;
    NSString *mail = self.mail.text;

     //check email format
     if([mail componentsSeparatedByString:@"@"].count != 2)
     {
         showCustomAlertMessage(@"请输入正确格式的邮箱");
         return;
     }
    
     //check length of password
     if(pwd.length<6||pwd.length>14)
     {
         showCustomAlertMessage(@"密码必须由6-14个字符组成");
         return;
     }
     
     //check password and confirm password
     if(![pwd isEqualToString:cpwd])
     {
         showCustomAlertMessage(@"两次输入的密码不一致");
         return;
     }
    
    UserEditController *uvc = [[UserEditController alloc] init];
    uvc.email = mail;
    uvc.password = pwd;
    [self.navigationController pushViewController:uvc animated:YES];
    
//    showIndicator(YES);
//    mail =[mail stringByReplacingOccurrencesOfString:@"@" withString:@"-"];
//    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:pwd,@"pwd",mail,@"lid", nil];
//    [theApp beginRegister:dict];
}

- (IBAction)loginAction:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)textFieldReturnEditing:(id)sender
{
    [sender resignFirstResponder];
}
- (IBAction)showProtocol:(id)sender
{
    ProtocolViewController *protocolViewController=[[ProtocolViewController alloc]init];
    
    [self.navigationController pushViewController:protocolViewController animated:YES];
    
}
-(BOOL)isValidEmail:(NSString*) email
{
    NSString *emailRegex=@"[A-Z0-9a-z._%+-]+@[A-Z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest=[NSPredicate predicateWithFormat:@"SELF MATCHES%@",emailRegex];
    return [emailTest evaluateWithObject:email];
}
-(BOOL)isValidNickname:(NSString*)nickname
{
    NSString *nameRegex=@"[A-Za-z0-9_\u4e00-\u9fa5_]{4,10}";
    NSPredicate *nameTest=[NSPredicate predicateWithFormat:@"SELF MATCHES%@",nameRegex];
    return [nameTest evaluateWithObject:nickname];
}

-(void) backToIndex
{
    [self dismissViewControllerAnimated:NO completion:nil];
//    self.navigationController.navigationBar.hidden=YES;
//    int count = [self.navigationController.viewControllers count];
//    if (count>3) {
//        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:count-3] animated:YES];
//    }
//    else{
//        [self.navigationController popToRootViewControllerAnimated:YES];
//    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)helpAction:(id)sender
{
    ProtocolViewController *pvc = [[ProtocolViewController alloc] init];
    pvc.url = @"http://www.linkcube.me/license.html";
    [self.navigationController pushViewController:pvc animated:YES];
}

- (void)dealloc
{
    showIndicator(NO);
}


@end
