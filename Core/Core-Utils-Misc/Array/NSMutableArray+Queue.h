//
//  NSMutableArray+Queue.h
//  Draw
//
//  Created by Kira on 12-10-31.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Queue)

- (void) enqueue: (id)item;
- (id) dequeue;
- (id) peek;

@end
