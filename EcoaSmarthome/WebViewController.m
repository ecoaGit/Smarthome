//
//  WebViewController.m
//  EcoaSmarthome
//
//  Created by Apple on 2016/3/29.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController () <UIWebViewDelegate, NSURLConnectionDelegate>

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    bar = [[UINavigationBar alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 60)];
    [bar setBackgroundColor:[UIColor grayColor]];
    web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 60, self.view.frame.size.width, self.view.frame.size.height-60)];
    web.scalesPageToFit = YES;
    [web setAutoresizesSubviews:YES];
    [web setAutoresizingMask:(UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth)];
    web.delegate = self;
    item = [[UINavigationItem alloc]initWithTitle:@"ECOA"];
    [bar pushNavigationItem:item animated:NO];
    UIBarButtonItem *button = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(closeWebView:)];
    item.rightBarButtonItem = button;
    [bar setItems:[NSArray arrayWithObject:item]];
    

    [item setBackBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil]];
    [item setHidesBackButton:NO];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [web loadRequest:req];
    
    [self.view addSubview:bar];
    [self.view addSubview:web];
    
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadWebView:(NSURL*)loadurl {
    url = loadurl;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    NSLog(@"webviewcontroller didstartload");
}

- (IBAction)closeWebView:(id)sender{
    [web loadHTMLString:@"about:blank" baseURL:nil];
    [self dismissViewControllerAnimated:NO completion:^{
    }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
