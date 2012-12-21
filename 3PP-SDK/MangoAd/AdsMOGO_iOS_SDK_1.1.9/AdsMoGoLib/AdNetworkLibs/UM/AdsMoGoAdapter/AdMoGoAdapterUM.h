//
//  AdMoGoAdapterUM.h
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//  Created by pengxu on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdMoGoAdNetworkAdapter.h"
#import "UMAdBannerView.h"
#import "UMAdManager.h"

@interface AdMoGoAdapterUM : AdMoGoAdNetworkAdapter <UMAdADBannerViewDelegate,UMWebViewDelegate,UMADAppDelegate> {
}
+ (AdMoGoAdNetworkType)networkType;
@end
