//
//  dialpad.m
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/19.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "dialpad.h"

@implementation dialpad

//@synthesize input;

static int TEXT=10;
static int NUM=11;

int inputType;
NSArray *arr;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSString *device = [UIDevice currentDevice].model;
        NSLog(@"%@", device);
        NSInteger font = 0;
        if ([device isEqualToString:@"iPhone"] || [device isEqualToString:@"iPhone5"]) {
            font = 20;
        }
        else if ([device isEqualToString:@"iPad"]){
            font = 30;
        }
        else {
            font = 20;
        }
        
        arr = @[@".", @"-", @"+", @"$", @"*", @"%", @":", @"@", @"#", @"/"];
    
        input = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height/5)];
        [input setBorderStyle:UITextBorderStyleNone];
        [input setTextAlignment:NSTextAlignmentCenter];
        [input setBackgroundColor:[UIColor darkGrayColor]];
        [input setTextColor:[UIColor whiteColor]];
        inputType = NUM;

        b7 = [[UIButton alloc]initWithFrame:CGRectMake(0, frame.size.height/5, frame.size.width/3, frame.size.height/5)];
        [b7 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b7 setBackgroundColor:[UIColor whiteColor]];
        b7.titleLabel.font = [UIFont boldSystemFontOfSize:font];
        [[b7 layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b7 layer]setBorderWidth:0.5f];
        [b7 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b7 setTag:7];
        
        b8 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/3, frame.size.height/5, frame.size.width/3, frame.size.height/5)];
        [b8 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b8 setBackgroundColor:[UIColor whiteColor]];
        b8.titleLabel.font = [UIFont boldSystemFontOfSize:font];
        [[b8 layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b8 layer]setBorderWidth:0.5f];
        [b8 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b8 setTag:8];
        
        b9 = [[UIButton alloc]initWithFrame:CGRectMake(2*(frame.size.width/3), frame.size.height/5, frame.size.width/3, frame.size.height/5)];
        [b9 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b9 setBackgroundColor:[UIColor whiteColor]];
        b9.titleLabel.font = [UIFont boldSystemFontOfSize:font];
        [[b9 layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b9 layer]setBorderWidth:0.5f];
        [b9 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b9 setTag:9];
        
        b4 = [[UIButton alloc]initWithFrame:CGRectMake(0, 2*(frame.size.height/5), frame.size.width/3, frame.size.height/5)];
        [b4 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b4 setBackgroundColor:[UIColor whiteColor]];
        b4.titleLabel.font = [UIFont boldSystemFontOfSize:font];
        [[b4 layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b4 layer]setBorderWidth:0.5f];
        [b4 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b4 setTag:4];
        
        b5 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/3, 2*(frame.size.height/5), frame.size.width/3, frame.size.height/5)];
        [b5 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b5 setBackgroundColor:[UIColor whiteColor]];
        b5.titleLabel.font = [UIFont boldSystemFontOfSize:font];
        [[b5 layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b5 layer]setBorderWidth:0.5f];
        [b5 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b5 setTag:5];
        
        b6 = [[UIButton alloc]initWithFrame:CGRectMake(2*(frame.size.width/3), 2*(frame.size.height/5), frame.size.width/3, frame.size.height/5)];
        [b6 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b6 setBackgroundColor:[UIColor whiteColor]];
        b6.titleLabel.font = [UIFont boldSystemFontOfSize:font];
        [[b6 layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b6 layer]setBorderWidth:0.5f];
        [b6 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b6 setTag:6];
        
        b1 = [[UIButton alloc]initWithFrame:CGRectMake(0, 3*(frame.size.height/5), frame.size.width/3, frame.size.height/5)];
        [b1 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b1 setBackgroundColor:[UIColor whiteColor]];
        b1.titleLabel.font = [UIFont boldSystemFontOfSize:font];
        [[b1 layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b1 layer]setBorderWidth:0.5f];
        [b1 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b1 setTag:1];
        
        b2 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/3, 3*(frame.size.height/5), frame.size.width/3, frame.size.height/5)];
        [b2 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b2 setBackgroundColor:[UIColor whiteColor]];
        b2.titleLabel.font = [UIFont boldSystemFontOfSize:font];
        [[b2 layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b2 layer]setBorderWidth:0.5f];
        [b2 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b2 setTag:2];
        
        b3 = [[UIButton alloc]initWithFrame:CGRectMake(2*(frame.size.width/3), 3*(frame.size.height/5), frame.size.width/3, frame.size.height/5)];
        [b3 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b3 setBackgroundColor:[UIColor whiteColor]];
        b3.titleLabel.font = [UIFont boldSystemFontOfSize:font];
        [[b3 layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b3 layer]setBorderWidth:0.5f];
        [b3 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b3 setTag:3];
        
        b_switch = [[UIButton alloc]initWithFrame:CGRectMake(0, 4*(frame.size.height/5), frame.size.width/3, frame.size.height/5)];
        [b_switch setBackgroundColor:[UIColor whiteColor]];
        [b_switch setImage:[UIImage imageNamed:@"switch"] forState:UIControlStateNormal];
        [[b_switch layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b_switch layer]setBorderWidth:0.5f];
        [b_switch addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b_switch setTag:11];
        
        b0 = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width/3, 4*(frame.size.height/5), frame.size.width/3, frame.size.height/5)];
        [b0 setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [b0 setBackgroundColor:[UIColor whiteColor]];
        b0.titleLabel.font = [UIFont boldSystemFontOfSize:font];
        [[b0 layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [[b0 layer]setBorderWidth:0.5f];
        [b0 addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b0 setTag:0];
        
        b_back = [[UIButton alloc]initWithFrame:CGRectMake(2*(frame.size.width/3), 4*(frame.size.height/5), frame.size.width/3, frame.size.height/5)];
        [b_back setBackgroundColor:[UIColor whiteColor]];
        [b_back setImage:[UIImage imageNamed:@"delete"] forState:UIControlStateNormal];
        [[b_back layer]setBorderWidth:0.5f];
        [[b_back layer]setBorderColor:[UIColor lightGrayColor].CGColor];
        [b_back addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [b_back setTag:12];
        
        [self setButton:inputType];
        
        [self addSubview:input];
        [self addSubview:b0];
        [self addSubview:b1];
        [self addSubview:b2];
        [self addSubview:b3];
        [self addSubview:b4];
        [self addSubview:b5];
        [self addSubview:b6];
        [self addSubview:b7];
        [self addSubview:b8];
        [self addSubview:b9];
        [self addSubview:b_back];
        [self addSubview:b_switch];

        
    }
    return self;
}

-(IBAction)buttonAction:(id)sender {
    switch ([sender tag]) {
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        {
            // add word
            NSString *texx = [input text];
            UIButton *button = (UIButton *) sender;
            [input setText: [texx stringByAppendingString:[NSString stringWithFormat:@"%@", button.currentTitle]]];
        }
            break;
        case 11:
        {
            if (inputType == NUM) {
                [self setButton:TEXT];
            }
            else {
                [self setButton:NUM];
            }
        }
            break;
        case 12:
        {
            NSString *texx = [input text];
            if (![texx isEqualToString:@""]) {
                [input setText: [texx substringToIndex:texx.length-1]];
            }
        }
            break;
        default:
            break;
    }
}

- (NSString*) getInput{
    NSString *temp = [[NSString alloc]initWithString:[input text]];
    [input setText:@""];
    return temp;
}

- (void) setButton:(int) type {
    if (type==TEXT) {
        [b0 setTitle:arr[0] forState:UIControlStateNormal];
        [b1 setTitle:arr[1] forState:UIControlStateNormal];
        [b2 setTitle:arr[2] forState:UIControlStateNormal];
        [b3 setTitle:arr[3] forState:UIControlStateNormal];
        [b4 setTitle:arr[4] forState:UIControlStateNormal];
        [b5 setTitle:arr[5] forState:UIControlStateNormal];
        [b6 setTitle:arr[6] forState:UIControlStateNormal];
        [b7 setTitle:arr[7] forState:UIControlStateNormal];
        [b8 setTitle:arr[8] forState:UIControlStateNormal];
        [b9 setTitle:arr[9] forState:UIControlStateNormal];
    }
    else if (type==NUM) {
        [b0 setTitle:@"0" forState:UIControlStateNormal];
        [b1 setTitle:@"1" forState:UIControlStateNormal];
        [b2 setTitle:@"2" forState:UIControlStateNormal];
        [b3 setTitle:@"3" forState:UIControlStateNormal];
        [b4 setTitle:@"4" forState:UIControlStateNormal];
        [b5 setTitle:@"5" forState:UIControlStateNormal];
        [b6 setTitle:@"6" forState:UIControlStateNormal];
        [b7 setTitle:@"7" forState:UIControlStateNormal];
        [b8 setTitle:@"8" forState:UIControlStateNormal];
        [b9 setTitle:@"9" forState:UIControlStateNormal];
    }
    
    inputType = type;
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
