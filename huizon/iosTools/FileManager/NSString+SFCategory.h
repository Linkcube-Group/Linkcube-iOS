//
//  NSString+SFCategory.h
//  SFExpress
//
//  Created by tixa tixa on 14-1-8.
//  Copyright (c) 2014年 TIXA. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (SFCategory)

- (NSString *)documentFilePath;             //转换为沙箱Documents文件夹下的路径
- (BOOL)isDocumentFilePath;                 //是否为沙箱Documents文件夹下的路径
- (BOOL)createDocumentFileDirectory;        //创建在沙箱Documents文件夹下的指定目录
- (BOOL)deleteDocumentFile;                 //删除在沙箱Documents文件夹下得指定文件
- (BOOL)isExistsDocumentFile;               //是否在沙箱Documents文件夹下存在指定文件

- (NSString *)cacheFilePath;                //转换为沙箱Library/Cache文件夹下的路径
- (BOOL)isCacheFilePath;                    //是否为沙箱Library/Cache文件夹下的路径


- (NSString *)substringWithMaxLength:(NSUInteger)maxLength;

- (NSString *)nonemptyString;               //非空字符串
- (NSString *)trimmedString;                //去除空格、换行和\r\n
- (NSString *)UTF8EncodedString;            //编码UTF8字符串
- (NSString *)encodeURL;
- (NSString *)GBKEncodedString;             //编码GBK字符串，并处理常见URL特殊字符
- (NSString *)MD5EncodedString;             //编码MD5字符串
- (NSString *)numberString;                 //转换为T9数字键盘对应的数字串
//- (NSString *)international;                //转换为国际化字符串


- (NSString *)formattedPhone;               //格式化手机号码
- (BOOL)isValidPhone;                       //是否为合法手机号
- (BOOL)isValidEmail;                       //是否为合法邮箱地址
- (BOOL)isValidImageURL;                    //是否为合法图片路径
- (BOOL)isValidVideoURL;                    //是否为合法视频路径
- (BOOL)isValidAudioURL;                    //是否为合法音频路径
- (BOOL)isValidWebURL;                      //是否为合法web链接
- (BOOL)isValidBrowseURL;                   //是否为合法用webview打开路径

//xss防护
-(NSString *)protectXssString;

@end
