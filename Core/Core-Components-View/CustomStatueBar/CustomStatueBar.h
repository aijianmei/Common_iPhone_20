//
//  CustomStatueBar.h
//  CustomStatueBar
//
//  Created by 贺 坤 on 12-5-21.
//  Copyright (c) 2012年 深圳市瑞盈塞富科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CustomStatueBar;
@protocol CustomStatueBarDelegate <NSObject>

@optional
- (void)didClickStatueBar:(CustomStatueBar *)statueBar;

@end

@interface CustomStatueBar : UIWindow
{
    UIButton *textButton;
    NSTimer *timer;
}
- (void)showStatusMessage:(NSString *)message;
- (void)hide;
- (void)changeMessge:(NSString *)message;

@property(nonatomic, assign) id<CustomStatueBarDelegate>customStatueBarDelegate;
@end
