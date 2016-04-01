//
//  AlarmHelper.h
//  EcoaSmarthome
//
//  Created by Apple on 2016/3/8.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "import.h"

@interface AlarmHelper : NSObject

    -(void) closeDatabase;
    -(void) saveAlarm:(NSString *)tag pid:(NSString *)pid message:(NSString *)message content:(NSString*)content sTime:(NSString*)sTime eTime:(NSString*)eTime sVal:(NSString*)sVal eVal:(NSString*)eVal pip:(NSString*)pip mode:(int)mode readed:(int)readed;
    -(void) saveAlarm:(NSString*)message withTime:(NSString*)time withPip:(NSString*)pip withMode:(int)mode;
    -(void) saveIPCamAlarm:(NSString*)camid time:(NSString*)time pip:(NSString*)pip mode:(int)mode content:(NSString*)content;
    -(int) checkForIPCamUpdate:(NSString*)camid;
    -(int) checkForUpdate:(NSString*)pid;
    -(void) updateAlarm:(NSString*)tag pid:(NSString*)pid message:(NSString*)message content:(NSString*)content sTime:(NSString*)sTime eTime:(NSString*)eTime sVal:(NSString*)sVal eVal:(NSString*)eVal pip:(NSString*)pip mode:(int)mode readed:(int)readed;
    -(void) setReaded:(NSString*)tag;
    -(void) deleteAlarm:(NSString *)tag;
    -(void) deleteAlarmWithTime:(NSString *)time;
    -(FMResultSet *) getAlarmList;
    -(FMResultSet *) getAlarmHistory;

@end
