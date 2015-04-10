//
//  httpser.h
//  EcoaSmarthome
//
//  Created by Apple on 2015/4/9.
//  Copyright (c) 2015年 ECOA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GCDAsyncSocket.h>
#import "httpsersub.h"
#import "httpconst.h"

@interface httpser : NSThread <GCDAsyncSocketDelegate>

-(void) httpser:(int) sPort;
-(void) httpser:(int) sPort Device: (NSString*) device;

@end
