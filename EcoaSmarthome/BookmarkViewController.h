//
//  BookmarkViewController.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/5/26.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "import.h"
#import "BookmarkViewCell.h"
#import "CustomIOS7AlertView.h"
#import "BookmarkDataView.h"
#import "EcoaDBHelper.h"

@interface BookmarkViewController : UITableViewController <CustomIOS7AlertViewDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>
{
    FMDatabase *ecoaDB;
    NSMutableArray *deviceList;
    BOOL isEditing;
}

@property (nonatomic, retain) UIBarButtonItem *rButton;

@end
