#import <sqlite3.h>
#import "Statement.h"

//
// Interface for Database connector
//
@interface DBConnection : NSObject
{
}

+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force;
+ (void)clearCache;
+ (void)deletePubsubCache;

+ (sqlite3*)getSharedDatabase;
+ (sqlite3*)getSigleDatabase;
+ (void)closeDatabase;

+ (void)beginTransaction;
+ (void)commitTransaction;

+ (Statement*)statementWithQuery:(const char*)sql;


@end