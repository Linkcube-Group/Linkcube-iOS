//
//  TopControlView.m
//  huizon
//
//  Created by yang Eric on 6/8/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "TopControlView.h"
#import "JASidePanelController.h"
#import "XMPPvCardTemp.h"
#import "XMPPvCardTempModule.h"

#import "UserViewController.h"

@interface TopControlView()
@property (strong,nonatomic) IBOutlet UIButton *btnMenu;
@property (strong,nonatomic) IBOutlet UIButton *btnHead;
@property (strong,nonatomic) IBOutlet UIImageView *imgTool;

@property (strong,nonatomic) IBOutlet UIButton *btnStatus;

@end

@implementation TopControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.btnHead = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnHead.frame = CGRectMake(267, 5, 34, 34);
        self.btnHead.backgroundColor = [UIColor whiteColor];
        [self.btnHead setImage:[UIImage imageNamed:@"navigation-unknown"] forState:UIControlStateNormal];
        self.btnHead.layer.cornerRadius = 17;
        self.btnHead.layer.masksToBounds = YES;
        [self addSubview:self.btnHead];
        
    }
    return self;
}

- (void)refreshTitleName
{
    if ([theApp isXmppAuthenticated]) {
        [theApp getUserCardTemp];
        if (theApp.xmppvCardUser && StringNotNullAndEmpty(theApp.xmppvCardUser.nickname)) {
            [self.btnStatus setTitle:theApp.xmppvCardUser.nickname forState:UIControlStateNormal];
            [self.btnHead setImage:[[UIImage alloc] initWithData:theApp.xmppvCardUser.photo] forState:UIControlStateNormal];
        }
    }
    else{//not login
        [self.btnStatus setTitle:@"请登录" forState:UIControlStateNormal];
        [self.btnHead setImage:[UIImage imageNamed:@"navigation-unknown"] forState:UIControlStateNormal];
    }
       
    if(theApp.blueConnType==1){
        self.imgTool.hidden = NO;
        self.imgTool.image = IMG(@"icon-mars.png");
    }
    else if (theApp.blueConnType==2){
        self.imgTool.hidden = NO;
        self.imgTool.image = IMG(@"icon-venus.png");
    }
    else{
        self.imgTool.hidden = YES;
    }
    
}

- (IBAction)menuAction:(id)sender
{
    [theApp.sidePanelController showLeftPanelAnimated:YES];
}

- (IBAction)userAction:(id)sender
{
    if ([theApp isXmppAuthenticated]==NO) {
        UserViewController *uvc = [[UserViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:uvc];
        [self.baseController presentViewController:nav animated:YES completion:nil];
    }
    else{
        [theApp.sidePanelController showRightPanelAnimated:YES];
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
