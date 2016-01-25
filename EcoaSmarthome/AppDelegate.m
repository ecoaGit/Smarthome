//
//  AppDelegate.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/5/14.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "AppDelegate.h"

/*@interface AppDelegate ()
@property(nonatomic, strong) void (^registrationHandler)
(NSString *registrationToken, NSError *error);
@property(nonatomic, assign) BOOL connectedToGCM;
@property(nonatomic, strong) NSString* registrationToken;
@property(nonatomic, assign) BOOL subscribedToTopic;
@end*/

@implementation AppDelegate

pjsua_call_setting call_setting;
pjsua_acc_id acc_id;
Boolean incall;

static bool _serviceIsStarted = NO;
//static pjsua_transport_id udp_id;
static pjsua_transport_id tcp_id;
//static UIBackgroundTaskIdentifier bgtask;
CallViewController *callViewController;
static int READ_HEADER = 2;
static int READ_CONTENT = 3;
static int WRITE_DEVICETOKEN = 4;
static int counter = 0;
CallView *_callView;
pjsua_player_id p_id;
NSThread *sipThread;
//static int restartArgc;
//static char **restartArgv;
//static pj_thread_desc   thread_desc;
//static pj_thread_t     *thread;
static bool _sipthreadisStarted = NO;
static bool inLan;
static NSString *_gcmSenderID = @"1006004105041";


struct pjsua_player_eof_data
{
    pj_pool_t          *pool;
    pjsua_player_id player_id;
};

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    // app 開始
    // 檢查使用者是否未設定基本資料
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault boolForKey:@"set"] == NO) {
        [userDefault setBool:YES forKey:@"firstUse"];
        [userDefault setBool:NO forKey:@"userLock"];
        [userDefault setBool:YES forKey:@"useWifi"];
        [userDefault setBool:NO forKey:@"use3G"];
        [userDefault setBool:NO forKey:@"useShowAlarm"];
        [userDefault setBool:NO forKey:@"useAutoSip"];
        [userDefault setObject:@"http:\\\\ecoacloud.com:80" forKey:@"default_address"];
    }
    EcoaDBHelper *helper = [[EcoaDBHelper alloc]init];
    [helper createDataBase];
    manager = [SessionManager getInstance];
    [manager getServerListFromCloud];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(callStateChange:) name:@"call_data" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkParameter:) name:@"check_param" object:nil];
    
    // initial variable
    incall = false;
    p_id = PJSUA_INVALID_ID;
    
    callViewController = [[CallViewController alloc]init];
    [self.window makeKeyAndVisible];
    
    if (application.applicationState == UIApplicationStateBackground) {
        [self setUpKeepAlive:application];
    }
    
    // push notification
    // for iOS 8.0 above
    if ([[[UIDevice currentDevice] systemVersion]floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else { // for below iOS 8.0
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert| UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
    }
    
    UIUserNotificationType allNotificationTypes =
    (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    UIUserNotificationSettings *settings =
    [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
    /*_registrationHandler = ^(NSString *registrationToken, NSError *error){
        if (registrationToken != nil) {
            weakSelf.registrationToken = registrationToken;
            NSLog(@"Registration Token: %@", registrationToken);
            [weakSelf subscribeToTopic];
            NSDictionary *userInfo = @{@"registrationToken":registrationToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
        } else {
            NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
            NSDictionary *userInfo = @{@"error":error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
        }
    };*/
    
    return YES;
}

							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    
}

- (BOOL) initializePjsua {
    pj_status_t status;
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    // must call pjsua_create() first
    status = pjsua_create();
    if (status != PJ_SUCCESS) {
        pjsua_destroy();
        return false;
    }
    
    NSString *domain = [ud stringForKey:@"sipAddress"];
    const char* url = [[NSString stringWithFormat:@"sip:%@", domain] UTF8String];
    status = pjsua_verify_sip_url((char*)url);
    if (status != PJ_SUCCESS) {
        NSLog(@"verify sip url failed");
        return false;
    }
   
    
    pjsua_config cfg;
    pjsua_logging_config logg_cfg;
    pjsua_config_default(&cfg);
    
    cfg.cb.on_incoming_call = &on_incoming_call;
    cfg.cb.on_call_media_state = &on_call_media_state;
    cfg.cb.on_call_state = &on_call_state;
    cfg.cb.on_reg_state2 = &on_reg_state2;

    pjsua_logging_config_default(&logg_cfg);
    logg_cfg.console_level = 4;

    status = pjsua_init(&cfg, &logg_cfg, NULL);
    if (status != PJ_SUCCESS) {
        return false;
    }
    else {
        pjsua_transport_config cfg;
        pjsua_transport_config_default(&cfg);
        //cfg.port = 5060;
        cfg.port = 0;
        pjsua_transport_config tcfg;
        pj_memcpy(&tcfg, &cfg, sizeof(tcfg));
        pjsua_transport_config_default(&tcfg);
        //tcfg.port = 5678;
        //status = pjsua_transport_create(PJSIP_TRANSPORT_UDP, &cfg, &udp_id);
        //if (status == PJ_SUCCESS) {
        //    NSLog(@"UDP create");
        //}
        status = pjsua_transport_create(PJSIP_TRANSPORT_TCP, &cfg, &tcp_id);
        if (status != PJ_SUCCESS) {
            NSLog(@"transport create failed");
            return false;
        }
        pj_status_t status = pjsua_start();
        return (status == PJ_SUCCESS);
    }
    
    //return true;
}
/*
static void on_stopped (pj_bool_t restart, int argc, char** argv) {
    
}

static void on_started (pj_status_t status, const char* msg) {
    
}

static void on_config_init (pjsua_app_config *cfg) {
    cfg->no_udp = PJ_TRUE;
    cfg->no_tcp = PJ_FALSE;
}
*/
- (BOOL) startService {
    _serviceIsStarted = true;
    if ([self initializePjsua]) {
        // initialize success
        //pj_status_t status;
        //status = pjsua_start();
        //if (status != PJ_SUCCESS) {
            //NSLog(@"failed when start");
            //pjsua_destroy();
            //_serviceIsStarted = false;
        //}
    }
    else {
        NSLog(@"initialize failed");
        pjsua_destroy();
        _serviceIsStarted = false;
    }
    
    return _serviceIsStarted;
}

- (BOOL) isServiceStarted {
    return _serviceIsStarted;
}

// 註冊sip
- (void) registeration {
    NSLog(@"registeration");
    /* Register to SIP server by creating SIP account. */
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud synchronize];
    //pjsua_acc_id acc_id;
    pj_status_t status;
    
    pjsua_acc_config acc_cfg;
    pjsua_acc_config_default(&acc_cfg);
    NSString *username = [ud stringForKey:@"sipUsername"];
    NSString *password = [ud stringForKey:@"sipPassword"];
    NSString *domain = [ud stringForKey:@"sipAddress"];
    const char *uid = [[NSString stringWithFormat:@"sip:%@@%@", username, domain]UTF8String];
    const char *reg_uri = [[NSString stringWithFormat:@"sip:%@@%@;transport=TCP", username, domain]UTF8String];
    //const char *reg_uri = [[NSString stringWithFormat:@"sip:%@@%@", username, domain]UTF8String];
    //NSLog(@"sip:%@@%@", username, domain);

    status = pjsua_verify_sip_url((char*)reg_uri);
    if (status != PJ_SUCCESS) {
        NSLog(@"verify sip url failed");
        return;
    }
    
    // update contact via response
    acc_cfg.allow_contact_rewrite = PJ_TRUE;
    // 帳號
    acc_cfg.id = pj_str((char*)uid);
    //sip domain
    acc_cfg.reg_uri = pj_str((char*)reg_uri);
    acc_cfg.cred_count = 1;
    acc_cfg.cred_info[0].realm = pj_str("*");
    acc_cfg.cred_info[0].scheme = pj_str("digest");
    acc_cfg.ka_interval = 15;
    
    // video codec
    pj_pool_factory pf;
    pjmedia_codec_openh264_vid_init(NULL, &pf);
    
    // video device
    pjmedia_vid_dev_info vd;
    pj_status_t t =pjmedia_vid_dev_get_info(PJMEDIA_VID_DEFAULT_RENDER_DEV, &vd);
    
    //if (t == PJ_SUCCESS) {
    //    NSLog(@"%d*********%@" , vd.id, [NSString stringWithCString:vd.name encoding:NSUTF8StringEncoding]);
    //}
    //acc_cfg.vid_cap_dev = vd.id;
    //acc_cfg.vid_rend_dev = 0;

    // 帳號
    acc_cfg.cred_info[0].username = pj_str((char *)[username UTF8String]);
    // 密碼
    acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
    acc_cfg.cred_info[0].data = pj_str((char*)[password UTF8String]);

    // auto show receive video
    acc_cfg.vid_in_auto_show = PJ_TRUE;
    
    
    // auto transfer video
    acc_cfg.vid_out_auto_transmit = PJ_TRUE;
    
    // 設定proxy
    //const char *proxy = [[NSString stringWithFormat:@"sip:%@", domain]UTF8String];
    const char *proxy = [[NSString stringWithFormat:@"sip:%@;transport=TCP", domain]UTF8String];
    acc_cfg.proxy[acc_cfg.proxy_cnt++] = pj_str((char*)proxy);
    
    //pjsua_acc_add_local(tcp_id, PJ_TRUE, &acc_id);
    
    if (pjsua_acc_is_valid(acc_id)) {
        pjsua_acc_modify(acc_id, &acc_cfg);
    }
    else {
        status = pjsua_acc_add(&acc_cfg, PJ_TRUE, &acc_id);
    }
    if (status != PJ_SUCCESS) {
        NSLog(@"adding account failed");
        //pjsua_destroy();
        //_serviceIsStarted = false;
        return;
    }
    else {
        
    }
}

- (void) re_registeration:(NSString *)domain {
    NSLog(@"re-register");
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud synchronize];
    NSLog(@"%@",domain);
    //pjsua_acc_id acc_id;
    pj_status_t status;
    
    pjsua_acc_config acc_cfg;
    pjsua_acc_config_default(&acc_cfg);
    
    NSString *username = [ud stringForKey:@"sipUsername"];
    NSString *password = [ud stringForKey:@"sipPassword"];
    const char *uid = [[NSString stringWithFormat:@"sip:%@@%@", username, domain]UTF8String];
    const char *reg_uri = [[NSString stringWithFormat:@"sip:%@@%@;transport=TCP", username, domain]UTF8String];
    
    status = pjsua_verify_sip_url((char*)reg_uri);
    if (status != PJ_SUCCESS) {
        NSLog(@"verify sip url failed");
        return;
    }
    
    //pj_pool_t *pool = pjsua_pool_create("re-registerpool", 1024, 1024);
    //status = pjsua_acc_get_config(acc_id, pool, &acc_cfg);
    //if (status == PJ_SUCCESS) {
        acc_cfg.reg_uri = pj_str((char*)reg_uri);
    //}
    //else {
        // update contact via response
        acc_cfg.allow_contact_rewrite = PJ_TRUE;
        // 帳號
        acc_cfg.id = pj_str((char*)uid);
        //sip domain
        acc_cfg.reg_uri = pj_str((char*)reg_uri);
        acc_cfg.cred_count = 1;
        acc_cfg.cred_info[0].realm = pj_str("*");
        acc_cfg.cred_info[0].scheme = pj_str("digest");
        acc_cfg.ka_interval = 15;
        
        // video codec
        pj_pool_factory pf;
        pjmedia_codec_openh264_vid_init(NULL, &pf);
        
        // 帳號
        acc_cfg.cred_info[0].username = pj_str((char *)[username UTF8String]);
        // 密碼
        acc_cfg.cred_info[0].data_type = PJSIP_CRED_DATA_PLAIN_PASSWD;
        acc_cfg.cred_info[0].data = pj_str((char*)[password UTF8String]);
        
        // auto show receive video
        acc_cfg.vid_in_auto_show = PJ_TRUE;
        
        
        // auto transfer video
        acc_cfg.vid_out_auto_transmit = PJ_TRUE;
        
        // 設定proxy
        const char *proxy = [[NSString stringWithFormat:@"sip:%@;transport=TCP", domain]UTF8String];
        acc_cfg.proxy[acc_cfg.proxy_cnt++] = pj_str((char*)proxy);
        
        //pjsua_acc_add_local(tcp_id, PJ_TRUE, &acc_id);
    //}
    
    
    if (pjsua_acc_is_valid(acc_id)) {
        pjsua_acc_modify(acc_id, &acc_cfg);
        NSLog(@"set registration");
        //pjsua_acc_set_registration(acc_id, PJ_TRUE);
    }
    else {
        status = pjsua_acc_add(&acc_cfg, PJ_TRUE, &acc_id);
    }
    if (status != PJ_SUCCESS) {
        NSLog(@"adding account failed");
        //pjsua_destroy();
        //_serviceIsStarted = false;
        return;
    }
    else {
    
    }
}

- (BOOL) checkAnyRegistered {
    if (pjsua_acc_is_valid(acc_id)) {
        return true;
    }
    else {
        return false;
    }
}

- (void)keepAlive {
    //NSLog(@"do keepalive");
    /* Register this thread if not yet */
    if (!pj_thread_is_registered()) {
        static pj_thread_desc   thread_desc;
        static pj_thread_t     *thread;
        pj_thread_register("keepalivethread", thread_desc, &thread);
    }
    //pjsua_acc_set_registration(acc_id, 0);
    pjsua_acc_set_registration(acc_id, PJ_TRUE);
    /* Simply sleep for 5s, give the time for library to send transport
     * keepalive packet, and wait for server response if any. Don't sleep
     * too short, to avoid too many wakeups, because when there is any
     * response from server, app will be woken up again (see also #1482).
     */
    //pj_thread_sleep(5000);
  
}

- (void)checkAlarm {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        while (true) {
            //NSLog(@"check alarm");
            //[manager getDeviceList];
            //sleep(10);
        }
    });
    
}

- (void) checkParameter:(NSNotification *)notify{
    NSLog(@"check parameter");
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    
    doCheckSip = [ud boolForKey:@"useAutoSip"];
    [self handleSip];
}

- (void) handleAlarm:(NSNotification *)notify{
    NSLog(@"delegate: handle alarm");
    if ([notify object] != nil) {
        NSDictionary *di = [notify object];
        if (di != nil) {
            NSMutableArray *temp = [[notify userInfo]objectForKey:@"list"];
            NSString *selfIp = [[notify userInfo]objectForKey:@"selfIp"];
            NSString *ip = [[temp objectAtIndex:0] objectAtIndex:2];
            NSString *port;
            // wan
            if (![self isSameNetwork:selfIp device:ip mask:@"255.255.255.0"]) {
                NSLog(@"wan");
                inLan = false;
                port = [[temp objectAtIndex:0] objectAtIndex:3];
            }
            // lan
            else {
                NSLog(@"lan");
                ip = [[temp objectAtIndex:0]objectAtIndex:4];
                port = [[temp objectAtIndex:0]objectAtIndex:5];
                inLan = true;
            }
            //NSLog(@"ip + %@", ip);
            //NSLog(@"port + %@", port);
            GCDAsyncSocket *socket = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
            NSError *err = nil;
            
            NSNumberFormatter *f = [[NSNumberFormatter alloc]init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber *num = [f numberFromString:port];
            
            NSLog(@"ip/port %@ %@", ip, num);
            
            if (![socket connectToHost:ip onPort:[num unsignedIntValue] error:&err]) {
                NSLog(@"error: %@", err);
            }
        }
    }
}

- (BOOL)isSameNetwork:(NSString *)selfIp device:(NSString *)deviceIp mask:(NSString *)mask
{
    Byte *d1 = (Byte *)[[selfIp dataUsingEncoding:NSUTF8StringEncoding]bytes];
    Byte *d2 = (Byte *)[[deviceIp dataUsingEncoding:NSUTF8StringEncoding]bytes];
    Byte *mas = (Byte *)[[mask dataUsingEncoding:NSUTF8StringEncoding]bytes];
    
    for (int i = 0; i < [[selfIp dataUsingEncoding:NSUTF8StringEncoding] length]; i++){
        if ((d1[i]&mas[i]) != (d2[i]&mas[i])) {
            return false;
        }
    }
    return true;
}

- (void)setUpKeepAlive:(UIApplication *)application{
    /*[self performSelectorOnMainThread:@selector(keepAlive)
                           withObject:nil waitUntilDone:YES];*/
    
}
         
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // setup keep-alive
    [self performSelectorOnMainThread:@selector(keepAlive) withObject:nil waitUntilDone:YES];
    [application setKeepAliveTimeout:600 handler: ^{
        //NSLog(@"keep alive handler");
        [self performSelectorOnMainThread:@selector(keepAlive)
                               withObject:nil waitUntilDone:YES];
    }];
    //[self setUpKeepAlive:application];
   
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [application setApplicationIconBadgeNumber:0];
    //[application cancelAllLocalNotifications]; 可能導致無法在背景執行
    NSLog(@"app is active");
}

- (void) showNotification:(NSString *)text {
    NSLog(@"show notification");
    //UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"alarm" message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    
    //[alertView show];
}

/*- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"didReceiveLocalNotification");
   if (notification) {
        
        NSData *c_i = [notification.userInfo objectForKey:@"call_id"];
        pjsua_call_id temp;
    
        [c_i getBytes:&temp length:sizeof(temp)];
        pjsua_call_info info;
        pjsua_call_get_info(temp, &info);
       
    }
}*/


// this function triggers by incoming call
static void on_incoming_call(pjsua_acc_id acc_id, pjsua_call_id call_id, pjsip_rx_data *rdata) {
    
    pjsua_call_info ci;
    PJ_UNUSED_ARG(acc_id);
    PJ_UNUSED_ARG(rdata);
    
    pjsua_call_get_info(call_id, &ci);
    
    NSLog(@"Incoming call from %@!!",[NSString stringWithCString:ci.remote_info.ptr encoding:NSASCIIStringEncoding]);
    NSData *data = [NSData dataWithBytes:&call_id length:sizeof(call_id)];
    pjsua_call_answer(call_id, 180, NULL, NULL);
    
    NSString *file = [[NSBundle mainBundle]pathForResource:@"oldphone_mono" ofType:@"wav"];
    if (file != nil) {
        //NSLog(@"file path confirm %@", file);
        const char *c_file = [file UTF8String];
        pj_str_t filename = pj_str((char*)c_file);
        pjmedia_port *med_pt = NULL;
        pj_status_t status;
        status = pjsua_player_create(&filename, 0, &p_id);
        if (status == PJ_SUCCESS) {
            status = pjsua_player_get_port(p_id, &med_pt);
        }
        if (status == PJ_SUCCESS) {
            pj_pool_t *pool = pjsua_pool_create("wav_pool", 512, 512);
            struct pjsua_player_eof_data *eof_data = PJ_POOL_ZALLOC_T(pool, struct pjsua_player_eof_data);
            eof_data->pool = pool;
            eof_data->player_id = p_id;
            pjmedia_wav_player_set_eof_cb(med_pt, eof_data, &on_pjsua_wav_file_end_callback);
            
            status = pjsua_conf_connect(pjsua_player_get_conf_port(p_id), pjsua_player_get_conf_port(p_id));
            pjsua_conf_connect(pjsua_player_get_conf_port(p_id), 0);
        }
    }
    UILocalNotification *alert = [[UILocalNotification alloc] init];
    if (alert) {
        alert.timeZone = [NSTimeZone defaultTimeZone];
        alert.repeatInterval = 0;
        NSString *remote_info = [NSString stringWithCString:ci.remote_info.ptr encoding:NSASCIIStringEncoding];
        // remove sip:
        remote_info = [remote_info substringFromIndex:[remote_info rangeOfString:@":"].location+1];
        // remove domain
        remote_info = [remote_info substringToIndex:[remote_info rangeOfString:@"@"].location];
        alert.alertBody = [NSString stringWithFormat:@"%@%@", NSLocalizedString(@"incoming", @"string"), remote_info];
        /* This action just brings the app to the FG, it doesn't
         * automatically answer the call (unless you specify the
         * --auto-answer option).
         */
        alert.alertAction = @"Active app";
        alert.applicationIconBadgeNumber = 1;
        //NSDictionary *info = [NSDictionary dictionaryWithObject:data forKey:@"call_id"];
        //alert.userInfo = info;
        
        NSLog(@"show localnotification");
        [[UIApplication sharedApplication] presentLocalNotificationNow:alert];
    }
    //auto answer
    //pjsua_call_answer(call_id, 200, NULL, NULL);
}


static PJ_DEF(pj_status_t) on_pjsua_wav_file_end_callback(pjmedia_port* media_port, void* args)
{
    NSLog(@"call back");
    pj_status_t status;
    
    pjsua_player_id p_id;
    pj_pool_t *pool;
    
    struct pjsua_player_eof_data *eof_data = (struct pjsua_player_eof_data *)args;
    p_id = eof_data->player_id;
    pool = eof_data->pool;
    
    //pjsua_pl
    //status = pjsua_player_destroy(p_id);
    NSString *file = [[NSBundle mainBundle]pathForResource:@"oldphone_mono" ofType:@"wav"];
        const char *c_file = [file UTF8String];
       // pj_str_t filename = pj_str((char*)c_file);

    //pjsua_player_create(&filename, 0, &p_id);

    
    if (status == PJ_SUCCESS)
    {
        return -1;//Here it is important to return value other than PJ_SUCCESS
        //Check link below
    }
    
    return PJ_SUCCESS;
}


static void on_call_media_state(pjsua_call_id call_id) {
    pjsua_call_info ci;
    
    pjsua_call_get_info(call_id, &ci);
    NSLog(@"on call media state change");
    if (ci.media_status == PJSUA_CALL_MEDIA_ACTIVE) {
        // When media is active, connect call to sound device.
        pjsua_conf_connect(ci.conf_slot, 0);
        pjsua_conf_connect(0, ci.conf_slot);
        pjsua_conf_adjust_rx_level(0, 3.0);
    }
    /*************/
    pjsua_call_id c_id = ci.id;
    pjsua_vid_win_id wid;
    int vid_idx;
    vid_idx = pjsua_call_get_vid_stream_idx(c_id);
    pjsua_call_media_status sta= ci.media[vid_idx].status;
    
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
        wid = ci.media[vid_idx].stream.vid.win_in;
        NSLog(@"win_in %d", wid);
        pjd = ci.media[vid_idx].stream.vid.cap_dev;
        NSLog(@"cap_dev %d", pjd);
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
                //_win = (__bridge UIWindow *)(info.hwnd.info.ios.window);
            }
            else {
                NSLog(@"not native");
            }
            //[_win setBackgroundColor:[UIColor greenColor]];
            //[_win setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            //[self addSubview:_win];
            //[self bringSubviewToFront:_win];
        }
        else {
            NSLog(@"callview window id invalid");
        }
    }
    else {
        NSLog(@"callview no video stream");
    }
}

static void on_call_state(pjsua_call_id call_id, pjsip_event *e) {
    pjsua_call_info ci;
    PJ_UNUSED_ARG(e);
    pjsua_call_get_info(call_id, &ci);
    NSLog(@"delegate call id: %d", call_id);
    NSLog(@"delegate call state changed to %@ send notification", [NSString stringWithCString:ci.state_text.ptr encoding:NSASCIIStringEncoding]);

    int state = ci.state;
    switch (state) {
        case PJSIP_INV_STATE_NULL:
            NSLog(@"null");
        case PJSIP_INV_STATE_DISCONNECTED:
            NSLog(@"disconnected");
            // do something in here
            if (p_id != PJSUA_INVALID_ID) {
                pjsua_player_destroy(p_id);
                p_id = PJSUA_INVALID_ID;
            }
            /*if ([_callView superview] != nil) {
                NSLog(@"added");
            }*/
            //[_callView loadView:c_i withType:state];
            //[_callView removeFromSuperview];
            incall = false;
            [callViewController bringCallView:call_id withType:state];
            //[callViewController dismissViewControllerAnimated:YES completion:nil];
            [[UIDevice currentDevice]setProximityMonitoringEnabled:NO];
            break;
        case PJSIP_INV_STATE_CONFIRMED:
            break;
        case PJSIP_INV_STATE_CONNECTING:
            // do something in here
            [[UIDevice currentDevice] setProximityMonitoringEnabled:YES];
            if (p_id != PJSUA_INVALID_ID) {
                pjsua_player_destroy(p_id);
                p_id = PJSUA_INVALID_ID;
            }
            [callViewController bringCallView:call_id withType:state];
            //[_callView loadView:call_id withType:state];
            break;
            //case PJSIP_INV_STATE_CONNECTING:
        case PJSIP_INV_STATE_INCOMING:
            NSLog(@"incoming");
            break;
        case PJSIP_INV_STATE_CALLING:
            NSLog(@"calling");
        case PJSIP_INV_STATE_EARLY:
            NSLog(@"early");
            
            if (!incall) {
                /*if ([_callView superview] == nil){
                    NSLog(@"add callView");
                    [_callView setHidden:NO];
                    [callViewController.view addSubview:_callView];
                    callViewController.callView = _callView;
                }*/
                [callViewController initialCallView];
                
                UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
                //NSLog(@"%@",[root description]);
                if (root.presentedViewController) {
                    root = root.presentedViewController;
                    //NSLog(@"%@", root.description);
                }
                //[callViewController isFirstResponder];
                [callViewController bringCallView:call_id withType:state];
                [root presentViewController:callViewController animated:YES completion:^{
                }];
                incall = true;
                
            }
            break;
    }
}

static void on_reg_state2(pjsua_acc_id acc_id, pjsua_reg_info *info) {
    
    if (info->cbparam->status == PJ_SUCCESS && info->cbparam->code == 200) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reg" object:@"success"];
    }
    else {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"reg" object:@"failed"];
    }
}


- (void)makeCall:(NSString *)sipURI withMode:(int)mode {
    NSLog(@"make call");
    const char *sipuri = [sipURI UTF8String];
    pj_str_t uri = pj_str((char*)sipuri);
    pj_status_t status;
    pjsua_call_setting_default(&call_setting);
    call_setting.vid_cnt = mode;
    if (pjsua_get_state() == PJSUA_STATE_RUNNING) {
        status = pjsua_call_make_call(acc_id, &uri, &call_setting, NULL, NULL, NULL);
        if (status != PJ_SUCCESS){
            NSLog(@"didn't make it");
            return;
        }
    }
    else {
        NSLog(@"pjsua not running");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    //[[UIApplication sharedApplication] endBackgroundTask:bgTask];
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void) stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode {
    
}

- (void) socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(uint16_t)port {
    // send url
    NSLog(@"connected to host");
    
    NSString *url = [NSString stringWithFormat:@"GET /alarmnew?command=newalarm&msg=Y&tm=%d%@", (int)[[NSDate date] timeIntervalSince1970], @"HTTP/1.1\r\n\r\n"];
   // NSLog(@"%@",url);
    [sock writeData:[url dataUsingEncoding:NSUTF8StringEncoding] withTimeout:15 tag:0];
}

- (void) socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag {
    // read data
    NSLog(@"delegate: receive data");
    if (data != nil) {
        if (tag == READ_HEADER) {
            
            //NSMutableData *dd;
            //[sock readDataWithTimeout:15 buffer:dd bufferOffset:0 tag:READ_HEADER];
            //NSLog(@"%@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            NSString *length = [self parseHTTPHeader:data];
            NSLog(@"%@bytes", length);
            [sock readDataToLength:[length integerValue] withTimeout:15 tag:READ_CONTENT];
        }
        else if (tag == READ_CONTENT) {
            //NSLog(@"content");
            //NSLog(@"content %@", [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding]);
            
        }
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSLog(@"error: %@", err);
}

- (void) socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag {
    if (tag == 0) {
        // write url
        NSLog(@"write sccuess");
        NSData *data = [@"\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding];
        [sock readDataToData:data withTimeout:15 tag:READ_HEADER];
    }
}

- (NSString *) parseHTTPHeader:(NSData *)data {
    NSString *string = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"read %D",[string rangeOfString:@"Content-Length:"].location);
    string = [string substringFromIndex:[string rangeOfString:@"Content-Length:"].location];
    string = [string substringToIndex:[string rangeOfString:@"\n"].location];
    string = [string substringFromIndex:[string rangeOfString:@":"].location+1];
    [string intValue];
    //NSLog(@"sub%@", string);

    return string;
}

- (void) callStateChange:(NSNotification *)notify {
    NSLog(@"callstatechange ");
    NSNumber *val = [[notify userInfo] objectForKey:@"call_id"];
    pjsua_call_id c_i = [val intValue];
    int state = [[[notify userInfo] objectForKey:@"call_state"] intValue];

    switch (state) {
        case PJSIP_INV_STATE_NULL:
            NSLog(@"null");
        case PJSIP_INV_STATE_DISCONNECTED:
            NSLog(@"disconnected");
            // do something in here
            if ([_callView superview] != nil) {
                NSLog(@"added");
            }
            //[_callView loadView:c_i withType:state];
            //[_callView removeFromSuperview];
            incall = false;
            [callViewController bringCallView:c_i withType:state];
            //[callViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        case PJSIP_INV_STATE_CONFIRMED:
            // do something in here
            [callViewController bringCallView:c_i withType:state];
            //[_callView loadView:c_i withType:state];
            break;
        //case PJSIP_INV_STATE_CONNECTING:
        case PJSIP_INV_STATE_CALLING:
            NSLog(@"calling");
        case PJSIP_INV_STATE_INCOMING:
            NSLog(@"incoming");
            break;
        case PJSIP_INV_STATE_EARLY:
            NSLog(@"early");
            if (!incall) {
                //if (_callView == nil){
                    //[_callView initWithFrame:];
                    //[_callView setHidden:NO];
                    //[callViewController.view addSubview:_callView];
                    //callViewController.callView = _callView;
               // }
                [callViewController initialCallView];
                
                UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
                //NSLog(@"%@",[root description]);
                if (root.presentedViewController) {
                    root = root.presentedViewController;
                    //NSLog(@"%@", root.description);
                }
                //[callViewController isFirstResponder];
                [callViewController bringCallView:c_i withType:state];
                [root presentViewController:callViewController animated:YES completion:^{
                                   }];
                incall = true;
            }
            break;
    }
}

/** push notification **/

-(void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    const unsigned *tokenBytes = [deviceToken bytes];
    NSString *iosDeviceToken = [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x", ntohl(tokenBytes[0]), ntohl(tokenBytes[1]), ntohl(tokenBytes[2]),ntohl(tokenBytes[3]), ntohl(tokenBytes[4]), ntohl(tokenBytes[5]), ntohl(tokenBytes[6]), ntohl(tokenBytes[7])];
    //NSLog(@"device token %@", iosDeviceToken);
    // send provision
    GCDAsyncSocket *t_socket = [[GCDAsyncSocket alloc]initWithSocketQueue:dispatch_queue_create("socket_queue", NULL)];
    NSString *cloudserver = @"http://ecoacloud.com/cloudserver/sendToken";
    [t_socket connectToHost:cloudserver onPort:80 error:NULL];
    [t_socket writeData:deviceToken withTimeout:10 tag:WRITE_DEVICETOKEN];
    [t_socket disconnectAfterWriting];
}

-(void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"failed when register remote notification");
    NSLog(@"error: %@", error.description);
}

/*-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"receive remote notification");
    
}*/

-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    pjsua_acc_set_registration(acc_id, PJ_TRUE);
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody =  @"Looks like i got a notification - fetch thingy";
    [application presentLocalNotificationNow:notification];
    completionHandler(UIBackgroundFetchResultNewData);
}

-(void) handleSip/*:(NSNotification *)notify*/{
    if (doCheckSip && !_sipthreadisStarted) {
        NSLog(@"situ 1");
        sipThread = [[NSThread alloc]initWithTarget:self selector:@selector(startSipThread) object:nil];
        [sipThread start];
    }
    else if (doCheckSip && _sipthreadisStarted) {
        NSLog(@"situ 2");
    }
    else if (!doCheckSip && _sipthreadisStarted){
        // stop sip thread after 5 secs
        NSLog(@"situ 3");
        [self performSelector:@selector(stopSipThread) withObject:nil afterDelay:5.0f];
    }
}

-(void) startSipThread {
    if (!pj_thread_is_registered()) {
        static pj_thread_desc   thread_desc;
        static pj_thread_t     *thread;
        pj_thread_register("checkregthread", thread_desc, &thread);
    }
    //[NSThread sleepForTimeInterval:1];
    _sipthreadisStarted = YES;
    while (doCheckSip) {
        NSLog(@"check sip domain");
        [manager login];
        [manager getDeviceList];
        NSMutableArray *array = [manager getDeviceList:0];
        if ([array count]>0) {
            //NSLog(@"%@",[[array objectAtIndex:0] description]);
            NSString *ip, *sip_reg;
             NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
            inLan = [self isSameNetwork:[manager getSelfIp] device:[[array objectAtIndex:0] objectAtIndex:2] mask:@"255.255.255.0"];
            if (!inLan) {
                //NSLog(@"wan");
                ip = [[array objectAtIndex:0] objectAtIndex:2];
                //NSString *port = [[array objectAtIndex:0] objectAtIndex:3];
                sip_reg = [ip stringByAppendingString:@":5678"];
            }
            else {
                //NSLog(@"inlan");
                sip_reg = [def stringForKey:@"sipAddress"];
            }
            //NSLog(@"%@", sip_reg);
            pjsua_acc_info info;
            pjsua_acc_get_info(acc_id, &info);
            
            NSString *old_reg = [[NSString alloc ]initWithBytes:info.acc_uri.ptr length:info.acc_uri.slen encoding:NSUTF8StringEncoding];
            //NSLog(@"old%@", old_reg);
            old_reg = [old_reg stringByReplacingOccurrencesOfString:@"sip:" withString:@""];
            old_reg = [old_reg substringFromIndex:[old_reg rangeOfString:@"@"].location +1];
            //NSLog(@"%@", old_reg);
            if (![sip_reg isEqualToString:old_reg]) {
                NSLog(@"refresh reg");
                [self re_registeration:sip_reg];
            }
        }
        [NSThread sleepForTimeInterval:20];
    }
}


- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
}

// [START receive_apns_token]
/*- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // [END receive_apns_token]
    // [START get_gcm_reg_token]
    // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    // Start the GGLInstanceID shared instance with the that config and request a registration
    // token to enable reception of notifications
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
    _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                             kGGLInstanceIDAPNSServerTypeSandboxOption:@YES};
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
    // [END get_gcm_reg_token]
}*/


/*
struct my_call_data
{
    pj_pool_t          *pool;
    pjmedia_port       *tonegen;
    pjsua_conf_port_id  toneslot;
};

struct my_call_data *call_init_tonegen(pjsua_call_id call_id)
{
    pj_pool_t *pool;
    struct my_call_data *cd;
    pjsua_call_info ci;
    
    pool = pjsua_pool_create("mycall", 512, 512);
    cd = PJ_POOL_ZALLOC_T(pool, struct my_call_data);
    cd->pool = pool;
    
    pjmedia_tonegen_create(cd->pool, 8000, 1, 160, 16, 0, &cd->tonegen);
    pjsua_conf_add_port(cd->pool, cd->tonegen, &cd->toneslot);
    
    pjsua_call_get_info(call_id, &ci);
    pjsua_conf_connect(cd->toneslot, ci.conf_slot);
    
    pjsua_call_set_user_data(call_id, (void*) cd);
    
    return cd;
}

void call_play_digit(pjsua_call_id call_id, const char *digits)
{
    pjmedia_tone_digit d[16];
    unsigned i;
    unsigned count = strlen(digits);
    struct my_call_data *cd;
    
    cd = (struct my_call_data*) pjsua_call_get_user_data(call_id);
    if (!cd)
        cd = call_init_tonegen(call_id);
    
    if (count > PJ_ARRAY_SIZE(d))
        count = PJ_ARRAY_SIZE(d);
    
    pj_bzero(d, sizeof(d));
    for (i=0; i<count; ++i) {
        d[i].digit = digits[i];
        d[i].on_msec = 100;
        d[i].off_msec = 200;
        d[i].volume = 0;
    }
    
    pjmedia_tonegen_play_digits(cd->tonegen, count, d, 0);
}

void call_deinit_tonegen(pjsua_call_id call_id)
{
    struct my_call_data *cd;
    
    cd = (struct my_call_data*) pjsua_call_get_user_data(call_id);
    if (!cd)
        return;
    
    pjsua_conf_remove_port(cd->toneslot);
    pjmedia_port_destroy(cd->tonegen);
    pj_pool_release(cd->pool);
    
    pjsua_call_set_user_data(call_id, NULL);
}

- (void) playdigits:(pjsua_call_id) call_id withDigit:(NSString *)str{
    const char *digits = [str UTF8String];
    call_play_digit(call_id, digits);
}*/

- (void) stopSipThread {
    [sipThread cancel];
    sipThread = nil;
}

- (BOOL) isDeviceInLan {
    return inLan;
}

@end
