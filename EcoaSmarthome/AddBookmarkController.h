//
//  AddBookmarkController.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/4.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "import.h"

@interface AddBookmarkController : UITableViewController
{
    FMDatabase *db;
}

@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *ipLabel;
@property (nonatomic, retain) IBOutlet UILabel *usernameLabel;
@property (nonatomic, retain) IBOutlet UILabel *passwordLabel;
@property (nonatomic, retain) IBOutlet UITextField *name;
@property (nonatomic, retain) IBOutlet UITextField *ip;
@property (nonatomic, retain) IBOutlet UITextField *username;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIButton *rButton;
@property (nonatomic, retain) IBOutlet UIButton *lButton;

@end
