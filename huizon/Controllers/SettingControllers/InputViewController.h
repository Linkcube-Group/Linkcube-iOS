//
//  InputViewController.h
//  huizon
//
//  Created by yang Eric on 7/6/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputViewController : UIViewController


@property (nonatomic,copy) EventHandler saveHandler;

@property (nonatomic, strong) NSString * modifyStr;
@property (nonatomic) int numberOfword;
@property (strong, nonatomic) UITextField *tfModify;
@property (nonatomic, strong) NSString * NavTitle;
@property (nonatomic) BOOL isNickNamePush;


@end
