//
//  AnimationManager.h
//  HitGameTest
//  这里需要QuartzCore.framework
//  Created by  on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

typedef enum {
    ClockWise = 1,
    AntiClockWise = -1
}RotateDirectionType;

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>
@interface AnimationManager : NSObject
{
    NSMutableDictionary *_animationDict;
}

- (CAAnimation *)animationForKey:(NSString *)key;
- (void)setAnimation:(CAAnimation *)animation forKey:(NSString *)key;

//rotation
+ (CAAnimation *)rotateAnimationWithRoundCount:(CGFloat) count
                               duration:(CFTimeInterval)duration;

+ (CAAnimation *)rotateAnimationFrom:(float)startValue
                                  to:(float)endValue 
                            duration:(float)duration;

+ (CAAnimation *)circlingAnimationWithDirection:(RotateDirectionType)direction
                                       duration:(float)duration
                                  repeatedCount:(int)repeatedCount;


//opacity
+ (CAAnimation *)disappearAnimationWithDuration:(CFTimeInterval)duration;
+ (CAAnimation *)disappearAnimationFrom:(CGFloat)startValue
                                     to:(CGFloat)endValue
                                  delay:(CGFloat)delay
                               duration:(CGFloat)duration;


+ (CAAnimation *)appearAnimationFrom:(CGFloat)startValue
                                  to:(CGFloat)endValue
                            duration:(CGFloat)duration;

+ (CAAnimation *)appearAnimationFrom:(CGFloat)startValue
                                  to:(CGFloat)endValue
                               delay:(CGFloat)delay
                            duration:(CGFloat)duration;


// position.y
+ (CAAnimation *)moveVerticalAnimationFrom:(CGFloat)startValue
                                        to:(CGFloat)endValue
                                  duration:(float)duration;

//scale
+ (CAAnimation *)scaleAnimationWithScale:(CGFloat)scale  
                                duration:(CFTimeInterval)duration 
                                delegate:(id)delegate 
                        removeCompeleted:(BOOL)removedOnCompletion;
+ (CAAnimation *)scaleAnimationWithFromScale:(CGFloat)fromScale 
                                     toScale:(CGFloat)toScale
                                    duration:(CFTimeInterval)duration 
                                    delegate:(id)delegate 
                            removeCompeleted:(BOOL)removedOnCompletion;



//translation
+ (CAAnimation *)translationAnimationFrom:(CGPoint) start
                                       to:(CGPoint)end
                                 duration:(CFTimeInterval)duration;
+ (CAAnimation *)translationAnimationTo:(CGPoint)end
                               duration:(CFTimeInterval)duration;
+ (CAAnimation *)translationAnimationFrom:(CGPoint) start
                                       to:(CGPoint)end
                                 duration:(CFTimeInterval)duration 
                                 delegate:(id)delegate 
                         removeCompeleted:(BOOL)removedOnCompletion;
+ (CAAnimation *)shakeFor:(CGFloat)margin originX:(CGFloat)orginX times:(int)times duration:(CFTimeInterval)duration;
+ (CAAnimation *)view:(UIView*)view shakeFor:(CGFloat)margin times:(int)times duration:(CFTimeInterval)duration;
+ (CAAnimation *)shakeLeftAndRightFrom:(CGFloat)origin 
                                    to:(CGFloat)destination 
                           repeatCount:(int)repeatCount
                              duration:(CFTimeInterval)duration;
+ (CAAnimationGroup *)raiseAndDismissFrom:(CGPoint)originPoint 
                                  to:(CGPoint)destinationPoint 
                            duration:(CFTimeInterval)duration;
+ (CAAnimationGroup*)transAndDismissTo:(CGPoint)destinationPoint
                                   scale:(CGFloat)scale
                              duration:(CFTimeInterval)duration
                              delegate:(id)delegate;

+ (CAAnimation *)trastionWithType:(NSString *)type duration:(CFTimeInterval)duration delegate:(id)delegate;

+ (void)popUpView:(UIView *)view 
     fromPosition:(CGPoint)fromPosition 
       toPosition:(CGPoint)toPosition
         interval:(NSTimeInterval)interval
         delegate:(id)delegate;
+ (void)alertView:(UIView *)view 
     fromPosition:(CGPoint)fromPosition 
       toPosition:(CGPoint)toPosition
         interval:(NSTimeInterval)interval 
         delegate:(id)delegate;

+ (void)snowAnimationAtView:(UIView *)view image:(UIImage *)image;
+ (void)snowAnimationAtView:(UIView *)view;
+ (void)fireworksAnimationAtView:(UIView *)view;

+ (CAKeyframeAnimation*)bezierCurveStart:(CGPoint)startPoint 
                           controlPoint1:(CGPoint)controlPoint1 
                           controlPoint2:(CGPoint)controlPoint2 
                                endPoint:(CGPoint)endPoint 
                                duration:(NSTimeInterval)duration
                                delegate:(id)delegate ;
+ (CAKeyframeAnimation*)pathByPoins:(CGPoint*)points 
                              count:(int)count
                           duration:(NSTimeInterval)duration 
                           delegate:(id)delegate;
+ (CAAnimationGroup *)scaleMissAnimation:(CFTimeInterval)duration
                                   scale:(CGFloat)scale
                                delegate:(id)delegate;

+ (CAAnimation *)flashAnimationFrom:(CGFloat)startValue
                                 to:(CGFloat)endValue
                           duration:(CGFloat)duration;
@end
