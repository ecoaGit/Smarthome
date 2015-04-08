//
//  DeviceViewCell.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/13.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UILabel *deviceName;
@property (nonatomic, retain) IBOutlet UIImageView *deviceState;

@end
