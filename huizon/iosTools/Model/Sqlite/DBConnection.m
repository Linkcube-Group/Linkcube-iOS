#import "DBConnection.h"
#import "Statement.h"

static sqlite3*             theDatabase = nil;

#define DATABASENAME @"database-1.0"

@implementation DBConnection

+ (sqlite3*)openDatabase:(NSString*)dbFilename
{
    sqlite3* instance;
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSAllDomainsMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:dbFilename];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {//文件不存在，拷贝
        NSString *dbpath=[[NSBundle mainBundle] pathForResource:DATABASENAME ofType:@"sqlite"];
        NSError *error;        
        if(![[NSFileManager defaultManager] copyItemAtPath:dbpath toPath:path error:&error]){
            NSLog(@"%@",error.description);
        }
    }

    // Open the database. The database was prepared outside the application.
    if (sqlite3_open([path UTF8String], &instance) != SQLITE_OK) {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(instance);
        NSLog(@"Failed to open database. (%s)", sqlite3_errmsg(instance));
        return nil;
    }        
    return instance;
}

+ (sqlite3*)getSharedDatabase
{
    if (theDatabase == nil) {
        [DBConnection createEditableCopyOfDatabaseIfNeeded:true];
        theDatabase = [self openDatabase:[NSString stringWithFormat:@"%@.sqlite",DATABASENAME]];
    }

    return theDatabase;
}

+(sqlite3*)getSigleDatabase
{
    [DBConnection createEditableCopyOfDatabaseIfNeeded:true];
    sqlite3 *db=[self openDatabase:[NSString stringWithFormat:@"%@.sqlite",DATABASENAME]];
    return db;
}

//
// delete caches
//
const char *delete_message_cache_sql = 
"BEGIN;DELETE FROM columns;DELETE FROM infos;COMMIT;";

+ (void)clearCache
{
    char *errmsg;
    [self getSharedDatabase];
    
    if (sqlite3_exec(theDatabase, delete_message_cache_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
        // ignore error
        NSLog(@"Error: failed to cleanup chache (%s)", errmsg);
    }
}

+ (void)deletePubsubCache
{
    char *errmsg;
    [self getSharedDatabase];
    
    if (sqlite3_exec(theDatabase, "DELETE FROM messages; DELETE FROM infos; VACUUM;", NULL, NULL, &errmsg) != SQLITE_OK) {
        // ignore error
        NSLog(@"Error: failed to cleanup chache (%s)", errmsg);
    }
}

//
// cleanup and optimize
//
const char *cleanup_sql =
"BEGIN;COMMIT";


const char *optimize_sql = "VACUUM; ANALYZE";

+ (void)closeDatabase
{
    char *errmsg;
    if (theDatabase) {
        if (sqlite3_exec(theDatabase, cleanup_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
            // ignore error
            NSLog(@"Error: failed to cleanup chache (%s)", errmsg);
        }
        
      	int launchCount = [[NSUserDefaults standardUserDefaults] integerForKey:@"launchCount"];
        NSLog(@"launchCount %d", launchCount);
        if (launchCount-- <= 0) {
            NSLog(@"Optimize database...");
            if (sqlite3_exec(theDatabase, optimize_sql, NULL, NULL, &errmsg) != SQLITE_OK) {
                NSLog(@"Error: failed to cleanup chache (%s)", errmsg);
            }
            launchCount = 50;
        }
        [[NSUserDefaults standardUserDefaults] setInteger:launchCount forKey:@"launchCount"];
        [[NSUserDefaults standardUserDefaults] synchronize];        
        sqlite3_close(theDatabase);
    }
}

// Creates a writable copy of the bundled default database in the application Documents directory.
+ (void)createEditableCopyOfDatabaseIfNeeded:(BOOL)force
{
    // 根据版本号判断，如果是新版本，删除数据库
    NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
    NSString *key=[NSString stringWithFormat:@"dbclear_%@",[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleVersionKey]];
    NSString *value=[def objectForKey:key];
    if (value==nil||[value isEqualToString:@"yes"]) {
        NSString *path = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@.sqlite",DATABASENAME];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
            [def setObject:@"no" forKey:key];
            [def synchronize];
        }
    }
//    [NSFileManager defaultManager] copy
}

+ (void)beginTransaction
{
    char *errmsg;     
    sqlite3_exec(theDatabase, "BEGIN", NULL, NULL, &errmsg);     
}

+ (void)commitTransaction
{
    char *errmsg;     
    sqlite3_exec(theDatabase, "COMMIT", NULL, NULL, &errmsg);     
}

+ (Statement*)statementWithQuery:(const char *)sql
{
    Statement* stmt = [Statement statementWithDB:theDatabase query:sql];
    return stmt;
}


@end
