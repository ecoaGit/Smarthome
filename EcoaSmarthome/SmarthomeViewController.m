//
//  SmarthomeViewController.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/6.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "SmarthomeViewController.h"

@interface SmarthomeViewController () <NSURLConnectionDataDelegate, NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@end

@implementation SmarthomeViewController

@synthesize deviceList;
@synthesize serverList;
@synthesize close;
@synthesize logout;
@synthesize refresh;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        TAG = @"SmarthomeViewController";
    }
    return self;
}

- (void)viewDidLoad
{
    NSLog(@"view did load");
    [super viewDidLoad];
    manager = [SessionManager getInstance];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(receive:) name:@"deviceData" object:@"cloud"];
    
    self.tableView.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    UILongPressGestureRecognizer *regniz = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(onLongPress:)];
    [self.tableView addGestureRecognizer:regniz];
    
    close = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(closeWebView:)];
    logout = [[UIBarButtonItem alloc]initWithTitle:@"logout" style:UIBarButtonItemStylePlain target:self action:@selector(logoutAction:)];
    refresh = [[UIBarButtonItem alloc]initWithTitle:@"refresh" style:UIBarButtonItemStylePlain target:self action:nil];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [self.navigationItem setHidesBackButton:NO];
    [self sendToken];
    ccount = 0;
}

-(void) viewWillAppear:(BOOL)animated {
    NSLog(@"view will appear");
    [[UIDevice currentDevice] setValue:
     [NSNumber numberWithInteger: UIInterfaceOrientationLandscapeLeft]
                                forKey:@"orientation"];
    // update serverList
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationItem setRightBarButtonItem:logout];
    [manager getServerListFromCloud];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) receive:(NSNotification *)notification {
    if([[notification object] isEqualToString:@"doneLoading"]){
        ccount++;
        if (ccount == self.serverList.count) {
            NSLog(@"reload data");
            // 設備資料下載完畢，重整頁面
            [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            ccount = 0;
        }
    }
    else if ([[notification object]isEqualToString:@"cloud"]) {
        NSMutableArray *temp = [[notification userInfo]objectForKey:@"list"];
        NSString *ip=[[temp objectAtIndex:0]objectAtIndex:2];
        NSString *selfip=[[notification userInfo]objectForKey:@"selfIp"];
        inlan=[self isSameNetwork:ip device:selfip mask:@"255.255.255.0"];
        if (self.deviceList == nil) {
            // 雲端設備初始化
            self.deviceList = temp;
        }
        else {
            // 比對雲端設備資料
            //NSLog(@"compare list");
            [self compareListWith:temp];
        }
        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

- (BOOL) initDatabase {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *diretory = [path objectAtIndex:0];
    NSString *dbPath = [diretory stringByAppendingPathComponent:@"EcoaDatabase.db"];
    db = [FMDatabase databaseWithPath:dbPath];
    if ([db open]) {
        NSLog(@"database is open");
        return true;
    }
    else {
        NSLog(@"open database failed");
        return false;
    }
}


- (void) compareListWith:(NSMutableArray*)arr {
    for (int i = 0; i < self.deviceList.count; i++) {
        for (int j = 0; j < arr.count; j++) {
            if ([[[self.deviceList objectAtIndex:i]objectAtIndex:6] isEqualToString:[[arr objectAtIndex:j]objectAtIndex:6]]) {
                NSInteger selfUpdate = [[[self.deviceList objectAtIndex:i]objectAtIndex:7]integerValue];
                NSInteger arrUpdate = [[[arr objectAtIndex:j]objectAtIndex:7]integerValue];
                if (arrUpdate > selfUpdate) {
                    NSMutableArray *temp = [NSMutableArray arrayWithArray:[arr objectAtIndex:j]];
                    [self.deviceList replaceObjectAtIndex:i withObject:temp];
                }
            }
        }
    }
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    NSLog(@"error occur");
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"start to parse data");
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)receiveData {
    NSLog(@"smarthomecontrol: receive data");
    //NSString *string = [[NSString alloc]initWithData:receiveData encoding:NSUTF8StringEncoding];
    //NSLog(string);
    [data appendData:receiveData];
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSLog(@"receive response");
    data = [[NSMutableData alloc]init];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    //#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.deviceList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DeviceViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceViewCell" forIndexPath:indexPath];
    // Configure the cell...
    if (cell == nil) {
        NSLog(@"create cell");
        NSArray *nib = [[NSBundle mainBundle]loadNibNamed:@"DeviceViewCell" owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    if (self.deviceList != nil && self.deviceList.count != 0) {
        [cell.deviceName setText:[[self.deviceList objectAtIndex:indexPath.row] objectAtIndex:0]];
        if ([[[deviceList objectAtIndex:indexPath.row]objectAtIndex:1]intValue] == 200) {
            [cell.deviceName setTextColor:[UIColor blackColor]];
            [cell.deviceState setImage:[UIImage imageNamed:@"online"]];
            [cell.deviceState setContentMode:UIViewContentModeScaleAspectFit];
        }
        else {
            [cell.deviceName setTextColor:[UIColor grayColor]];
            [cell.deviceState setImage:[UIImage imageNamed:@"offline"]];
            [cell.deviceState setContentMode:UIViewContentModeScaleAspectFit];
        }
    }
    else {
        [cell.deviceName setText:@"Loading"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"connect");
    NSString *path;
    if(inlan){
        path=[NSString stringWithFormat:@"http://%@:%@", [[self.deviceList objectAtIndex:indexPath.row]objectAtIndex:4], [[self.deviceList objectAtIndex:indexPath.row] objectAtIndex:5]];
                
    }
    else {
        path=[NSString stringWithFormat:@"http://%@:%@", [[self.deviceList objectAtIndex:indexPath.row] objectAtIndex:2], [[self.deviceList objectAtIndex:indexPath.row] objectAtIndex:3]];
    }
    NSLog(@"%@", path);
    NSUserDefaults *ud=[NSUserDefaults standardUserDefaults];
    NSString *user_info=[ud stringForKey:[[self.deviceList objectAtIndex:indexPath.row] objectAtIndex:6]];
    NSString *username=@"";
    NSString *password=@"";
    if (user_info!=nil) {
        NSData *da=[user_info dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *json=[NSJSONSerialization JSONObjectWithData:da options:0 error:nil];
        username=[json valueForKey:@"username"];
        NSLog(@"un: %@",username);
        password=[json valueForKey:@"password"];
        NSLog(@"pw: %@",password);
    }
    if (![username isEqualToString:@""]&&![password isEqualToString:@""]) {
        NSLog(@"user data is not null");
        NSData* aData = [[NSString stringWithFormat:@"%@:%@", username, password]dataUsingEncoding:NSUTF8StringEncoding];
        NSString *auth = [[NSString alloc]initWithData:[aData base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
        path=[path stringByAppendingString:[NSString stringWithFormat:@"?auth=%@", auth]];
    }
    NSURL *url=[NSURL URLWithString:path];
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setHidesBackButton:YES];
    [self.navigationItem setRightBarButtonItem:close];
    
    if (web == nil) {
        web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        web.scalesPageToFit = YES;
        [web setAutoresizesSubviews:YES];
        [web setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
        web.delegate = self;
    }
    [web loadRequest:request];
    [web setTag:55];
    [self.view addSubview:web];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
}

- (void) openWebView:(NSURL*)url {
    NSLog(@"smarthomeviewcontroller openwebview");
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    [web loadRequest:request];
    //[self.view addSubview:web];
    //[web setHidden:NO];
    //[self.view bringSubviewToFront:web];
}

- (IBAction) closeWebView:(id) sender {
    //NSLog(@"closewebview");
    [web loadHTMLString:@"about:blank" baseURL:nil];
    [[self.view viewWithTag:55]removeFromSuperview];
    [self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItem:logout];
    [self.navigationItem setHidesBackButton:NO];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];
}

- (IBAction) logoutAction:(id)sender {
    // 執行登出
    [manager logout];
    // 顯示登入畫面
    [self performSegueWithIdentifier:@"logout" sender:self];
    // 更改按鈕
    /*[self.navigationItem setRightBarButtonItem:nil];
    [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"default" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [[NSRunLoop mainRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:0.5]];*/
}

- (void)onLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gesture locationInView:self.tableView];
        NSIndexPath *path = [self.tableView indexPathForRowAtPoint:point];
        
        if (path == nil) {
            return;
        }
        else {
            CustomIOS7AlertView *alertview = [[CustomIOS7AlertView alloc]init];
            [alertview setContainerView:[[DeviceDataView alloc]initWithFrameAndData:CGRectMake(0, 0, 300, 320) data:[self.deviceList objectAtIndex:path.row]]];
            
            [alertview show];
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (webView.isLoading)
        return;
    NSLog(@"webviewfinish");
    [splash close];
    splash = nil;
    //[web setHidden:NO];
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    //if (web.isLoading)
    //    return;
    NSLog(@"webviewstart");
    if (splash == nil) {
    splash = [[CustomIOS7AlertView alloc]init];
    UIDevice *dev = [UIDevice currentDevice];
    if ([dev.model isEqualToString:@"iPhone"] || [dev.model isEqualToString:@"iPhone6"]) {
        [splash setContainerView:[[LoadingView alloc]initWithFrame:CGRectMake(0, 0, 100, 70)]];
    }
    else if ([dev.model isEqualToString:@"iPad"]) {
        [splash setContainerView:[[LoadingView alloc] initWithFrame:CGRectMake(0, 0, 160, 160)]];
    }
    [splash setOnButtonTouchUpInside:^(CustomIOS7AlertView *alertView, int buttonIndex) {
        [alertView close];
    }];
    [splash show];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSLog(@"webview should start");
    
    return true;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
}

- (void) sendToken{
    NSUserDefaults *def=[NSUserDefaults standardUserDefaults];
    NSString *token=[def stringForKey:@"APNS_TOKEN"];
    NSString *username=[def stringForKey:@"cloudUsername"];
    NSString *type=@"iOS";
    NSDictionary *js_dic = [[NSDictionary alloc] initWithObjectsAndKeys:
                            token,@"token",
                            username, @"username",
                            type, @"type", nil];
    NSError *error;
    NSData *post_data=[NSJSONSerialization dataWithJSONObject:js_dic options:0 error:&error];
    NSURL *URL=[NSURL URLWithString:@"http://ecoacloud.com:80/cloudserver/sendtoken"];
    NSMutableURLRequest *request=[[NSMutableURLRequest alloc] initWithURL:URL];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setValue:[NSString stringWithFormat:@"%d", post_data.length] forHTTPHeaderField:@"Content-Length"];
    [request setHTTPBody:post_data];
    NSURLConnection *connect=[[NSURLConnection alloc]initWithRequest:request delegate:self];
}

- (BOOL)isSameNetwork:(NSString *)selfIp device:(NSString *)deviceIp mask:(NSString *)mask{
    Byte *d1=(Byte *)[[selfIp dataUsingEncoding:NSUTF8StringEncoding]bytes];
    Byte *d2=(Byte *)[[deviceIp dataUsingEncoding:NSUTF8StringEncoding]bytes];
    Byte *mas=(Byte *)[[mask dataUsingEncoding:NSUTF8StringEncoding]bytes];
    
    for (int i=0; i<[[selfIp dataUsingEncoding:NSUTF8StringEncoding] length]; i++){
        if ((d1[i]&mas[i])!=(d2[i]&mas[i])) {
            return NO;
        }
    }
    return YES;
}

@end
