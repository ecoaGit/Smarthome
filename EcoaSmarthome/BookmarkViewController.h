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
#import "LoadingView.h"

@interface BookmarkViewController : UITableViewController <CustomIOS7AlertViewDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate, UIWebViewDelegate>
{
    FMDatabase *ecoaDB;
    NSMutableArray *deviceList;
    BOOL isEditing;
    CustomIOS7AlertView *splash;
}

@property (nonatomic, retain) UIBarButtonItem *rButton;

@end
