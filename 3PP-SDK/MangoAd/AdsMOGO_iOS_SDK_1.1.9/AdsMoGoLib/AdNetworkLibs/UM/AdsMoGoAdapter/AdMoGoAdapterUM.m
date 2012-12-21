//
//  AdMoGoAdapterUM.m
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//  Created by pengxu on 12-3-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AdMoGoAdapterUM.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoView.h"
#import "AdMoGoAdNetworkConfig.h"

#define kAdMoGoUMClientID @"ClientID"
#define kAdMoGoUMSlotID @"SlotID"

@implementation AdMoGoAdapterUM

+ (AdMoGoAdNetworkType)networkType {
	return AdMoGoAdNetworkTypeUM;
}

+ (void)load {
	[[AdMoGoAdNetworkRegistry sharedRegistry] registerClass:self];
}
- (void)getAd {
    CGSize size = CGSizeZero;
    AdViewType type = adMoGoView.adType;
    switch (type) {
        case AdViewTypeNormalBanner:
            size = [UMAdBannerView bannerSizeofSize320x50];
            break;
        case AdViewTypeiPadNormalBanner:
            size = [UMAdBannerView bannerSizeofSize320x50];
            break;
        case AdViewTypeMediumBanner:
            size = [UMAdBannerView bannerSizeofSize480x75];
            break;
        default:
            [adMoGoView adapter:self didGetAd:@"um"];
            [adMoGoView adapter:self didFailAd:nil];
            return;
            break;
    }
    
    [UMAdManager setAppDelegate:self];
    [UMAdManager appLaunched];
    UMAdBannerView *adView = [[UMAdBannerView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    [adView setProperty:[adMoGoDelegate viewControllerForPresentingModalView] slotid:[networkConfig.credentials objectForKey:kAdMoGoUMSlotID]];
    [adView setDelegate:self];
    self.adNetworkView = [adView autorelease];
}

-(NSString *)UMADClientId{
    return [networkConfig.credentials objectForKey:kAdMoGoUMClientID];
}

- (void)UMADBannerViewDidLoadAd:(UMAdBannerView *)banner {
    [adMoGoView adapter:self didGetAd:@"um"];
    [adMoGoView adapter:self didReceiveAdView:banner];
}

- (void)UMADBannerView:(UMAdBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    [adMoGoView adapter:self didGetAd:@"um"];
    [adMoGoView adapter:self didFailAd:error];
}

- (void) dealloc {
    [UMAdManager setAppDelegate:nil];
    [super dealloc];
}

- (void)stopBeingDelegate {
    UMAdBannerView *umadView = (UMAdBannerView *)adNetworkView;
    if(umadView != nil){
        [umadView setProperty:nil slotid:[networkConfig.credentials objectForKey:kAdMoGoUMSlotID]];
        [umadView setDelegate:nil];
    }
}


@end
