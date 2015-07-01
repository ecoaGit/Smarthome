//
//  SessionManager.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/26.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "import.h"
@interface SessionManager : NSObject <NSURLConnectionDelegate>
{
    FMDatabase *db;
    BOOL login;
    NSMutableArray *serverList;
    NSMutableArray *deviceList;
    int ccount;
    BOOL useBookmark;
    NSString *selfIp;
}
+ (SessionManager *)getInstance;
- (void) initializeManager;
- (BOOL) login;
- (BOOL) logout;
- (BOOL) isLogin;
- (void) getDeviceList;
- (NSMutableArray *) getDeviceList:(int) n;
- (BOOL) getServerListFromCloud;
- (BOOL) useBookmark;
- (NSString *) getSelfIp;
@end
