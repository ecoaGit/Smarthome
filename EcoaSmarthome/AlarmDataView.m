//
//  AlarmDataView.m
//  EcoaSmarthome
//
//  Created by Apple on 2016/3/18.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "AlarmDataView.h"

@implementation AlarmDataView



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        alarmMessage = [[UILabel alloc]initWithFrame:CGRectMake(0, 20, self.frame.size.width-40, 20)];
        [alarmMessage setFont:[UIFont boldSystemFontOfSize:12]];
        [alarmMessage setTextColor:[UIColor blueColor]];
        [alarmMessage setBackgroundColor:[UIColor clearColor]];
        [alarmMessage setTextAlignment:NSTextAlignmentCenter];
        alarmTime = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, self.frame.size.width-40, 20)];
        [alarmTime setFont:[UIFont boldSystemFontOfSize:12]];
        [alarmTime setTextColor:[UIColor blueColor]];
        [alarmTime setBackgroundColor:[UIColor clearColor]];
        [alarmTime setTextAlignment:NSTextAlignmentCenter];
        [self addSubview:alarmMessage];
        [self addSubview:alarmTime];
    }
    return self;
}

- (void) setMessage:(NSString*)message andTime:(NSString*)time{
    [alarmMessage setText:message];
    [alarmTime setText:time];
}
@end
