//
//  ProtocolViewController.m
//  huizon
//
//  Created by meng on 3/13/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "ProtocolViewController.h"

@interface ProtocolViewController ()

@end

@implementation ProtocolViewController

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
    NSURLRequest *request=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [self.webView loadRequest:request];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
