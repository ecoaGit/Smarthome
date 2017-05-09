//
//  TabViewController.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/5/26.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "EcoaTabViewController.h"

@interface EcoaTabViewController () <UITabBarControllerDelegate>

@end

@implementation EcoaTabViewController

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
    [self.tabBarController setSelectedIndex:2];
    [self setSelectedIndex:2];
    //manager = [EcoaSipManager getInstance];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserverForName:@"call_state" object:nil queue:nil usingBlock:^(NSNotification *notif) {
        pjsua_call_info ci;
        
        NSData *data = notif.userInfo[@"call_info"];
        if (!data || data.length != sizeof(ci)) {
            // failed
        }
        else {
           // [self.tabBarController setSelectedIndex:3];
           // [self setSelectedIndex:3];
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    if (![delegate isServiceStarted]) {
        if ([delegate startService]){
            [delegate registeration];
        }
    }
    else {
        if (![delegate checkAnyRegistered]){
            [delegate registeration];
        }
    }
    /*
    if ([manager isServiceStarted]) {
        [manager registeration];
    }*/
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initUISet {
    
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
