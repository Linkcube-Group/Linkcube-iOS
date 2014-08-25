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

#define IMG_FILE(name) [UIImage imageWithContentsOfFile:name]
//返回可以变形的图片
#define IMG_ST(name,x,y) [IMG(name) stretchableImageWithLeftCapWidth:x topCapHeight:y]


typedef enum {
    UIImageRoundedCornerTopLeft = 1,
    UIImageRoundedCornerTopRight = 1 << 1,
    UIImageRoundedCornerBottomRight = 1 << 2,
    UIImageRoundedCornerBottomLeft = 1 << 3
} UIImageRoundedCorner;
    
    
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

- (UIImage *)roundedRectWith:(float)radius;
@end
