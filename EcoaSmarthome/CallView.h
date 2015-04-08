//
//  CallView.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/19.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pjsua.h>
#import "dialpad.h"
#import "EcoaSipManager.h"
#import <pjmedia_videodev.h>
#import <pjmedia.h>


#define call_vid 0
#define call_aud 1
#define call_wait 2
#define call_end 3
#define call_inc 4
#define call_none 11


@interface CallView : UIView
{
    UIImageView *remoteView;
    //UIView *localView;
    
    UILabel *remoteName;
    UIButton *hangup;
    UIButton *answer;
    UIButton *answerVid;
    UIButton *opendoor;
    UIButton *dtmf;
    UIButton *speaker;
    UILabel *callTime;
    long time;
    NSTimer *timer;
    NSDateFormatter *format;
    
    int currentType;
    
    dialpad *dtmfPad;
    
    pjsua_call_id cid;
}

- (void) loadView:(pjsua_call_id)call_id withType:(int)callType;
- (int) getCurrentType;
- (void) callStateChange:(NSNotification *)notify;

@end
