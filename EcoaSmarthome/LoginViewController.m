//
//  LoginViewController.m
//  EcoaSmartHome
//
//  Created by Apple on 2014/5/8.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController () <UITextFieldDelegate>

@end

@implementation LoginViewController

@synthesize textView;
@synthesize pButton;
@synthesize nButton;
@synthesize appPassword;


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
    appLock = nil;
    //[self setUI];
    //[self setUserData];

    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [self setUI];
}

- (void)viewDidAppear:(BOOL)animated {
    NSUserDefaults *nd = [NSUserDefaults standardUserDefaults];
    if ([nd boolForKey:@"firstUse"] != YES && [nd boolForKey:@"userLock"] != YES) {
        [self performSegueWithIdentifier:@"ecoa" sender:self];
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
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



- (void) setUI {
    NSLog(@"LoginView: set UI component");
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];

    [textView setTranslatesAutoresizingMaskIntoConstraints:NO];
    textView.editable = NO;
    [pButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [nButton setTranslatesAutoresizingMaskIntoConstraints:NO];
    [appPassword setTranslatesAutoresizingMaskIntoConstraints:NO];
    [appPassword setPlaceholder:@"password"];
    [appPassword setHidden:true];
    [appPassword setSecureTextEntry:YES];
    [appPassword setDelegate:self];
    
    // check if the first time user
    if ([userData boolForKey:@"firstUse"] == YES) {
        NSLog(@"LoginView: first time");
        //NSLog(NSLocalizedString(@"welcom_to_app_first", nil));
        textView.text = NSLocalizedString(@"welcom_to_app_first", nil);
        [pButton setTitle:NSLocalizedString(@"set_info", @"set info text") forState:UIControlStateNormal];
        [pButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [nButton setTitle:NSLocalizedString(@"exit", @"exit text") forState:UIControlStateNormal];
        [nButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    }
    else {
        NSLog(@"LoginView: not first time");
        [textView setText:NSLocalizedString(@"welcom_to_app", @"welcom text")];
        [pButton setTitle:NSLocalizedString(@"login", @"login text") forState:UIControlStateNormal];
        [pButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [nButton setTitle:NSLocalizedString(@"exit", @"exit text") forState:UIControlStateNormal];
        [nButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        if ([userData boolForKey:@"userLock"] == YES) {
            [appPassword setHidden:false];
            [textView setText:@"welcom_to_app_pass"];
        }
    }
}

- (IBAction) login : (id)sender {
    BOOL login;
    
    NSUserDefaults *userData = [NSUserDefaults standardUserDefaults];
    
    if ([userData boolForKey:@"firstUse"] == YES) {
        [self performSegueWithIdentifier:@"set info" sender:nil];
    }
    else {
        if ([userData boolForKey:@"userLock"]) {
            appLock = [userData valueForKey:@"appPassword"];
            if (appLock != nil) {
                // check password
                if (![appLock isEqualToString: appPassword.text]) {
                    // wrong password
                    // show message
                    NSLog(@"LoginView: wrong password");
                    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"wrong_password_alert", @"alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"text") otherButtonTitles: nil];
                    [alert show];
                    login = NO;
                }
                else {
                    login = YES;
                }
            }
        }
        else {
            login = YES;
        }
        if (login) {
            // login
            [self performSegueWithIdentifier:@"ecoa" sender:self];
        }
    }
}

- (IBAction) cancel: (id)sender {
    [self dismissViewControllerAnimated:YES completion:^(void){
        
    }];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
