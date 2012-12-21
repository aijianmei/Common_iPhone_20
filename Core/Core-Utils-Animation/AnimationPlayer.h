//
//  animationItem.h
//  Draw
//
//  Created by Orange on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AnimationManager.h"

typedef void (^AnimationPlayerFinishBlock)(BOOL finished);

@interface AnimationPlayer : NSObject {
    AnimationPlayerFinishBlock finishAnimation;
//    void (^finishAnimation)(BOOL finished);
}

@property (retain, nonatomic) UIView* view;

+ (void)showView:(UIView*)view 
          inView:(UIView*)superView 
       animation:(CAAnimation*)animation 
      completion:(AnimationPlayerFinishBlock)completion;

- (id)initWithView:(UIView*)aView;
- (void)showInView:(UIView*)superView 
         animation:(CAAnimation*)animation 
        completion:(AnimationPlayerFinishBlock)completion;

@end
