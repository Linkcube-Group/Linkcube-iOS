//
//  UIButton+Extension.m
//  iTrends
//
//  Created by wujin on 12-9-12.
//
//

#import "UIButton+Extension.h"

@implementation UIButton (Extension)

//设置图片，同时设置按下效果
-(void)setImageForNormalAndHighlighted:(NSString *)imageName// forState:(UIControlState)state
{
    UIImage *normal=[UIImage imageNamed:imageName];
    NSString *name_press=[NSString stringWithFormat:@"%@_press",imageName];
    UIImage *press=[UIImage imageNamed:name_press];
    
    [self setImage:normal forState:UIControlStateNormal];
    [self setImage:press forState:UIControlStateHighlighted];
}
//设置背景图片，同时设置按下效果
-(void)setBackgroundImageForNormalAndHighlighted:(NSString *)imageName//forState:(UIControlState)state
{
    UIImage *normal=[UIImage imageNamed:imageName];
    NSString *name_press=[NSString stringWithFormat:@"%@_press",imageName];
    UIImage *press=[UIImage imageNamed:name_press];
    
    [self setBackgroundImage:normal forState:UIControlStateNormal];
    [self setBackgroundImage:press forState:UIControlStateHighlighted];
}

//设置图片，同时设置按下效果
-(void)setImageForNormalAndSelected:(NSString *)imageName// forState:(UIControlState)state
{
    UIImage *normal=[UIImage imageNamed:imageName];
    NSString *name_press=[NSString stringWithFormat:@"%@_selected",imageName];
    UIImage *press=[UIImage imageNamed:name_press];
    
    [self setImage:normal forState:UIControlStateNormal];
    [self setImage:press forState:UIControlStateSelected];
}


//设置背景图片，同时设置按下效果
-(void)setBackgroundImageForNormalAndSelected:(NSString *)imageName//forState:(UIControlState)state
{
    UIImage *normal=[UIImage imageNamed:imageName];
    NSString *name_press=[NSString stringWithFormat:@"%@_selected",imageName];
    UIImage *press=[UIImage imageNamed:name_press];
    
    [self setImage:normal forState:UIControlStateNormal];
    [self setImage:press forState:UIControlStateSelected];
}

@end

#include <objc/runtime.h>

@implementation UIDataButton

+(id)buttonWithType:(UIButtonType)buttonType
{
    UIDataButton *btn=[[UIDataButton alloc] init];
    
    return btn;
}

-(void)dealloc
{
    self.args=nil;
    
}

@end


@implementation UIMultibleStateButton

//
+(id)buttonWithType:(UIButtonType)buttonType
{
    UIMultibleStateButton *muBtn = [[UIMultibleStateButton alloc] init];
    
    return muBtn;
}

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imgAry = [[NSMutableArray alloc] init];
        titleAry = [[NSMutableArray alloc] init];
        self.currentStateIndex = 0;
    }
    return self;
}

//设置各个状态的图片
-(void)setImageAryWithImages:(NSArray *)theImageAry
{
    if (!imgAry) {
        imgAry = [[NSMutableArray alloc] initWithArray:theImageAry];
    }else{
        [imgAry removeAllObjects];
        [imgAry addObjectsFromArray:theImageAry];
    }
    
}
//设置各个状态标题
-(void)setTitleAryWithTitles:(NSArray *)theTitlesAry
{
    if (!titleAry) {
        titleAry = [[NSMutableArray alloc] initWithArray:theTitlesAry];
    }else{
        [titleAry removeAllObjects];
        [titleAry addObjectsFromArray:theTitlesAry];
    }
    
}

//设置按钮状态
-(void)setButtonState:(NSInteger)theStateIndex
{
    if (theStateIndex>=[imgAry count] && theStateIndex>=[titleAry count]) {
        return;
    }
    
    self.currentStateIndex = theStateIndex;
    
    if (theStateIndex<[imgAry count]) {
        UIImage *stateImage = [UIImage imageNamed:[imgAry objectAtIndex:theStateIndex]];
        [self setImage:stateImage forState:UIControlStateNormal];
    }
    if (theStateIndex<[titleAry count]) {
        [self setTitle:[titleAry objectAtIndex:theStateIndex] forState:UIControlStateNormal];
    }
    
    
    
}


//获取当前状态
-(NSInteger)getCurrentStateIndex
{
    return self.currentStateIndex;
}

-(void)dealloc
{
   
}

@end



