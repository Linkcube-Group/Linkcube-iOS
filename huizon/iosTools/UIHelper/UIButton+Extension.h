//
//  UIButton+Extension.h
//  iTrends
//
//  Created by wujin on 12-9-12.
//
//

#import <UIKit/UIKit.h>


@interface UIButton (Extension)

//设置图片，同时设置按下效果
-(void)setImageForNormalAndHighlighted:(NSString *)imageName;// forState:(UIControlState)state

//设置背景图片，同时设置按下效果
-(void)setBackgroundImageForNormalAndHighlighted:(NSString *)imageName;//forState:(UIControlState)state

//设置图片，同时设置按下效果
-(void)setImageForNormalAndSelected:(NSString *)imageName;// forState:(UIControlState)state

//设置背景图片，同时设置按下效果
-(void)setBackgroundImageForNormalAndSelected:(NSString *)imageName;//forState:(UIControlState)state

@end


@interface UIDataButton : UIButton


@property(nonatomic,retain) id args;//一个用于保存数据的button

@end


//多状态按钮


@interface UIMultibleStateButton : UIDataButton
{
    //不同状态下的图片
    NSMutableArray *imgAry;
    NSMutableArray *titleAry;
//    NSInteger currentStateIndex;
}
@property (nonatomic, assign) NSInteger currentStateIndex;
//设置各个状态的图片
-(void)setImageAryWithImages:(NSArray *)theImageAry;
//设置各个状态标题
-(void)setTitleAryWithTitles:(NSArray *)theTitlesAry;
//设置按钮状态
-(void)setButtonState:(NSInteger)theStateIndex;
//获取当前状态
-(NSInteger)getCurrentStateIndex;

@end