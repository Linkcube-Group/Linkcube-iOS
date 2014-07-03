//
//  UIView+Extension.m
//  iTrends
//
//  Created by wujin on 12-9-3.
//
//

#import "UIView+Extension.h"

@implementation UIView (Extension)
-(CGFloat)height
{
    return self.frame.size.height;
}
-(void)setHeight:(CGFloat)height
{
    [self setHeight:height Animated:NO];
}
-(void)setHeight:(CGFloat)height Animated:(BOOL)animate
{
    CGRect frame=self.frame;
    frame.size.height=height;
    if (animate) {
        [UIView animateWithDuration:.3 animations:^{
            self.frame=frame;
        }];
    }else{
        self.frame=frame;
    }
}
-(void)addHeight:(CGFloat)height
{
    [self setHeight:[self height]+height ];
}


-(CGFloat)width
{
    return self.frame.size.width;
}
-(void)setWidth:(CGFloat)width
{
    [self setWidth:width Animated:NO];
}
-(void)setWidth:(CGFloat)width Animated:(BOOL)animate
{
    CGRect frame=self.frame;
    frame.size.width=width;
    if (animate) {
        [UIView animateWithDuration:.3 animations:^{
            self.frame=frame;
        }];
    }else{
        self.frame=frame;
    }

}
-(void)addWidth:(CGFloat)width
{
    [self setWidth:[self width]+width Animated:NO];
}

-(CGFloat)originX
{
    return self.frame.origin.x;
}
-(void)setOriginX:(CGFloat)x
{
    [self setOriginX:x Animated:NO];
}
-(void)setOriginX:(CGFloat)x Animated:(BOOL)animate
{
    CGRect frame=self.frame;
    frame.origin.x=x;
    if (animate) {
        [UIView animateWithDuration:.3 animations:^{
            self.frame=frame;
        }];
    }else{
        self.frame=frame;
    }

}
-(void)addOriginX:(CGFloat)x
{
    [self setOriginX:[self originX]+x];
}

-(CGFloat)originY
{
    return self.frame.origin.y;
}
-(void)setOriginY:(CGFloat)y
{
    [self setOriginY:y Animated:NO];
}
-(void)setOriginY:(CGFloat)y Animated:(BOOL)animate
{
    CGRect frame=self.frame;
    frame.origin.y=y;
    if (animate) {
        [UIView animateWithDuration:.3 animations:^{
            self.frame=frame;
        }];
    }else{
        self.frame=frame;
    }

}
-(void)addOriginY:(CGFloat)y
{
    [self setOriginY:[self originY]+y];
}

-(CGSize)size
{
    return self.frame.size;
}
-(void)setSize:(CGSize)size
{
    [self setSize:size Animated:NO];
}
-(void)setSize:(CGSize)size Animated:(BOOL)animate
{
    CGRect frame=self.frame;
    frame.size=size;
    if (animate) {
        [UIView animateWithDuration:.3 animations:^{
            self.frame=frame;
        }];
    }else{
        self.frame=frame;
    }
}

-(CGPoint)origin
{
    return self.frame.origin;
}
-(void)setOrigin:(CGPoint)point
{
    [self setOrigin:point Animated:NO];
}
-(void)setOrigin:(CGPoint)point Animated:(BOOL)animate
{
    CGRect frame=self.frame;
    frame.origin=point;
    if (animate) {
        [UIView animateWithDuration:.3 animations:^{
            self.frame=frame;
        }];
    }else{
        self.frame=frame;
    }

}


-(CGPoint)originTopRight
{
    return CGPointMake(self.origin.x+self.width, self.origin.y);
}

-(CGPoint)originBottomLeft
{
    return CGPointMake(self.originX, self.originY+self.height);
}

-(CGPoint)originBottomRight
{
    return CGPointMake(self.originX+self.width, self.originY+self.height);
}
-(CGRect)rectForAddViewTop:(CGFloat)height//返回在该view上面添加一个视图时的frame
{
    CGRect frame=self.frame;
    frame.size.height=height;
    frame.origin.y=frame.origin.y-height;
    
    return frame;
}
-(CGRect)rectForAddViewBottom:(CGFloat)height//返回在该view下面添加一个视图的时候的frame
{
    CGRect frame=self.frame;
    frame.origin.y=frame.origin.y+frame.size.height;
    frame.size.height=height;
    return frame;
}
-(CGRect)rectForAddViewLeft:(CGFloat)width//返回在该view左边添加一个视图的时候的frame
{
    CGRect frame=self.frame;
    frame.size.width=width;
    frame.origin.x=frame.origin.x-width;
    return frame;
}
-(CGRect)rectForAddViewRight:(CGFloat)width//返回在该view右边添加一个视图的时候的frame
{
    CGRect frame=self.frame;
    frame.size.width=width;
    frame.origin.x=frame.origin.x+width;
    return frame;
}

-(CGRect)rectForAddViewTop:(CGFloat)height Offset:(CGFloat)offset//返回在该view上面添加一个视图时的frame
{
    CGRect frame=self.frame;
    frame.size.height=height;
    frame.origin.y=frame.origin.y-height-offset;
    return frame;

}
-(CGRect)rectForAddViewBottom:(CGFloat)height Offset:(CGFloat)offset//返回在该view下面添加一个视图的时候的frame
{
    CGRect frame=self.frame;
    frame.origin.y=frame.origin.y+frame.size.height+offset;
    frame.size.height=height;
    return frame;

}
-(CGRect)rectForAddViewLeft:(CGFloat)width Offset:(CGFloat)offset//返回在该view左边添加一个视图的时候的frame
{
    CGRect frame=self.frame;
    frame.size.width=width;
    frame.origin.x=frame.origin.x-width-offset;
    return frame;

}
-(CGRect)rectForAddViewRight:(CGFloat)width Offset:(CGFloat)offset//返回在该view右边添加一个视图的时候的frame
{
    CGRect frame=self.frame;
    frame.size.width=width;
    frame.origin.x=frame.origin.x+width+offset;
    return frame;
}

-(CGRect)rectForCenterofSize:(CGSize)size
{
    CGRect rect;
    rect.size.width=size.width;
    rect.size.height=size.height;
    rect.origin.x=(self.width-size.width)/2.0;
    rect.origin.y=(self.height-size.height)/2.0;
    return rect;
}

-(NSArray*)subviewsWithClass:(Class )cls
{
    NSArray *array=[self subviews];
    return [array filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([evaluatedObject isKindOfClass:cls]) {
            return YES;
        }
        return NO;
    }]];
}

-(id)viewWithTag2:(int)tag
{
    return [self viewWithTag:tag];
}

/**
 取消子视图中UIAsyncImageView与UIAsyncImageButton的图片下载请求
 此方法不会遍历子视图的视图，只会进行一次遍历
 */
-(void)cancelSubviewImageDownload
{
//    for (UIView *s_view in self.subviews) {
//        if ([s_view isKindOfClass:[UIButton class]]) {
//            [(UIButton*)s_view cancelCurrentImageLoad];
//        }else if ([s_view isKindOfClass:[UIImageView class]]){
//            [(UIImageView*)s_view cancelCurrentImageLoad];
//        }
//    }
}

/**
 取消所有子视图的异步图片下载
 */
+(void)cancelSubviewImageDownloadinView:(UIView*)view
{
    for (UIView *s_view in view.subviews) {
        [s_view cancelSubviewImageDownload];
        [UIView cancelSubviewImageDownloadinView:s_view];
    }
}

-(id)initWithFrame:(CGRect)frame nibNameOrNil:(NSString *)nibNameOrNil
{
	if(self.layer==nil){//兼容5.0以前的系统，5.0以前的系统如果多次初始化会导致视图从父视图移除
		self=[self initWithFrame:frame];
	}else{
		self.frame=frame;
	}
    if (self) {
        if (nibNameOrNil==nil||[nibNameOrNil isEqualToString:@""]) {
            nibNameOrNil=NSStringFromClass([self class]);
        }
        UIView *view=[[UINib nibWithNibName:nibNameOrNil bundle:[NSBundle mainBundle]] instantiateWithOwner:self options:nil][0];
		self.backgroundColor=[UIColor clearColor];
		if([self isKindOfClass:[UITableViewCell class]])
		{
			self.frame=frame;
			[[(UITableViewCell*)self contentView] setFrame:self.bounds];
			[[(UITableViewCell*)self contentView] setBackgroundColor:[UIColor clearColor]];
			[[(UITableViewCell*)self contentView] addSubview:view];
		}else{
			view.frame=self.bounds;
			[self addSubview:view];
		}
    }
    return self;
}
@end