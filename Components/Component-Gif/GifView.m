//
//  GifView.m
//  GIFViewer
//
//  Created by xToucher04 on 11-11-9.
//  Copyright 2011 Toucher. All rights reserved.
//

#import "GifView.h"
#import <QuartzCore/QuartzCore.h>

@implementation GifView
@synthesize playTimeInterval;


- (id)initWithFrame:(CGRect)frame filePath:(NSString *)_filePath playTimeInterval:(float)timeInterval{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.playTimeInterval = timeInterval;
		gifProperties = [[NSDictionary dictionaryWithObject:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:0] forKey:(NSString *)kCGImagePropertyGIFLoopCount]
													 forKey:(NSString *)kCGImagePropertyGIFDictionary] retain];
		gif = CGImageSourceCreateWithURL((CFURLRef)[NSURL fileURLWithPath:_filePath], (CFDictionaryRef)gifProperties);
		count =CGImageSourceGetCount(gif);
        isPlaying = YES;
		timer = [NSTimer scheduledTimerWithTimeInterval:self.playTimeInterval target:self selector:@selector(play) userInfo:nil repeats:YES];
		[timer fire];
    }
    return self;
}

-(void)play
{        
    if (!isPlaying)
        return;
    
//    PPDebug(@"<%@> play gif", [self description]);
    
	index ++;
	index = index%count;
	CGImageRef ref = CGImageSourceCreateImageAtIndex(gif, index, (CFDictionaryRef)gifProperties);
	self.layer.contents = (id)ref;
    CGImageRelease(ref);
}

- (void)stopPlay
{
	PPDebug(@"<%@> stop play", [self description]);
    isPlaying = NO;
    if (timer != nil && [timer isValid]){
        [timer invalidate];
        timer = nil;
    }
}

-(void)removeFromSuperview
{
	PPDebug(@"<%@> removeFromSuperview", [self description]);
    
    [self stopPlay];

	[super removeFromSuperview];
}
- (void)dealloc {
    
    [self stopPlay];
    
	PPDebug(@"<%@> dealloc", [self description]);
	CFRelease(gif);
    gif = nil;
    
	[gifProperties release];
    gifProperties = nil;
    
    [super dealloc];
}


@end
