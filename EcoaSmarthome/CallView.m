//
//  CallView.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/19.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "CallView.h"

Boolean vid;
int font;

@implementation CallView


- (id)init
{
    CGRect rect = [[UIScreen mainScreen] bounds];
    self = [super initWithFrame:rect];
    if (self) {
        // Initialization code
        NSLog(@"initial callview");
        vid = false;
        cid = PJSUA_INVALID_ID;
        // set font size
        NSString *device = [UIDevice currentDevice].model;
        int font = 0;
        if ([device isEqualToString:@"iPhone"] || [device isEqualToString:@"iPhoneSimulator"]) {
            font = 20;
        }else if ([device isEqualToString:@"iPhone5"]) {
            font = 20;
        }
        else if ([device isEqualToString:@"iPad"]) {
            font = 35;
        }
        else {
            font = 20;
        }
        
        remoteName = [[UILabel alloc]init];
        [remoteName setTextColor:[UIColor whiteColor]];
        [remoteName setTextAlignment:NSTextAlignmentCenter];
        [remoteName setTag:101];
        [remoteName setHidden:NO];
        [remoteName setFrame:CGRectMake(0, 20, self.frame.size.width, font+4)];
        [remoteName setBackgroundColor:[UIColor redColor]];
        callTime = [[UILabel alloc]init];
        [callTime setTextColor:[UIColor whiteColor]];
        [callTime setTextAlignment:NSTextAlignmentCenter];
        [callTime setBackgroundColor:[UIColor redColor]];
        [callTime setFrame:CGRectMake(0, remoteName.frame.size.height+20, self.frame.size.width, font)];
        [callTime setHidden:NO];
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
        [answerVid setImage:[UIImage imageNamed:@"answerVid"] forState:UIControlStateNormal];
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
        [dtmf addTarget:self action:@selector(dtmf:) forControlEvents:UIControlEventTouchUpInside];
        opendoor = [[UIButton alloc]init];
        [opendoor setBackgroundColor:[UIColor lightGrayColor]];
        opendoor.layer.borderWidth=3.0f;
        opendoor.layer.borderColor=[[UIColor grayColor]CGColor];
        [opendoor setImage:[UIImage imageNamed:@"opendoor"] forState:UIControlStateNormal];
        [opendoor setTag:107];
        currentType = call_none;
        
        dtmfPad = [[dialpad alloc]initWithFrame:CGRectMake(60, 60, self.frame.size.width-120, self.frame.size.height-120)];
        [dtmfPad setHidden:YES];
        [dtmfPad setDtmfDial:YES];
        
        [self addSubview:dtmfPad];
        [self addSubview:remoteName];
        [self addSubview:remoteView];
        [self addSubview:hangup];
        [self addSubview:answer];
        [self addSubview:answerVid];
        [self addSubview:speaker];
        [self addSubview:dtmf];
        [self addSubview:opendoor];
        [self addSubview:callTime];
        
    }
    return self;
}

- (void)loadView:(pjsua_call_id)call_id withType:(int)callType {
    NSLog(@"call view: load view type");
    cid = call_id;
    NSLog(@"call view get call id");
    currentType = callType;
    NSLog(@"call view get call type");
    pjsua_call_info call_info;
    NSString *remote_info;
    
    pj_status_t status = pjsua_call_get_info(call_id, &call_info);
    NSLog(@"call view get call info");
    if (status != PJ_SUCCESS) {
        NSLog(@"get call info failed");
        return;
    }
    else {
        NSLog(@"get call info");
        remote_info = [NSString stringWithCString:call_info.remote_info.ptr encoding:NSASCIIStringEncoding];
        NSLog(@"remote info %@", [NSString stringWithCString:call_info.remote_info.ptr encoding:NSASCIIStringEncoding]);
        //** remove sip:
        remote_info = [remote_info substringFromIndex:[remote_info rangeOfString:@":"].location+1];
        //** remove domain
        remote_info = [remote_info substringToIndex:[remote_info rangeOfString:@"@"].location];
        //NSLog(@"%@", remote_info);
        [remoteName setText:remote_info];
    }
    if (callType == PJSIP_INV_STATE_EARLY || callType == PJSIP_INV_STATE_CALLING) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadIncomingView:call_info];
        });
    }
    else if (callType == PJSIP_INV_STATE_CONNECTING) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadCallingView:call_info];
        });
    }
    else if (callType == PJSIP_INV_STATE_DISCONNECTED || callType == PJSIP_INV_STATE_NULL) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadCallEndView:call_info];
        });
    }
    return;
   
}

- (void) loadWaitingView:(pjsua_call_info) c_i {
    NSInteger rest = self.frame.size.height - font - 50;
    NSLog(@"call type:call_wait");
    remoteView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20+font, self.frame.size.width, rest/2)];
    [remoteView setImage:[UIImage imageNamed:@"remote"]];
    if (c_i.state == PJSIP_INV_STATE_CALLING) {
        [hangup setFrame:CGRectMake(0, remoteView.frame.origin.y+remoteView.frame.size.height, self.frame.size.width, rest/4)];
        [hangup setHidden:NO];
        [answer setHidden:YES];
    }
}

- (void) loadCallEndView:(pjsua_call_info) c_i {
    NSLog(@"call type:call_end");
    [self stopTimer];
    cid = PJSUA_INVALID_ID;
    [answer setHidden:YES];
    [hangup setHidden:YES];
    [speaker setHidden:YES];
    [dtmf setHidden:YES];
    [opendoor setHidden:YES];
}

- (void) loadCallingView:(pjsua_call_info) call_info {
   
    if (call_info.setting.vid_cnt == 1) {
        NSLog(@"call type:call_vid");
        
        [answer setHidden:YES];
        [answerVid setHidden:YES];
        NSInteger rest = self.frame.size.height - font - 50;
        [hangup setFrame:CGRectMake(0, remoteView.frame.origin.y+remoteView.frame.size.height, self.frame.size.width, rest/4)];
        [hangup setHidden:NO];
        [speaker setFrame:CGRectMake(0, remoteView.frame.origin.y+remoteView.frame.size.height+rest/4, self.frame.size.width/3, rest/4)];
        [speaker setHidden:YES];
        [dtmf setFrame:CGRectMake(self.frame.size.width/3, remoteView.frame.origin.y+remoteView.frame.size.height+rest/4, self.frame.size.width/3, rest/4)];
        [dtmf setHidden:NO];
        [opendoor setFrame:CGRectMake(2*(self.frame.size.width/3), remoteView.frame.origin.y+remoteView.frame.size.height+rest/4, self.frame.size.width/3, rest/4)];
        [opendoor setHidden:YES];
        
        pjsua_vid_preview_param pre;
        pjsua_vid_win_id pre_id;
        pjsua_vid_preview_param_default(&pre);
        pj_status_t status;
        pjsua_vid_win_info pre_info;
        NSLog(@"start preview");
        status = pjsua_vid_preview_start(PJMEDIA_VID_DEFAULT_CAPTURE_DEV, &pre);
        if (status == PJ_SUCCESS) {
            NSLog(@"preview success render id %d", pre.rend_id);
            pre_id = pjsua_vid_preview_get_win(PJMEDIA_VID_DEFAULT_CAPTURE_DEV);
            if (pre_id == PJSUA_INVALID_ID)
                NSLog(@"preview window invalid");
            pjsua_vid_win_get_info(pre_id, &pre_info);
            NSLog(@"show%d", pre_info.show);
            NSLog(@"isnative%d", pre_info.is_native);
            //NSLog(@"%d",pre_info.size.h);
            //NSLog(@"%s", pre_info.hwnd.info.ios.window);
        }
        //pjsua_vid_preview_get_win(PJMEDIA_VID_DEFAULT_CAPTURE_DEV);
        //pjsua_vid_win_info pre_info;
        //pjsua_vid_win_get_info(pre_id, &pre_info);
        //pjsua_vid_win_set_show(pre_id, PJ_TRUE);
        
        UIWindow *_win = self.window;// put this to vid handler
        pjsua_call_id c_id = call_info.id;
        pjsua_vid_win_id wid;
        int vid_idx;
        vid_idx = pjsua_call_get_vid_stream_idx(c_id);
        pjsua_call_media_status sta= call_info.media[vid_idx].status;
        if (call_info.media[vid_idx].stream.vid.win_in == PJSUA_INVALID_ID) {
            NSLog(@"invalid");
        }
        if (call_info.media[vid_idx].stream.vid.cap_dev == PJMEDIA_VID_INVALID_DEV){
            NSLog(@"invalid dev");
        }
        NSLog(@"%d",call_info.media[vid_idx].status);
        if (sta==PJSUA_CALL_MEDIA_NONE) {
            NSLog(@"media none");
        }
        
        /**
         * The media is active
         */
        else if (sta ==PJSUA_CALL_MEDIA_ACTIVE){
            NSLog(@"media active");
        }
        /**
         * The media is currently put on hold by local endpoint
         */
        else if (sta==PJSUA_CALL_MEDIA_LOCAL_HOLD){
            NSLog(@"media hold local");
        }
        
        /**
         * The media is currently put on hold by remote endpoint
         */
        else if (sta==PJSUA_CALL_MEDIA_REMOTE_HOLD){
            NSLog(@"media hold remote");
        }
        
        /**
         * The media has reported error (e.g. ICE negotiation)
         */
        else if (sta ==PJSUA_CALL_MEDIA_ERROR){
            NSLog(@"media error");
        }
        
        pjmedia_vid_dev_index pjd;
        NSLog(@"get vid stream idx %d", vid_idx);
        if (vid_idx >= 0) {
            wid = call_info.media[vid_idx].stream.vid.win_in;
            NSLog(@"%d", wid);
            pjd = call_info.media[vid_idx].stream.vid.cap_dev;
            NSLog(@"%d", pjd);
            if (pjd == PJMEDIA_VID_INVALID_DEV) {
                NSLog(@"send invalid");
            }
            if (wid != PJSUA_INVALID_ID) {
                pj_status_t st;
                st = pjsua_vid_win_set_show(wid, PJ_TRUE);
                
                if (st != PJ_SUCCESS) {
                    NSLog(@"show failed");
                }
                pjsua_vid_win_info info;
                pjsua_vid_win_get_info(wid, &info);
                if (info.is_native){
                    NSLog(@"is native");
                    _win = (__bridge UIWindow *)(info.hwnd.info.ios.window);
                }
                else {
                    NSLog(@"not native");
                }
                [_win setBackgroundColor:[UIColor greenColor]];
                [_win setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
                [self addSubview:_win];
                [self bringSubviewToFront:_win];
            }
            else {
                NSLog(@"callview window id invalid");
            }
        }
        else {
            NSLog(@"callview no video stream");
        }
        return;
    }
    NSLog(@"call type:call_aud");
    [self initTimer];
    [timer fire];
    NSInteger rest = self.frame.size.height - font - 50;
    [answer setHidden:YES];
    [answerVid setHidden:YES];
    [hangup setFrame:CGRectMake(0, remoteView.frame.origin.y+remoteView.frame.size.height, self.frame.size.width, rest/4)];
    [hangup setHidden:NO];
    [speaker setFrame:CGRectMake(0, remoteView.frame.origin.y+remoteView.frame.size.height+rest/4, self.frame.size.width/3, rest/4)];
    [speaker setHidden:NO];
    [dtmf setFrame:CGRectMake(self.frame.size.width/3, remoteView.frame.origin.y+remoteView.frame.size.height+rest/4, self.frame.size.width/3, rest/4)];
    [dtmf setHidden:NO];
    [opendoor setFrame:CGRectMake(2*(self.frame.size.width/3), remoteView.frame.origin.y+remoteView.frame.size.height+rest/4, self.frame.size.width/3, rest/4)];
    [opendoor setHidden:NO];
    return;
}

- (void) loadIncomingView:(pjsua_call_info) call_info {
    NSInteger rest = self.frame.size.height - font - 50;
    remoteView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 20+font, self.frame.size.width, rest/2)];
    [remoteView setBackgroundColor:[UIColor greenColor]];
    [remoteView setImage:[UIImage imageNamed:@"remote"]];
    [answer setFrame:CGRectMake(0, remoteView.frame.origin.y+remoteView.frame.size.height, self.frame.size.width/3, rest/4)];
    [answerVid setFrame:CGRectMake(self.frame.size.width/3, remoteView.frame.origin.y+remoteView.frame.size.height, self.frame.size.width/3, rest/4 )];
    [hangup setFrame:CGRectMake(2*(self.frame.size.width/3), remoteView.frame.origin.y+remoteView.frame.size.height, self.frame.size.width/3, rest/4)];
    if (call_info.state == PJSIP_INV_STATE_CALLING) {
        [answer setHidden:YES];
        [answerVid setHidden:YES];
        [hangup setFrame:CGRectMake(0, remoteView.frame.origin.y+remoteView.frame.size.height, self.frame.size.width, rest/4)];
    }
    else {
        [answer setHidden:NO];
        [answerVid setHidden:NO];
    }
    [hangup setHidden:NO];
    [opendoor setHidden:YES];
    [speaker setHidden:YES];
    [dtmf setHidden:YES];
}

- (void) drawRect:(CGRect)rect{
    NSLog(@"draw rect");
}

- (void) dealloc {
}

- (void) initTimer {
    float freq = 1.0f;
    time = 0;
    [callTime setText:[NSString stringWithFormat:@"%@%ld:%ld:%ld", NSLocalizedString(@"time", @"text"),time/3600, time/60, time]];
    timer = [NSTimer scheduledTimerWithTimeInterval:freq target:self selector:@selector(countTotalTime:) userInfo:nil repeats:YES];
    
}

- (void) countTotalTime:(NSTimer *)timer {
    time++;
    [callTime setText:[NSString stringWithFormat:@"%@%ld:%ld:%ld", NSLocalizedString(@"time", @"text"), time/3600, time/60, time]];
}

- (void) stopTimer {
    [timer invalidate];
}

- (int) getCurrentType {
    return currentType;
}



- (IBAction)answer:(id)sender {
    NSLog(@"callview: answer call");
    UIButton *button = (UIButton *)sender;
    NSInteger tag = [button tag];
    pjsua_call_setting c_set;
    pjsua_call_setting_default(&c_set);
    c_set.vid_cnt = 0;
    if (tag == 108) {
        vid = true;
        c_set.vid_cnt = 1;
    }
    pjsua_call_answer2(cid, &c_set, 200, NULL, NULL);
}

- (IBAction)hangup:(id)sender {
    NSLog(@"callview: hangup call");
    pjsua_call_hangup(cid, 0, NULL, NULL);
}

- (IBAction)dtmf:(id)sender {
    NSLog(@"callview: dtmf");
    /*pjsua_call_vid_strm_op_param parm;
    pjsua_call_vid_strm_op_param_default(&parm);
    parm.dir = PJMEDIA_DIR_CAPTURE;
    pjsua_call_set_vid_strm(cid, PJSUA_CALL_VID_STRM_CHANGE_DIR, &parm);*/
    [dtmfPad setHidden:![dtmfPad isHidden]];
    [self bringSubviewToFront:dtmfPad];
    
}

- (IBAction)openDoor:(id)sender {
    const char *hash = [@"#" UTF8String];
    pj_str_t digits = pj_str((char*)hash);
    pjsua_call_dial_dtmf(cid, &digits);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/


@end
