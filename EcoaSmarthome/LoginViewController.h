//
//  LoginViewController.h
//  EcoaSmartHome
//
//  Created by Apple on 2014/5/8.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "import.h"

@interface LoginViewController : UIViewController <UIViewControllerTransitioningDelegate, UITextFieldDelegate>
{
    NSString *appLock;
}

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIButton *pButton;
@property (nonatomic, retain) IBOutlet UIButton *nButton;
@property (nonatomic, retain) IBOutlet UITextField *appPassword;

- (void) setUI;
- (IBAction) login : (id)sender;

@end
