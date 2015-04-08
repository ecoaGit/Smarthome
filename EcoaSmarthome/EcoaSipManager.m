//
//  EcoaSipManager.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/19.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "EcoaSipManager.h"

@implementation EcoaSipManager

static EcoaSipManager *_instance;
static bool _serviceIsStarted;

- (id) init {
    self = [super init];
    if (self) {
        //_serviceIsStarted = [self startService];
    }
    return self;
}

+ (EcoaSipManager *) getInstance{
    
    @synchronized([EcoaSipManager class]) {
        if (!_instance)
            [[self alloc]init];
        return _instance;
    }
    return nil;
}

+ (id) alloc {
    @synchronized([EcoaSipManager class]) {
        NSAssert(_instance == nil, @"_singletonObject 已經做過記憶體配置");
        _instance = [super alloc];
        
        return _instance;
    }
    return nil;
}

- (BOOL) isServiceStarted{
    return _serviceIsStarted;
}

- (void)makeCall:(NSString *)sipURI withMode:(int)mode {
    NSLog(@"make call");
    const char *sipuri = [sipURI UTF8String];
    pj_str_t uri = pj_str((char*)sipuri);
    pj_status_t status;
    //NSLog(@"look %d", call_setting.vid_cnt);
    if (pjsua_get_state() == PJSUA_STATE_RUNNING) {
        status = pjsua_call_make_call(acc_id, &uri, &call_setting, NULL, NULL, NULL);
        if (status != PJ_SUCCESS){
            NSLog(@"didn't make it");
            return;
        }
    }
}

- (void)answerCall:(pjsua_call_id)cid {
    // answer call
    pjsua_call_answer(cid, 200, NULL, NULL);
}

- (void)hangUpCall:(pjsua_call_id)cid {
    NSLog(@"hang up");
    pjsua_call_hangup(cid, 0, NULL, NULL);
}

- (void)onIncomingCall:(pjsua_acc_id)acc_id withCallId:(pjsua_call_id)call_id {
    NSLog(@"receive a call");
    
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    
    NSData *data = [NSData dataWithBytes:&ci length:sizeof(ci)];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"call_state" object:self userInfo:@{@"call_info" : data}];
    
    UILocalNotification *alert = [[UILocalNotification alloc] init];
    if (alert) {
        alert.timeZone = [NSTimeZone defaultTimeZone];
        alert.repeatInterval = 0;
        alert.alertBody = @"Incoming call ";
        /* This action just brings the app to the FG, it doesn't
         * automatically answer the call (unless you specify the
         * --auto-answer option).
         */
        alert.alertAction = @"Active app";
        alert.soundName = UILocalNotificationDefaultSoundName;
        alert.applicationIconBadgeNumber = pjsua_call_get_count();
        
        NSLog(@"show localnotification");
        [[UIApplication sharedApplication] presentLocalNotificationNow:alert];
    }
}

- (void)callStateChanged:(pjsua_call_id)call_id {
    pjsua_call_info ci;
    pjsua_call_get_info(call_id, &ci);
    
    NSData *data = [NSData dataWithBytes:&ci length:sizeof(ci)];
    //NSLog(@"call state changed to %@ send notification", [NSString stringWithCString:ci.state_text.ptr encoding:NSASCIIStringEncoding]);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"call_state" object:self userInfo:@{@"call_info" : data}];
}
/*
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata) {
    pjsua_call_info ci;
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);
    
    pjsua_call_get_info(call_id, &ci);
    
    NSLog(@"Incoming call from %ld%@!!",ci.remote_info.slen,[NSString stringWithCString:ci.remote_info.ptr encoding:NSASCIIStringEncoding]);
    // Automatically answer incoming calls with 200/OK
    
    [_instance onIncomingCall:acc_id withCallId:call_id];
    //pjsua_call_answer(call_id, 200, NULL, NULL);
}

static void on_call_media_state(pjsua_call_id call_id) {
    pjsua_call_info ci;
    
    pjsua_call_get_info(call_id, &ci);
    
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
    }
}

static void on_call_state(pjsua_call_id call_id, pjsip_event *e) {
    pjsua_call_info ci;
    PJ_UNUSED_ARG(e);
    pjsua_call_get_info(call_id, &ci);
    NSLog(@"Call %d state=%ld%@",call_id,ci.state_text.slen,[NSString stringWithCString:ci.state_text.ptr encoding:NSASCIIStringEncoding]);
    [_instance callStateChanged:call_id];
}*/

@end
