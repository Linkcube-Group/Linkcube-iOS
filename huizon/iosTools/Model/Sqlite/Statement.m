//
//  Statement.m
//  TwitterFon
//
//  Created by kaz on 12/21/08.
//  Copyright 2008 naan studio. All rights reserved.
//

#import "Statement.h"
#import "DBConnection.h"

#import "JSONKit.h"
@implementation Statement

- (id)initWithDB:(sqlite3*)db query:(const char*)sql
{
    self = [super init];
    int code=sqlite3_prepare_v2(db, sql, -1, &stmt, NULL);
    if ( code!= SQLITE_OK) {
//        int ercode=sqlite3_extended_result_codes(db, 3);
        NSLog( @"Failed to prepare statement '%s' (%s)", sql, sqlite3_errmsg(db));
    }
    return self;
}

+ (id)statementWithDB:(sqlite3*)db query:(const char*)sql
{
    return [[Statement alloc] initWithDB:db query:sql];
}

+ (id)statementWithsql:(const char*)sql
{
    sqlite3 *db=[DBConnection getSharedDatabase];
    return [[Statement alloc] initWithDB:db query:sql];
}

- (int)step
{
    int result = sqlite3_step(stmt);
//    NSAssert(result!=SQLITE_BUSY, @"bad db busy");
    if(result==SQLITE_BUSY)
    {
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"dbbusy" message:@"dbbusy" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
//    NSLog(@"sql execute result: %d",result);
    return result;
}

- (void)reset
{
    sqlite3_reset(stmt);
}

- (void)dealloc
{
    sqlite3_finalize(stmt);
}

//
//
//
- (NSString*)getString:(int)index
{
#ifdef IndexStartOne
    index--;
#endif
    char *s = (char*)sqlite3_column_text(stmt, index);
    if (s) {
         NSString *str= [[NSString alloc] initWithCString:s encoding:NSUTF8StringEncoding];
        return str;
    }
    else {
        return @"";
    }

    
}

- (double)getDouble:(int)index{
#ifdef IndexStartOne
    index--;
#endif
    return sqlite3_column_double(stmt, index);
}

- (int)getInt32:(int)index
{
#ifdef IndexStartOne
    index--;
#endif
    return (int)sqlite3_column_int(stmt, index);
}

- (long long)getInt64:(int)index
{
#ifdef IndexStartOne
    index--;
#endif
    return (long long)sqlite3_column_int(stmt, index);
}

- (NSData*)getData:(int)index
{
#ifdef IndexStartOne
    index--;
#endif
    int length = sqlite3_column_bytes(stmt, index);
    return [NSData dataWithBytes:sqlite3_column_blob(stmt, index) length:length];    
}

//
//
//
- (void)bindString:(NSString*)value forIndex:(int)index
{
    if (value==nil) {
        value=@"";
    }
    if (![value isKindOfClass:[NSString class]]) {
//        value=@"";
        if ([value respondsToSelector:@selector(JSONString)]) {
            value=[value JSONString];
        }else{
            NSLog(@"error:unknown kind of class");
            value=@"";
        }
    }
    sqlite3_bind_text(stmt, index, [value UTF8String], -1, SQLITE_TRANSIENT);
}

- (void)bindInt32:(int)value forIndex:(int)index
{
    sqlite3_bind_int(stmt, index, value);
}
- (void)bindDouble:(double)value forIndex:(int)index{
    sqlite3_bind_double(stmt, index, value);
}

- (void)bindInt64:(long long)value forIndex:(int)index
{
    sqlite3_bind_int64(stmt, index, value);
}

- (void)bindData:(NSData*)value forIndex:(int)index
{
    sqlite3_bind_blob(stmt, index, value.bytes, value.length, SQLITE_TRANSIENT);
}

-(sqlite3_stmt*)stmt
{
    return stmt;
}
@end
