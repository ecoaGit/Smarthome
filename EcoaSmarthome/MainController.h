//
//  MainController.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/7/31.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "SessionManager.h"
#import "AlarmViewCell.h"
#import "WebViewController.h"
#import "AlarmDataView.h"

@interface MainController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate> {
    SessionManager *manager;
    NSMutableArray *alarmList;
    UIWebView *web;
    UINavigationBar *nBar;
}

@property (nonatomic, retain) IBOutlet UIButton *smarthome;
@property (nonatomic, retain) IBOutlet UIButton *myFavorites;
@property (nonatomic, retain) IBOutlet UIButton *sipPhone;
@property (nonatomic, retain) IBOutlet UIButton *setting;
@property (nonatomic, retain) IBOutlet UIButton *history;
//@property (nonatomic, retain) IBOutlet UIButton *newcity;
@property (nonatomic, retain) IBOutlet UITableView *board;
@property (nonatomic, retain) IBOutlet UILabel *regisLabel;
@property (nonatomic, retain) IBOutlet UIImageView *regisMode;



@end
