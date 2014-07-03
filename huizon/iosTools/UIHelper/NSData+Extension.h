//
//  NSData+Extension.h
//  iTrends
//
//  Created by wujin on 12-11-30.
//
//

#import <Foundation/Foundation.h>

@interface NSData (Extension)

/*
 缓存的存放路径
 */
+(NSString*)cacheDirectory;

/*
 读取来自某个url的数据，并且缓存此内容，下次读取时，如果已经存在，会使用缓存
 */
+(id)dataWithContentsOfURL:(NSURL *)url userCache:(BOOL)cache;

@end
