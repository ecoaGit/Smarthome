//
//  EcoaDBHelper.h
//  EcoaSmartHome
//
//  Created by Apple on 2014/5/12.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "import.h"

@interface EcoaDBHelper : NSObject {
    FMDatabase *database;
}

@property (readonly, nonatomic) FMDatabase *database;

- (BOOL) openDataBase;
- (void) closeDataBase;
- (void) createDataBase;
+ (EcoaDBHelper *) newInstance;
- (NSString *) getDatabasePath;
//- (sqlite3_stmt *) executeQuery : (NSString *)query;

@end
