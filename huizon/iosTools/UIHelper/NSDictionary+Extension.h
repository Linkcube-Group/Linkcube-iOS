//
//  NSDictionary+Extension.h
//  Cloud
//
//  Created by wujin on 12-11-8.
//  Copyright (c) 2012年 wujin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Extension)
/**
 获取指定value的key
 */
-(id)keyForValue:(id)value;
@end


@interface NSMutableDictionary(Extension)

/**
 将一个int给字典赋值
 将会将int转换为字符串
 @param value 值
 @param key 键
 */
-(void)setInt:(int)value forKey:(NSString*)key;
/**
 将一个float给字典赋值
 将会将float转换为字符串
 @param value 值
 @param key 键
 */
-(void)setFloat:(float)value forKey:(NSString*)key;

/**
 将一个double给字典赋值
 将会将double转换为字符串
 @param value 值
 @param key 键
 */
-(void)setDouble:(double)value forKey:(NSString*)key;
@end

/**
 支持缓存的持久化字典
 字典会在退出程序的时候写入缓存
 在启动时从缓存读取
 */
@interface NSCacheMutableDicionary : NSObject

///最大缓存的数量
@property (nonatomic,assign) int maxCount;

/**
 缓存一个对象
 @param object : 要缓存的对象
 @param aKey :	保存的key
 */
-(void)setObject:(id)object forKey:(id<NSCopying>)aKey;

/**
 获取缓存后的某对象的值
 @param aKey : 保存的key
 @return 返回缓存的对象
 */
-(id)objectForKey:(id<NSCopying>)aKey;

/**
 返回保存的路径 默认为   %Home%/Documents/Cache/id.cache
 @return 返回缓存文件的保存路径，请重写此方法返回自己的路径
 */
-(NSString*)cachePath;

/**
 返回单例对象
 */
+(id)shareCache;
@end