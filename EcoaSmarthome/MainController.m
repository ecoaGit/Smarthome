//
//  MainController.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/7/31.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "MainController.h"

@interface MainController () <UITableViewDelegate, UITableViewDataSource, UIWebViewDelegate>

@end

@implementation MainController

@synthesize smarthome;
@synthesize setting;
@synthesize sipPhone;
@synthesize myFavorites;
@synthesize board;
@synthesize history;
@synthesize regisLabel;
@synthesize regisMode;
//@synthesize newcity;

NSMutableArray *alarmList;
AlarmHelper *helper;

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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"alarm" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receive:) name:@"reg" object:nil];
    self.board.dataSource = self;
    [self setNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([[UIDevice currentDevice] orientation] != UIInterfaceOrientationPortrait || [[UIDevice currentDevice]orientation] != UIInterfaceOrientationPortraitUpsideDown) {
        [[UIDevice currentDevice] setValue:
         [NSNumber numberWithInteger: UIInterfaceOrientationPortrait]
                                forKey:@"orientation"];
    }
    AppDelegate *delegate=(AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (![delegate isServiceStarted]) {
        if ([delegate startService]) {
            [delegate registeration];
        }
    }
    else {
        if (![delegate checkAnyRegistered]) {
            [delegate registeration];
        }
    }
    helper = [[AlarmHelper alloc]init];
    [self showAlarmList];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [helper closeDatabase];
    helper = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) receive:(NSNotification *) notify {
    //NSLog(@"maincontroller receive:");
    if ([[notify name] isEqualToString:@"alarm"]) {
        NSLog(@"main refresh alarm");
        [self showAlarmList];
    }
    else if ([[notify name] isEqualToString:@"reg"]) {
        NSLog(@"maincontroller reg:%@", [notify object]);
        if ([[notify object]isEqualToString:@"success"]) {
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                [regisMode setImage:[UIImage imageNamed:@"regimode_on"]];
                [regisLabel setText:@"Registered"];
            });
            //AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
            //[[NSNotificationCenter defaultCenter]postNotificationName:@"check_param" object:nil];
        }
        else {
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                [regisMode setImage:[UIImage imageNamed:@"regimode_off"]];
                [regisLabel setText:@"Registered fail"];
            });
        }
        [[NSNotificationCenter defaultCenter]postNotificationName:@"check_param" object:nil];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    /*if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft || toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
        if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
            return;
        }
    }*/
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"cellforrowindexpath");
    AlarmViewCell *cell =[board dequeueReusableCellWithIdentifier:@"alarmViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"AlarmViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (alarmList != nil && [alarmList count] >indexPath.row) {
        NSDictionary *nd = [alarmList objectAtIndex:indexPath.row];
        //NSLog(@"%@", [nd description]);
        [cell.alarmMessage setText:[nd objectForKey:@"stime"]];
        [cell.alarmTitle setText:[nd objectForKey:@"message"]];
        int readed = [nd[@"readed"] intValue];
        //NSLog(@"%d", readed);
        if (readed==0) {
            [cell.alarmstate setImage:[UIImage imageNamed:@"alarm"]];
        }
        else {
            [cell.alarmstate setImage:[UIImage imageNamed:@"alarm_readed"]];
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [alarmList count];
}

- (void) showAlarmList{
    FMResultSet *rs = [helper getAlarmList];
    alarmList = [NSMutableArray array];
    
    while ([rs next]) {
        [alarmList addObject:[rs resultDictionary]];
    }
    //[helper closeDatabase];
    NSLog(@"reload data");
    [self.board performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *nd = [alarmList objectAtIndex:indexPath.row];
    [helper setReaded:[nd objectForKey:@"tag"]];
    NSLog(@"%@", [nd description]);
    if ([[nd objectForKey:@"mode"]intValue]==0) {
        CustomIOS7AlertView *view = [[CustomIOS7AlertView alloc]init];
        UIDevice *dev = [UIDevice currentDevice];
        AlarmDataView *adView;
        if ([dev.model isEqualToString:@"iPhone"] || [dev.model isEqualToString:@"iPhone6"]) {
            adView = [[AlarmDataView alloc]initWithFrame:CGRectMake(0, 0, 150, 70)];
        }
        else if ([dev.model isEqualToString:@"iPad"]) {
            adView = [[AlarmDataView alloc] initWithFrame:CGRectMake(0, 0, 200, 70)];
        }
        [adView setMessage:[nd objectForKey:@"message"] andTime:[nd objectForKey:@"stime"]];
        [view setContainerView:adView];
        [view setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
            [alertView close];
        }];
        [view show];
    }
    else if ([[nd objectForKey:@"mode"]intValue]==1) {
        // IPCAM_ALARM
        //NSLog(@"%@", [nd description]);
        NSString *camid = [nd objectForKey:@"tag"];
        NSString *url = [NSString stringWithFormat:@"http://%@/3sipcam.shw?cam=Cam0%c", [nd objectForKey:@"pip"], [camid characterAtIndex:camid.length-1]] ;
        NSURL *nsurl = [NSURL URLWithString:url];
        //NSURLRequest *req = [NSURLRequest requestWithURL:nsurl];
        WebViewController *webCon = [[WebViewController alloc]init];
        [webCon loadWebView:nsurl];
        [self presentViewController:webCon animated:YES completion:^{
        }];
    }
}

- (void)setNavigationBar{
    if (nBar == nil) {
        nBar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 40)];
        UINavigationItem *backButton = [UINavigationItem alloc];
        [nBar pushNavigationItem:backButton animated:YES];
        [self.view addSubview:nBar];
    }
    [nBar setHidden:YES];
    //[self.view addSubview:nBar];
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
