//
//  AnimationManager.m
//  HitGameTest
//
//  Created by  on 11-12-26.
//  Copyright (c) 2011年 __MyCompanyName__. All rights reserved.
//

#import "AnimationManager.h"
#import "DeviceDetection.h"

AnimationManager *animatinManager;

@implementation AnimationManager

- (id)init
{
    self = [super init];
    if (self) {
        _animationDict  = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (AnimationManager *)defaultManager
{
    if (animatinManager == nil) {
        animatinManager = [[AnimationManager alloc] init];
    }
    return animatinManager;
}

- (CAAnimation *)animationForKey:(NSString *)key
{
    if ([_animationDict count] == 0) {
        return nil;
    }
    CAAnimation *animation = [_animationDict valueForKey:key];
    return animation;
}
- (void)setAnimation:(CAAnimation *)animation forKey:(NSString *)key
{
    
}

#pragma mark - common function

+ (CAAnimation *)rotateAnimationWithRoundCount:(CGFloat)roundCount
                                      duration:(CFTimeInterval)duration;
{
    CABasicAnimation * animation = [CABasicAnimation 
                                  animationWithKeyPath:@"transform.rotation.z"]; 
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.toValue = [NSNumber numberWithFloat:roundCount * M_PI * 2];
    animation.duration = duration ;
    return animation;
}

+ (CAAnimation *)rotateAnimationFrom:(float)startValue
                                  to:(float)endValue 
                            duration:(float)duration
{
    CABasicAnimation * animation = [CABasicAnimation
                                    animationWithKeyPath:@"transform.rotation.z"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:startValue];
    animation.toValue = [NSNumber numberWithFloat:endValue];
    animation.duration = duration;
    return animation;
}

+ (CAAnimation *)circlingAnimationWithDirection:(RotateDirectionType)direction
                                       duration:(float)duration
                                  repeatedCount:(int)repeatedCount
{
    CABasicAnimation * animation = [CABasicAnimation 
                                    animationWithKeyPath:@"transform.rotation.z"]; 
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animation.fromValue = [NSNumber numberWithFloat:0];
    animation.toValue = [NSNumber numberWithFloat:2 * M_PI * (direction == ClockWise ? 1 : -1)];
    animation.duration = duration;
    animation.repeatCount = repeatedCount;
    return animation;
}

+ (CAAnimation *)disappearAnimationWithDuration:(CFTimeInterval)duration
{
    CABasicAnimation * animation = [CABasicAnimation 
                                    animationWithKeyPath:@"opacity"]; 
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSNumber numberWithInt:1];
    animation.toValue = [NSNumber numberWithInt:0];
    animation.duration = duration ;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

+ (CAAnimation *)disappearAnimationFrom:(CGFloat)startValue
                                     to:(CGFloat)endValue
                                  delay:(CGFloat)delay
                               duration:(CGFloat)duration
{
    CABasicAnimation * animation = [CABasicAnimation
                                    animationWithKeyPath:@"opacity"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.fromValue = [NSNumber numberWithInt:startValue];
    animation.toValue = [NSNumber numberWithInt:endValue];
    animation.beginTime = delay;
    animation.duration = duration ;
    animation.fillMode = kCAFillModeForwards;
    return animation;
}

+ (CAAnimation *)flashAnimationFrom:(CGFloat)startValue
                                 to:(CGFloat)endValue
                           duration:(CGFloat)duration
{
    CAAnimation * flashing = [AnimationManager disappearAnimationFrom:startValue
                                                                        to:endValue
                                                                     delay:0
                                                                  duration:duration];
    [flashing setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    flashing.autoreverses = YES;
    flashing.repeatCount = HUGE_VAL;
    return flashing;
}


+ (CAAnimation *)appearAnimationFrom:(CGFloat)startValue
                                  to:(CGFloat)endValue
                            duration:(CGFloat)duration
{
    CABasicAnimation * animation = [CABasicAnimation
                                    animationWithKeyPath:@"opacity"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.fromValue = [NSNumber numberWithInt:startValue];
    animation.toValue = [NSNumber numberWithInt:endValue];
    animation.duration = duration ;
    return animation;
}

+ (CAAnimation *)appearAnimationFrom:(CGFloat)startValue
                                  to:(CGFloat)endValue
                               delay:(CGFloat)delay
                            duration:(CGFloat)duration
{
    CABasicAnimation * animation = [CABasicAnimation
                                    animationWithKeyPath:@"opacity"];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.fromValue = [NSNumber numberWithInt:startValue];
    animation.toValue = [NSNumber numberWithInt:endValue];
    animation.beginTime = delay;
    animation.duration = duration ;
    return animation;
}

+ (CAAnimation *)moveVerticalAnimationFrom:(CGFloat)startValue
                                        to:(CGFloat)endValue
                                  duration:(float)duration
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position.y"];
    animation.duration = duration;
    animation.fromValue = [NSNumber numberWithFloat:startValue];
    animation.toValue = [NSNumber numberWithFloat:endValue];
    return animation;
}




+ (CAAnimation *)scaleAnimationWithScale:(CGFloat)scale  
                                duration:(CFTimeInterval)duration 
                                delegate:(id)delegate 
                        removeCompeleted:(BOOL)removedOnCompletion
{
    
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"transform"]; 
    animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(scale, scale, scale)];
    animation.duration = duration;
    animation.delegate = delegate;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = removedOnCompletion;
    return animation;
}


+ (CAAnimation *)scaleAnimationWithFromScale:(CGFloat)fromScale 
                                     toScale:(CGFloat)toScale
                                duration:(CFTimeInterval)duration 
                                delegate:(id)delegate 
                        removeCompeleted:(BOOL)removedOnCompletion
{
    
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"transform"]; 
    animation.fromValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(fromScale, fromScale, fromScale)];

    animation.toValue = [ NSValue valueWithCATransform3D: CATransform3DMakeScale(toScale, toScale, toScale)];
    animation.duration = duration;
    animation.delegate = delegate;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = removedOnCompletion;
    return animation;
}

+ (CAAnimation *)translationAnimationFrom:(CGPoint) start
                                         to:(CGPoint)end
                                  duration:(CFTimeInterval)duration
{
    
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"position"]; 
    animation.fromValue = [NSValue valueWithCGPoint:start];
    animation.toValue = [NSValue valueWithCGPoint:end];
    animation.duration = duration;
    return animation;
}
+ (CAAnimation *)translationAnimationTo:(CGPoint)end
                                 duration:(CFTimeInterval)duration
{
    
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"position"]; 
    animation.toValue = [NSValue valueWithCGPoint:end];
    animation.duration = duration;
    return animation;
}

+ (CAAnimation *)translationAnimationFrom:(CGPoint) start
                                       to:(CGPoint)end
                                 duration:(CFTimeInterval)duration 
                                 delegate:(id)delegate 
                         removeCompeleted:(BOOL)removedOnCompletion
{
    
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"position"]; 
    animation.fromValue = [NSValue valueWithCGPoint:start];
    animation.toValue = [NSValue valueWithCGPoint:end];
    animation.duration = duration;
    animation.delegate = delegate;
    if (removedOnCompletion) {
        animation.removedOnCompletion = YES;
    }else{
        animation.fillMode = kCAFillModeForwards;
        animation.removedOnCompletion = NO;
    }
    return animation;
}

+ (CAAnimation *)shakeFor:(CGFloat)margin originX:(CGFloat)orginX times:(int)times duration:(CFTimeInterval)duration
{
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"position.x"]; 
    animation.fromValue = [NSNumber numberWithFloat:orginX-margin/2];
    animation.toValue = [NSNumber numberWithFloat:orginX+margin/2];
    animation.duration = duration / times;
    animation.repeatCount = times;
    animation.autoreverses = YES;
    return animation;
    
    
}

+ (CAAnimation *)shakeLeftAndRightFrom:(CGFloat)origin 
                                    to:(CGFloat)destination 
                           repeatCount:(int)repeatCount 
                              duration:(CFTimeInterval)duration
{
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"transform.rotation.z"]; 
    animation.fromValue = [NSNumber numberWithFloat:(-origin/180*M_PI)];
    animation.toValue = [NSNumber numberWithFloat:(origin/180*M_PI)];
    animation.duration = duration / repeatCount;
    animation.repeatCount = repeatCount;
    animation.autoreverses = YES;
    return animation;
}

+ (CAAnimationGroup*)raiseAndDismissFrom:(CGPoint)originPoint 
                                 to:(CGPoint)destinationPoint 
                           duration:(CFTimeInterval)duration
{
    CAAnimation* raise = [AnimationManager translationAnimationFrom:originPoint to:destinationPoint duration:duration ];
    CAAnimation* dismiss = [AnimationManager disappearAnimationWithDuration:duration];
    CAAnimationGroup* animGroup = [CAAnimationGroup animation];
    raise.beginTime = 0;
    dismiss.beginTime = 0;
    animGroup.removedOnCompletion = NO;
    animGroup.duration = duration;
    animGroup.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];    
    animGroup.repeatCount         = 1;//FLT_MAX;  //"forever";
    animGroup.fillMode             = kCAFillModeForwards;
    animGroup.animations = [NSArray arrayWithObjects:raise, dismiss, nil];

    return animGroup;
}

+ (CAAnimationGroup*)transAndDismissTo:(CGPoint)destinationPoint
                                 scale:(CGFloat)scale
                              duration:(CFTimeInterval)duration
                              delegate:(id)delegate
{
    CAAnimation* trans = [AnimationManager translationAnimationTo:destinationPoint duration:duration];
    CAAnimation* stay = [AnimationManager translationAnimationFrom:destinationPoint to:CGPointMake(destinationPoint.x, destinationPoint.y*1.001) duration:duration];
    CAAnimation* dismiss = [AnimationManager disappearAnimationWithDuration:duration];
    CAAnimation* scaleAnim = [AnimationManager scaleAnimationWithScale:scale duration:duration delegate:nil removeCompeleted:NO];
    CAAnimationGroup* animGroup = [CAAnimationGroup animation];
    trans.beginTime = 0;
    stay.beginTime = duration;
    dismiss.beginTime = duration;
    scaleAnim.beginTime = duration;
    animGroup.removedOnCompletion = NO;
    animGroup.duration = duration*2;
    animGroup.timingFunction      = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    animGroup.repeatCount         = 1;//FLT_MAX;  //"forever";
    animGroup.fillMode             = kCAFillModeForwards;
    animGroup.animations = [NSArray arrayWithObjects:trans, dismiss, scaleAnim, stay, nil];
    animGroup.delegate = delegate;
    
    return animGroup;
}


+ (CAAnimation *)view:(UIView*)view shakeFor:(CGFloat)margin times:(int)times duration:(CFTimeInterval)duration
{
    CABasicAnimation * animation=[CABasicAnimation animationWithKeyPath:@"position.y"]; 
    animation.fromValue = [NSNumber numberWithFloat:view.center.y-margin/2];
    animation.toValue = [NSNumber numberWithFloat:view.center.y+margin/2];
    animation.duration = duration / times;
    animation.repeatCount = times;
    animation.autoreverses = YES;
    return animation;    
}

+ (CAAnimation *)trastionWithType:(NSString *)type duration:(CFTimeInterval)duration delegate:(id)delegate{
    
    CATransition *transition = [CATransition animation];
    transition.delegate = delegate;
    transition.duration = duration;         /* 间隔时间*/
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]; /* 动画的开始与结束的快慢*/
    transition.type = type; /* 各种动画效果*/
    //@"cube" @"moveIn" @"reveal" @"fade"(default) @"pageCurl" @"pageUnCurl" @"suckEffect" @"rippleEffect" @"oglFlip"

    //    transition.subtype = kCATransitionFromRight;   /* 动画方向*/
    return transition;
}
+ (void)popUpView:(UIView *)view 
     fromPosition:(CGPoint)fromPosition 
       toPosition:(CGPoint)toPosition
         interval:(NSTimeInterval)interval 
         delegate:(id)delegate
{
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
    [translation setDuration:interval];
    [translation setFromValue:[NSValue valueWithCGPoint:fromPosition]];
    [translation setToValue:[NSValue valueWithCGPoint:toPosition]];
    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    translation.fillMode = kCAFillModeForwards;
    translation.removedOnCompletion = NO;
    
    
    CABasicAnimation * opacityAnimation = [CABasicAnimation 
                                           animationWithKeyPath:@"opacity"]; 
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    opacityAnimation.toValue = [NSNumber numberWithInt:0];
    opacityAnimation.duration = interval;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    
    [view.layer addAnimation:translation forKey:@"translation"];
    [view.layer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}


+ (void)alertView:(UIView *)view 
     fromPosition:(CGPoint)fromPosition 
       toPosition:(CGPoint)toPosition
         interval:(NSTimeInterval)interval 
         delegate:(id)delegate
{
    CABasicAnimation *translation = [CABasicAnimation animationWithKeyPath:@"position"];
    [translation setDuration:interval];
    [translation setFromValue:[NSValue valueWithCGPoint:fromPosition]];
    [translation setToValue:[NSValue valueWithCGPoint:toPosition]];
    translation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    translation.fillMode = kCAFillModeForwards;
    translation.removedOnCompletion = NO;
    
    
    CABasicAnimation * opacityAnimation = [CABasicAnimation 
                                           animationWithKeyPath:@"opacity"]; 
    opacityAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    opacityAnimation.fromValue = [NSNumber numberWithInt:0];
    opacityAnimation.toValue = [NSNumber numberWithInt:1];
    opacityAnimation.duration = interval;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.removedOnCompletion = NO;
    opacityAnimation.delegate = delegate;
    [view.layer addAnimation:translation forKey:@"translation"];
    [view.layer addAnimation:opacityAnimation forKey:@"opacityAnimation"];
}

+ (void)snowAnimationAtView:(UIView *)view image:(UIImage *)image
{
    if ([DeviceDetection isOS5] == NO){
        return;
    }
    
    if (image == nil) {
        image = [UIImage imageNamed:@"snow.png"];
    }
    
    UIView *frontView = [[UIView alloc] initWithFrame:view.bounds];
    frontView.userInteractionEnabled = NO;
    [view addSubview:frontView];
    [frontView release];
    
    // Configure the particle emitter to the top edge of the screen
	CAEmitterLayer *snowEmitter = [CAEmitterLayer layer];
	snowEmitter.emitterPosition = CGPointMake(frontView.bounds.size.width / 2.0, -30);
	snowEmitter.emitterSize		= CGSizeMake(frontView.bounds.size.width * 2.0, 0.0);;
	
	// Spawn points for the flakes are within on the outline of the line
	snowEmitter.emitterMode		= kCAEmitterLayerOutline;
	snowEmitter.emitterShape	= kCAEmitterLayerLine;
	
	// Configure the snowflake emitter cell
	CAEmitterCell *snowflake = [CAEmitterCell emitterCell];
	
	snowflake.birthRate		= 5.0;
	snowflake.lifetime		= 20.0;
	
	snowflake.velocity		= -100;				// falling down slowly
	snowflake.velocityRange = 100;
	snowflake.yAcceleration = 2;
	snowflake.emissionRange = 0.5 * M_PI;		// some variation in angle
	snowflake.spinRange		= 0.25 * M_PI;		// slow spin
	
	snowflake.contents		= (id) [image CGImage];
	snowflake.color			= [[UIColor colorWithRed:0.600 green:0.658 blue:0.743 alpha:1.000] CGColor];
    
	// Make the flakes seem inset in the background
	snowEmitter.shadowOpacity = 1.0;
	snowEmitter.shadowRadius  = 0.0;
	snowEmitter.shadowOffset  = CGSizeMake(0.0, 1.0);
	snowEmitter.shadowColor   = [[UIColor whiteColor] CGColor];
	
	// Add everything to our backing layer below the UIContol defined in the storyboard
	snowEmitter.emitterCells = [NSArray arrayWithObject:snowflake];
	[frontView.layer insertSublayer:snowEmitter atIndex:0];
}

+ (void)snowAnimationAtView:(UIView *)view
{
    [AnimationManager snowAnimationAtView:view image:[UIImage imageNamed:@"snow.png"]];
}
+ (void)fireworksAnimationAtView:(UIView *)view
{
    if ([DeviceDetection isOS5] == NO){
        return;
    }
    
    UIView *frontView = [[UIView alloc] initWithFrame:view.bounds];
    frontView.userInteractionEnabled = NO;
    [view addSubview:frontView];
    [frontView release];
    
    // Cells spawn in the bottom, moving up
	CAEmitterLayer *fireworksEmitter = [CAEmitterLayer layer];
	CGRect viewBounds = frontView.layer.bounds;
	fireworksEmitter.emitterPosition = CGPointMake(viewBounds.size.width/2.0, viewBounds.size.height);
	fireworksEmitter.emitterSize	= CGSizeMake(viewBounds.size.width/2.0, 0.0);
	fireworksEmitter.emitterMode	= kCAEmitterLayerOutline;
	fireworksEmitter.emitterShape	= kCAEmitterLayerLine;
	fireworksEmitter.renderMode		= kCAEmitterLayerAdditive;
	fireworksEmitter.seed = (arc4random()%100)+1;
	
	// Create the rocket
	CAEmitterCell* rocket = [CAEmitterCell emitterCell];
	


	if ([DeviceDetection isIPAD]) {
        rocket.velocity			= 380 * 2.2;
        rocket.velocityRange	= 100 * 2;
        rocket.yAcceleration	= 75 * 2;
        rocket.emissionRange	= 0.25 * M_PI / 2;  // some variation in angle
        rocket.lifetime			= 1.02;    
    	rocket.birthRate		= 0.1 * 0.2;
        rocket.scale			= 0.2 * 2.1;
    }else{
        rocket.velocity			= 380;
        rocket.velocityRange	= 100;
        rocket.yAcceleration	= 75;
        rocket.emissionRange	= 0.25 * M_PI;
        rocket.lifetime			= 1.02;    
        rocket.birthRate		= 0.1;
        rocket.scale			= 0.2;
    }
	rocket.contents			= (id) [[UIImage imageNamed:@"fireworks1"] CGImage];
	rocket.color			= [[UIColor redColor] CGColor];	
	rocket.greenRange		= 1.0;		// different colors
	rocket.redRange			= 1.0;
	rocket.blueRange		= 1.0;
	rocket.spinRange		= M_PI;		// slow spin
	
    
	
	// the burst object cannot be seen, but will spawn the sparks
	// we change the color here, since the sparks inherit its value
	CAEmitterCell* burst = [CAEmitterCell emitterCell];
	
	burst.birthRate			= 1;		// at the end of travel
	burst.velocity			= 0;
    
    if ([DeviceDetection isIPAD]) {
        burst.scale				= 2.5 * 1.5;        
    }else{
        burst.scale				= 2.5;        
    }

    
	burst.redSpeed			=-1.5;		// shifting
	burst.blueSpeed			=+1.5;		// shifting
	burst.greenSpeed		=+1.0;		// shifting
	burst.lifetime			= 0.35;
	
	// and finally, the sparks
	CAEmitterCell* spark = [CAEmitterCell emitterCell];
	
	spark.birthRate			= 400;
	spark.velocity			= 125;
	spark.emissionRange		= 2* M_PI;	// 360 deg
	spark.yAcceleration		= 75;		// gravity
	spark.lifetime			= 3;
    
	spark.contents			= (id) [[UIImage imageNamed:@"fireworks2"] CGImage];
	spark.scaleSpeed		=-0.2;
	spark.greenSpeed		=-0.1;
	spark.redSpeed			= 0.4;
	spark.blueSpeed			=-0.1;
	spark.alphaSpeed		=-0.25;
	spark.spin				= 2* M_PI;
	spark.spinRange			= 2* M_PI;
	
	// putting it together
	fireworksEmitter.emitterCells	= [NSArray arrayWithObject:rocket];
	rocket.emitterCells				= [NSArray arrayWithObject:burst];
	burst.emitterCells				= [NSArray arrayWithObject:spark];
	[frontView.layer addSublayer:fireworksEmitter];

}

+ (CAKeyframeAnimation*)bezierCurveStart:(CGPoint)startPoint 
                           controlPoint1:(CGPoint)controlPoint1 
                           controlPoint2:(CGPoint)controlPoint2 
                                endPoint:(CGPoint)endPoint 
                                duration:(NSTimeInterval)duration 
                                delegate:(id)delegate
{
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = NO;
    CGMutablePathRef curvedPath = CGPathCreateMutable();
    CGPathMoveToPoint(curvedPath, NULL, startPoint.x, startPoint.y);
    CGPathAddCurveToPoint(curvedPath, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, endPoint.x, endPoint.y);
    
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    pathAnimation.duration = duration;
    pathAnimation.delegate = delegate;
    
    return pathAnimation;
}

+ (CAKeyframeAnimation*)pathByPoins:(CGPoint *)points 
                              count:(int)count 
                           duration:(NSTimeInterval)duration 
                           delegate:(id)delegate
{
    CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    pathAnimation.calculationMode = kCAAnimationPaced;
    pathAnimation.fillMode = kCAFillModeForwards;
    pathAnimation.removedOnCompletion = YES;
    CGMutablePathRef curvedPath = CGPathCreateMutable();
//    CGPathMoveToPoint(curvedPath, NULL, startPoint.x, startPoint.y);
//    CGPathAddCurveToPoint(curvedPath, NULL, controlPoint1.x, controlPoint1.y, controlPoint2.x, controlPoint2.y, endPoint.x, endPoint.y);
    CGPathMoveToPoint(curvedPath, NULL, points[0].x, points[0].y);
//    if (array.count >0) {
//        NSNumber* number = [array objectAtIndex:0];
//        CGPoint point = [DrawUtils decompressIntPoint:number.intValue];
//        CGPathMoveToPoint(curvedPath, NULL, point.x, point.y);
//    }
//    for (int i = 0; i < array.count; i ++) {
//        NSNumber* number = [array objectAtIndex:0];
//        CGPoint point = [DrawUtils decompressIntPoint:number.intValue];
//        CGPathAddLines(<#CGMutablePathRef path#>, <#const CGAffineTransform *m#>, <#const CGPoint *points#>, <#size_t count#>);
//    }
    CGPathAddLines(curvedPath, NULL, points, count);
//    
    pathAnimation.path = curvedPath;
    CGPathRelease(curvedPath);
    pathAnimation.duration = duration;
    pathAnimation.delegate = delegate;
    
    return pathAnimation;
}

+ (CAAnimationGroup *)scaleMissAnimation:(CFTimeInterval)duration
                                   scale:(CGFloat)scale
                                delegate:(id)delegate
{
    CAMediaTimingFunction *timing = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    CAAnimation* enlarge = [AnimationManager scaleAnimationWithFromScale:1 toScale:scale duration:duration delegate:delegate removeCompeleted:NO];
    
    CAAnimation* miss = [AnimationManager disappearAnimationWithDuration:duration];
    CAAnimationGroup* animGroup    = [CAAnimationGroup animation];
    
    //设置动画代理
    animGroup.delegate = delegate;
    animGroup.removedOnCompletion = NO;
    animGroup.duration             = duration;
    animGroup.timingFunction = enlarge.timingFunction = miss.timingFunction = timing;
    animGroup.repeatCount         = 1;//FLT_MAX;  //"forever";
    animGroup.fillMode             = kCAFillModeForwards;
    animGroup.animations  = [NSArray arrayWithObjects:enlarge, miss,nil];
    return animGroup;
    
}


@end
