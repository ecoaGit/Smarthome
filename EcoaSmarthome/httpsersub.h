//
//  httpsersub.h
//  EcoaSmarthome
//
//  Created by Apple on 2015/4/9.
//  Copyright (c) 2015年 ECOA. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <GCDAsyncSocket.h>
#import "httpconst.h"

@interface httpsersub : NSThread

-(void) httpsersub:(GCDAsyncSocket*)parent withDevice:(NSString *)pardevice port:(int)parListenPort index:(int)ix;

@end
