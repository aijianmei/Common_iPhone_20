//
//  NSMutableArray+Queue.m
//  Draw
//
//  Created by Kira on 12-10-31.
//
//

#import "NSMutableArray+Queue.h"

@implementation NSMutableArray (Queue)

- (void) enqueue: (id)item {
    [self addObject:item];
}

- (id) dequeue {
    id item = nil;
    if ([self count] != 0) {
        item = [[[self objectAtIndex:0] retain] autorelease];
        [self removeObjectAtIndex:0];
    }
    return item;
}

- (id) peek {
    id item = nil;
    if ([self count] != 0) {
        item = [[[self objectAtIndex:0] retain] autorelease];
    }
    return item;
}

@end
