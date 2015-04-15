//
//  httpser.m
//  EcoaSmarthome
//
//  Created by Apple on 2015/4/9.
//  Copyright (c) 2015年 ECOA. All rights reserved.
//

#import "httpser.h"

@implementation httpser

int httpPort;
GCDAsyncSocket *serverSock;
NSString *_device = @"ECOA000C08000F86";

bool runit = YES;
int listenPort = 3123;
Byte _bit[] = {1, 2, 4, 8, 0x10, 0x20, 0x40, (Byte)0x80};

-(void) httpser:(int) port {
    httpPort = port;
    for (int i = 0;i < 8;i++) {
        ExPort[i] = 0;
        ExUDPSocket[i] = NULL;
    }
    bitmk = 0;
    serverSock = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];;
}

- (void)start {
    while (runit) {
        [serverSock acceptOnPort:httpPort error:NULL];
    }
}

-(void) httpser:(int) port Device:(NSString*) device {
    _device = device;
    httpPort = port;
    for (int i = 0;i < 8;i++) {
        ExPort[i] = 0;
        ExUDPSocket[i] = NULL;
    }
    bitmk = 0;
    serverSock = [[GCDAsyncSocket alloc]initWithDelegate:self delegateQueue:dispatch_get_main_queue()];;
}

- (void)socket:(GCDAsyncSocket *)sock didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"accept new socket");
    for (int i=0; i<8; i++){
        if ((bitmk&_bit[i]) == 0) {
            bitmk |= _bit[i];
            httpsersub *me = [[httpsersub alloc]init];
            [me httpsersub:newSocket withDevice:_device port:listenPort+i index:i];
        }
    }
}

@end
