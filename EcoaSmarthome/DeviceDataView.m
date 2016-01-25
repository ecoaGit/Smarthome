//
//  DeviceDataView.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/16.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "DeviceDataView.h"

@implementation DeviceDataView 

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id) initWithFrameAndData:(CGRect)frame data:(NSMutableArray *)data {
    NSLog(@"devicedataview");

    self = [super initWithFrame:frame];
    if (self) {
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        
        wanLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, dheight, (dwidth/2), dheight)];
        [wanLabel setText:NSLocalizedString(@"wan", @"label")];
        wanIP = [[UITextField alloc]initWithFrame:CGRectMake(padding, wanLabel.frame.origin.y+dheight+(padding/2), dwidth, dheight)];
        [wanIP setDelegate:self];
        [wanIP setBorderStyle:UITextBorderStyleRoundedRect];
        [wanIP setText:[NSString stringWithFormat:@"%@:%@", [data objectAtIndex:2], [data objectAtIndex:3]]];
        [wanIP setTag:wanTag];
        
        
        lanLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, dheight+wanIP.frame.origin.y+padding, (dwidth/2), dheight)];
        [lanLabel setText:NSLocalizedString(@"lan", @"label")];
        lanIP = [[UITextField alloc]initWithFrame:CGRectMake(padding, dheight+lanLabel.frame.origin.y+(padding/2), dwidth, dheight)];
        [lanIP setDelegate:self];
        [lanIP setBorderStyle:UITextBorderStyleRoundedRect];
        [lanIP setText:[NSString stringWithFormat:@"%@:%@", [data objectAtIndex:4], [data objectAtIndex:5]]];
        [lanIP setTag:lanTag];
        
        unLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, lanIP.frame.origin.y+dheight+padding, dwidth, dheight)];
        [unLabel setText:NSLocalizedString(@"username", @"label")];
        username = [[UITextField alloc]initWithFrame:CGRectMake(padding, unLabel.frame.origin.y+dheight+(padding/2), dwidth, dheight)];
        [username setDelegate:self];
        [username setBorderStyle:UITextBorderStyleRoundedRect];
        [username setTag:userTag];
        
        passLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, username.frame.origin.y+dheight+padding, dwidth, dheight)];
        [passLabel setText:NSLocalizedString(@"password", @"label")];
        password = [[UITextField alloc]initWithFrame:CGRectMake(padding, passLabel.frame.origin.y+dheight+(padding/2), dwidth, dheight)];
        [password setDelegate:self];
        [password setBorderStyle:UITextBorderStyleRoundedRect];
        [password setTag:passTag];
        
        did = [data objectAtIndex:6];
        NSString *source = [ud stringForKey:did];
        if (source != nil) {
            NSData *da = [source dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:da options:0 error:nil];
            [username setText:[json valueForKey:@"username"]];
            [password setText:[json valueForKey:@"password"]];
        }
    }
    [wanIP setEnabled:NO];
    [lanIP setEnabled:NO];
    
    [self addSubview:wanLabel];
    [self addSubview:wanIP];
    [self addSubview:wConnect];
    [self addSubview:lanLabel];
    [self addSubview:lanIP];
    [self addSubview:unLabel];
    [self addSubview:username];
    [self addSubview:passLabel];
    [self addSubview:password];
    
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    switch ([textField tag]) {
        case wanTag:
        case lanTag:
        {
            NSLog(@"connect");
            NSString *path = [NSString stringWithFormat:@"http://%@", textField.text];
            if (![username.text isEqualToString:@""] &&![password.text isEqualToString:@""]) {
                NSData* data = [[NSString stringWithFormat:@"%@:%@", username.text, password.text]dataUsingEncoding:NSUTF8StringEncoding];
                NSString *auth = [[NSString alloc]initWithData:[data base64EncodedDataWithOptions:0] encoding:NSUTF8StringEncoding];
                path = [path stringByAppendingString:[NSString stringWithFormat:@"?auth=%@", auth]];
            }
            NSURL *url = [NSURL URLWithString:path];
            //[[UIApplication sharedApplication]openURL:url];
            [self openWebView:url];
            
        }
            break;
        default:
            break;
    }
}

- (void) openWebView:(NSURL*)url {
    NSLog(@"deviceDataview openwebView");
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(0, 0, 320, 480)];
    web.scalesPageToFit = YES;
    [web loadRequest:request];
    [self addSubview:web];

}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"finished edit");
    switch ([textField tag]) {
        case userTag:
        case passTag:
        {
            NSLog(@"save");
            NSMutableDictionary *nd = [[NSMutableDictionary alloc]init];
            [nd setValue:username.text forKey:@"username"];
            [nd setValue:password.text forKey:@"password"];
            NSData* json = [NSJSONSerialization dataWithJSONObject:nd options:NSJSONReadingMutableLeaves error:nil];
            NSString *result = [[NSString alloc]initWithData:json encoding:NSUTF8StringEncoding];
            
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            [ud setObject:result forKey:did];
            [ud synchronize];
        }
            break;
        default:
            break;
    }
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
