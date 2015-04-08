//
//  CallViewController.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/18.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <pjsua.h>
#import <AVFoundation/AVAudioSession.h>
#import "CallView.h"

@interface CallViewController : UIViewController
{
    UIImageView *remoteView;
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

@property (assign) pjsua_call_id ci;
@property (nonatomic) int calltype;
@property (nonatomic) CallView *callView;


- (void) bringCallView:(pjsua_call_id)ci withType:(int)type;


@end
