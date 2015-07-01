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


@interface AppDelegate : UIResponder <UIApplicationDelegate, GCDAsyncSocketDelegate>
{
    SessionManager *manager;
    NSArray *callArray; // use this for multiple call control
    BOOL doCheckSip;
    //UITransitionView *_transView;
    __block UIBackgroundTaskIdentifier bgTask;
}

@property (strong, nonatomic) UIWindow *window;

- (BOOL) initializePjsua;
- (BOOL) startService;
- (void) registeration;
- (BOOL) isServiceStarted;
- (BOOL) checkAnyRegistered;
- (void) makeCall:(NSString*) sipURI withMode:(int) mode;
- (void) handleSip;

@end
