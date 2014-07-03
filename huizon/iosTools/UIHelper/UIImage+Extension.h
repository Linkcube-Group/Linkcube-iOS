//
//  UIImage+Extension.h
//  iTrends
//
//  Created by wujin on 12-7-17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

//取得指定名称的图片
#define IMG(name) [UIImage imageNamed:name]

//返回可以变形的图片
#define IMG_ST(name,x,y) [IMG(name) stretchableImageWithLeftCapWidth:x topCapHeight:y]


@interface UIImage (Extension)

//调整大小后的图像
-(UIImage*)sizedImage:(CGSize)size;
//旋转图片
+(UIImage *)rotateImage:(UIImage *)aImage;
//获取旋转后的图片
-(UIImage *)rotatedImage;

//指定图片的大小
+(UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

-(UIImage *)scaleToSize:(CGSize)size;
@end
