//
//  NSMutableArray+Stack.h
//  Draw
//
//  Created by Kira on 12-10-31.
//
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (Stack)

- (void)push:(id)item;
- (id)pop;
- (id)peek;

@end
