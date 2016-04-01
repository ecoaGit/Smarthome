//
//  AlarmViewCell.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/12/31.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "AlarmViewCell.h"

@implementation AlarmViewCell

@synthesize alarmTitle;
@synthesize alarmMessage;
@synthesize alarmstate;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
