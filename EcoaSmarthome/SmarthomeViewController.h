//
//  SmarthomeViewController.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/6.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "import.h"
#import "DeviceViewCell.h"
#import "DeviceDataView.h"
#import "SessionManager.h"

@interface SmarthomeViewController : UITableViewController <NSURLConnectionDataDelegate, NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate>
{
    NSString *TAG;
    FMDatabase *db;
    NSMutableData *data;
    int ccount;
    
    SessionManager *manager;
}

@property (nonatomic, strong) NSMutableArray *deviceList;
@property (nonatomic, strong) NSMutableArray *serverList;
@property (nonatomic, strong) UIBarButtonItem *close;
@property (retain, strong) UIBarButtonItem *logout;
@property (retain, strong) UIBarButtonItem *refresh;
@property (retain, strong) UIBarButtonItem *loginDefault;

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response;
-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;
-(void) connectionDidFinishLoading:(NSURLConnection *)connection;
-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;

@end
