//
//  AlarmHelper.m
//  EcoaSmarthome
//
//  Created by Apple on 2016/3/8.
//  Copyright © 2016年 ECOA. All rights reserved.
//
  
#import "AlarmHelper.h"

@implementation AlarmHelper

FMDatabase *db;
BOOL opened;

- (id)init {
    [self startDB];
    return self;
}

- (void)startDB{
    if (opened) {
        NSLog(@"AlarmHelper: database already opened");
        return;
    }
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diretory = [path objectAtIndex:0];
    NSString *dbPath = [diretory stringByAppendingPathComponent:@"EcoaDatabase.db"];
    db = [FMDatabase databaseWithPath:dbPath];
    opened = [db open];
    if (opened) {
        NSLog(@"AlarmHelper: database opened");
    }
    else {
        NSLog(@"AlarmHelper: failed when opening database");
    }
}

- (void) closeDatabase {
    BOOL dbClosed = [db close];
    if (dbClosed) {
        NSLog(@"AlarmHelper: database closed");
    }
    else {
        NSLog(@"AlarmHelper: failed when closing database");
    }
    opened = false;
}
-(void)saveAlarm:(NSString *)sql{
    NSString *query = @"SELECT count(*) FROM alarm_list ORDER BY time DESC";
    FMResultSet *rs = [db executeQuery:query];
    if (rs.next) {
        int count = [rs intForColumn:@"count"];
        if (count >=30) {
            NSString *tag = [rs[count-1] stringForColumn:@"tag"];
            [self deleteAlarmWithTag:tag];
        }
    }
    [self execsql:sql];
}

- (void)saveAlarm:(NSString *)tag pid:(NSString *)pid message:(NSString *)message content:(NSString *)content sTime:(NSString *)sTime eTime:(NSString *)eTime sVal:(NSString *)sVal eVal:(NSString *)eVal pip:(NSString *)pip mode:(int)mode readed:(int)readed {
    NSString *sql  = [NSString stringWithFormat: @"INSERT INTO alarm_list (tag,mode,pid,message,content,stime,etime,sval,eval,pip,readed) VALUES ('%@', %d, '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', %d)",tag,mode,pid,message,content,sTime,eTime,sVal,eVal,pip,readed];
    [self saveAlarm:sql];
}

- (void)saveAlarm:(NSString *)message withTime:(NSString *)time withPip:(NSString *)pip withMode:(int)mode {
    NSLog(@"AlarmHelper: saveAlarm");
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM alarm_list ORDER BY stime DESC"];
    NSUInteger count = [db intForQuery:@"SELECT COUNT(*) FROM alarm_list"];
    FMResultSet *rs = [db executeQuery:sql];
    if (rs.next) {
        //count = [rs intForColumn:@"count"];
        if (count >=30) {
            int redundant = (int)count -30;
            for (int i = 0; i <= redundant;i++) {
                NSString *tag = [rs[i] stringForColumn:@"tag"];
                [self deleteAlarmWithTag:tag];
            }
        }
    }
    else {
        NSLog(@"no result");
    }
    sql = [NSString stringWithFormat: @"INSERT INTO alarm_list (tag,mode,pid,message,content,stime,etime,sval,eval,pip,readed) VALUES ('%@', %d, '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', %d)",[NSString stringWithFormat:@"%f", ([[NSDate date] timeIntervalSince1970]/1000)],mode, @"",message, @"",time,@"",@"",@"",pip,0];
    [rs close];
    [self execsql:sql];
}

- (void)saveIPCamAlarm:(NSString *)camid time:(NSString *)time pip:(NSString *)pip mode:(int)mode content:(NSString *)content {
    int checkNum = [self checkForIPCamUpdate:camid];
    if(checkNum == 1){
        NSString *sql = [NSString stringWithFormat:@"UPDATE alarm_list SET mode=%d, pid='', message='IP CAM ALARM', content='%@', stime='%@', etime='', sval='', eval='', pip='%@', readed=0 WHERE tag='%@'", mode,content,time,pip,camid];
        [self execsql:sql];
    }
    else if(checkNum == 0){
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO alarm_list (tag,mode,pid,message,content,stime,etime,sval,eval,pip,readed) VALUES('%@',%d,'','IP CAM ALARM','%@','%@','','','','%@',0)", camid,mode,content,time,pip];
        [self execsql:sql];
    }
}

- (void)deleteAlarmWithTag:(NSString *)tag {
    NSString *sql =[NSString stringWithFormat:@"DELETE FROM alarm_list WHERE tag = '%@'", tag];
    [self execsql:sql];
}

- (void)deleteAlarmWithTime:(NSString *)time {
    NSString *sql =[NSString stringWithFormat:@"DELETE FROM alarm_list WHERE stime = '%@'", time];
    [self execsql:sql];
}

- (void)setReaded:(NSString *)tag {
    NSString *sql = [NSString stringWithFormat:@"UPDATE alarm_list SET readed=1 WHERE tag = '%@'", tag];
    [self execsql:sql];
}

- (int)checkForIPCamUpdate:(NSString *)camid {
    //NSString *sql = [NSString stringWithFormat:@"SELECT count(*) FROM alarm_list where tag='%@'", camid];
    //FMResultSet *rs = [db executeQuery:sql];
    int count = [db intForQuery:[NSString stringWithFormat:@"SELECT count(*) FROM alarm_list where tag='%@'", camid]];
    if (count > 0) {
        NSLog(@"this work");
        return 1;
    }
    else return 0;
    /*if (rs.next && [rs intForColumn:@"count"] > 0) {
        return 1;
    }
    else {
        return 0;
    }*/
}

- (int)checkForUpdate:(NSString *)pid {
    NSString *sql = [NSString stringWithFormat:@"SELECT count(etime) FROM  alarm_list where tag='%@'", pid];
    FMResultSet *rs = [db executeQuery:sql];
    if (rs.next && [rs intForColumn:@"count"] > 0) {
        if ([[rs[0] stringForColumn:@"etime"] isEqualToString:@""]) {
            [rs close];
            return 1;//update
        }
        else {
            [rs close];
            return 2;//ignore
        }
    }
    [rs close];
    return 0;//insert
}

- (void)updateAlarm:(NSString *)tag pid:(NSString *)pid message:(NSString *)message content:(NSString *)content sTime:(NSString *)sTime eTime:(NSString *)eTime sVal:(NSString *)sVal eVal:(NSString *)eVal pip:(NSString *)pip mode:(int)mode readed:(int)readed {
    
}

- (void)execsql:(NSString *)sql{
    NSLog(@"AlarmHelper: execsql");
    if (opened) {
        BOOL result = [db executeUpdate:sql];
        if (result) {
            NSLog(@"AlarmHelper: execsql success");
        }
        else {
            NSLog(@"AlarmHelper: execsql failed");
        }
    }
    else {
        NSLog(@"AlarmHelper: open db first");
    }
}

-(FMResultSet *)getAlarmList {
    if (!opened) {
        [self startDB];
    }
    if (opened) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM alarm_list WHERE readed = 0 ORDER BY stime DESC limit 30"];
        if (rs != nil) {
            return rs;
        }
        else {
            NSLog(@"getAlarmList fix the code");
            return nil;
        }
    }
    else {
        return nil;
    }
}

-(FMResultSet *)getAlarmHistory{
    if (!opened) {
        [self startDB];
    }
    if (opened) {
        FMResultSet *rs = [db executeQuery:@"SELECT * FROM alarm_list WHERE readed = 1 ORDER BY stime DESC"];
        if (rs != nil) {
            return rs;
        }
        else {
            NSLog(@"fix the code");
            return nil;
        }
    }
    else {
        return nil;
    }
    
}


@end

