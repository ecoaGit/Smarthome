//
//  WebViewController.h
//  EcoaSmarthome
//
//  Created by Apple on 2016/3/29.
//  Copyright © 2016年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate>
{
    UINavigationItem *item;
    UINavigationBar *bar;
    UIWebView *web;
    NSURL *url;
}

- (void)loadWebView:(NSURL*)url;
@end
