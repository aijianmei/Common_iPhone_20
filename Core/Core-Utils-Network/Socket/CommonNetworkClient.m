//
//  CommonNetworkClient.m
//  TestProtocolBuffer
//
//  Created by  on 11-12-23.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "CommonNetworkClient.h"
#import "PPDebug.h"

@implementation CommonNetworkClient

@synthesize asyncSocket;
@synthesize workingQueue;
@synthesize serverHost;
@synthesize serverPort;
@synthesize reconnectTimer;
@synthesize needReconnect;
@synthesize delegate;

- (id)init
{
    self = [super init];
    self.workingQueue = dispatch_queue_create("CommonNetworkClient", NULL);
    return self;
}

- (void)dealloc
{
    dispatch_release(self.workingQueue);
    self.workingQueue = NULL;
    
    [reconnectTimer release];
    [asyncSocket release];
    [serverHost release];
    [super dealloc];
}

- (BOOL)isConnected
{
    return [asyncSocket isConnected];
}

- (void)setConnectingFlag
{
    _connecting = YES;
}

- (void)clearConnectingFlag
{
    _connecting = NO;
}

- (BOOL)isConnecting
{
    return _connecting;
}

- (void)setDisconnectingFlag
{
    _disconnecting = YES;
}

- (void)clearDisconnectingFlag
{
    _disconnecting = NO;
}

- (BOOL)isDisconnecting
{
    return _disconnecting;
}

- (void)handleData:(NSData*)data
{
    PPDebug(@"Handle Data But Do Nothing, You Must Override this method!");
}

- (BOOL)sendData:(NSData*)data
{
    if (![self isConnected]){
        PPDebug(@"ERROR!!!, Send Data But Socket Not Connected");
        return NO;
    }
    
//    int TAG_HEADER = 1;
//    int TAG_DATA = 2;
    int TAG_BOTH = 3;
    
    if ([data length] == 0){
        PPDebug(@"WARNING, Send Data But Data Length = 0");
        return YES;
    }
    
    if ([asyncSocket isConnected] == NO){
        return NO;
    }
    
    dispatch_async(self.workingQueue, ^{
        
        int len = [data length];
        
        uint32_t netInt = CFSwapInt32HostToBig(len);    
        NSMutableData* headerData = [NSMutableData dataWithBytes:(uint8_t*)(&netInt) length:sizeof(netInt)];
        
        int MIN_WRITE_TIMEOUT = 5;   // 15 seconds for time out
        int networkSpeed = (9600/8); // worse case, GPRS 9.6KBit
        int timeOutSeconds = len / networkSpeed + 5; // extra 5 seconds
        if (timeOutSeconds < MIN_WRITE_TIMEOUT){
            timeOutSeconds = MIN_WRITE_TIMEOUT;
        }

        [headerData appendData:data];
        NSData* finalData = headerData;
        [asyncSocket writeData:finalData withTimeout:timeOutSeconds tag:TAG_BOTH];
        
//        [asyncSocket writeData:headerData withTimeout:timeOutSeconds tag:TAG_HEADER];        
//        [asyncSocket writeData:data withTimeout:timeOutSeconds tag:TAG_DATA];
    });
    
    return YES;
}

- (void)stopReconnectTimer
{
    PPDebug(@"stopReconnectTimer");

    [self.reconnectTimer invalidate];
    self.reconnectTimer = nil;
}

#define RECONNECT_TIMER_INTERVAL    1   // 1 seconds

- (void)startReconnectTimer
{
    // stop timer if any
    [self stopReconnectTimer];
        
    PPDebug(@"startReconnectTimer");
    dispatch_async(dispatch_get_main_queue(), ^{
        self.reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:RECONNECT_TIMER_INTERVAL
                                                               target:self 
                                                             selector:@selector(reconnect:) 
                                                             userInfo:nil 
                                                              repeats:NO];
    });
    
}

- (void)reconnect:(NSTimer*)timer
{    
    if (!self.needReconnect)
        return;
        
    PPDebug(@"Reconnecting...");
    [self connect:serverHost port:serverPort];
}

- (void)connect:(NSString*)host port:(int)port
{
    [self connect:host port:port autoReconnect:YES];
}

- (void)connect:(NSString*)host port:(int)port autoReconnect:(BOOL)autoReconnect
{            
    dispatch_sync(self.workingQueue, ^{
        
        // set flag
        self.needReconnect = autoReconnect;

        [self stopReconnectTimer];
        
        // close socket firstly
        [self disconnect];
        
        self.serverHost = host;
        self.serverPort = port;        
        self.asyncSocket = [[[GCDAsyncSocket alloc] initWithDelegate:self 
                                                       delegateQueue:self.workingQueue] 
                            autorelease];
        NSError *err = nil;
        [asyncSocket connectToHost:host onPort:port error:&err];    
        PPDebug(@"Connecting to Host(%@) Port(%d) Error(%@)", host, port, [err description]);        
    });
    
    return;
}

- (void)disconnect
{
    if ([self isConnected] == NO){
        return;
    }
    
    dispatch_block_t block = ^{
        [self setNeedReconnect:NO];
        [self stopReconnectTimer];
        
        if (asyncSocket){
            PPDebug(@"<disconnect>");
//          [asyncSocket disconnectAfterReadingAndWriting];
            [asyncSocket disconnect];
            [asyncSocket setDelegate:nil delegateQueue:NULL];
            self.asyncSocket = nil;
        }
	};
		
	// Synchronous disconnection
	if (dispatch_get_current_queue() == workingQueue)
		block();
	else
		dispatch_sync(workingQueue, block);
}


#pragma GCD Socket Delegate
#pragma mark -

- (void)closeSocketAndfireBrokenMessage:(NSError *)error
{
    [self.asyncSocket setDelegate:nil delegateQueue:NULL];
    self.asyncSocket = nil;
    
    if (delegate && [delegate respondsToSelector:@selector(didBroken:)]){
        [delegate didBroken:error];
    }
    
    if ([self needReconnect]){
        [self startReconnectTimer];
    }
}

- (void)socketDidCloseReadStream:(GCDAsyncSocket *)sock
{
    PPDebug(@"<socketDidCloseReadStream>");
//    [self closeSocketAndfireBrokenMessage];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    PPDebug(@"<socketDidDisconnect> error = %@", [err description]);
    
    [self closeSocketAndfireBrokenMessage:err];
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    PPDebug(@"<didWriteDataWithTag> tag = %ld", tag);
}

- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag
{
//    PPDebug(@"<didReadData> data length=%d, tag = %ld", [data length], tag);    
    if (tag == READ_TAG_LENGTH)
    {
        int* bodyLength = (int*)[data bytes];
        int len = ntohl(*bodyLength);
//        PPDebug(@"<didReadData> header length read, length = %d", len);
        [asyncSocket readDataToLength:len withTimeout:COMMON_NETWORK_READ_TIMEOUT tag:READ_TAG_DATA];
    }
    else if (tag == READ_TAG_DATA)
    {
        // business logci here
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleData:data];
        });
                
        // Start reading the next response
        [asyncSocket readDataToLength:4 withTimeout:COMMON_NETWORK_READ_TIMEOUT tag:1];
    }
}

- (void)startReadLength
{
    [asyncSocket readDataToLength:4     // length size is 4 (int32)
                      withTimeout:COMMON_NETWORK_READ_TIMEOUT 
                              tag:READ_TAG_LENGTH];
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port
{
    PPDebug(@"Host(%@) Port(%d) Connected", host, port);
    
    if (delegate && [delegate respondsToSelector:@selector(didConnected)]){
        [delegate didConnected];
    }
    
    [self startReadLength];
}     



@end
