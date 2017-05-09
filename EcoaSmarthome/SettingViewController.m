//
//  SettingViewController.m
//  EcoaSmartHome
//
//  Created by Apple on 2014/5/8.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController () <UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UITabBarControllerDelegate, UITextFieldDelegate>

@end

@implementation SettingViewController

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
@synthesize useWifi;
@synthesize use3G;
@synthesize rButton;
@synthesize autoSipLabel;
@synthesize showAlarmLabel;
@synthesize useAutoSip;
//@synthesize useShowAlarm;


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
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    self.tableView.separatorColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    self.tableView.scrollEnabled = YES;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.frame.size.height/2, 0);
    isEditing = false;
    rButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"edit"] style:UIBarButtonItemStyleBordered target:self action:@selector(rButtonAction:)];
    [rButton setImageInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.navigationItem setRightBarButtonItem:rButton];
    [nameLabel setText:NSLocalizedString(@"name", @"name label")];
    [appPassLabel setText:NSLocalizedString(@"appPassword", @"app password label")];
    [cloudAddLabel setText:NSLocalizedString(@"cloudAddress", @"cloud address label")];
    [cloudNameLabel setText:NSLocalizedString(@"cloudUsername", @"username label")];
    [cloudPassLabel setText:NSLocalizedString(@"cloudPassword", @"password label")];
    [sipAddLabel setText:NSLocalizedString(@"sipAddress", @"sip address label")];
    [sipNameLabel setText:NSLocalizedString(@"sipUsername", @"sip username label")];
    [sipPassLabel setText:NSLocalizedString(@"sipPassword", @"sip password label")];
    [autoSipLabel setText:NSLocalizedString(@"autoSip", @"auto sip label")];
    //[showAlarmLabel setText:NSLocalizedString(@"showAlarm", @"show alarm label")];
    [self registerForKeyboardNotifications];
    [self readUserDefault];
    [self setUI:isEditing];
}

- (void) viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillDisappear:(BOOL)animated {
    AppDelegate *delegate = [AppDelegate alloc];
    [delegate registeration];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
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
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
 
    if (editable) {
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"confirm"]];
    }
    else {
        [self.navigationItem.rightBarButtonItem setImage:[UIImage imageNamed:@"edit"]];
    }

    [name setEnabled:editable];
    [name setDelegate:self];
    [userLock addTarget:self action:@selector(showAppPassword:) forControlEvents:UIControlEventValueChanged];
    [userLock setOn:[userDefaults boolForKey:@"userLock"]];
    [userLock setEnabled:editable];
    [appPassword setHidden:![userLock isOn]];
    [appPassword setSecureTextEntry:YES];
    [appPassword setDelegate:self];
    [appPassword setEnabled:editable];
    [cloudAddress setEnabled:editable];
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
    [useAutoSip setEnabled:editable];
    [useAutoSip setOn:[userDefaults boolForKey:@"useAutoSip"]];
    //[useShowAlarm setEnabled:editable];
    //[useShowAlarm setOn:[userDefaults boolForKey:@"useShowAlarm"]];
    
}

- (IBAction) showAppPassword:(id)sender {
    if (userLock.on) {
        [appPassword setHidden:NO];
    }
    else {
        [appPassword setHidden:YES];
    }
}

- (void) readUserDefault {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    // check if we got data
    if ([userDefaults boolForKey:@"firstUse"] == YES) {
        NSLog(@"first use");
        [cloudAddress setText:[userDefaults stringForKey:@"default_address"]];
        [self setUI:true];
    }
    else {
        [name setText:[userDefaults stringForKey:@"name"]];
        
        if ([userDefaults boolForKey:@"userLock"]) {
            [appPassword setText:[userDefaults stringForKey:@"appPassword"]];
        }
        [cloudUsername setText:[userDefaults stringForKey:@"cloudUsername"]];
        [cloudPassword setText:[userDefaults stringForKey:@"cloudPassword"]];
        [cloudAddress setText:[userDefaults stringForKey:@"cloudAddress"]];
        [sipAddress setText:[userDefaults stringForKey:@"sipAddress"]];
        [sipUsername setText:[userDefaults stringForKey:@"sipUsername"]];
        [sipPassword setText:[userDefaults stringForKey:@"sipPassword"]];
    }
    
}

- (BOOL) saveUserDefault {
    NSLog(@"saving data");
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if ([self checkUserData]) {
        if ([userDefaults boolForKey:@"firstUse"]== YES) {
            [userDefaults setBool:NO forKey:@"firstUse"];
        }
        
        [userDefaults setObject:[name text] forKey:@"name"];
        [userDefaults setBool:[userLock isOn] forKey:@"userLock"];
        
        if ([userLock isOn]) {
            NSLog(@"using lock");
            [userDefaults setValue:[appPassword text] forKey:@"appPassword"];
        }
        else {
            NSLog(@"not using lock");
        }
        [userDefaults setValue:[cloudAddress text] forKey:@"cloudAddress"];
        [userDefaults setValue:[cloudUsername text] forKey:@"cloudUsername"];
        [userDefaults setValue:[cloudPassword text] forKey:@"cloudPassword"];
        [userDefaults setValue:[sipAddress text] forKey:@"sipAddress"];
        [userDefaults setValue:[sipUsername text] forKey:@"sipUsername"];
        [userDefaults setValue:[sipPassword text] forKey:@"sipPassword"];
        [userDefaults setBool:[useWifi isOn] forKey:@"useWifi"];
        [userDefaults setBool:[use3G isOn] forKey:@"use3G"];
        [userDefaults setBool:[useAutoSip isOn] forKey:@"useAutoSip"];
        //[userDefaults setBool:[useShowAlarm isOn] forKey:@"useShowAlarm"];
        
        if ([userDefaults synchronize]) {
            NSLog(@"saved successfully!");
            // check background parameter
            [[NSNotificationCenter defaultCenter]postNotificationName:@"check_param" object:nil];
        }
        else {
            NSLog(@"save failed");
        }
        return true;
    }
    else {
        return false;
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

- (IBAction) rButtonAction:(id)sender {
    if (isEditing) {
        NSLog(@"lock UI");
        
        if([self saveUserDefault]){
            isEditing = false;
            [self setUI:isEditing];
            [[[[self.tabBarController tabBar]items]objectAtIndex:0]setEnabled:true];
            [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:true];
            [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:true];
            [[[[self.tabBarController tabBar]items]objectAtIndex:3]setEnabled:true];
        }
    }
    else {
        NSLog(@"unlock UI");
        isEditing = true;
        [self setUI:isEditing];
        [[[[self.tabBarController tabBar]items]objectAtIndex:0]setEnabled:false];
        [[[[self.tabBarController tabBar]items]objectAtIndex:1]setEnabled:false];
        [[[[self.tabBarController tabBar]items]objectAtIndex:2]setEnabled:false];
        [[[[self.tabBarController tabBar]items]objectAtIndex:3]setEnabled:false];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"textfielddidbeginediting");
    UITableViewCell *cell = (UITableViewCell*) [[textField superview] superview];
    [self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell]atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    //NSLog(@"%@", [self.tableView indexPathForCell:cell]);
    //if (self.tableView.contentOffset.y == 0)
    //{
        //[UIView animateWithDuration:0.0 delay:0.5 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        //} completion:^(BOOL finished) {
            //UITableViewCell *cell = (UITableViewCell*) [[textField superview] superview];
            //[self.tableView scrollToRowAtIndexPath:[self.tableView indexPathForCell:cell] atScrollPosition:UITableViewScrollPositionTop animated:YES];
        //}];
    //}
    /*if (self.view.frame.origin.y>=0) {
        [self viewMoveUp:YES];
    }
    else if (self.view.frame.origin.y<0) {
        [self viewMoveUp:NO];
    }*/
}
- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (self.view.frame.origin.y>=0) {
        [self viewMoveUp:YES];
    }
    else if (self.view.frame.origin.y<0) {
        [self viewMoveUp:NO];
    }
}

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification
{
    //NSDictionary* info = [aNotification userInfo];
    //CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    //self.tableView.scroll
    //UIEdgeInsets contentInsets = UIEdgeInsetsMake(20.0, 0.0, kbSize.height, 0.0);
    //self.tableView.contentInset = contentInsets;
    //self.tableView.scrollIndicatorInsets = contentInsets;
    
    // If active text field is hidden by keyboard, scroll it so it's visible
    // Your app might not need or want this behavior.
    //CGRect aRect = self.view.frame;
    //aRect.size.height -= kbSize.height;
    
    //if (!CGRectContainsPoint(aRect, self.tableView.frame.origin) {
     //   [self.tableView scrollRectToVisible:activeField.frame animated:YES];
    //}
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    /*if (self.view.frame.origin.y>=0) {
        [self viewMoveUp:YES];
    }
    else if (self.view.frame.origin.y<0){
        [self viewMoveUp:NO];
    }*/
}

- (void) keyboardWillShow:(NSNotification*)notify {
   /* if (self.view.frame.origin.y>=0) {
        // move up
        [self viewMoveUp:YES];
    }
    else if (self.view.frame.origin.y<0){
        [self viewMoveUp:NO];
    }*/
}

- (void)viewMoveUp:(BOOL) move{
    NSLog(@"view move up");
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (move)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= 160.0;
        rect.size.height += 160.0;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += 160.0;
        rect.size.height -= 160.0;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}


@end
