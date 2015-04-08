//
//  CallViewController.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/18.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "CallViewController.h"

int currentType;
Boolean vid;
pjsua_call_id cid;

@interface CallViewController ()

@end

@implementation CallViewController

@synthesize ci;
@synthesize calltype;
@synthesize callView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        cid = PJSUA_INVALID_ID;
        vid = false;
        
        remoteName = [[UILabel alloc]init];
        [remoteName setTextColor:[UIColor whiteColor]];
        [remoteName setTextAlignment:NSTextAlignmentCenter];
        [remoteName setTag:101];
        remoteView = [[UIImageView alloc]init];
        [remoteView setTag:102];
        [remoteView setImage:[UIImage imageNamed:@"remote"]];
        hangup = [[UIButton alloc]init];
        [hangup setBackgroundColor:[UIColor whiteColor]];
        hangup.layer.borderWidth=3.0f;
        hangup.layer.borderColor=[[UIColor grayColor] CGColor];
        [hangup setImage:[UIImage imageNamed:@"hangup"] forState:UIControlStateNormal];
        [hangup addTarget:self action:@selector(hangup:) forControlEvents:UIControlEventTouchUpInside];
        [hangup setTag:103];
        answer = [[UIButton alloc]init];
        [answer setBackgroundColor:[UIColor whiteColor]];
        answer.layer.borderWidth=3.0f;
        answer.layer.borderColor=[[UIColor grayColor] CGColor];
        [answer setImage:[UIImage imageNamed:@"answer"] forState:UIControlStateNormal];
        [answer addTarget:self action:@selector(answer:) forControlEvents:UIControlEventTouchUpInside];
        [answer setTag:104];
        answerVid = [[UIButton alloc]init];
        [answerVid setBackgroundColor:[UIColor whiteColor]];
        [answerVid setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
        answerVid.layer.borderWidth=3.0f;
        answerVid.layer.borderColor=[[UIColor grayColor]CGColor];
        [answerVid addTarget:self action:@selector(answer:) forControlEvents:UIControlEventTouchUpInside];
        [answerVid setTag:108];
        speaker = [[UIButton alloc]init];
        [speaker setBackgroundColor:[UIColor lightGrayColor]];
        speaker.layer.borderWidth=3.0f;
        speaker.layer.borderColor=[[UIColor grayColor]CGColor];
        [speaker setImage:[UIImage imageNamed:@"speaker"] forState:UIControlStateNormal];
        [speaker setTag:105];
        dtmf = [[UIButton alloc]init];
        [dtmf setBackgroundColor:[UIColor lightGrayColor]];
        dtmf.layer.borderWidth=3.0f;
        dtmf.layer.borderColor=[[UIColor grayColor] CGColor];
        [dtmf setImage:[UIImage imageNamed:@"dtmf"] forState:UIControlStateNormal];
        [dtmf setTag:106];
        opendoor = [[UIButton alloc]init];
        [opendoor setBackgroundColor:[UIColor lightGrayColor]];
        opendoor.layer.borderWidth=3.0f;
        opendoor.layer.borderColor=[[UIColor grayColor]CGColor];
        [opendoor setImage:[UIImage imageNamed:@"opendoor"] forState:UIControlStateNormal];
        [opendoor setTag:107];
        currentType = call_none;
        
        //[self addSubview:remoteName];
        //[self addSubview:remoteView];
        //[self addSubview:hangup];
        //[self addSubview:answer];
        //[self addSubview:answerVid];
        //[self addSubview:speaker];
        //[self addSubview:dtmf];
        //[self addSubview:opendoor];
        
    }
    return self;

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"callviewcontroll viewdidload");
    
    CGRect rect = [[UIScreen mainScreen] bounds];

    //NSLog(@"callviewcontrol: view did load");
    //currentType = call_none;
    //callView = nil;
    //[[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(retriveCallid:) name:@"callview_call_state" object:nil];
    /*[[NSNotificationCenter defaultCenter]addObserverForName:@"callview_call_state" object:nil queue:nil usingBlock:^(NSNotification *notif) {
        pjsua_call_id ca_i;
        NSLog(@"callviewcontroller: notify call_state");
        NSData *data = notif.userInfo[@"call_id"];
        NSLog(@"callviewcontrol get call id");
        if (!data || data.length != sizeof(ca_i)) {
            // failed
            NSLog(@"callviewcontrol failed");
        }
        else {
            // extract call info
            NSLog(@"callviewcontrol extract call id");
            [data getBytes:&ca_i length:sizeof(ca_i)];
            NSLog(@"%d" ,ca_i);
            pjsua_call_info info;
            pj_status_t status = pjsua_call_get_info(ca_i, &info);
            //NSLog(@"callviewcontrol status");
            if (status == PJ_SUCCESS) {
                NSLog(@"callviewcontrol success");
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"dispatch get main queue");
                    [ self bringCallView:info];
                });
            }
            else {
                NSLog(@"get status failed");
            }
        }
    }];*/
}

- (void) viewWillAppear:(BOOL)animated {
    /*NSLog(@"callviewcontrol: viewWillAppear");
    if (&ci != NULL) {
        pjsua_call_info info;
        pjsua_call_get_info(ci, &info);
        //dispatch_async(dispatch_get_main_queue(), ^{
                [self bringCallView:info];
           // });
    }*/
}


/**
 *  載入通話畫面
 *  通話模式：
        call_wait：等待中
        call_aud：語音通話
        call_vid：視訊通話
        call_end：通話結束
 
    通話模式定義於#CallView中

 */

- (void) bringCallView:(pjsua_call_id)c_i withType:(int)type{
    NSLog(@"callviewcontrol: bring call view");
    [self.view setBackgroundColor:[UIColor blackColor]];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [callView loadView:c_i withType:type];
    });
    if (type == PJSIP_INV_STATE_DISCONNECTED) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            sleep(3);
            [self dismissViewControllerAnimated:YES completion:nil];
        });
    }
}


- (void)dealloc {
    NSLog(@"dealloc");
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

@end
