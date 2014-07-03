//
//  NSDate+Extension.h
//  iTrends
//
//  Created by wujin on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Extension)
+(NSString*)now;

/**
 将指定字符串格式化成时间
 @param dateString:要格式的字符串
 @return 返回格式化后的时间
 */
+(NSDate *)dateWithString:(NSString*)dateString;

/**
 将指定字符串格式化为时间
 @param dateString:要格式化的字符串
 @param format:时间的格式
 @return 返回格式化后的时间
 */
+(NSDate*)dateWithString:(NSString *)dateString Format:(NSString*)format;

-(NSString *)stringDate;

-(NSString*)stringDateWithFormat:(NSString*)formatString;

//时间戳格式的字符串
-(NSString *)dateDiff;

//美式时间显示
-(NSString*)dateAmerican;

/**
 返回当前时间所代表的年、月、日、时、分、秒
 */
-(int)year;
-(int)month;
-(int)day;
-(int)hour;
-(int)minute;
-(int)seconds;
@end

@interface DFDateFormatterFactory : NSObject {
    
    NSCache *loadedDataFormatters;
    
}

+ (DFDateFormatterFactory *)sharedFactory;
- (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format andLocale:(NSLocale *)locale;
- (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format andLocaleIdentifier:(NSString *)localeIdentifier;

@end
