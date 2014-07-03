//
//  NSURL+Extension.m
//  iOSShare
//
//  Created by wujin on 13-4-19.
//  Copyright (c) 2013年 wujin. All rights reserved.
//

#import "NSURL+Extension.h"
#import "RegexKitLite.h"

@implementation NSURL (Extension)

-(NSDictionary*)paramDictionary
{
    NSString *paramstr=self.query;
    NSArray *split=[paramstr componentsSeparatedByString:@"&"];
    NSMutableDictionary *dic=[NSMutableDictionary dictionary];
    for (NSString *str in split) {
        if ([str isMatchedByRegex:@".=."]) {
            NSArray *str_split=[str componentsSeparatedByString:@"="];
            if (str_split.count==2) {
                [dic setValue:[str_split objectAtIndex:1] forKey:[str_split objectAtIndex:0]];
            }
        }
    }
    return dic;
}

-(NSString*)valueForParam:(NSString *)param
{
    return [self.paramDictionary valueForKey:param];
}
@end
