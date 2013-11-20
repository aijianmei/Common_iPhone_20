//
//  DomobSplashAdService.h
//  Draw
//
//  Created by qqn_pipi on 13-5-4.
//
//

#import <UIKit/UIKit.h>
#import "CommonSplashAdService.h"
#import "DMSplashAdController.h"

@interface DomobSplashAdService : CommonSplashAdService<DMSplashAdControllerDelegate>
{
    DMSplashAdController *_splashAd;
}


@end
