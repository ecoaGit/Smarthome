//
//  AlarmDataView.h
//  EcoaSmarthome
//
//  Created by Apple on 2016/3/18.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmDataView : UIView
{
    UILabel *alarmMessage;
    UILabel *alarmTime;
}
- (void) setMessage:(NSString*)message andTime:(NSString*)time;

@end
