//
//  MainController.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/7/31.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "MainController.h"

@interface MainController () <UITableViewDelegate, UITableViewDataSource>

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
@synthesize newcity;

NSMutableArray *alarmList;


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
    [self setUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receive:) name:@"alarm" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receive:) name:@"reg" object:nil];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
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
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setUI {
    //manager = [SessionManager getInstance];
    
    
    /*CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:249.0/255.0 green:155.0/255.0 blue:255.0/255.0 alpha:1.0f].CGColor,(id)[UIColor colorWithRed:250.0/255.0 green:53.0/255.0 blue:150.0/255.0 alpha:1.0f].CGColor, nil];
    gradientLayer.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:1.0f] , nil];
    gradientLayer.frame = newcity.bounds;
    [newcity.layer insertSublayer:gradientLayer atIndex:0];
    [newcity clipsToBounds];*/
   
}

- (void) receive:(NSNotification *) notify {
    //NSLog(@"maincontroller receive:");
    if ([[notify object] isEqualToString:@"alarm"]) {
        
    }
    else if ([[notify name] isEqualToString:@"reg"]) {
        NSLog(@"maincontroller reg:%@", [notify object]);
        if ([[notify object]isEqualToString:@"success"]) {
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                [regisMode setImage:[UIImage imageNamed:@"regimode_on"]];
                [regisLabel setText:@"registred"];
            });
        }
        else {
            dispatch_barrier_async(dispatch_get_main_queue(), ^{
                [regisMode setImage:[UIImage imageNamed:@"regimode_off"]];
                [regisLabel setText:@"registered fail"];
            });
            
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self setUI];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AlarmViewCell *cell =[tableView dequeueReusableCellWithIdentifier:@"alarmViewCell" forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"AlarmViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (alarmList != nil && [alarmList count] != 0) {
        cell.alarmMessage;
        cell.alarmTitle;
        cell.alarmstate;
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
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
