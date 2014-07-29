//
//  TIXAFileManager.h
//  Lianxi
//
//  Created by Liusx on 12-7-5.
//  Copyright (c) 2012年 TIXA. All rights reserved.
//

@interface FileManager : NSObject

+ (UIImage *)loadImage:(NSString *)path;     /*沙箱Documents读取*/
+ (UIImage *)loadCacheImage:(NSString *)path;/*读取图片(Library/Caches文件夹下)*/
+ (id)loadObject:(NSString *)path;
+ (NSMutableArray *)loadArray:(NSString *)path;
+ (NSMutableArray *)loadCacheArray:(NSString *)path;
+ (NSMutableDictionary *)loadDictionary:(NSString *)path;
+ (NSMutableDictionary *)loadCacheDictionary:(NSString *)path;

+ (BOOL)saveObject:(id)object filePath:(NSString *)path;     /*沙箱Documents保存*/
+ (BOOL)saveCacheObject:(id)object filePath:(NSString *)path;/*存储序列化对象(Library/Caches文件夹下)*/
+ (BOOL)saveData:(NSData *)data filePath:(NSString *)path;   /*存储数据(Documents文件夹下)*/

+ (BOOL)fileExistsAtPath:(NSString *)path;     /*是否存在指定文件(Documents文件夹下)*/
+ (BOOL)createDirectoryAtPath:(NSString *)path;/*创建指定路径文件夹(Documents文件夹下)*/
+ (BOOL)deleteFile:(NSString *)path;

@end
