//
//  PostureView.h
//  huizon
//
//  Created by yang Eric on 3/2/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface PostureView : UIView

@property (nonatomic,assign) id _delegate;

- (id)initWithFrame:(CGRect)frame PatternType:(PatternState)type;
@end
