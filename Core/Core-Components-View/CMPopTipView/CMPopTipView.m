//
//  CMPopTipView.m
//
//  Created by Chris Miles on 18/07/10.
//  Copyright (c) Chris Miles 2010-2011.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//  
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//  
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "CMPopTipView.h"

@interface CMPopTipView ()
@property (nonatomic, retain, readwrite)	id	targetObject;
@end


@implementation CMPopTipView

@synthesize backgroundColor;
@synthesize delegate;
@synthesize message;
@synthesize customView;
@synthesize targetObject;
@synthesize textColor;
@synthesize textFont;
@synthesize textAlignment;
@synthesize animation;
@synthesize maxWidth;
@synthesize disableTapToDismiss;
@synthesize isPopup;

- (CGRect)bubbleFrame {
	CGRect bubbleFrame;
	if (_pointDirection == PointDirectionUp) {
		bubbleFrame = CGRectMake(2.0, targetPoint.y+pointerSize, bubbleSize.width, bubbleSize.height);
	}
	else {
		bubbleFrame = CGRectMake(2.0, targetPoint.y-pointerSize-bubbleSize.height, bubbleSize.width, bubbleSize.height);
	}
	return bubbleFrame;
}

- (CGRect)contentFrame {
	CGRect bubbleFrame = [self bubbleFrame];
    CGRect contentFrame;
    if (_withoutBubble) {
        contentFrame = CGRectMake(bubbleFrame.origin.x,
                                  bubbleFrame.origin.y,
                                  bubbleFrame.size.width - cornerRadius*2,
                                  bubbleFrame.size.height - cornerRadius*2);
    }else {
        contentFrame = CGRectMake(bubbleFrame.origin.x + cornerRadius,
                                  bubbleFrame.origin.y + cornerRadius,
                                  bubbleFrame.size.width - cornerRadius*2,
                                  bubbleFrame.size.height - cornerRadius*2);
    }

	return contentFrame;
}

- (void)layoutSubviews {
	if (self.customView) {
		
		CGRect contentFrame = [self contentFrame];
        [self.customView setFrame:contentFrame];
    }
}

- (void)drawRect:(CGRect)rect {
    
    if (_withoutBubble) {
        self.backgroundColor = [UIColor clearColor];
    }
	
	CGRect bubbleRect = [self bubbleFrame];
    
	CGContextRef c = UIGraphicsGetCurrentContext(); 
	
	CGContextSetRGBStrokeColor(c, 0.0, 0.0, 0.0, 1.0);	// black

	CGContextSetLineWidth(c, 1.0);
    
	CGMutablePathRef bubblePath = CGPathCreateMutable();
	
	if (_pointDirection == PointDirectionUp) {
		CGPathMoveToPoint(bubblePath, NULL, targetPoint.x, targetPoint.y);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x+pointerSize, targetPoint.y+pointerSize);
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x+bubbleRect.size.width-cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y,
							bubbleRect.origin.x+cornerRadius, bubbleRect.origin.y,
							cornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x-pointerSize, targetPoint.y+pointerSize);
	}
	else {
		CGPathMoveToPoint(bubblePath, NULL, targetPoint.x, targetPoint.y);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x-pointerSize, targetPoint.y-pointerSize);
		
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x, bubbleRect.origin.y+bubbleRect.size.height-cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x, bubbleRect.origin.y,
							bubbleRect.origin.x+cornerRadius, bubbleRect.origin.y,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+cornerRadius,
							cornerRadius);
		CGPathAddArcToPoint(bubblePath, NULL,
							bubbleRect.origin.x+bubbleRect.size.width, bubbleRect.origin.y+bubbleRect.size.height,
							bubbleRect.origin.x+bubbleRect.size.width-cornerRadius, bubbleRect.origin.y+bubbleRect.size.height,
							cornerRadius);
		CGPathAddLineToPoint(bubblePath, NULL, targetPoint.x+pointerSize, targetPoint.y-pointerSize);
	}
    
	CGPathCloseSubpath(bubblePath);
    
	
	// Draw shadow
	CGContextAddPath(c, bubblePath);
    CGContextSaveGState(c);
	CGContextSetShadow(c, CGSizeMake(0, 3), 5);
//	CGContextSetRGBFillColor(c, 0.0, 0.0, 0.0, 0.9);
    CGContextSetRGBFillColor(c, 0.0, 0.0, 0.0, 0);

	CGContextFillPath(c);
    CGContextRestoreGState(c);
    
	
	// Draw clipped background gradient
	CGContextAddPath(c, bubblePath);
	CGContextClip(c);
	
	CGFloat bubbleMiddle = (bubbleRect.origin.y+(bubbleRect.size.height/2)) / self.bounds.size.height;
	
	CGGradientRef myGradient;
	CGColorSpaceRef myColorSpace;
	size_t locationCount = 5;
	CGFloat locationList[] = {0.0, bubbleMiddle-0.03, bubbleMiddle, bubbleMiddle+0.03, 1.0};
    
	CGFloat colourHL = 0.0;
	if (highlight) {
		colourHL = 0.25;
	}
	
	CGFloat red;
	CGFloat green;
	CGFloat blue;
	CGFloat alpha;
	int numComponents = CGColorGetNumberOfComponents([backgroundColor CGColor]);
	const CGFloat *components = CGColorGetComponents([backgroundColor CGColor]);
	if (numComponents == 2) {
		red = components[0];
		green = components[0];
		blue = components[0];
		alpha = components[1];
	}
	else {
		red = components[0];
		green = components[1];
		blue = components[2];
		alpha = components[3];
	}
	CGFloat colorList[] = {
		//red, green, blue, alpha 
		red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
		red*1.16+colourHL, green*1.16+colourHL, blue*1.16+colourHL, alpha,
		red*1.08+colourHL, green*1.08+colourHL, blue*1.08+colourHL, alpha,
		red     +colourHL, green     +colourHL, blue     +colourHL, alpha,
		red     +colourHL, green     +colourHL, blue     +colourHL, alpha
	};

	myColorSpace = CGColorSpaceCreateDeviceRGB();
	myGradient = CGGradientCreateWithColorComponents(myColorSpace, colorList, locationList, locationCount);
	CGPoint startPoint, endPoint;
	startPoint.x = 0;
	startPoint.y = 0;
	endPoint.x = 0;
	endPoint.y = CGRectGetMaxY(self.bounds);
	
	CGContextDrawLinearGradient(c, myGradient, startPoint, endPoint,0);
	CGGradientRelease(myGradient);
	CGColorSpaceRelease(myColorSpace);
	
//	CGContextSetRGBStrokeColor(c, 0.4, 0.4, 0.4, 1.0);
    CGContextSetRGBStrokeColor(c, 0.4, 0.4, 0.4, (_needBubblePath ? 1.0 : 0.0));

	CGContextAddPath(c, bubblePath);
	CGContextDrawPath(c, kCGPathStroke);
	
	CGPathRelease(bubblePath);
	
	// Draw text
	
	if (self.message) {
		[textColor set];
		CGRect textFrame = [self contentFrame];
        [self.message drawInRect:textFrame
                        withFont:textFont
                   lineBreakMode:UILineBreakModeWordWrap
                       alignment:UITextAlignmentCenter];
    }
}

- (void)presentPointingAtView:(UIView *)targetView 
                       inView:(UIView *)containerView 
                     animated:(BOOL)animated {
    [self presentPointingAtView:targetView
                         inView:containerView 
                       animated:animated 
                 pointDirection:PointDirectionAuto];
}

- (void)presentPointingAtView:(UIView *)targetView 
                       inView:(UIView *)containerView
                    aboveView:(UIView *)aboveView
                     animated:(BOOL)animated
{
    [self presentPointingAtView:targetView
                         inView:containerView 
                      aboveView:aboveView
                       animated:animated 
                 pointDirection:PointDirectionAuto];
}

- (void)presentPointingAtView:(UIView *)targetView 
                       inView:(UIView *)containerView
                     animated:(BOOL)animated 
               pointDirection:(PointDirection)pointDirection
{
    [self presentPointingAtView:targetView
                         inView:containerView
                      aboveView:nil 
                       animated:animated 
                 pointDirection:pointDirection];
}

- (void)presentPointingAtView:(UIView *)targetView
                       inView:(UIView *)containerView 
                    aboveView:(UIView *)aboveView
                     animated:(BOOL)animated
               pointDirection:(PointDirection)pointDirection
{
    isPopup = YES;
    
    if (!self.targetObject) {
		self.targetObject = targetView;
	}
	
    if (aboveView == nil) {
        [containerView addSubview:self];
    }else {
        [containerView insertSubview:self aboveSubview:aboveView];
    }
    
	// Size of rounded rect
	CGFloat rectWidth;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        // iPad
        if (maxWidth) {
            if (maxWidth < containerView.frame.size.width) {
                rectWidth = maxWidth;
            }
            else {
                rectWidth = containerView.frame.size.width - 20;
            }
        }
        else {
            rectWidth = (int)(containerView.frame.size.width/3);
        }
    }
    else {
        // iPhone
        if (maxWidth) {
            if (maxWidth < containerView.frame.size.width) {
                rectWidth = maxWidth;
            }
            else {
                rectWidth = containerView.frame.size.width - 10;
            }
        }
        else {
            rectWidth = (int)(containerView.frame.size.width*2/3);
        }
    }
    
	CGSize textSize = CGSizeZero;
    
    if (self.message!=nil) {
        textSize= [self.message sizeWithFont:textFont
                           constrainedToSize:CGSizeMake(rectWidth, 99999.0)
                               lineBreakMode:UILineBreakModeWordWrap];
    }
    if (self.customView != nil) {
        textSize = self.customView.frame.size;
    }
    
    if (_withoutBubble) {
        bubbleSize = CGSizeMake(textSize.width, textSize.height);
    }else {
        bubbleSize = CGSizeMake(textSize.width + cornerRadius*2, textSize.height + cornerRadius*2);
    }
	
	CGPoint targetRelativeOrigin    = [targetView.superview convertPoint:targetView.frame.origin toView:containerView.superview];
	CGPoint containerRelativeOrigin = [containerView.superview convertPoint:containerView.frame.origin toView:containerView.superview];
    
	CGFloat pointerY;	// Y coordinate of pointer target (within containerView)
	
    if (pointDirection == PointDirectionAuto) {
        if (targetRelativeOrigin.y+targetView.bounds.size.height < containerRelativeOrigin.y) {
            pointerY = 0.0;
            _pointDirection = PointDirectionUp;
        }
        else if (targetRelativeOrigin.y > containerRelativeOrigin.y+containerView.bounds.size.height) {
            pointerY = containerView.bounds.size.height;
            _pointDirection = PointDirectionDown;
        }
        else {
            CGPoint targetOriginInContainer = [targetView convertPoint:CGPointMake(0.0, 0.0) toView:containerView];
            CGFloat sizeBelow = containerView.bounds.size.height - targetOriginInContainer.y;
            if (sizeBelow > targetOriginInContainer.y) {
                pointerY = targetOriginInContainer.y + targetView.bounds.size.height;
                _pointDirection = PointDirectionUp;
            }
            else {
                pointerY = targetOriginInContainer.y;
                _pointDirection = PointDirectionDown;
            }
        }
    }else {
        _pointDirection = pointDirection;
        if (targetRelativeOrigin.y+targetView.bounds.size.height < containerRelativeOrigin.y) {
            pointerY = 0.0;
        }
        else if (targetRelativeOrigin.y > containerRelativeOrigin.y+containerView.bounds.size.height) {
            pointerY = containerView.bounds.size.height;
        }
        else {
            CGPoint targetOriginInContainer = [targetView convertPoint:CGPointMake(0.0, 0.0) toView:containerView];
            if (pointDirection == PointDirectionUp) {
                pointerY = targetOriginInContainer.y + targetView.bounds.size.height;
            }
            else {
                pointerY = targetOriginInContainer.y;
            }
        }
    }
	
	CGFloat W = containerView.frame.size.width;
	
	CGPoint p = [targetView.superview convertPoint:targetView.center toView:containerView];
	CGFloat x_p = p.x;
	CGFloat x_b = x_p - roundf(bubbleSize.width/2);
	if (x_b < sidePadding) {
		x_b = sidePadding;
	}
	if (x_b + bubbleSize.width + sidePadding > W) {
		x_b = W - bubbleSize.width - sidePadding;
	}
	if (x_p - pointerSize < x_b + cornerRadius) {
		x_p = x_b + cornerRadius + pointerSize;
	}
	if (x_p + pointerSize > x_b + bubbleSize.width - cornerRadius) {
		x_p = x_b + bubbleSize.width - cornerRadius - pointerSize;
	}
	
	CGFloat fullHeight = bubbleSize.height + pointerSize + 10.0;
	CGFloat y_b;
	if (_pointDirection == PointDirectionUp) {
		y_b = topMargin + pointerY;
		targetPoint = CGPointMake(x_p-x_b, 0);
	}
	else {
		y_b = pointerY - fullHeight;
		targetPoint = CGPointMake(x_p-x_b, fullHeight-2.0);
	}
	
	CGRect finalFrame = CGRectMake(x_b-sidePadding,
								   y_b,
								   bubbleSize.width+sidePadding*2,
								   fullHeight);
    
   	
	if (animated) {
        if (animation == CMPopTipAnimationSlide) {
            self.alpha = 0.0;
            CGRect startFrame = finalFrame;
            startFrame.origin.y += 10;
            self.frame = startFrame;
        }
		else if (animation == CMPopTipAnimationPop) {
            self.frame = finalFrame;
            self.alpha = 0.5;
            
            // start a little smaller
            self.transform = CGAffineTransformMakeScale(0.75f, 0.75f);
            
            // animate to a bigger size
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationDidStopSelector:@selector(popAnimationDidStop:finished:context:)];
            [UIView setAnimationDuration:0.15f];
            self.transform = CGAffineTransformMakeScale(1.1f, 1.1f);
            self.alpha = 1.0;
            [UIView commitAnimations];
        }
		
		[self setNeedsDisplay];
		
		if (animation == CMPopTipAnimationSlide) {
			[UIView beginAnimations:nil context:nil];
			self.alpha = 1.0;
			self.frame = finalFrame;
			[UIView commitAnimations];
		}
	}
	else {
		// Not animated
		[self setNeedsDisplay];
		self.frame = finalFrame;
	}

}

- (void)presentPointingAtBarButtonItem:(UIBarButtonItem *)barButtonItem animated:(BOOL)animated {
    isPopup = YES;
    
	UIView *targetView = (UIView *)[barButtonItem performSelector:@selector(view)];
	UIView *targetSuperview = [targetView superview];
	UIView *containerView = nil;
	if ([targetSuperview isKindOfClass:[UINavigationBar class]]) {
		UINavigationController *navController = [(UINavigationBar *)targetSuperview delegate];
		containerView = [[navController topViewController] view];
	}
	else if ([targetSuperview isKindOfClass:[UIToolbar class]]) {
		containerView = [targetSuperview superview];
	}
	
	if (nil == containerView) {
		NSLog(@"Cannot determine container view from UIBarButtonItem: %@", barButtonItem);
		self.targetObject = nil;
		return;
	}
	
	self.targetObject = barButtonItem;
	
	[self presentPointingAtView:targetView inView:containerView animated:animated];
}

- (void)finaliseDismiss {
	[self removeFromSuperview];
	highlight = NO;
	self.targetObject = nil;
}

- (void)dismissAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
	[self finaliseDismiss];
}

- (void)dismissAnimated:(BOOL)animated {
	isPopup = NO;
    
	if (animated) {
		CGRect frame = self.frame;
		frame.origin.y += 10.0;
		
		[UIView beginAnimations:nil context:nil];
		self.alpha = 0.0;
		self.frame = frame;
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(dismissAnimationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
	else {
		[self finaliseDismiss];
	}
    
    if ([delegate respondsToSelector:@selector(popTipViewWasDismissedByCallingDismissAnimatedMethod:)]) {
        [delegate popTipViewWasDismissedByCallingDismissAnimatedMethod:self];
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	if (self.disableTapToDismiss) {
		[super touchesBegan:touches withEvent:event];
		return;
	}
	
	highlight = YES;
	[self setNeedsDisplay];
	
	[self dismissAnimated:YES];
	
	if (delegate && [delegate respondsToSelector:@selector(popTipViewWasDismissedByUser:)]) {
		[delegate popTipViewWasDismissedByUser:self];
	}
}

- (void)popAnimationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    // at the end set to normal size
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.1f];
	self.transform = CGAffineTransformIdentity;
	[UIView commitAnimations];
}

- (id)initWithFrame:(CGRect)frame
        pointerSize:(CGFloat)pSize{
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.opaque = NO;
		
        if (_withoutBubble) {
            pointerSize = 0.0;
            cornerRadius = 0.0;
            topMargin = 0;
            sidePadding = 0;
        }else {
            pointerSize = pointerSize;
            cornerRadius = pSize;
            topMargin = 2.0;
            sidePadding = 2.0;
        }
		
		self.textFont = [UIFont boldSystemFontOfSize:14.0];
		self.textColor = [UIColor whiteColor];
		self.textAlignment = UITextAlignmentCenter;
		self.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:60.0/255.0 blue:154.0/255.0 alpha:1.0];
        self.animation = CMPopTipAnimationSlide;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
		self.opaque = NO;
		
        if (_withoutBubble) {
            pointerSize = 0.0;
            cornerRadius = 0.0;
            topMargin = 0;
            sidePadding = 0;
        }else {
            pointerSize = 12.0;
            cornerRadius = 10.0;
            topMargin = 2.0;
            sidePadding = 2.0;
        }
		
		self.textFont = [UIFont boldSystemFontOfSize:14.0];
		self.textColor = [UIColor whiteColor];
		self.textAlignment = UITextAlignmentCenter;
		self.backgroundColor = [UIColor colorWithRed:62.0/255.0 green:60.0/255.0 blue:154.0/255.0 alpha:1.0];
        self.animation = CMPopTipAnimationSlide;
    }
    return self;
}

- (PointDirection) getPointDirection {
  return _pointDirection;
}

- (id)initWithMessage:(NSString *)messageToShow {
    return [self initWithMessage:messageToShow needBubblePath:YES];
}

- (id)initWithMessage:(NSString *)messageToShow needBubblePath:(BOOL)needBubblePath {
    _needBubblePath = needBubblePath;
    
    CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.message = messageToShow;
	}
	return self;
}

- (id)initWithMessageWithoutBubble:(NSString *)messageToShow
{
    _needBubblePath = NO;
    _withoutBubble = YES;
    
    CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.message = messageToShow;
	}
	return self;
}

- (id)initWithCustomView:(UIView *)aView {
    return [self initWithCustomView:aView needBubblePath:YES];
}

- (id)initWithCustomView:(UIView *)aView needBubblePath:(BOOL)needBubblePath {
    _needBubblePath = needBubblePath;
    
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.customView = aView;
        [self addSubview:self.customView];
	}
	return self;
}

- (id)initWithCustomView:(UIView *)aView
             pointerSize:(CGFloat)pSize
{    
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame pointerSize:pSize])) {
		self.customView = aView;
        [self addSubview:self.customView];
	}
	return self;
}

- (id)initWithCustomViewWithoutBubble:(UIView *)aView
{
    _needBubblePath = NO;
    _withoutBubble = YES;
    
	CGRect frame = CGRectZero;
	
	if ((self = [self initWithFrame:frame])) {
		self.customView = aView;
        [self addSubview:self.customView];
	}
	return self;
}

- (void)dealloc {
	[backgroundColor release];
    [customView release];
	[message release];
	[targetObject release];
	[textColor release];
	[textFont release];
	
    [super dealloc];
}


@end
