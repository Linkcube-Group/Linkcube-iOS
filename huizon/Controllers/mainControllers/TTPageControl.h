//
//  TTPageControl.h
//  CustomUIKit
//
//  Created by Ma Jianglin on 11-6-27.
//  Copyright 2011 Totem. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TTPageControl : UIPageControl
{
	UIImage *imageNormal;
	UIImage *imageCurrent;
}

@property (nonatomic, readwrite, strong) UIImage *imageNormal;
@property (nonatomic, readwrite, strong) UIImage *imageCurrent;

@end