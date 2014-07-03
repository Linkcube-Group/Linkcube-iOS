//
//  TTPageControl.m
//  CustomUIKit
//
//  Created by Ma Jianglin on 11-6-27.
//  Copyright 2011 Totem. All rights reserved.
//

#import "TTPageControl.h"


@interface TTPageControl (Private)
- (void) updateDots;
@end


@implementation TTPageControl

@synthesize imageNormal;
@synthesize imageCurrent;

/** override to update dots */
- (void) setCurrentPage:(NSInteger)currentPage
{
	[super setCurrentPage:currentPage];
	
	// update dot views
	[self updateDots];
}

/** override to update dots */
- (void) updateCurrentPageDisplay
{
	[super updateCurrentPageDisplay];
	
	// update dot views
	[self updateDots];
}

/** Override setImageNormal */
//- (void) setImageNormal:(UIImage*)image
//{
//	// update dot views
//	[self updateDots];
//}
//
///** Override setImageCurrent */
//- (void) setImageCurrent:(UIImage*)image
//{
//	// update dot views
//	[self updateDots];
//}

/** Override to fix when dots are directly clicked */
- (void) endTrackingWithTouch:(UITouch*)touch withEvent:(UIEvent*)event 
{
	[super endTrackingWithTouch:touch withEvent:event];
	
	[self updateDots];
}




/** Override to fix calculation of optimal size */
- (CGSize)sizeForNumberOfPages:(NSInteger)pageCount
{
	CGSize size = CGSizeMake((imageCurrent.size.width * pageCount) + (10.0f * (pageCount - 1)), 36.0f);
	return size;
}

#pragma mark – (Private)
- (void) updateDots
{
	if(imageCurrent || imageNormal)
	{
		// Get subviews
		NSArray* dotViews = self.subviews;
		for(int i = 0; i < dotViews.count; ++i)
		{
            
            if ([[dotViews objectAtIndex:i] isKindOfClass:[UIImageView class]]) {
                UIImageView* dot = (UIImageView *)[dotViews objectAtIndex:i];
                // Set image
                dot.image = (i == self.currentPage) ? imageCurrent : imageNormal;
             //   dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, imageNormal.size.width, imageNormal.size.height);
            }
			else if ([[dotViews objectAtIndex:i] isKindOfClass:[UIView class]]){
                UIView *dot = (UIView *)[dotViews objectAtIndex:i];
                dot.backgroundColor = [UIColor clearColor];
                UIImage *temp = (i == self.currentPage) ? imageCurrent : imageNormal;
                [dot.layer setContents:(id)[temp CGImage]];
             //   dot.frame = CGRectMake(dot.frame.origin.x, dot.frame.origin.y, imageNormal.size.width, imageNormal.size.height);
            }
		}
	}
	
}

@end
