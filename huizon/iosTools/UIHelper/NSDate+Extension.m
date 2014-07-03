//
//  NSDate+Extension.m
//  iTrends
//
//  Created by wujin on 12-7-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NSDate+Extension.h"

#define CACHE_LIMIT 15;

@implementation DFDateFormatterFactory


- (id)init {
    self = [super init];
    if (self) {
        loadedDataFormatters = [[NSCache alloc] init];
        loadedDataFormatters.countLimit = CACHE_LIMIT;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
    return self;
}
- (void)dealloc
{

}

#pragma mark -
#pragma mark Static Methods
/**
 收到内存警告时将所有的缓存 的nslocal全部移除
 */
-(void)didReceiveMemoryWarning
{
    [loadedDataFormatters removeAllObjects];
}

+ (DFDateFormatterFactory *)sharedFactory {
    static DFDateFormatterFactory *sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DFDateFormatterFactory alloc] init];
    });
    
    return sharedInstance;
}


#pragma mark -
#pragma mark NSDateFormatter Initialization Methods

- (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format andLocale:(NSLocale *)locale {
    @synchronized(self) {
        NSString *key = [NSString stringWithFormat:@"%@|%@", format, locale.localeIdentifier];
        
        NSDateFormatter *dateFormatter = [loadedDataFormatters objectForKey:key];
        if (!dateFormatter) {
            dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateFormat = format;
            dateFormatter.locale = locale;
            [loadedDataFormatters setObject:dateFormatter forKey:key];
        }
        
        return dateFormatter;
    }
}

- (NSDateFormatter *)dateFormatterWithFormat:(NSString *)format andLocaleIdentifier:(NSString *)localeIdentifier {
    return [self dateFormatterWithFormat:format andLocale:[[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier]];
}

@end

@implementation NSDate (Extension)


+(NSString*)now
{
    NSDateFormatter *format=[[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss" andLocale:[NSLocale currentLocale]];
//    format
    NSString *str=[format stringFromDate:[NSDate date]];
    return str;
}

+(NSDate *)dateWithString:(NSString*)dateString
{
    if (dateString==nil||[dateString isEqualToString:@""]) {
        return nil;
    }
    
    NSDateFormatter *format=[[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss" andLocale:[NSLocale currentLocale]];
    NSDate *str=[format dateFromString:dateString];
    return str;
}

+(NSDate*)dateWithString:(NSString *)dateString Format:(NSString *)format
{
    if (dateString==nil||[dateString isEqualToString:@""]) {
        return nil;
    }
    
    NSDateFormatter *fm=[[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:format andLocale:[NSLocale currentLocale]];
    NSDate *str=[fm dateFromString:dateString];
    return str;
}

-(NSString *)stringDate
{
    NSDateFormatter *format=[[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"yyyy-MM-dd HH:mm:ss" andLocale:[NSLocale currentLocale]];
    NSString *str=[format stringFromDate:self];
    return str;
}

-(NSString*)stringDateWithFormat:(NSString *)formatString
{
    NSDateFormatter *format=[[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:formatString andLocale:[NSLocale currentLocale]];
    
    NSString *str=[format stringFromDate:self];
    return str;
}

-(NSString*)dateAmerican
{
    NSDateFormatter *format=[[DFDateFormatterFactory sharedFactory] dateFormatterWithFormat:@"MMM dd,yyyy" andLocaleIdentifier:@"en-US"];
    
    NSString *str=[format stringFromDate:self];
    return str;
}

-(int)year
{
	return [[self stringDateWithFormat:@"yyyy"] intValue];
}
-(int)month
{
	return [[self stringDateWithFormat:@"MM"] intValue];
}
-(int)day
{
	return [[self stringDateWithFormat:@"dd"] intValue];
}
-(int)hour
{
	return [[self stringDateWithFormat:@"hh"] intValue];
}
-(int)minute
{
	return [[self stringDateWithFormat:@"mm"] intValue];
}
-(int)seconds
{
	return [[self stringDateWithFormat:@"ss"] intValue];
}
//时间戳格式的字符串
-(NSString *)dateDiff
{
    NSDate *todayDate = [NSDate date];
    
    double ti = [self timeIntervalSinceDate:todayDate];
    
    ti = ti * -1;
    
    if(ti < 1) {
        
        return @"刚刚";
        
    } else      if (ti < 60*3) {
        
        return @"3分钟前";
        
    } else if (ti < 3600) {
        
        int diff = round(ti / 60);
        
        return [NSString stringWithFormat:@"%d分钟", diff];
        
    } else if (ti < 86400) {
        
        int diff = round(ti / 60 / 60);
        
        return [NSString stringWithFormat:@"%d小时", diff];
        
    } else if (ti < 2629743) {
        
        int diff = round(ti / 60 / 60 / 24);
        
        return [NSString stringWithFormat:@"%d天", diff];
        
    } else if (ti<60*60*24*30*12)
    {
        int diff=round(ti/60/60/24/30);
        return [NSString stringWithFormat:@"%d月",diff];
    }else {
        int diff=round(ti/60/60/24/30/12);

        return [NSString stringWithFormat:@"%d年",diff];
    }   
    
}
@end
