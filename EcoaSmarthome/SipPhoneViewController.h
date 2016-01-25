//
//  SipPhoneViewController.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/5/20.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "import.h"
#import <pjsua.h>
#import "dialpad.h"
#import "CallViewController.h"
#import <AVFoundation/AVAudioSession.h>
#import "AppDelegate.h"

@interface SipPhoneViewController : UIViewController
{
    dialpad *dialPad;
    UIButton* audio;
    UIButton* video;
    UINavigationBar *navigationBar;
}

@end
