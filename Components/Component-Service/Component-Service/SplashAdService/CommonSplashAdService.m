//
//  CommonSplashAdService.m
//  Draw
//
//  Created by qqn_pipi on 13-5-4.
//
//

#import "CommonSplashAdService.h"

@implementation CommonSplashAdService

- (void)dealloc
{
    PPRelease(_adPubliserId);
    [super dealloc];
}

- (id)initWithPublisherId:(NSString *)publisherId   // PublisherId
                   window:(UIWindow *)keyWindow     // 用于呈现开屏广告的Key Window
               background:(UIImage *)image          // 开屏广告出现前的背景颜色、图片（默认为黑色）
                animation:(BOOL)yesOrNo;            // 开屏广告关闭时，是否使用渐变动画（默认有关闭动画）
{
    
    self = [super init];    
    self.adPubliserId = publisherId;
    return self;
}

- (void)present
{
    
}

- (void)setGender:(AdUserGender)gender;
{
    self.gender = gender;
}

@end
