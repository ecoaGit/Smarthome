//
//  EcoaDBHelper.m
//  EcoaSmartHome
//
//  Created by Apple on 2014/5/12.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "EcoaDBHelper.h"

@implementation EcoaDBHelper

static EcoaDBHelper *sInstance = nil;

@synthesize database;

- (BOOL) openDataBase {
    
    if (!database.open) {
        NSLog(@"could not open database");
        return false;
    }
    else {
        return true;
    }
    
}

- (void) closeDataBase {
    if (database.open) {
        [database close];
    }
    return;
}

- (void) createDataBase {
    NSLog(@"create database");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSString *databasePath = [self getDatabasePath];

    // check if database exists
    if ([fileManager fileExistsAtPath:databasePath]) {
        NSLog(@"database already exists");
        return;
    }
    
    // create database
    database = [FMDatabase databaseWithPath:databasePath];
    if (!database.open) {
        NSLog(@"could not open database");
        return;
    }
    
    // create bookmark_list table
    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS bookmark_list (_id INTEGER PRIMARY KEY, bookmarkname TEXT, ipaddress TEXT, userid TEXT, password TEXT )"];
    // create server_list table
    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS server_list (_id INTEGER PRIMARY KEY, number INTEGER, ip_path TEXT,  name TEXT DEFAULT '')"];
    // create aralm_list
    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS alarm_list (tag TEXT PRIMARY KEY, mode INTEGER, pid TEXT, message TEXT, content TEXT, stime TEXT, etime TEXT, sval TEXT, eval TEXT, pip TEXT,readed INTEGER)"];
    // create device_list
    [database executeUpdate:@"CREATE TABLE IF NOT EXISTS device_list (id TEXT PRIMARY KEY, p_code TEXT, name TEXT"];
    
    [database close];
}

+ (EcoaDBHelper *) newInstance {
    @synchronized (self) {
        if (sInstance == nil) {
            sInstance = [[EcoaDBHelper alloc] init];
            [sInstance createDataBase];
        }
    }
    return sInstance;
}

- (NSString *) getDatabasePath {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diretory = [path objectAtIndex:0];
    NSString *dbPath = [diretory stringByAppendingPathComponent:@"EcoaDatabase.db"];
    
    return dbPath;
}




@end
