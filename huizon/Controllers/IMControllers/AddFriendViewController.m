//
//  AddFriendViewController.m
//  huizon
//
//  Created by Meng Wang on 14-6-22.
//  Copyright (c) 2014年 zhaopin. All rights reserved.
//

#import "AddFriendViewController.h"

@interface AddFriendViewController ()
{
    IBOutlet UITextField *txtSearch;
    IBOutlet UITableView *tbResult;
}

@end

@implementation AddFriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationItem.titleView=[[Theam currentTheam] navigationTitleViewWithTitle:@"添加情侣"];
    self.navigationItem.leftBarButtonItem=[[Theam currentTheam] navigationBarButtonBackItemWithTarget:self Selector:@selector(btBack_DisModal:)];
    
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





-(IBAction)textFieldDoneEditing:(id)sender
{
    [sender resignFirstResponder];
    NSString *name=txtSearch.text;
    name =[name stringByReplacingOccurrencesOfString:@"@" withString:@"-"];
    NSString *requestText=[NSString stringWithFormat:@"%@%@%@",@"已向",txtSearch.text,@"发出请求"];
    [theApp XMPPAddFriendSubscribe:name];
    [theApp showAlertView:requestText];
}

@end
