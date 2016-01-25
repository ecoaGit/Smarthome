//
//  AppDelegate.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/5/14.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "import.h"
#import "EcoaDBHelper.h"
#import "CallViewController.h"
#import "SessionManager.h"
#import "CallView.h"

#import <GCDAsyncSocket.h>
#import <pjsua.h>
#import <pjlib.h>
//#import <Google/CloudMessaging.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, GCDAsyncSocketDelegate/*, GGLInstanceIDDelegate, GCMReceiverDelegate*/>
{
    SessionManager *manager;
    NSArray *callArray; // use this for multiple call control
    BOOL doCheckSip;
    //UITransitionView *_transView;
    __block UIBackgroundTaskIdentifier bgTask;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, readonly, strong) NSDictionary *registrationOptions;

- (BOOL) initializePjsua;
- (BOOL) startService;
- (void) registeration;
- (BOOL) isServiceStarted;
- (BOOL) checkAnyRegistered;
- (void) makeCall:(NSString*) sipURI withMode:(int) mode;
- (void) handleSip;
- (BOOL) isDeviceInLan;
+ (void) playdigits:(pjsua_call_id) call_id withDigit:(NSString *)str;

@end
