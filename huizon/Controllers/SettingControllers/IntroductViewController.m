//
//  IntroductViewController.m
//  huizon
//
//  Created by yang Eric on 3/11/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "IntroductViewController.h"

@interface IntroductViewController ()

@property (strong,nonatomic) IBOutlet UILabel *lbVersion;
@end

@implementation IntroductViewController

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
    if (iPhone5) {
        [self.view.layer setContents:(id)[IMG(@"about_bg_2.png") CGImage]];
    }
    else{
        [self.view.layer setContents:(id)[IMG(@"about_bg.png") CGImage]];
    }
    
    self.navigationController.navigationBar.hidden = YES;

    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey];
    self.lbVersion.text = _S(@"Ver %@",version);
    self.navigationItem.hidesBackButton = YES;
    // Do any additional setup after loading the view from its nib.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = NO;
}
- (void)viewDidAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden = YES;
}

#pragma mark -
#pragma mark Action
- (IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
