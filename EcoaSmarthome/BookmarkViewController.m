//
//  BookmarkViewController.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/5/26.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "BookmarkViewController.h"

@interface BookmarkViewController () <CustomIOS7AlertViewDelegate, UITableViewDataSource, UITableViewDelegate, NSURLConnectionDataDelegate>

@end

@implementation BookmarkViewController

@synthesize rButton;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    isEditing = false;
    rButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStyleBordered target:self action:@selector(buttonAction:)];
    [rButton setImageInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setRightBarButtonItem:rButton];
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationItem setHidesBackButton:NO];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    
    UILongPressGestureRecognizer *recnizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onLongPress:)];
    [self.tableView addGestureRecognizer:recnizer];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self readBookmarkListFromDatabase];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)readBookmarkListFromDatabase {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diretory = [path objectAtIndex:0];
    NSString *dbPath = [diretory stringByAppendingPathComponent:@"EcoaDatabase.db"];

 
    // open database or create it if didn't exists.
    ecoaDB = [FMDatabase databaseWithPath:dbPath];
    if ([ecoaDB open]) {
        NSLog(@"database opened");
    }
    else {
        NSLog(@"database open failed");
        return false;
    }
    
    NSString *query = @"SELECT _id, bookmarkname, ipaddress, userid, password from bookmark_list order by _id";
    
    NSLog(@"read data from database");
    FMResultSet *rs = [ecoaDB executeQuery:query];
    if ([rs columnCount] > 0) {
        deviceList = [[NSMutableArray alloc] initWithCapacity:[rs columnCount]];
        NSInteger count = 0;
        while ([rs next]) {
            
            NSString *bookmarkName = [rs stringForColumn:@"bookmarkname"];
            NSString *ip = [rs stringForColumn:@"ipaddress"];
            NSString *username = [rs stringForColumn:@"userid"];
            NSString *password = [rs stringForColumn:@"password"];
            NSString *b_id = [rs stringForColumn:@"_id"];
            
            [deviceList insertObject:[NSMutableArray arrayWithObjects:bookmarkName, ip, username, password, b_id, nil] atIndex:count];
            count++;
        }
    }
    else {
        NSLog(@"no data");
    }
    [rs close];
    [ecoaDB close];
    
    return true;
}

- (IBAction) buttonAction:(id)sender {
    
    [self performSegueWithIdentifier:@"add bookmark" sender:self];
}

- (void) dealloc {

}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *path = [NSString stringWithFormat:@"http://%@", [[deviceList objectAtIndex:indexPath.row] objectAtIndex:1]];
   
    NSString *username = [[deviceList objectAtIndex:indexPath.row] objectAtIndex:2];
    NSString *password = [[deviceList objectAtIndex:indexPath.row] objectAtIndex:3];
   
    
    if (![username isEqualToString:@""] &&![password isEqualToString:@""]) {
        NSLog(@"user data is not null");
        NSData* data = [[NSString stringWithFormat:@"%@:%@", username, password]dataUsingEncoding:NSUTF8StringEncoding];
        NSString *auth = [[NSString alloc]initWithData:[data base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
        path = [path stringByAppendingString:[NSString stringWithFormat:@"?auth=%@", auth]];
    }
    NSURL *url = [NSURL URLWithString:path];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
   
    UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    web.scalesPageToFit = YES;
    [web setAutoresizesSubviews:YES];
    [web setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    [web loadRequest:request];
    [web setTag:55];
    [self.view addSubview:web];
    
    [self.navigationItem setHidesBackButton:YES];
    [rButton setImage:[UIImage imageNamed:@"back"]];
    [rButton setAction:@selector(closeWebView:)];
    
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
}

- (IBAction) closeWebView:(id) sender {
    [[self.view viewWithTag:55]removeFromSuperview];
    [rButton setImage:[UIImage imageNamed:@"edit"]];
    [rButton setAction:@selector(buttonAction:)];
    [self.navigationItem setHidesBackButton:NO];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [deviceList count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"table cell");
    BookmarkViewCell *cell = (BookmarkViewCell *)[tableView dequeueReusableCellWithIdentifier:@"BookmarkListCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (cell == nil) {
        NSLog(@"create cell");
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"BookmarkViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (deviceList != nil) {
        [cell.deviceName setText:[[deviceList objectAtIndex:indexPath.row] objectAtIndex:0]];
        [cell.deviceIP setText:[[deviceList objectAtIndex:indexPath.row]objectAtIndex:1]];
    }
    
    return cell;
}


-(void)onLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self.tableView];
        NSIndexPath *path = [self.tableView indexPathForRowAtPoint:point];
        
        if (path == nil) {
            return;
        }
        else {
            CustomIOS7AlertView *alertview = [[CustomIOS7AlertView alloc]init];
            BookmarkDataView *datView = [[BookmarkDataView alloc]initWithFrameAndData:CGRectMake(0, 0, 300, 320) data:[deviceList objectAtIndex:path.row]];
            [alertview setContainerView:datView];
            [alertview setButtonTitles:[NSMutableArray arrayWithObjects:NSLocalizedString(@"delete", "text"), NSLocalizedString(@"save_exit", "text"), nil]];
            [alertview setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
                if (buttonIndex == 1) {
                    
                    NSString *query =[NSString stringWithFormat:@"UPDATE bookmark_list SET bookmarkname='%@', ipaddress='%@', userid='%@', password='%@' WHERE _id='%@'",[datView.bookmarkName text], [datView.ip text], [datView.username text], [datView.password text], [[deviceList objectAtIndex:path.row] objectAtIndex:4]];
                    
                    [ecoaDB open];
                    [ecoaDB executeUpdate:query];
                    [ecoaDB close];
                    
                    [self readBookmarkListFromDatabase];
                    [self.tableView reloadData];
                    [alertView close];
                }
                else if (buttonIndex == 0){
                    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSNumber *_id = [f numberFromString:[[deviceList objectAtIndex:path.row] objectAtIndex:4]];
                    [ecoaDB open];
                    [ecoaDB executeUpdate:@"DELETE from bookmark_list WHERE _id = ?", _id ];
                    [ecoaDB close];
                    
                    [self readBookmarkListFromDatabase];
                    [self.tableView reloadData];
                    [alertView close];
                }
            }];
            
            [alertview show];
        }
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
