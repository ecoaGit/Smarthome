//
//  DeviceViewCell.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/13.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "DeviceViewCell.h"

@implementation DeviceViewCell

@synthesize deviceName;
@synthesize deviceState;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        deviceState.contentMode = UIViewContentModeScaleAspectFit;
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
