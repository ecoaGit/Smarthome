//
//  SessionManager.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/26.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "SessionManager.h"

@implementation SessionManager

static SessionManager *instance = nil;

-(id) init {
    self = [super init];
    [self initializeManager];
    useBookmark = false;
    return self;
}

+(id) alloc {
    @synchronized ([SessionManager class]) {
        NSAssert(_singletonObject == nil, @"_singletonObject 已經做過記憶體配置");
        instance = [super alloc];
        return instance;
    }
    return  nil;
}

+ (SessionManager *) getInstance {
    @synchronized ([SessionManager class]) {
        if (!instance) {
            [[self alloc] init];
        }
        return instance;
    }
    return nil;
}

- (void)initializeManager {
    serverList = [self getServerList];
    //NSLog(@"%@", serverList);
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleServerList:) name:@"serverList" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleDeviceList:) name:@"deviceList" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleLogin:) name:@"login" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(handleLogout:) name:@"logout" object:nil];
    ccount = 0;
    //[self getServerListFromCloud];
}

- (void) handleServerList:(NSNotification *)notify{
    if ([notify object] != nil) {
        serverList = [notify object];
    }
    [self login];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

/**
 * 登入伺服器完成後取得設備ip  
 *
 */
- (void) handleDeviceList:(NSNotification *)notify{

    ccount ++;
    if (ccount == serverList.count) {
        
        ccount = 0;
    }
}

- (void) handleLogin:(NSNotification *)notify{
    if ([[notify object]isEqualToString:@"done"]) {
        login = true;
        [self getDeviceList];
    }
}

- (void) handleLogout:(NSNotification *)notify{
    if ([[notify object]isEqualToString:@"done"]) {
        login = false;
    }
}

/**
 *
 *  登入雲端伺服器
 *
 */
- (BOOL) login {
    
    NSLog(@"login");
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [userDefaults stringForKey:@"cloudUsername"];
    NSString *password = [userDefaults stringForKey:@"cloudPassword"];
    NSString *command = [NSString stringWithFormat:@"&account=%@&password=%@", [username stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],
                         [password stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    if (serverList == nil) {
        NSLog(@"serverList nil");
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://ecoacloud.com:80/account/login"] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:15];
        [request setHTTPBody:[command dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPMethod:@"POST"];
        
        // fire request
        NSOperationQueue *queue = [[NSOperationQueue alloc]init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *result, NSError *error) {
            if (error) {
                // failed when login
            }
            else {
                NSDictionary *nsJson = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
                
                if ([nsJson objectForKey:@"chkMsg"] != nil) {
                    // error
                    NSString *error = [nsJson objectForKey:@"chkMsg"];
                    NSLog(@"error : %@", error);
                    [serverList replaceObjectAtIndex:0 withObject:[NSMutableArray arrayWithObjects:@"http://ecoacloud.com.80/", @"", nil]];
                } else {
                    NSString *session = [nsJson objectForKey:@"__sess"];
                    [serverList replaceObjectAtIndex:0 withObject:[NSMutableArray arrayWithObjects:@"http://ecoacloud.com.80/", @"0", session, nil]];
                }
                [[NSNotificationCenter defaultCenter]postNotificationName:@"login" object:@"done"];
            }
        }];
    }
    else {
        for (int i = 0; i < serverList.count;i++) {
            NSString *serverIP = [[serverList objectAtIndex:i]objectAtIndex:0];
            NSString *number = [[serverList objectAtIndex:i] objectAtIndex:1];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[serverIP stringByAppendingString:@"/account/login"]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
            [request setHTTPBody:[command dataUsingEncoding:NSUTF8StringEncoding]];
            [request setHTTPMethod:@"POST"];
            
            // fire request
            NSOperationQueue *queue = [[NSOperationQueue alloc]init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *result, NSError *error) {
                if (error) {
                    // login failed
                }
                else {
                // handle return
                    NSDictionary *nsJson = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
                    
                    if ([nsJson objectForKey:@"chkMsg"] != nil) {
                        NSLog(@"%@", [nsJson objectForKey:@"chkMsg"]);
                        [serverList insertObject:[NSMutableArray arrayWithObjects:serverIP, number, @"", nil] atIndex:0];
                    } else {
                        NSString *session = [nsJson objectForKey:@"__sess"];
                        [serverList replaceObjectAtIndex:i withObject:[NSMutableArray arrayWithObjects:serverIP, number, session, nil]];
                    }
                    if (i == serverList.count -1) {
                        [[NSNotificationCenter defaultCenter]postNotificationName:@"login" object:@"done"];
                    }
                }
            }];
        }
    }
    return true;

}

- (BOOL) logout {
    NSLog(@"logout");
    
    if (!login) {
        NSLog(@"logged in first");
        return true;
    }
    // 登出cloud server
    for (int i = 0; i <serverList.count;i++) {
        if ([[serverList objectAtIndex:i]objectAtIndex:2]) {
            NSString *serverIP = [[serverList objectAtIndex:i]objectAtIndex:0];
            NSString *command = @"/account/logout";
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[serverIP stringByAppendingString:command]] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:5];
            [request setHTTPMethod:@"GET"];
            NSOperationQueue *queue = [[NSOperationQueue alloc]init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *result, NSError *error) {
                if (error) {
                    NSLog(@"error");
                }
                else {
                    NSDictionary *nsJson = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
                    
                    if ([nsJson objectForKey:@"chkMsg"] != nil) {
                        if ([[nsJson objectForKey:@"chkMsg"] isEqualToString:@"OK"]) {
                            [[NSNotificationCenter defaultCenter]postNotificationName:@"logout" object:@"done"];
                            NSLog(@"logout is done");
                        }
                        else {
                            NSLog(@"%@", [nsJson objectForKey:@"chkMsg"]);
                        }
                    }
                }
            }];
        }
    }
    
    return true;
}

/**
 * 
 *  檢查登入狀態
 *
 */

- (BOOL)isLogin {
    return login;
}

/**
 *
 *  從雲端伺服器下載新的伺服器列表
 *
 */

- (BOOL)getServerListFromCloud {
    NSString *url;
    if (serverList != nil) {
        url = [[serverList objectAtIndex:0]objectAtIndex:0];
        url = [url stringByAppendingString:@"./server_list"];
    }
    else {
        NSLog(@"use default");
        url = @"http://ecoacloud.com:80/server_list";
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:15];
    [request setHTTPMethod:@"POST"];
    NSOperationQueue *queue = [[NSOperationQueue alloc]init];
    [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *result, NSError *error) {
        if (error) {
            // 取得serverlist失敗
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error!" message:@"network issues" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        }
        else {
            NSDictionary *nsJson = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&error];
            
            if ([nsJson objectForKey:@"chkMsg"] != nil) {
                // server回傳錯誤
                NSLog(@"%@", [nsJson objectForKey:@"chkMsg"]);
            } else {
                int count = [[nsJson objectForKey:@"list_ct"]intValue];
                if (count > 0) {
                    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:count];
                    NSArray *list = [nsJson objectForKey:@"list"];
                    for (int i = 0; i < count;i++ ) {
                        NSDictionary *arr = [list objectAtIndex:i];
                        NSString *ip = [arr objectForKey:@"ip_path"];
                        NSString *number = [arr objectForKey:@"number"];
                        if (number == nil) {
                            number = @"";
                        }
                        NSString *name = [arr objectForKey:@"name"];
                        if (name == nil) {
                            name = @"";
                        }
                        NSArray *ttemp = [[NSArray alloc]initWithObjects:ip, number, name, nil];
                        [temp addObject:ttemp];
                        //[serverList addObject:[NSNull null]];
                        //[serverList replaceObjectAtIndex:i withObject:temp];
                    }
                    
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"serverList" object:temp];
                    //[self updateServerList];
                }else {
                    NSLog(@"no result return from cloud");
                }
            }
        }
    }];
    return true;
}

/**
 *  讀取資料庫內的雲端伺服器列表
 *
 */

- (NSMutableArray *)getServerList {
    NSMutableArray *temp;
    if ([self initDatabase]) {
        NSString *query = @"SELECT count(distinct ip_path) as count from server_list";
        FMResultSet *rs = [db executeQuery:query];
        int count = 0;
        if ([rs next]) {
            count = [rs intForColumn:@"count"];
        }
        [rs close];
        if (count > 0) {
            temp = [NSMutableArray arrayWithCapacity:count];
            
            query = @"SELECT * from server_list";
            rs = [db executeQuery:query];
            while([rs next]) {
                NSString *serverIP = [rs stringForColumn:@"ip_path"];
                NSString *number = [NSString stringWithFormat:@"%d", [rs intForColumn:@"number"]];
                [temp addObject:[NSMutableArray arrayWithObjects:serverIP, number, @"", nil]];
            }
            [rs close];
        }
        else {
            temp = [NSMutableArray arrayWithCapacity:1];
            NSString *ip = @"http://ecoacloud.com:80/";
            NSString *number = @"0";
            NSString *name = @"default server";
            NSArray *def = [NSArray arrayWithObjects:ip, number, name, nil];
            [temp addObject:def];
        }
    }
    [db close];
    return temp;
}

/**
 *  更新雲端伺服器列表
 *
 */

- (void) updateServerList {
    if ([self initDatabase]) {
        [db executeUpdate:@"DELETE FROM server_list where number != -1"];
        for (int i = 0;i < serverList.count; i++) {
            NSString *ip = [[serverList objectAtIndex:i]objectAtIndex:0];
            NSNumber *number = [NSNumber numberWithInt:[[[serverList objectAtIndex:i]objectAtIndex:1]intValue]];
            NSString *name = [[serverList objectAtIndex:i]objectAtIndex:2];
            NSString *ins = @"INSERT into server_list (ip_path, number, name) VALUES (?, ?, ?)";
            [db executeUpdate:ins, ip, number, name];
        }
    }
    else {
        NSLog(@"can't update list");
    }
    
    [db close];
    return;
}

/**
 *   下載並比對設備列表
 *
 */

- (NSMutableArray *) getDeviceList:(int) n {
    return deviceList;
}

- (void) getDeviceList {
    NSLog(@"getdevicelist");
    NSString *url;

    for (int i = 0; i < serverList.count; i++) {
        NSString *sess = [[serverList objectAtIndex:i]objectAtIndex:2];
        if (![sess isEqualToString:@""]){
            url = [[serverList objectAtIndex:i]objectAtIndex:0];
            url = [url stringByAppendingString:[NSString stringWithFormat:@"./my_devices?tm=%f", [[NSDate date]timeIntervalSince1970] * 1000]];
            
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:15];
            [request setHTTPMethod:@"GET"];
            [request setValue:sess forHTTPHeaderField:@"Auth-Token"];
            NSOperationQueue *queue = [[NSOperationQueue alloc]init];
            [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *result, NSError *error) {
                if (error.code == NSURLErrorTimedOut) {
                    NSLog(@"use old data");
                    NSDictionary *nd = [NSDictionary dictionaryWithObjectsAndKeys:deviceList, @"list", nil];
                    [[NSNotificationCenter defaultCenter]postNotificationName:@"deviceData" object:@"cloud" userInfo:nd];
                }
                else {
                    NSError *jsonError;
                    //NSLog(@"use cloud data");
                    if (result != NULL){
                        //NSLog(@"result != null");
                        NSDictionary *nsJson = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingMutableLeaves error:&jsonError];
                        //NSLog(@"%@", [nsJson description]);
                    
                        if ([nsJson objectForKey:@"chkMsg"] != nil) {
                            // error
                            NSString *error = [nsJson objectForKey:@"chkMsg"];
                            NSLog(@"error message %@", error);
                        }
                        else if ([nsJson objectForKey:@"list"] != nil){
                            int count = [[nsJson objectForKey:@"list_count"]intValue];
                            NSArray *list = [nsJson objectForKey:@"list"];
                            NSString *selfIp = [nsJson objectForKey:@"destinationIP"];
                            
                            NSMutableArray *temp = [NSMutableArray arrayWithCapacity:count];
                            for (int i = 0; i < count; i++) {
                                NSDictionary *ns = [list objectAtIndex:i];
                                
                                NSString *decodeUTF8 = [ns objectForKey:@"alias"];
                                decodeUTF8 = [decodeUTF8 stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                                NSData *decode64 = [[NSData alloc]initWithBase64EncodedString:decodeUTF8 options:0];
                                NSString *alias = [[NSString alloc]initWithData:decode64 encoding:NSUTF8StringEncoding];
            
                                NSString *state = [ns objectForKey:@"state"];
                                NSString *wan_ip = [ns objectForKey:@"wan_ip"];
                                NSString *wan_port = [ns objectForKey:@"wan_port"];
                                NSString *lan_ip = [ns objectForKey:@"lan_ip"];
                                NSString *lan_port = [ns objectForKey:@"lan_port"];
                                NSString *did = [ns objectForKey:@"did"];
                                NSString *update = [ns objectForKey:@"update_time"];
                                
                                NSArray *arr = [[NSArray alloc]initWithObjects:alias, state, wan_ip, wan_port, lan_ip, lan_port, did, update, nil];
                                [temp addObject:arr];
                            }
                            
                            if (temp != nil)
                            {
                                deviceList = temp;
                                NSDictionary *nd = [NSDictionary dictionaryWithObjectsAndKeys:temp, @"list", selfIp, @"selfIp", nil];
                                
                                [[NSNotificationCenter defaultCenter]postNotificationName:@"deviceData" object:@"cloud" userInfo:nd];
                            }
                            else {
                                NSLog(@"temp is null don't use it");
                            }
                        }
                    }
                }
            }];
        }
        else {
            // use default address
            
        }
    }
    
}
/**
 *  初始化資料庫
 *
 */

- (BOOL) initDatabase {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diretory = [path objectAtIndex:0];
    NSString *dbPath = [diretory stringByAppendingPathComponent:@"EcoaDatabase.db"];
    db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        NSLog(@"database is open");
        return true;
    }
    else {
        NSLog(@"open database failed");
        return false;
    }
}

- (BOOL) useBookmark {
    return useBookmark;
}

- (void) getBookmark {
    NSString *query = @"SELECT _id, bookmarkname, ipaddress, userid, password from bookmark_list order by _id";
    
    FMResultSet *res = [db executeQuery:query];
    if ([res columnCount] > 0) {
        
    }
}

@end
