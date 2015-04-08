//
//  EcoaSipManager.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/19.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVAudioSession.h>
#import <pjsua.h>
#import <pjlib.h>
#import <pj/log.h>

@interface EcoaSipManager : NSObject
{
    pjsua_acc_id acc_id;
    pjsua_call_setting call_setting;
}

+ (EcoaSipManager *) getInstance;
- (BOOL) startService;
- (void) makeCall:(NSString*) sipURI withMode:(int) mode;
- (BOOL) isServiceStarted;
- (void) registeration;
- (void) answerCall:(pjsua_call_id) cid;
- (void) hangUpCall:(pjsua_call_id) cid;
@end
