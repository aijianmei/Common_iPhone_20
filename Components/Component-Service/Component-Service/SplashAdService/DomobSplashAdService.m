//
//  DomobSplashAdService.m
//  Draw
//
//  Created by qqn_pipi on 13-5-4.
//
//

#import "DomobSplashAdService.h"


@implementation DomobSplashAdService

- (id)initWithPublisherId:(NSString *)publisherId   // PublisherId
                   window:(UIWindow *)keyWindow     // 用于呈现开屏广告的Key Window
               background:(UIImage *)image          // 开屏广告出现前的背景颜色、图片（默认为黑色）
                animation:(BOOL)yesOrNo            // 开屏广告关闭时，是否使用渐变动画（默认有关闭动画）
{
    self = [super initWithPublisherId:publisherId window:keyWindow background:image animation:yesOrNo];
    
    // 初始化开屏广告控制器
    _splashAd = [[DMSplashAdController alloc] initWithPublisherId:publisherId
                                                           window:keyWindow
                                                       background:[UIColor colorWithPatternImage:image]
                                                        animation:YES];
    _splashAd.delegate = self;
    return self;
}

- (void)setGender:(AdUserGender)gender
{
    if (gender == kAdUserGenderMale)
        [_splashAd setUserGender:DMUserGenderMale];
    else if (gender == kAdUserGenderFemale)
        [_splashAd setUserGender:DMUserGenderFemale];
}

- (void)present
{
    [_splashAd setKeywords:@"Splash"];
    if (_splashAd.isReady)
    {
        [_splashAd present];
    }
    _splashAd.delegate = nil;
    [_splashAd release];
    _splashAd = nil;
}


#pragma mark -
#pragma makr Domob Splash Ad Delegate
- (void)dmSplashAdSuccessToLoadAd:(DMSplashAdController *)dmSplashAd
{
    PPDebug(@"[Domob Splash] success to load ad.");
}

// 当开屏广告加载失败后，回调该方法
- (void)dmSplashAdFailToLoadAd:(DMSplashAdController *)dmSplashAd withError:(NSError *)err
{
    PPDebug(@"[Domob Splash] fail to load ad. error=%@", [err description]);
}

// 当插屏广告要被呈现出来前，回调该方法
- (void)dmSplashAdWillPresentScreen:(DMSplashAdController *)dmSplashAd
{
    PPDebug(@"[Domob Splash] will appear on screen.");
}

// 当插屏广告被关闭后，回调该方法
- (void)dmSplashAdDidDismissScreen:(DMSplashAdController *)dmSplashAd
{
    PPDebug(@"[Domob Splash] did disappear on screen.");
}


@end
