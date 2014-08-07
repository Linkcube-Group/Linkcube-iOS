//
//  Theam.m
//  zhaopin
//
//  Created by wujin on 13-10-18.
//  Copyright (c) 2013年 zhaopin.com. All rights reserved.
//

#import "Theam.h"
@interface NavigationTitleLabel:UIView
@end

@implementation NavigationTitleLabel

-(void)setFrame:(CGRect)frame
{
	[super setFrame:frame];
	if (self.superview) {
        UIView *superview=self.superview;
        while ([superview isKindOfClass:[UINavigationBar class]]==NO) {
            superview=superview.superview;
        }
		CGPoint point=[self.superview convertPoint:CGPointMake([UIScreen mainScreen].bounds.size.width/2, self.center.y) fromView:superview];
		self.center=CGPointMake(point.x, self.center.y);
	}
}

//-(CGSize)sizeThatFits:(CGSize)size
//{
//	return CGSizeMake(320-108, size.height);
//}

@end

@implementation Theam

- (id)init
{
    self = [super init];
    if (self) {
        [self globalConfig];
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+(Theam*)currentTheam
{
	static Theam *theam;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		theam=[[Theam alloc] init];
	});
	return theam;
}

-(void)globalConfig
{
	//导航条背景
	if (isIOS7) {
		[[UINavigationBar appearance] setBackgroundImage:IMG(@"bg_title_2") forBarMetrics:UIBarMetricsDefault];
	}else{
		[[UINavigationBar appearance] setBackgroundImage:IMG(@"bg_title") forBarMetrics:UIBarMetricsDefault];
	}
	//表格
//	[[UITableView appearance] setSeparatorStyle:UITableViewCellSeparatorStyleNone];///没有分隔线
//	[[UITableView appearance] setBackgroundColor:RGBColor(247, 247, 247)];
//	
//	//tableViewCell
//	[[UITableViewCell appearance] setBackgroundColor:[UIColor clearColor]];///背景透明
	
	///label 背景透明
	//[[UILabel appearance] setBackgroundColor:[UIColor clearColor]];
}

-(UIFont*)navigationBarItemFont
{
	return [UIFont systemFontOfSize:16];
}

-(UIColor*)navigationBarItemTitleColor
{
	return [UIColor whiteColor];
}
-(UIColor*)viewBackgroundColor
{
	return RGBColor(247, 247, 247);
}
-(UIColor*)tableViewCellSepartorColor
{
	return RGBColor(231, 231, 231);
}
-(UIColor*)tableSelectedBackgroundColor
{
	return RGBColor(229, 229, 229);
}
-(UIColor*)labelBlackColor
{
	return RGBColor(0x33, 0x33, 0x33);
}

-(UIColor*)labelGrayColor
{
	return RGBColor(0x66, 0x66, 0x66);
}

-(UIColor*)labelLightGrayColor
{
	return RGBColor(0x99,0x99,0x99);
}

-(UIColor*)labelWhiteColor
{
	return RGBColor(0xf7, 0xf7, 0xf7);
}

-(UIColor*)labelBlueColor
{
	return RGBColor(0x25, 0x85, 0xe5);
}

-(UIFont*)actionSheetFont
{
	return [UIFont systemFontOfSize:15];
}

-(UIView*)navigationTitleViewWithTitle:(NSString *)title
{
    UIView *navView = [[NavigationTitleLabel alloc] initWithFrame:CGRectMake(0, 0, 320-108, 44)];
	UILabel *label=[[UILabel alloc] initWithFrame:CGRectMake(0, 0, 212, 44)];
	label.backgroundColor=[UIColor clearColor];
	label.textColor=[UIColor whiteColor];
	label.text=title;
    label.font=[UIFont boldSystemFontOfSize:18];
    
    label.numberOfLines = 0;
    CGRect rect = [NSString heightForString:title Size:CGSizeMake(200, 44) Font:[UIFont boldSystemFontOfSize:18] Lines:2];
    if (rect.size.height>40) {
        label.width -= 20;
        label.originX = 10;
          label.font=[UIFont boldSystemFontOfSize:14];
    }
    label.lineBreakMode = NSLineBreakByTruncatingMiddle;
	
	label.textAlignment=NSTextAlignmentCenter;
	label.autoresizingMask=UIViewAutoresizingFlexibleWidth;
    
    [navView addSubview:label];
	return navView;
}

-(UIBarButtonItem*)navigationBarRightButtonItemWithImage:(UIImage *)image Title:(NSString *)title Target:(id)target Selector:(SEL)sel
{
	UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
	[btn setImage:image forState:UIControlStateNormal];
	[btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
	btn.titleLabel.font=[Theam currentTheam].navigationBarItemFont;
    btn.titleLabel.adjustsFontSizeToFitWidth = YES;
	[btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
	[btn setTitle:title forState:UIControlStateNormal];
	[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[btn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	btn.frame=CGRectMake(0, 0, 54, 44);
	//让图片在最右侧对齐
	CGSize imagesize=image.size;
	imagesize.width=imagesize.width/2;
	imagesize.height=imagesize.height/2;
	CGSize btnsize=btn.size;
	
	//iOS7下面导航按钮会默认有10px间距
	UIEdgeInsets insets=UIEdgeInsetsMake((btnsize.height-imagesize.height)/2, btnsize.width-imagesize.width, (btnsize.height-imagesize.height)/2, 0);
	[btn setImageEdgeInsets:insets];
	btn.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	UIBarButtonItem *item=[[UIBarButtonItem alloc] initWithCustomView:btn];
	
	CGRect textFrame=[btn.titleLabel textRectForBounds:btn.bounds limitedToNumberOfLines:1];
	//iOS7上会有10px间距，所以将label的右边距+10
	if (DeviceSystemSmallerThan(7.0)) {
		[btn setTitleEdgeInsets:UIEdgeInsetsMake(0, btn.width-10-textFrame.size.width, 0, 10)];
	}
	return item;
}

-(UIBarButtonItem*)navigationBarLeftButtonItemWithImage:(UIImage *)image Title:(NSString *)title Target:(id)target Selector:(SEL)sel
{
	UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
	[btn setImage:image forState:UIControlStateNormal];
	[btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
	btn.titleLabel.font=[Theam currentTheam].navigationBarItemFont;
	[btn setTitleColor:[Theam currentTheam].navigationBarItemTitleColor forState:UIControlStateNormal];
	[btn setTitle:title forState:UIControlStateNormal];
	[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
	[btn setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
	btn.frame=CGRectMake(0, 0, 44, 44);
	//让图片在最右侧对齐
	CGSize imagesize=image.size;
	imagesize.width=imagesize.width/2;
	imagesize.height=imagesize.height/2;
	CGSize btnsize=btn.size;
	
	//iOS7下面导航按钮会默认有10px间距
	UIEdgeInsets insets=UIEdgeInsetsMake((btnsize.height-imagesize.height)/2, btnsize.width-imagesize.width, (btnsize.height-imagesize.height)/2, 0);
//	[btn setImageEdgeInsets:insets];
	btn.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	UIBarButtonItem *item=[[UIBarButtonItem alloc] initWithCustomView:btn];
	
//	CGRect textFrame=[btn.titleLabel textRectForBounds:btn.bounds limitedToNumberOfLines:1];
	//iOS7上会有10px间距，所以将label的右边距+10
	if (DeviceSystemSmallerThan(7.0)) {
		[btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
	}
	return item;
}

#if 0

-(UIBarButtonItem*)navigationBarButtonBackItemWithTarget:(id)target Selector:(SEL)sel
{
	UIButton *btn=[UIButton buttonWithType:UIButtonTypeCustom];
	[btn setImage:IMG(@"icon_back") forState:UIControlStateNormal];
	[btn setImage:IMG(@"icon_back_default") forState:UIControlStateHighlighted];
	[btn addTarget:target action:sel forControlEvents:UIControlEventTouchUpInside];
	[btn setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
	[btn setTitleColor:[Theam currentTheam].navigationBarItemTitleColor forState:UIControlStateNormal];
	btn.titleLabel.font=[Theam currentTheam].navigationBarItemFont;
	btn.frame=CGRectMake(0, 0, 60, 20);
	if (DeviceSystemSmallerThan(7.0)) {
//		btn.width+=10;
		[btn setImageEdgeInsets:UIEdgeInsetsMake(0, 10, 0, 0)];
	}else{
		[btn setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10)];
	}
	UILabel *lb=[[UILabel alloc] initWithFrame:CGRectMake(25, -1, 40, 22)];
	if (!DeviceSystemSmallerThan(7.0)) {
		lb.originX-=10;
	}
	lb.font=[Theam currentTheam].navigationBarItemFont;
	lb.textColor=self.navigationBarItemTitleColor;
	lb.text=@"返回";
	lb.textAlignment=NSTextAlignmentLeft;
	lb.backgroundColor=[UIColor clearColor];
	lb.userInteractionEnabled=NO;
//	[btn addSubview:lb];
	UIBarButtonItem *item=[[UIBarButtonItem alloc] initWithCustomView:btn];
	
	return item;
}

#else
-(UIBarButtonItem*)navigationBarButtonBackItemWithTarget:(id)target Selector:(SEL)sel
{
    // change by yuyang
	return [self navigationBarLeftButtonItemWithImage:IMG(@"close_btn.png") Title:nil Target:target Selector:sel];
}
#endif

-(UIFont*)labelFontTitle1
{
	return [UIFont systemFontOfSize:15];
}
-(UIFont*)labelFontTitle2
{
	return [UIFont systemFontOfSize:14];
}
-(UIFont*)labelFontContent
{
	return [UIFont systemFontOfSize:12];
}
@end
