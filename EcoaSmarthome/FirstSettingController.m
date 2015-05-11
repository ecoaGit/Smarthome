//
//  FirstSettingController.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/5/23.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "FirstSettingController.h"

@interface FirstSettingController () <UITableViewDelegate, UITextFieldDelegate>

@end

@implementation FirstSettingController

@synthesize rButton;
@synthesize lButton;
@synthesize name;
@synthesize appPassword;
@synthesize userLock;
@synthesize cloudAddress;
@synthesize cloudUsername;
@synthesize cloudPassword;
@synthesize sipAddress;
@synthesize sipUsername;
@synthesize sipPassword;
@synthesize nameLabel;
@synthesize appPassLabel;
@synthesize cloudAddLabel;
@synthesize cloudNameLabel;
@synthesize cloudPassLabel;
@synthesize sipAddLabel;
@synthesize sipNameLabel;
@synthesize sipPassLabel;
@synthesize use3G;
@synthesize useWifi;

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
    isEditing = true;
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [self setUI:isEditing];

    [nameLabel setText:NSLocalizedString(@"name", @"name label")];
    [appPassLabel setText:NSLocalizedString(@"appPassword", @"app password label")];
    [cloudAddLabel setText:NSLocalizedString(@"cloudAddress", @"cloud address label")];
    [cloudNameLabel setText:NSLocalizedString(@"cloudUsername", @"username label")];
    [cloudPassLabel setText:NSLocalizedString(@"cloudPassword", @"password label")];
    [sipAddLabel setText:NSLocalizedString(@"sipAddress", @"sip address label")];
    [sipNameLabel setText:NSLocalizedString(@"sipUsername", @"sip username label")];
    [sipPassLabel setText:NSLocalizedString(@"sipPassword", @"sip password label")];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) setUI : (BOOL) editable {
    NSLog(@"first setting view: setUI");
    if (editable) {
        NSLog(@"true");
    }
    else {
        NSLog(@"false");
    }
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [lButton setTitle:NSLocalizedString(@"exit",@"cancelbutton") forState:UIControlStateNormal];
    if (editable) {
        [rButton setTitle:NSLocalizedString(@"save", @"savebutton") forState:UIControlStateNormal];
    }
    else {
        [rButton setTitle:NSLocalizedString(@"edit_text", @"editbutton") forState:UIControlStateNormal];
    }

    
    [name setEnabled:editable];
    [name setDelegate:self];
    [userLock addTarget:self action:@selector(showAppPassword:) forControlEvents:UIControlEventValueChanged];
    [userLock setOn:[userDefaults boolForKey:@"userLock"]];
    [userLock setEnabled:editable];
    [appPassword setHidden:![userLock isOn]];
    [appPassword setSecureTextEntry:YES];
    [appPassword setEnabled:editable];
    [appPassword setDelegate:self];
    [cloudAddress setEnabled:editable];
    [cloudAddress setText:[userDefaults valueForKey:@"default_address"]];
    [cloudAddress setDelegate:self];
    [cloudUsername setEnabled:editable];
    [cloudUsername setDelegate:self];
    [cloudPassword setEnabled:editable];
    [cloudPassword setSecureTextEntry:YES];
    [cloudPassword setDelegate:self];
    [sipAddress setEnabled:editable];
    [sipAddress setDelegate:self];
    [sipUsername setEnabled:editable];
    [sipUsername setDelegate:self];
    [sipPassword setEnabled:editable];
    [sipPassword setSecureTextEntry:YES];
    [sipPassword setDelegate:self];
    [use3G setEnabled:editable];
    [use3G setOn:[userDefaults boolForKey:@"use3G"]];
    [useWifi setEnabled:editable];
    [useWifi setOn:[userDefaults boolForKey:@"useWifi"]];
    
}

- (IBAction) showAppPassword:(id)sender {
    if (userLock.on) {
        [appPassword setHidden:NO];
    }
    else {
        [appPassword setHidden:YES];
    }
}

- (void) saveUserDefault {
    NSLog(@"saving data");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([self checkUserData]) {
        if ([userDefaults boolForKey:@"firstUse"]== YES) {
            [userDefaults setBool:NO forKey:@"firstUse"];
            [userDefaults setBool:YES forKey:@"set"];
        }
        
        [userDefaults setObject:[name text] forKey:@"name"];
        [userDefaults setBool:[userLock isOn] forKey:@"userLock"];
        if ([userLock isOn]) {
            [userDefaults setValue:[appPassword text] forKey:@"appPassword"];
        }
        else {
            [userDefaults setValue:[appPassword text] forKey:@"appPassword"];
        }
        [userDefaults setValue:[cloudAddress text] forKey:@"cloudAddress"];
        [userDefaults setValue:[cloudUsername text] forKey:@"cloudUsername"];
        [userDefaults setValue:[cloudPassword text] forKey:@"cloudPassword"];
        [userDefaults setValue:[sipAddress text] forKey:@"sipAddress"];
        [userDefaults setValue:[sipUsername text] forKey:@"sipUsername"];
        [userDefaults setValue:[sipPassword text] forKey:@"sipPassword"];
        [userDefaults setBool:[useWifi isOn] forKey:@"useWifi"];
        [userDefaults setBool:[use3G isOn] forKey:@"use3G"];
        
        if ([userDefaults synchronize]) {
            NSLog(@"saved successfully!");
          
        }
        else {
            NSLog(@"save failed");
        }
    }
    
}

- (BOOL) checkUserData {
    BOOL checked = true;
    
    if ([[[name text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"blank_name_alert", @"alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"text") otherButtonTitles: nil];
        [alert show];
        checked = false;
    }
    else if ([userLock isOn]) {
        if ([[[appPassword text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"blank_password_alert", @"alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"text") otherButtonTitles: nil];
            [alert show];
            checked = false;
        }
    }
    else if (![[[sipAddress text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || ![[[sipUsername text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] || ![[[sipPassword text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
        // check sip data
        if ([[[sipUsername text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"blank_username_alert", @"alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"text") otherButtonTitles: nil];
            [alert show];
            checked = false;
        }
        else if ([[[sipPassword text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""]) {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:NSLocalizedString(@"blank_password_alert", @"alert text") delegate:self cancelButtonTitle:NSLocalizedString(@"cancel", @"text") otherButtonTitles: nil];
            [alert show];
            checked = false;
        }
    }
    
    return checked;
}

- (IBAction)lButtonAction:(id)sender {
    if (isEditing) {
        isEditing = false;
        [self setUI:isEditing];
    }
    else {
        [self dismissViewControllerAnimated:YES completion:^(void){}];
    }
}

- (IBAction)rButtonAction:(id)sender {
    if (isEditing) {
        [self saveUserDefault];
        isEditing = false;
        [self setUI:isEditing];
    }
    else {
        isEditing = true;
        [self setUI:isEditing];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
