//
//  SipPhoneViewController.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/5/20.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "SipPhoneViewController.h"

@interface SipPhoneViewController ()

@end

@implementation SipPhoneViewController

CallViewController *callView;

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
    NSLog(@"viewDidLoad");

    // add a observer to receiver call_info
    [[NSNotificationCenter defaultCenter]addObserverForName:@"call_state" object:nil queue:nil usingBlock:^(NSNotification *notif) {
        pjsua_call_info ci;
        
        NSData *data = notif.userInfo[@"call_info"];
        if (!data || data.length != sizeof(ci)) {
            // failed
        }
        else {
            // extract call info
            [data getBytes:&ci length:sizeof(ci)];
            dispatch_async(dispatch_get_main_queue(), ^{
            });
        }
    }];
    
    callView = nil;
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc]initWithTitle:@" " style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationItem setHidesBackButton:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dialPad = [[dialpad alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20, self.view.frame.size.width, (self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-20)*5/6)];
    audio = [[UIButton alloc]initWithFrame:CGRectMake(0, dialPad.frame.origin.y + dialPad.frame.size.height, self.view.frame.size.width/2, (self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-20)/6)];
    video = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, dialPad.frame.origin.y + dialPad.frame.size.height, self.view.frame.size.width/2, (self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-20)/6)];
    
    [[audio layer]setBorderWidth:0.5f];
    [[audio layer]setBorderColor:[UIColor lightGrayColor].CGColor];
    [audio setBackgroundColor:[UIColor orangeColor]];
    [audio addTarget:self action:@selector(audioAction:) forControlEvents:UIControlEventTouchUpInside];
    [audio setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
    [[video layer]setBorderWidth:0.5f];
    [[video layer]setBorderColor:[UIColor lightGrayColor].CGColor];
    [video setBackgroundColor:[UIColor orangeColor]];
    [video addTarget:self action:@selector(videoAction:) forControlEvents:UIControlEventTouchUpInside];
    [video setImage:[UIImage imageNamed:@"video"] forState:UIControlStateNormal];
    [self.view addSubview:dialPad];
    [self.view addSubview:audio];
    [self.view addSubview:video];
    
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    NSLog(@"rotation occur");
    [dialPad removeFromSuperview];
    [video removeFromSuperview];
    [audio removeFromSuperview];
    dialPad = [[dialpad alloc]initWithFrame:CGRectMake(0, self.navigationController.navigationBar.frame.size.height+20, self.view.frame.size.width, (self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-20)*5/6)];
    audio = [[UIButton alloc]initWithFrame:CGRectMake(0, dialPad.frame.origin.y + dialPad.frame.size.height, self.view.frame.size.width/2, (self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-20)/6)];
    video = [[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width/2, dialPad.frame.origin.y + dialPad.frame.size.height, self.view.frame.size.width/2, (self.view.frame.size.height-self.navigationController.navigationBar.frame.size.height-20)/6)];
    
    [[audio layer]setBorderWidth:0.5f];
    [[audio layer]setBorderColor:[UIColor lightGrayColor].CGColor];
    [audio setBackgroundColor:[UIColor orangeColor]];
    [audio addTarget:self action:@selector(audioAction:) forControlEvents:UIControlEventTouchUpInside];
    [audio setImage:[UIImage imageNamed:@"audio"] forState:UIControlStateNormal];
    [[video layer]setBorderWidth:0.5f];
    [[video layer]setBorderColor:[UIColor lightGrayColor].CGColor];
    [video setBackgroundColor:[UIColor orangeColor]];
    [video addTarget:self action:@selector(videoAction:) forControlEvents:UIControlEventTouchUpInside];
    [video setImage:[UIImage imageNamed:@"video"] forState:UIControlStateNormal];
    [self.view addSubview:dialPad];
    [self.view addSubview:audio];
    [self.view addSubview:video];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

- (IBAction)videoAction:(id)sender {
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"sip:%@@%@", [dialPad getInput], [nd stringForKey:@"sipAddress"]];
    AppDelegate *dele = [[UIApplication sharedApplication]delegate];
    [dele makeCall:url withMode:1];

    //[self presentCallingView];
}

- (IBAction)audioAction:(id)sender {
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    NSString *url = [NSString stringWithFormat:@"sip:%@@%@", [dialPad getInput], [nd stringForKey:@"sipAddress"]];
    AppDelegate *dele = [[UIApplication sharedApplication]delegate];
    [dele makeCall:url withMode:0];
    //[self presentCallingView];
}

- (void) presentCallingView {
    callView = [[CallViewController alloc]init];
    UIViewController *rootController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootController.presentedViewController) {
        rootController = rootController.presentedViewController;
    }
   
    [rootController presentViewController:callView animated:YES completion:nil];
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
