//
//  AlarmViewCell.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/12/31.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AlarmViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *alarmstate;
@property (nonatomic, retain) IBOutlet UILabel *alarmTitle;
@property (nonatomic, retain) IBOutlet UILabel *alarmMessage;

@end
