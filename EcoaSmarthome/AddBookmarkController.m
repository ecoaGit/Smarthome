//
//  AddBookmarkController.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/4.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "AddBookmarkController.h"

@interface AddBookmarkController ()

@end

@implementation AddBookmarkController

@synthesize nameLabel;
@synthesize ipLabel;
@synthesize usernameLabel;
@synthesize passwordLabel;
@synthesize name;
@synthesize ip;
@synthesize username;
@synthesize password;
@synthesize rButton;
@synthesize lButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    //[self initDatabase];
    [self setUI];
    UIBarButtonItem *backbutton = [[UIBarButtonItem alloc]initWithTitle:NSLocalizedString(@"cancel", @"button text") style:UIBarButtonItemStyleBordered target:self action:@selector(lButtonAction:)];
    
    [self.navigationItem setLeftBarButtonItem:backbutton];
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL) initDatabase {
    // initailize database
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diretory = [path objectAtIndex:0];
    NSString *dbPath = [diretory stringByAppendingPathComponent:@"EcoaDatabase.db"];
    db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        NSLog(@"database is open");
        return true;
    }
    else {
        NSLog(@"open database failed");
        return false;
    }
}

- (void) setUI {
    [nameLabel setText:NSLocalizedString(@"name", @"label text")];
    [ipLabel setText:NSLocalizedString(@"ip", @"label text")];
    [usernameLabel setText:NSLocalizedString(@"username", @"label text")];
    [passwordLabel setText:NSLocalizedString(@"password", @"label text")];
    [rButton setTitle:NSLocalizedString(@"save", @"button text") forState:UIControlStateNormal];
    [lButton setTitle:NSLocalizedString(@"cancel", @"button text") forState:UIControlStateNormal];
    
}

- (NSString *) checkData {
    if ([[[name text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""]) {
        return NSLocalizedString(@"blank_name_alert", @"alert text");
    }
    if ([[[ip text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""]) {
        return NSLocalizedString(@"blank_name_alert", @"alert text");
    }
    return @"";
}

- (IBAction)lButtonAction:(id)sender {
    [self.presentingViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)rButtonAction:(id)sender {
    NSString *result = [self checkData];
    if ([result isEqualToString:@""]) {
        if ([self initDatabase]) {
            [db executeUpdate: @"INSERT INTO bookmark_list (bookmarkname, ipaddress, userid, password) VALUES (?,?,?,?)", [name text], [ip text], [username text], [password text]];
            [db close];
            [self.presentingViewController.presentedViewController dismissViewControllerAnimated:YES completion:nil];
        }
        else {
            // show alert
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"save_failed", @"alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"text")otherButtonTitles:nil];
            [alert show];
        }
    }
    else {
        // show alert
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:result delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"text") otherButtonTitles: nil];
        [alert show];
    }
}

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
