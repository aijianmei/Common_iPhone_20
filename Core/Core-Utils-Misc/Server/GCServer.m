//
//  GCServer.m
//  Draw
//
//  Created by Orange on 12-8-30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GCServer.h"

@implementation GCServer
@synthesize address;
@synthesize port;
- (void)dealloc
{
    [address release];
    [super dealloc];
}

@end
