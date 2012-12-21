//
//  animationItem.m
//  Draw
//
//  Created by Orange on 12-9-28.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AnimationPlayer.h"

@implementation AnimationPlayer
@synthesize view;

- (void)dealloc
{
    PPRelease(view);
    [super dealloc];
}


+ (void)showView:(UIView*)view 
          inView:(UIView*)superView 
       animation:(CAAnimation*)animation 
      completion:(AnimationPlayerFinishBlock)completion
{
    AnimationPlayer* player = [[[AnimationPlayer alloc] initWithView:view] autorelease];
    [player showInView:superView animation:animation completion:completion];
}

- (id)initWithView:(UIView*)aView
{
    self = [super init];
    if (self) {
        self.view = aView;
    }
    return self;
}

- (void)showInView:(UIView*)superView 
         animation:(CAAnimation*)animation 
        completion:(AnimationPlayerFinishBlock)completion
{
    finishAnimation = completion;

    [superView addSubview:self.view];
    animation.delegate = self;
    [self.view.layer addAnimation:animation forKey:nil];
}

- (void)hideView
{
//    [self.view setHidden:YES];
}

- (void)animationDidStart:(CAAnimation *)anim
{
    [self performSelector:@selector(hideView) withObject:nil afterDelay:anim.duration];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
//    self.view.hidden = YES;
    
//    finishAnimation = ^(BOOL finished){
//        PPDebug(@"test block");
//    };
    
    if (finishAnimation != NULL){
        finishAnimation(flag);
    }

    [self.view removeFromSuperview];
}



@end
