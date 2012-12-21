//
//  CommonInfoView.h
//  Draw
//
//  Created by Orange on 12-8-20.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#define RUN_OUT_TIME 0.2
#define RUN_IN_TIME 0.4

@class CommonInfoView;
@protocol CommonInfoViewDelegate <NSObject>
@optional
- (void)infoViewDidDisappear;
- (void)infoViewDidDisappear:(CommonInfoView*)view;

@end

@interface CommonInfoView : UIView 
@property (retain, nonatomic) IBOutlet UIView *contentView;
@property (assign, nonatomic) id<CommonInfoViewDelegate> disappearDelegate;
+ (CommonInfoView*)createInfoViewByXibName:(NSString*)name;
- (void)disappear;
- (void)showInView:(UIView*)view;
- (void)appear;
@end
