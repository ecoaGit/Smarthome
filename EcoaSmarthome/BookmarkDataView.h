//
//  BookmarkDataView.h
//  EcoaSmarthome
//
//  Created by Apple on 2014/6/10.
//  Copyright (c) 2014年 ECOA. All rights reserved.
//

#import <UIKit/UIKit.h>


#define padding 10
#define dNameTag 0
#define ipTag 1
#define userTag 2
#define passTag 3

@interface BookmarkDataView : UIView <UITextFieldDelegate>
{
    //UITextField *bookmarkName;
    //UITextField *ip;
    //UITextField *username;
    //UITextField *password;
    UIBarButtonItem *edit;
    UINavigationBar *naviBar;
    UILabel *nameLabel;
    UILabel *ipLabel;
    UILabel *unLabel;
    UILabel *passLabel;
}

@property UITextField *bookmarkName;
@property UITextField *ip;
@property UITextField *username;
@property UITextField *password;
- (id) initWithFrameAndData:(CGRect)frame data:(NSMutableArray *)data;

@end
