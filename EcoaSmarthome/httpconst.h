//
//  httpconst.h
//  EcoaSmarthome
//
//  Created by Apple on 2015/4/9.
//  Copyright (c) 2015年 ECOA. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GCDAsyncSocket.h>

@interface httpconst : NSObject

extern GCDAsyncSocket *ExUDPSocket[8];
extern int ExPort[8];
extern NSString *ExIpaddr[8];
extern long *ExTime[8];
extern int bitmk;
//extern Byte bit[8];

@end
