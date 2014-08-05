/*
 Copyright 2012 Javier Soto (ios@javisoto.es)
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "JSBadgeView.h"
#import <QuartzCore/QuartzCore.h>

#define kVersion [[[UIDevice currentDevice] systemVersion] floatValue]

#define kDefaultBadgeTextColor [UIColor whiteColor]
#define kDefaultBadgeBackgroundColor [UIColor redColor] ///[UIColor redColor]
#define kDefaultOverlayColor [UIColor colorWithWhite:1.0f alpha:0.3]

#define kDefaultBadgeTextFont [UIFont systemFontOfSize:[UIFont systemFontSize]]

#define kDefaultBadgeShadowColor [UIColor clearColor]

#define kBadgeStrokeColor [UIColor whiteColor]
#define kBadgeStrokeWidth kVersion >= 7.0 ? 0.0 : 2.0f

#define kMarginToDrawInside (kBadgeStrokeWidth * 2)

#define kShadowOffset CGSizeMake(0.0f, 3.0f)
#define kShadowOpacity 0.4f
#define kShadowColor [UIColor colorWithWhite:0.0f alpha:kShadowOpacity]
#define kShadowRadius 1.0f

#define kBadgeHeight 16.0f
#define kBadgeTextSideMargin 8.0f

#define kBadgeCornerRadius 10.0f

#define kDefaultBadgeAlignment JSBadgeViewAlignmentTopRight

@interface JSBadgeView()

- (void)_init;
- (CGSize)sizeOfTextForCurrentSettings;

@end

@implementation JSBadgeView

@synthesize badgeAlignment = _badgeAlignment;

@synthesize badgePositionAdjustment = _badgePositionAdjustment;
@synthesize frameToPositionInRelationWith = _frameToPositionInRelationWith;

@synthesize badgeText = _badgeText;
@synthesize badgeTextColor = _badgeTextColor;
@synthesize badgeTextShadowColor = _badgeTextShadowColor;
@synthesize badgeTextShadowOffset = _badgeTextShadowOffset;
@synthesize badgeTextFont = _badgeTextFont;
@synthesize badgeBackgroundColor = _badgeBackgroundColor;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self _init];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        [self _init];
    }
    
    return self;
}

- (id)initWithParentView:(UIView *)parentView alignment:(JSBadgeViewAlignment)alignment
{
    if ((self = [self initWithFrame:CGRectZero]))
    {
        self.badgeAlignment = alignment;
        [parentView addSubview:self];
        [parentView bringSubviewToFront:self];
        //中心点向内收缩5像素
        _badgePositionAdjustment = [self defaultPositionAdjustment];
    }
    
    return self;
}

- (void)_init
{
    self.backgroundColor = [UIColor clearColor];
    
    if (kVersion >= 7.0) {
        self.badgeAlignment = kDefaultBadgeAlignment;
        
        self.badgeBackgroundColor = kDefaultBadgeBackgroundColor;
        //        self.badgeOverlayColor = kDefaultOverlayColor;
        self.badgeTextColor = kDefaultBadgeTextColor;
        //        self.badgeTextShadowColor = kDefaultBadgeShadowColor;
        self.badgeTextFont = kDefaultBadgeTextFont;
        self.showBadgeShadow = NO;
    } else {
        self.badgeAlignment = kDefaultBadgeAlignment;
        
        self.badgeBackgroundColor = kDefaultBadgeBackgroundColor;
        self.badgeOverlayColor = kDefaultOverlayColor;
        self.badgeTextColor = kDefaultBadgeTextColor;
        self.badgeTextShadowColor = kDefaultBadgeShadowColor;
        self.badgeTextFont = kDefaultBadgeTextFont;
        self.showBadgeShadow = YES;
    }
    
    
    
    //显示阴影效果
    //     self.showBadgeShadow = NO;
    //    self.showBadgeShadow = YES;
    
    //禁用触控
    self.userInteractionEnabled = NO;
}

/*默认偏移量*/
- (CGPoint)defaultPositionAdjustment
{
    CGFloat l = 5.0;
    
    CGPoint positionAdjustment;
    switch (_badgeAlignment) {
        case JSBadgeViewAlignmentTopLeft:       positionAdjustment = CGPointMake(l, l);     break;
        case JSBadgeViewAlignmentTopRight:      positionAdjustment = CGPointMake(-l, l);    break;
        case JSBadgeViewAlignmentTopCenter:     positionAdjustment = CGPointMake(0.0, l);   break;
        case JSBadgeViewAlignmentCenterLeft:    positionAdjustment = CGPointMake(l, 0.0);   break;
        case JSBadgeViewAlignmentCenterRight:   positionAdjustment = CGPointMake(-l, 0.0);  break;
        case JSBadgeViewAlignmentBottomLeft:    positionAdjustment = CGPointMake(l, -l);    break;
        case JSBadgeViewAlignmentBottomRight:   positionAdjustment= CGPointMake(-l, -l);    break;
        case JSBadgeViewAlignmentBottomCenter:  positionAdjustment = CGPointMake(0.0, -l);  break;
        case JSBadgeViewAlignmentCustom:        positionAdjustment = CGPointMake(0.0, 0.0);  break;
        default:                                positionAdjustment = CGPointMake(0.0, 0.0); break;
    }
    return positionAdjustment;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    CGRect newFrame = self.frame;
    CGRect superviewFrame = CGRectIsEmpty(_frameToPositionInRelationWith) ? self.superview.frame : _frameToPositionInRelationWith;
    
    CGFloat textWidth = [self sizeOfTextForCurrentSettings].width;
    
    CGFloat viewWidth = textWidth + kBadgeTextSideMargin + (kMarginToDrawInside * 2);
    CGFloat viewHeight = self.badgeText.length ? kBadgeHeight + (kMarginToDrawInside * 2) : viewWidth;//允许绘制空字符串
    //    CGFloat viewHeight = kBadgeHeight + (kMarginToDrawInside * 2);
    
    if (kVersion >= 7.0) {
        viewWidth = textWidth + kBadgeTextSideMargin + 2.0;
        viewHeight = self.badgeText.length ? kBadgeHeight + 2.0 : viewWidth;
    }
    
    CGFloat superviewWidth = superviewFrame.size.width;
    CGFloat superviewHeight = superviewFrame.size.height;
    
    newFrame.size.width = viewWidth;
    newFrame.size.height = viewHeight;
    
    switch (self.badgeAlignment) {
        case JSBadgeViewAlignmentTopLeft:
            newFrame.origin.x = -viewWidth / 2.0f;
            newFrame.origin.y = -viewHeight / 2.0f;
            break;
        case JSBadgeViewAlignmentTopRight:
            newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = -viewHeight / 2.0f;
            break;
        case JSBadgeViewAlignmentTopCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = -viewHeight / 2.0f;
            break;
        case JSBadgeViewAlignmentCenterLeft:
            newFrame.origin.x = -viewWidth / 2.0f;
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case JSBadgeViewAlignmentCenterRight:
            newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case JSBadgeViewAlignmentBottomLeft:
            newFrame.origin.x = -textWidth / 2.0f;
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case JSBadgeViewAlignmentBottomRight:
            newFrame.origin.x = superviewWidth - (viewWidth / 2.0f);
            newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
            break;
        case JSBadgeViewAlignmentBottomCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = superviewHeight - (viewHeight / 2.0f);
            break;
        case JSBadgeViewAlignmentCenter:
            newFrame.origin.x = (superviewWidth - viewWidth) / 2.0f;
            newFrame.origin.y = (superviewHeight - viewHeight) / 2.0f;
            break;
        case JSBadgeViewAlignmentCustom:
            newFrame.origin.x = superviewWidth - viewWidth - 5;
            newFrame.origin.y = 0;
            break;
        default:
            NSAssert(NO, @"Unimplemented JSBadgeAligment type %d", self.badgeAlignment);
    }
    
    newFrame.origin.x += _badgePositionAdjustment.x;
    newFrame.origin.y += _badgePositionAdjustment.y;
    
    self.frame = CGRectIntegral(newFrame);
    
    [self setNeedsDisplay];
}

#pragma mark - Private

- (CGSize)sizeOfTextForCurrentSettings
{
    return [self.badgeText sizeWithFont:self.badgeTextFont];
}

#pragma mark - Setters

- (void)setBadgeAlignment:(JSBadgeViewAlignment)badgeAlignment
{
    if (badgeAlignment != _badgeAlignment)
    {
        _badgeAlignment = badgeAlignment;
        
        switch (badgeAlignment)
        {
            case JSBadgeViewAlignmentTopLeft:
                self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
                break;
            case JSBadgeViewAlignmentTopRight:
                self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
                break;
            case JSBadgeViewAlignmentTopCenter:
                self.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                break;
            case JSBadgeViewAlignmentCenterLeft:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
                break;
            case JSBadgeViewAlignmentCenterRight:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin;
                break;
            case JSBadgeViewAlignmentBottomLeft:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin;
                break;
            case JSBadgeViewAlignmentBottomRight:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
                break;
            case JSBadgeViewAlignmentBottomCenter:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
                break;
            case JSBadgeViewAlignmentCenter:
                self.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
                break;
            case JSBadgeViewAlignmentCustom:
                break;
            default:
                NSAssert(NO, @"Unimplemented JSBadgeAligment type %d", self.badgeAlignment);
        }
        
        //中心点向内收缩5像素
        _badgePositionAdjustment = [self defaultPositionAdjustment];
        
        [self setNeedsLayout];
    }
}

- (void)setBadgePositionAdjustment:(CGPoint)badgePositionAdjustment
{
    _badgePositionAdjustment = badgePositionAdjustment;
    
    [self setNeedsLayout];
}

- (void)setBadgeText:(NSString *)badgeText
{
    if (badgeText != _badgeText)
    {
        _badgeText = [badgeText copy];
        
        [self setNeedsLayout];
    }
}

- (void)setBadgeTextColor:(UIColor *)badgeTextColor
{
    if (badgeTextColor != _badgeTextColor)
    {
        _badgeTextColor = badgeTextColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeTextShadowColor:(UIColor *)badgeTextShadowColor
{
    if (badgeTextShadowColor != _badgeTextShadowColor)
    {
        _badgeTextShadowColor = badgeTextShadowColor;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeTextShadowOffset:(CGSize)badgeTextShadowOffset
{
    _badgeTextShadowOffset = badgeTextShadowOffset;
    
    [self setNeedsDisplay];
}

- (void)setBadgeTextFont:(UIFont *)badgeTextFont
{
    if (badgeTextFont != _badgeTextFont)
    {
        _badgeTextFont = badgeTextFont;
        
        [self setNeedsDisplay];
    }
}

- (void)setBadgeBackgroundColor:(UIColor *)badgeBackgroundColor
{
    if (badgeBackgroundColor != _badgeBackgroundColor)
    {
        _badgeBackgroundColor = badgeBackgroundColor;
        
        [self setNeedsDisplay];
    }
}

/*显示阴影效果*/
- (void)setShowBadgeShadow:(BOOL)showBadgeShadow
{
    if (_showBadgeShadow != showBadgeShadow) {
        _showBadgeShadow = showBadgeShadow;
        [self setNeedsDisplay];
    }
}

#pragma mark - Drawing

- (void)drawRect:(CGRect)rect
{
    BOOL anyTextToDraw = (self.badgeText != nil);//绘制空字符串@“”
    //    BOOL anyTextToDraw = (self.badgeText.length > 0);
    
    if (anyTextToDraw)
    {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        
        CGRect rectToDraw = CGRectInset(rect, kMarginToDrawInside, kMarginToDrawInside);
        
        UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:rectToDraw byRoundingCorners:(UIRectCorner)UIRectCornerAllCorners cornerRadii:CGSizeMake(kBadgeCornerRadius, kBadgeCornerRadius)];
        
        /* Background and shadow */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, borderPath.CGPath);
            
            CGContextSetFillColorWithColor(ctx, self.badgeBackgroundColor.CGColor);
            
            //显示阴影效果
            if (self.showBadgeShadow) {
                CGContextSetShadowWithColor(ctx, kShadowOffset, kShadowRadius, kShadowColor.CGColor);
            }
            
            CGContextDrawPath(ctx, kCGPathFill);
        }
        CGContextRestoreGState(ctx);
        
        BOOL colorForOverlayPresent = self.badgeOverlayColor && ![self.badgeOverlayColor isEqual:[UIColor clearColor]];
        
        if (colorForOverlayPresent)
        {
            /* Gradient overlay */
            CGContextSaveGState(ctx);
            {
                CGContextAddPath(ctx, borderPath.CGPath);
                CGContextClip(ctx);
                
                CGFloat height = rectToDraw.size.height;
                CGFloat width = rectToDraw.size.width;
                
                CGRect rectForOverlayCircle = CGRectMake(rectToDraw.origin.x,
                                                         rectToDraw.origin.y - ceilf(height * 0.5),
                                                         width,
                                                         height);
                
                CGContextAddEllipseInRect(ctx, rectForOverlayCircle);
                CGContextSetFillColorWithColor(ctx, self.badgeOverlayColor.CGColor);
                
                CGContextDrawPath(ctx, kCGPathFill);
            }
            CGContextRestoreGState(ctx);
        }
        
        /* Stroke */
        CGContextSaveGState(ctx);
        {
            CGContextAddPath(ctx, borderPath.CGPath);
            
            CGContextSetLineWidth(ctx, kBadgeStrokeWidth);
            CGContextSetStrokeColorWithColor(ctx, kBadgeStrokeColor.CGColor);
            
            CGContextDrawPath(ctx, kCGPathStroke);
        }
        CGContextRestoreGState(ctx);
        
        /* Text */
        CGContextSaveGState(ctx);
        {
            CGContextSetFillColorWithColor(ctx, self.badgeTextColor.CGColor);
            CGContextSetShadowWithColor(ctx, self.badgeTextShadowOffset, 1.0, self.badgeTextShadowColor.CGColor);
            
            CGRect textFrame = rectToDraw;
            CGSize textSize = [self sizeOfTextForCurrentSettings];
            
            textFrame.size.height = textSize.height;
            textFrame.origin.y = rectToDraw.origin.y + ceilf((rectToDraw.size.height - textFrame.size.height) / 2.0f);
            
            [self.badgeText drawInRect:textFrame
                              withFont:self.badgeTextFont
                         lineBreakMode:NSLineBreakByCharWrapping
                             alignment:NSTextAlignmentCenter];
        }
        CGContextRestoreGState(ctx);
    }
}

@end