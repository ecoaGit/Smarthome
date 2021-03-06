//
//  SettingViewController.h
//  EcoaSmartHome
//
//  Created by Apple on 2014/5/8.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "import.h"
#import "AppDelegate.h"

@interface SettingViewController : UITableViewController<UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate, UITextFieldDelegate>
{
    BOOL isEditing;

}

@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UISwitch *userLock;
@property (nonatomic, retain) IBOutlet UITextField *appPassword;
@property (nonatomic, retain) IBOutlet UITextField *cloudAddress;
@property (nonatomic, retain) IBOutlet UITextField *cloudUsername;
@property (nonatomic, retain) IBOutlet UITextField *cloudPassword;
@property (nonatomic, retain) IBOutlet UITextField *sipAddress;
@property (nonatomic, retain) IBOutlet UITextField *sipUsername;
@property (nonatomic, retain) IBOutlet UITextField *sipPassword;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *appPassLabel;
@property (nonatomic, retain) IBOutlet UILabel *cloudAddLabel;
@property (nonatomic, retain) IBOutlet UILabel *cloudNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *cloudPassLabel;
@property (nonatomic, retain) IBOutlet UILabel *sipAddLabel;
@property (nonatomic, retain) IBOutlet UILabel *sipNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *sipPassLabel;
@property (nonatomic, retain) IBOutlet UISwitch *useWifi;
@property (nonatomic, retain) IBOutlet UISwitch *use3G;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *rButton;
@property (nonatomic, retain) IBOutlet UILabel *autoSipLabel;
@property (nonatomic, retain) IBOutlet UILabel *showAlarmLabel;
@property (nonatomic, retain) IBOutlet UISwitch *useAutoSip;
//@property (nonatomic, retain) IBOutlet UISwitch *useShowAlarm;



- (void) setUI : (BOOL) editable;
- (IBAction) showAppPassword : (id) sender;

@end
