//
//  BlockUtils.h
//  Draw
//
//  Created by qqn_pipi on 12-11-30.
//
//

#import <Foundation/Foundation.h>

#define RELEASE_BLOCK(__x)            if (__x != NULL) Block_release(__x); __x = NULL
#define COPY_BLOCK(__x, __y)          if (__y != NULL) __x = Block_copy(__y)

#define EXECUTE_BLOCK(A,...)             if(A != NULL) {A(__VA_ARGS__);}


@interface BlockUtils : NSObject

@end
