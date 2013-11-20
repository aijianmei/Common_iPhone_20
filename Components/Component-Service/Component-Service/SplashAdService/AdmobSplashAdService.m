//
//  AdmobSplashAdService.m
//  Draw
//
//  Created by qqn_pipi on 13-5-4.
//
//

#import "AdmobSplashAdService.h"

@implementation AdmobSplashAdService

- (id)initWithPublisherId:(NSString *)publisherId   // PublisherId
                   window:(UIWindow *)keyWindow     // 用于呈现开屏广告的Key Window
               background:(UIImage *)image          // 开屏广告出现前的背景颜色、图片（默认为黑色）
                animation:(BOOL)yesOrNo            // 开屏广告关闭时，是否使用渐变动画（默认有关闭动画）
{
    self = [super initWithPublisherId:publisherId window:keyWindow background:image animation:yesOrNo];

    _splashInterstitial = [[GADInterstitial alloc] init];
    
    _splashInterstitial.adUnitID = publisherId;
    _splashInterstitial.delegate = self;
    
    _bgImage = image;
    _window = keyWindow;       
    return self;
}

- (void)present
{
    GADRequest* request = [GADRequest request];
    [request setGender:self.gender];
    
    [_splashInterstitial loadAndDisplayRequest:request
                                   usingWindow:_window
                                  initialImage:_bgImage];
}



#pragma mark Ad Request Lifecycle Notifications

// Sent when an interstitial ad request succeeded.  Show it at the next
// transition point in your application such as when transitioning between view
// controllers.
- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    PPDebug(@"<interstitialDidReceiveAd>");
}

// Sent when an interstitial ad request completed without an interstitial to
// show.  This is common since interstitials are shown sparingly to users.
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    PPDebug(@"<didFailToReceiveAdWithError> error=%@", [error description]);
}

#pragma mark Display-Time Lifecycle Notifications

// Sent just before presenting an interstitial.  After this method finishes the
// interstitial will animate onto the screen.  Use this opportunity to stop
// animations and save the state of your application in case the user leaves
// while the interstitial is on screen (e.g. to visit the App Store from a link
// on the interstitial).
- (void)interstitialWillPresentScreen:(GADInterstitial *)ad
{
    PPDebug(@"<interstitialWillPresentScreen>");
}


// Sent before the interstitial is to be animated off the screen.
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    PPDebug(@"<interstitialWillDismissScreen>");
}


// Sent just after dismissing an interstitial and it has animated off the
// screen.
- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    PPDebug(@"<interstitialDidDismissScreen>");
}


// Sent just before the application will background or terminate because the
// user clicked on an ad that will launch another application (such as the App
// Store).  The normal UIApplicationDelegate methods, like
// applicationDidEnterBackground:, will be called immediately before this.
- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    PPDebug(@"<interstitialWillLeaveApplication>");
}



@end
