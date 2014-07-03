//
//  UIColor+Extension.h
//  iTrends
//
//  Created by wujin on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RGBColor(r,g,b) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1]
#define RGBAColor(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]

@interface UIColor (Extension)

+ (UIColor *) colorWithHexString: (NSString *) hexString;
+ (NSString*) stringWithColor:(UIColor*)color;
@end
