//
//  CommonInfoView.m
//  Draw
//
//  Created by Orange on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "CommonInfoView.h"
#import "AnimationManager.h"


@interface CommonInfoView (privateMethod)
- (void)appear;
@end

@implementation CommonInfoView
@synthesize contentView = _contentView;
@synthesize disappearDelegate = _disappearDelegate;

- (void)dealloc
{
    _disappearDelegate = nil;    
    [_contentView release];
    [super dealloc];
}

+ (CommonInfoView*)createInfoViewByXibName:(NSString*)name
{
    NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:name owner:self options:nil];
    if (topLevelObjects == nil || [topLevelObjects count] <= 0){
        NSLog(@"create %@ but cannot find cell object from Nib", name);
        return nil;
    }
    return (CommonInfoView*)[topLevelObjects objectAtIndex:0];
}

- (void)showInView:(UIView*)view
{
    self.frame = view.bounds;
    [view addSubview:self];
    [self appear];
}

- (void)startRunOutAnimation
{

    CAAnimation *runOut = [AnimationManager scaleAnimationWithFromScale:1 toScale:0.001 duration:RUN_OUT_TIME delegate:self removeCompeleted:YES];
    [runOut setValue:@"runOut" forKey:@"AnimationKey"];
    [self.contentView.layer addAnimation:runOut forKey:@"runOut"];
    CAAnimation* dismiss = [AnimationManager disappearAnimationWithDuration:RUN_OUT_TIME];
    self.contentView.layer.opacity = 0;
    [self.contentView.layer addAnimation:dismiss forKey:nil];
    
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    NSString* value = [anim valueForKey:@"AnimationKey"];
    if ([value isEqualToString:@"runOut"]) {
        [self setHidden:YES];
//        self.layer.transform = CATransform3DMakeScale(0, 0, 0);
        [self removeFromSuperview];
//        if (_disappearDelegate && [_disappearDelegate respondsToSelector:@selector(infoViewDidDisappear)]) {
//            [_disappearDelegate infoViewDidDisappear];
//        }
        if (_disappearDelegate && [_disappearDelegate respondsToSelector:@selector(infoViewDidDisappear:)]) {
            [_disappearDelegate infoViewDidDisappear:self];
        }
    }
}

- (void)disappear
{
    [self startRunOutAnimation];
}

- (void)appear
{
    [self setHidden:NO];
    CAAnimation *runIn = [AnimationManager scaleAnimationWithFromScale:0.1 toScale:1 duration:RUN_IN_TIME delegate:self removeCompeleted:YES];
    [self.contentView.layer addAnimation:runIn forKey:@"runIn"];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */




@end
