//
//  HIstoryViewController.h
//  EcoaSmarthome
//
//  Created by Apple on 2016/3/31.
//  Copyright © 2016年 ECOA. All rights reserved.
//
#import "import.h"
#import "AlarmHelper.h"
#import "AlarmViewCell.h"
#import <UIKit/UIKit.h>

@interface HIstoryViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *array;
    AlarmHelper *helper;
}

@end
