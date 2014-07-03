//
//  PostureScrollView.h
//  huizon
//
//  Created by yang Eric on 3/1/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PostureDelegate <NSObject>

- (void)viewScrollToPage:(int)index;

- (void)patternCommand:(NSString *)command;

@end

@class TTPageControl;

@interface PostureScrollView : UIView<UIScrollViewDelegate>
{
    BOOL pageControlUsed;
    UIScrollView    *scrollControl;
    TTPageControl *_pageControl;
    __unsafe_unretained id<PostureDelegate> _delegate;
}
@property (nonatomic,assign) id<PostureDelegate> _delegate;
//@property (nonatomic,assign) responseHandler scrollHandler;

- (id)initWithFrame:(CGRect)frame Count:(int)count;
- (void)beginPosture;
@end
