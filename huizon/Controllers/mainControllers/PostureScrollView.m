//
//  PostureScrollView.m
//  huizon
//
//  Created by yang Eric on 3/1/14.
//  Copyright (c) 2014 zhaopin. All rights reserved.
//

#import "PostureScrollView.h"
#import "TTPageControl.h"
#import "PostureView.h"

@implementation PostureScrollView
@synthesize _delegate;

- (id)initWithFrame:(CGRect)frame Count:(int)count
{
    self = [super initWithFrame:frame];
    if (self)
    {
        scrollControl = [[UIScrollView alloc] initWithFrame:self.bounds];
        scrollControl.pagingEnabled = YES;
        scrollControl.delegate = self;
        scrollControl.showsVerticalScrollIndicator = NO;
        [self addSubview:scrollControl];
        
        scrollControl.contentSize = CGSizeMake(305*count, 0);
        
        _pageControl = [[TTPageControl alloc] initWithFrame:CGRectMake(30, frame.size.height-10, 260, 10)];

        _pageControl.imageNormal = [UIImage imageNamed:@"dot.png"];
        _pageControl.imageCurrent = [UIImage imageNamed:@"dot_s.png"];
        _pageControl.numberOfPages = count;
        _pageControl.currentPage = 0;
        [self addSubview:_pageControl];
    }
    return self;
}

- (void)beginPosture
{
    if ([scrollControl viewWithTag:kPageTag]==nil) {
        UIView *tempView = [self postureView:0];
        [scrollControl addSubview:tempView];
    }
    if(self._delegate && [self._delegate respondsToSelector:@selector(viewScrollToPage:)]){
        [self._delegate viewScrollToPage:0];
    }
}

- (UIView *)postureView:(int)page
{
    __autoreleasing UIView *pageView = [[UIView alloc] initWithFrame:CGRectMake(15+page*(290+5), 0, 290, 200)];
    pageView.tag = page+kPageTag;
    pageView.backgroundColor = [UIColor clearColor];
    UIView *bgView = [[UIView alloc] initWithFrame:pageView.bounds];
    bgView.backgroundColor = [UIColor whiteColor];
    bgView.alpha = 0.5;
    [pageView addSubview:bgView];
    
    PostureView *postView = [[PostureView alloc] initWithFrame:CGRectMake(45, 0, 200, 200) PatternType:page];
    postView._delegate = self._delegate;
    [pageView addSubview:postView];
  

    return pageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _pageControl.currentPage = page;
    
    if ([scrollControl viewWithTag:page+kPageTag]==nil) {
        UIView *tempView = [self postureView:page];
        [scrollControl addSubview:tempView];
    }
    
    
    if(self._delegate && [self._delegate respondsToSelector:@selector(viewScrollToPage:)]){
        [self._delegate viewScrollToPage:page];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

- (void)dealloc
{
    _delegate = nil;
}

@end
