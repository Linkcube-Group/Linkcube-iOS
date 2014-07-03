//
//  UIView+Extension.h
//  iTrends
//
//  Created by wujin on 12-9-3.
//
//

#import <UIKit/UIKit.h>
#import "UIDevice+Extension.h"
/**
 根据当前设备是iphone4还是iphone5返回指定的值
 @param value4 iphone4时对应的值
 @param value5 iphone5时对应的值
 */
#define VALUE4OR5(value4,value5) [UIScreen mainScreen].bounds.size.height>480?value5:value4

static inline CGRect CGRectAddX(CGRect rect,CGFloat x)
{
    rect.origin.x=rect.origin.x+x;
    return rect;
}

static inline CGRect CGRectAddY(CGRect rect,CGFloat y)
{
    rect.origin.y=rect.origin.y+y;
    return rect;
}

static inline CGRect CGRectAddWidth(CGRect rect,CGFloat width)
{
    rect.size.width=rect.size.width+width;
    return rect;
}

static inline CGRect CGRectAddHeight(CGRect rect,CGFloat height)
{
    rect.size.height=rect.size.height+height;
    return rect;
}

static inline CGRect CGRectMakePlus(float x4,float x5,float y4,float y5,float width4,float width5,float height4,float height5)
{
    if (DeviceIsiPhone5OrLater()) {
        return CGRectMake(x5, y5, width5, height5);
    }else{
        return CGRectMake(x4, y4, width4, height4);
    }
}

static inline CGRect CGRectMakePlusH(float x,float y,float width,float height4,float height5)
{
    return CGRectMakePlus(x, x, y, y, width, width, height4, height5);
}

static inline CGRect CGRectMakePlusW(float x,float y,float width4,float width5,float height)
{
    return CGRectMakePlus(x, x, y, y, width4, width5, height, height);
}

static inline CGRect CGRectMakePlusX(float x4,float x5,float y,float width,float height)
{
    return CGRectMakePlus(x4, x5, y, y, width, width, height, height);
}

static inline CGRect CGRectMakePlusY(float x,float y4,float y5,float width,float height)
{
    return CGRectMakePlus(x,x , y4, y5, width, width, height, height);
}

static inline CGRect CGRectMakePlusOrigin(float x4,float x5,float y4,float y5,float width,float height)
{
    return CGRectMakePlus(x4, x5, y4, y5, width, width, height, height);
}

static inline CGRect CGRectMakePlusSize(float x,float y,float width4,float width5,float height4,float height5)
{
    return CGRectMakePlus(x, x, y, y, width4, width5, height4, height5);
}

/**
 获取一个CGRect中指定大小的CGSize时候Center时所处的位置
 
 @param rect 要计算的原始大小
 @param size 要占位的大小
 */
static inline CGRect CGRectCenter(CGRect rect,CGSize size)
{
    return CGRectMake((rect.size.width-size.width)/2, (rect.size.height-size.height)/2, size.width, size.height);
}

@interface UIView (Extension)
///元素的高度 同  self.frame.size.height
-(CGFloat)height;
///设置元素的高度
-(void)setHeight:(CGFloat)height;
-(void)setHeight:(CGFloat)height Animated:(BOOL)animate;
-(void)addHeight:(CGFloat)height;

///元素的宽度 同  self.frame.size.width
-(CGFloat)width;
-(void)setWidth:(CGFloat)width;
-(void)setWidth:(CGFloat)width Animated:(BOOL)animate;
///设置元素的宽度
-(void)addWidth:(CGFloat)width;
///元素的x坐标 同self.frame.origin.x
-(CGFloat)originX;
///设置元素的x坐标
-(void)setOriginX:(CGFloat)x ;
-(void)setOriginX:(CGFloat)x Animated:(BOOL)animate;
-(void)addOriginX:(CGFloat)x;
///元素的y坐标 同self.frame.origin.y
-(CGFloat)originY;
///设置元素的y坐标
-(void)setOriginY:(CGFloat)y;
-(void)setOriginY:(CGFloat)y Animated:(BOOL)animate;
-(void)addOriginY:(CGFloat)y;
///元素的大小  同self.frame.size
-(CGSize)size;
///设置元素的大小
-(void)setSize:(CGSize)size;
-(void)setSize:(CGSize)size Animated:(BOOL)animate;
///元素的位置 同self.frame.origin
-(CGPoint)origin;
///设置元素的位置
-(void)setOrigin:(CGPoint)point;
-(void)setOrigin:(CGPoint)point Animated:(BOOL)animate;


-(CGRect)rectForAddViewTop:(CGFloat)height;///返回在该view上面添加一个视图时的frame
-(CGRect)rectForAddViewTop:(CGFloat)height Offset:(CGFloat)offset;///返回在该view上面添加一个视图时的frame

-(CGRect)rectForAddViewBottom:(CGFloat)height;///返回在该view下面添加一个视图的时候的frame
-(CGRect)rectForAddViewBottom:(CGFloat)height Offset:(CGFloat)offset;///返回在该view下面添加一个视图的时候的frame
-(CGRect)rectForAddViewLeft:(CGFloat)width;///返回在该view左边添加一个视图的时候的frame
-(CGRect)rectForAddViewLeft:(CGFloat)width Offset:(CGFloat)offset;///返回在该view左边添加一个视图的时候的frame
-(CGRect)rectForAddViewRight:(CGFloat)width;///返回在该view右边添加一个视图的时候的frame
-(CGRect)rectForAddViewRight:(CGFloat)width Offset:(CGFloat)offset;///返回在该view右边添加一个视图的时候的frame

/**
 元素的右上角的点
 */
-(CGPoint)originTopRight;
/**
 元素的左下角的点
 */
-(CGPoint)originBottomLeft;
/**
 元素的右下角的点
 */
-(CGPoint)originBottomRight;

-(CGRect)rectForCenterofSize:(CGSize)size;//居中一个size
/*
 返回该类中所有指定类型的subview
 */
-(NSArray*)subviewsWithClass:(Class )cls;


/**
 取消子视图中UIAsyncImageView与UIAsyncImageButton的图片下载请求
 此方法不会遍历子视图的视图，只会进行一次遍历
 */
-(void)cancelSubviewImageDownload;

/**
 取消所有子视图的异步图片下载
 */
+(void)cancelSubviewImageDownloadinView:(UIView*)view;

/**
 同viewWithTag:(int)tag
 
 此函数返回id类型，以不用强制转换类型
 */
-(id)viewWithTag2:(int)tag;

#pragma mark -
#pragma mark -xib
/**
 从xib加载控件
 需要将xib的file's owner设置为self
 @param frame:视图的大小
 @param nibNameOrNil:要加载的xib名称，默认为类名
 @return 返回加载后的视图
 */
-(id)initWithFrame:(CGRect)frame nibNameOrNil:(NSString*)nibNameOrNil;

@end