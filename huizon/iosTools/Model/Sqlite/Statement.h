//
//  Statement.h
//  TwitterFon
//
//  Created by kaz on 12/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//
//标记索引从1开始
#define IndexStartOne

#import <sqlite3.h>

//
// Interface for Statement
//
@interface Statement : NSObject
{
    sqlite3_stmt*   stmt;
}

+ (id)statementWithDB:(sqlite3*)db query:(const char*)sql;
- (id)initWithDB:(sqlite3*)db query:(const char*)sql;

+ (id)statementWithsql:(const char*)sql;
// method
- (int)step;
- (void)reset;

// Getter
- (double)getDouble:(int)index;
- (NSString*)getString:(int)index;
- (int)getInt32:(int)index;
- (long long)getInt64:(int)index;
- (NSData*)getData:(int)index;

// Binder
- (void)bindString:(NSString*)value forIndex:(int)index;
- (void)bindInt32:(int)value forIndex:(int)index;
- (void)bindInt64:(long long)value forIndex:(int)index;
- (void)bindData:(NSData*)data forIndex:(int)index;
- (void)bindDouble:(double)value forIndex:(int)index;


//sqlite
-(sqlite3_stmt*)stmt;
@end

