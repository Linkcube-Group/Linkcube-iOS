//
//  CustomAlartView.h
//  Star
//
//  Created by Han Jin on 11-7-28.
//  Copyright 2011年 e-linkway.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomAlertView : UIView 
{
    UILabel *_titleLabel;
}
@property (nonatomic, readonly) UILabel *titleLabel;

- (void)hideView;
@end
