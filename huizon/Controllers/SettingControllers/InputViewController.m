//
//  InputViewController.m
//  huizon
//
//  Created by yang Eric on 7/6/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "InputViewController.h"

@interface InputViewController ()<UITextFieldDelegate>

@end

@implementation InputViewController

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
    UIImageView * bgImageView = [[UIImageView alloc] init];
    bgImageView.frame = CGRectMake(-1, 110, self.view.frame.size.width + 2, 40);
    bgImageView.layer.borderWidth = 1.f;
    bgImageView.layer.borderColor = [UIColor colorWithHexString:@"c6c6c6"].CGColor;
//    bgImageView.image = [UIImage imageNamed:@"white_box.png"];
    [self.view addSubview:bgImageView];
    self.tfModify = [[UITextField alloc] init];
    self.tfModify.delegate = self;
    self.tfModify.placeholder = NSLocalizedString(@"请输入", nil);
    self.tfModify.frame = CGRectMake(10, 5, self.view.frame.size.width - 20, 30);
    [bgImageView addSubview:self.tfModify];
    [self.tfModify becomeFirstResponder];
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:NSLocalizedString(@"编辑", nil)];
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(btBack_PopNav:)];
    
    self.navigationItem.rightBarButtonItem = [[Theam currentTheam] navigationBarRightButtonItemWithImage:nil Title:@"保存" Target:self Selector:@selector(saveAction:)];
    if (StringNotNullAndEmpty(self.modifyStr)) {
        self.tfModify.text = self.modifyStr;
    }
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)backAction{
    
    [self.navigationController popViewControllerAnimated:YES];
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    
    [self saveAction:nil];
    return YES;
}


/**
 *  保存
 */
- (void)saveAction:(id)sender {
    if (self.tfModify.text.length == 0) {
        showCustomAlertMessage(@"不能为空");
        return;
    }else if(getTextLength(self.tfModify.text) > self.numberOfword){
        //这个长度判断(⊙o⊙)…
        showCustomAlertMessage(_S(@"不得超过%d个",self.numberOfword));
        return;
        
    }
   
    BlockCallWithOneArg(self.saveHandler, self.tfModify.text);
    if(_isNickNamePush)
    {
        [self synNickData];
    }
    [self backAction];
}

- (void)synNickData
{
    
    
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
    DDXMLNode *nick=[DDXMLNode elementWithName:@"name" stringValue:self.tfModify.text];
    DDXMLNode *email=[DDXMLNode elementWithName:@"email" stringValue:unameOri];
    
    [query addChild:username];
    [query addChild:password];
    [query addChild:nick];
    [query addChild:email];
    [iq addChild:query];
    [[theApp xmppStream] sendElement:iq];
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
