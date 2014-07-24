//
//  UserEditController.m
//  huizon
//
//  Created by yang Eric on 6/15/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "UserEditController.h"
#import "XMPPvCardTemp.h"
#import "XMPPvCardTempModule.h"

@interface UserEditController ()<UITextFieldDelegate>

@property (strong,nonatomic) IBOutlet UIDatePicker   *pickerView;
@property (strong,nonatomic) IBOutlet UIButton *btnMale;
@property (strong,nonatomic) IBOutlet UIButton *btnFemale;

@property (strong,nonatomic) IBOutlet UITextField *tfName;
@property (strong,nonatomic) IBOutlet UITextField *tfDate;

@property (strong,nonatomic) IBOutlet UIView    *bgView;
@end

@implementation UserEditController

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
    self.pickerView.maximumDate = [NSDate date];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didFinishUpload:) name:kXMPPvCardTempElement object:nil];
    // Do any additional setup after loading the view from its nib.
}

- (void)didFinishUpload:(NSNotification *)noti
{
    XMPPvCardTemp *myvCard=[theApp.xmppvCardTempModule myvCardTemp];

    int  state = [[noti object] intValue];
    if (state==1){
        if(StringNotNullAndEmpty(myvCard.nickname)) {
            showCustomAlertMessage(@"保存成功");
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
    else{
        showCustomAlertMessage(@"服务器错误，保存失败，请重试");
    }
    showFullScreen(NO);
    showIndicator(NO);
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"填写资料"];
    self.navigationItem.rightBarButtonItem = [[Theam currentTheam] navigationBarRightButtonItemWithImage:nil Title:@"提交" Target:self Selector:@selector(saveAction:)];
    
}

- (void)saveAction:(id)sender
{
    if (StringIsNullOrEmpty(self.tfName.text)) {
        showCustomAlertMessage(@"请输入昵称");
        return;
    }
    
    if (StringIsNullOrEmpty(self.tfDate.text)) {
        showCustomAlertMessage(@"请选择出生日期");
        return;
    }
    
    NSString *nickname=[self.tfName.text trimString];
    theApp.xmppvCardUser.nickname = nickname;
 
    if (self.btnMale.selected) {
        theApp.xmppvCardUser.gender = @"男";
    }
    else{
        theApp.xmppvCardUser.gender = @"女";
    }
    
    theApp.xmppvCardUser.birthday=self.tfDate.text;
    
    showFullScreen(YES);
    showIndicator(YES);
    [theApp updateUserCardTemp:theApp.xmppvCardUser];
    

    
    
    //add user nick and email
    NSString *uname = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyJID];
    NSString *pwd = [[NSUserDefaults standardUserDefaults]objectForKey:kXMPPmyPassword];
    NSString *unameOri =[uname stringByReplacingOccurrencesOfString:@"-" withString:@"@"];
    NSXMLElement *query = [NSXMLElement elementWithName:@"query" xmlns:@"jabber:iq:register"];
    NSXMLElement *iq = [NSXMLElement elementWithName:@"iq"];
    [iq addAttributeWithName:@"type" stringValue:@"set"];
    [iq addAttributeWithName:@"to" stringValue:[NSString stringWithFormat:@"%@@%@",uname,kXMPPmyDomain]];
    [iq addAttributeWithName:@"id" stringValue:@"change1"];
    
    
    DDXMLNode *username=[DDXMLNode elementWithName:@"username" stringValue:uname];
    DDXMLNode *password=[DDXMLNode elementWithName:@"password" stringValue:pwd];
    DDXMLNode *nick=[DDXMLNode elementWithName:@"name" stringValue:nickname];
    DDXMLNode *email=[DDXMLNode elementWithName:@"email" stringValue:unameOri];

    [query addChild:username];
    [query addChild:password];
    [query addChild:nick];
    [query addChild:email];
    [iq addChild:query];
    [[theApp xmppStream] sendElement:iq];

}


#pragma mark -
#pragma mark Delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField==self.tfDate) {
        [self.tfName resignFirstResponder];
        [self showDatePicker:YES];
        return NO;
    }
    return YES;
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.tfName resignFirstResponder];
    return YES;
}

- (void)showDatePicker:(BOOL)flag
{
    if (flag) {
        [UIView animateWithDuration:0.2 animations:^{
            self.bgView.originY = 0;
        }];
    }
    else{
        [UIView animateWithDuration:0.2 animations:^{
            self.bgView.originY = theApp.window.frame.size.height;
        }];
    }
    
}

- (IBAction)finishAction:(id)sender
{
    NSDate *selected = [self.pickerView date];
    
    self.tfDate.text = [selected stringDateWithFormat:@"yyyy-MM-dd"];
    [self showDatePicker:NO];
}

- (IBAction)genderAction:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if (btn.tag==1) {//male
        self.btnMale.selected = YES;
        self.btnFemale.selected = NO;
    }
    else{
        self.btnFemale.selected = YES;
        self.btnMale.selected = NO;
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
