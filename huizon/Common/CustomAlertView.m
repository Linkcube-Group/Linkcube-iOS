//
//  CustomAlartView.m
//  Star
//
//  Created by Eric on 12-8-8.
//  Copyright 2012年 zhilian.com. All rights reserved.
//

#import "CustomAlertView.h"


@implementation CustomAlertView
@synthesize titleLabel = _titleLabel;
- (id)initWithFrame:(CGRect)frame
{
    if (self) 
    {
        self = [super initWithFrame:frame];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"alert_bg.png"]];

        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.frame.size.width - 150) / 2, (self.frame.size.height - 40) / 2, 150, 40)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_titleLabel];
    }
    
    //TLOG(@"未初始化");
    return self;
}

-(void)didMoveToSuperview
{
    // 一定要在主线程中执行这个操作，否则可能会不显示弹出框
    [self performSelectorOnMainThread: @selector(hideView) withObject: nil waitUntilDone: NO];
}

-(void) viewDidHidden
{
    [self performSelectorOnMainThread: @selector(removeFromSuperview) withObject: nil waitUntilDone: NO];
}

- (void)hideView//:(UIView *)view
{
    [UIView beginAnimations: @"alert" context:nil];
    [UIView setAnimationDelay: 1.0f];
    [UIView setAnimationDuration: 1.5f];
    self.alpha = 0;
    [UIView setAnimationDelegate: self];
    [UIView setAnimationDidStopSelector: @selector(viewDidHidden)];
    [UIView commitAnimations];
}

@end
