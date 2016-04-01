//
//  LoadingVIew.m
//  EcoaSmarthome
//
//  Created by Apple on 2015/8/5.
//  Copyright (c) 2015年 ECOA. All rights reserved.
//

#import "LoadingView.h"

@implementation LoadingView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        message = [[UITextView alloc]initWithFrame:CGRectMake(0, (self.frame.size.height/2)-40, self.frame.size.width, 40)];
        [message setFont:[UIFont boldSystemFontOfSize:25]];
        [message setTextColor:[UIColor blueColor]];
        [message setText:@"Loading"];
        [message setTextAlignment:NSTextAlignmentCenter];
        [message setBackgroundColor:[UIColor clearColor]];
        
        progress = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        progress.center = CGPointMake((self.frame.size.width)/2, (self.frame.size.height/2)+10);
        [progress startAnimating];
        progress.transform = CGAffineTransformMakeScale(1.2f, 1.2f);
        [self addSubview:message];
        [self addSubview:progress];
    }
    return self;
}

@end
