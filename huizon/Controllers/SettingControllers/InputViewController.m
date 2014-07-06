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
    
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"编辑"];
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
        
        showCustomAlertMessage(_S(@"不得超过%d个",self.numberOfword));
        return;
        
    }
   
    BlockCallWithOneArg(self.saveHandler, self.tfModify.text);
    
    [self backAction];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
