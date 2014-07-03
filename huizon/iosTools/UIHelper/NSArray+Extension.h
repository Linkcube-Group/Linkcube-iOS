//
//  NSArray+Extension.h
//  iTrends
//
//  Created by wujin on 13-1-9.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (Extension)

/**
 返回数组中的第一个元素
 */
-(id)firstObject;

-(BOOL)containsString:(NSString*)string;

- (NSInteger)indexOfString:(NSString *)string;
@end
