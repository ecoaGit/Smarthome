//
//  dialpad.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/19.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//
#import <UIKit/UIKit.h>



@interface dialpad : UIView
{
    UITextField *input;
    UIButton *b0;
    UIButton *b1;
    UIButton *b2;
    UIButton *b3;
    UIButton *b4;
    UIButton *b5;
    UIButton *b6;
    UIButton *b7;
    UIButton *b8;
    UIButton *b9;
    UIButton *b_switch;
    UIButton *b_back;
}

//@property (nonatomic,retain) UITextField* input;
- (NSString*) getInput;
@end
