//
//  httpsersub.m
//  EcoaSmarthome
//
//  Created by Apple on 2015/4/9.
//  Copyright (c) 2015年 ECOA. All rights reserved.
//

#import "httpsersub.h"

@implementation httpsersub

GCDAsyncSocket *client;
int ListenPort = 3123, serPort = 3456, ind;
NSString *device = @"ECOA000C08000F86";
Byte _bit1[] = {1, 2, 4, 8, 0x10, 0x20, 0x40, (Byte)0x80};
Byte OK[4];
Byte buffer[];

-(void) httpsersub:(GCDAsyncSocket*)parent withDevice:(NSString *)pardevice port:(int)parListenPort index:(int)ix {
    client=parent;
    device=pardevice;
    ListenPort=parListenPort;
    ind=ix;
    
    OK[0]=(Byte)0x84;
    OK[1]=0x1;
    OK[2]=0;
    OK[3]=0;
    
    if (ExUDPSocket[ix] == NULL || (long)([[NSDate date] timeIntervalSince1970] * 1000)>=ExTime[ix]) {
        if (ExUDPSocket[ix] != NULL) {
            [ExUDPSocket[ix] disconnect];
            ExUDPSocket[ix] = NULL;
        }
        if ([self askForConnet]>=5) {
            [client disconnect];
            bitmk &= ~_bit1[ix];
            NSLog(@"=== httpsersub unnormal close %d ===", ix);
        }
        else {
            [self start];
        }
    }
    else {
        [self start];
    }
}

-(int) askForConnet {
    int retry = 0;
    
    return retry;
}

-(void) start {
    Byte ContentLength[]={'C','o','n','t','e','n','t','-','L','e','n','g','t','h',':',' '};
    Byte cmd[512];
    int rd,i,k,total,s1,s2,s3,sz;
    bool readFg=true;
    Byte sockRead[8192];
    bool sockOk=true;
    long begtm=0;
    NSMutableData *buff;
    
    begtm = [[NSDate date] timeIntervalSince1970] * 1000;
    
    sockOk = true;
    total = 0;
    
    s1 = -1;
    sz = 0;
    while (readFg) {
        [client readDataWithTimeout:5 buffer:buff bufferOffset:0 maxLength:512 tag:0];
        rd = [buff length];
        memccpy(cmd, [buff bytes], 0, rd);
        if (rd<=0){
            break;
        }
        [self writeUDP:buff length:rd];
        total+=rd;
        
        if (s1 == -1) {
            
        }
    }
}

-(void) writeUDP:(NSMutableData*)bff length:(int) ln{
    
}

@end
