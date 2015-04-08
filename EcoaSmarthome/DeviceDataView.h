//
//  DeviceDataView.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/16.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import "import.h"

#define dheight 20
#define dwidth 280
#define padding 10
#define wanTag 0
#define lanTag 1
#define userTag 2
#define passTag 3

@interface DeviceDataView : UIView <UITextFieldDelegate>
{
    UITextField *wanIP;
    UITextField *lanIP;
    UITextField *username;
    UITextField *password;
    UILabel *wanLabel;
    UILabel *lanLabel;
    UILabel *unLabel;
    UILabel *passLabel;
    UIButton *wConnect;
    UIButton *lConnect;
    UIButton *edit;
    NSString *did;
}

- (id) initWithFrameAndData:(CGRect)frame data:(NSMutableArray *)data;


@end
