//
//  LoginController.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/8/9.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "LoginController.h"

@interface LoginController ()

@end

@implementation LoginController

@synthesize username;
@synthesize password;
@synthesize nameLabel;
@synthesize passLabel;
@synthesize login;
@synthesize cancel;

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
    
    //[self.navigationItem setHidesBackButton:YES];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *name = [userDefaults stringForKey:@"cloudUsername"];
    NSString *pass = [userDefaults stringForKey:@"cloudPassword"];
    
    [nameLabel setText:NSLocalizedString(@"cloudUsername", @"text")];
    [passLabel setText:NSLocalizedString(@"cloudPassword", @"text")];
    [login setTitle:NSLocalizedString(@"login", @"text") forState:UIControlStateNormal];
    [cancel setTitle:NSLocalizedString(@"cancel", @"text") forState:UIControlStateNormal];
    
    
    [username setText:name];
    [password setText:pass];
    [password setSecureTextEntry:YES];
    
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)login:(id)sender {
    [self performSegueWithIdentifier:@"login" sender:self];
}

- (IBAction)canel:(id)sender {
    [self performSegueWithIdentifier:@"cancel" sender:self];
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
