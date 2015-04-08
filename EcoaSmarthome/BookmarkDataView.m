//
//  BookmarkDataView.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/10.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "BookmarkDataView.h"


@implementation BookmarkDataView

@synthesize bookmarkName;
@synthesize ip;
@synthesize username;
@synthesize password;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
    }
    return self;
}

- (id)initWithFrameAndData:(CGRect)frame data:(NSMutableArray *)data
{
    self = [super initWithFrame:frame];
    if (self) {
        
        nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, padding*2, 280, 20)];
        [nameLabel setText:NSLocalizedString(@"device name", @"label")];
        
        bookmarkName = [[UITextField alloc]initWithFrame:CGRectMake(padding, nameLabel.frame.origin.y+20+(padding/2), 280, 30)];
        bookmarkName.delegate = self;
        [bookmarkName setBorderStyle:UITextBorderStyleRoundedRect];
        [bookmarkName setText:[data objectAtIndex:0]];
        [bookmarkName setTag:dNameTag];
        
        ipLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, bookmarkName.frame.origin.y+20+padding, 280, 20)];
        [ipLabel setText:NSLocalizedString(@"ip", @"label")];
        
        ip = [[UITextField alloc]initWithFrame:CGRectMake(padding, ipLabel.frame.origin.y+20+(padding/2), 280, 30)];
        ip.delegate = self;
        [ip setBorderStyle:UITextBorderStyleRoundedRect];
        [ip setText:[data objectAtIndex:1]];
        [ip setTag:ipTag];
        
        unLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, ip.frame.origin.y+20+padding, 280, 20)];
        [unLabel setText:NSLocalizedString(@"username", @"label")];
        
        username = [[UITextField alloc]initWithFrame:CGRectMake(padding, unLabel.frame.origin.y+20+(padding/2), 280, 30)];
        username.delegate = self;
        [username setBorderStyle:UITextBorderStyleRoundedRect];
        [username setText:[data objectAtIndex:2]];
        [username setTag:userTag];
        
        passLabel = [[UILabel alloc]initWithFrame:CGRectMake(padding, username.frame.origin.y+20+padding, 280, 20)];
        [passLabel setText:NSLocalizedString(@"password", @"label")];
        
        password = [[UITextField alloc]initWithFrame:CGRectMake(padding, passLabel.frame.origin.y+20+(padding/2), 280, 30)];
        password.delegate = self;
        [password setBorderStyle:UITextBorderStyleRoundedRect];
        [password setText:[data objectAtIndex:3]];
        [password setTag:passTag];
        
        [self addSubview:nameLabel];
        [self addSubview:bookmarkName];
        [self addSubview:ipLabel];
        [self addSubview:ip];
        [self addSubview:unLabel];
        [self addSubview:username];
        [self addSubview:passLabel];
        [self addSubview:password];
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    NSLog(@"drawrect");
    
}*/


@end
