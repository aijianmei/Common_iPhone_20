//
//  AdmobSplashAdService.h
//  Draw
//
//  Created by qqn_pipi on 13-5-4.
//
//

#import <UIKit/UIKit.h>
#import "CommonSplashAdService.h"
#import "GADInterstitial.h"

@interface AdmobSplashAdService : CommonSplashAdService<GADInterstitialDelegate>
{
    GADInterstitial *_splashInterstitial;
    UIImage *_bgImage;
    UIWindow *_window;
}
@end
