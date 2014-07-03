//
//  NSURL+Extension.h
//  iOSShare
//
//  Created by wujin on 13-4-19.
//  Copyright (c) 2013年 wujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (Extension)

/**
 获取paramString对应生成的url中的附加参数
 */
-(NSDictionary*)paramDictionary;

/**
 返回URL中指定参数的值
 */
-(NSString*)valueForParam:(NSString*)param;
@end
