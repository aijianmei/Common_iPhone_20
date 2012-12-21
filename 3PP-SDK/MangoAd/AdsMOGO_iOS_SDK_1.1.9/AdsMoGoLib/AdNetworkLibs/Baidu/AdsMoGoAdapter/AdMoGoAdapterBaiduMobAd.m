//
//  File: AdMoGoAdapterBaiduMobAd.m
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//

#import "AdMoGoAdapterBaiduMobAd.h"
#import "AdMoGoView.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "AdMoGoAdNetworkConfig.h"

#define kAdMoGoBaiduAppIDKey @"AppID"
#define kAdMoGoBaiduAppSecretKey @"AppSEC"

static BaiduMobAdView* sBaiduAdview = nil;

@implementation AdMoGoAdapterBaiduMobAd

+ (AdMoGoAdNetworkType)networkType{
    return AdMoGoAdNetworkTypeBaiduMobAd;
}

+ (void)load{
    [[AdMoGoAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd{
    timer = [[NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(loadAdTimeOut:) userInfo:nil repeats:NO] retain];
    sBaiduAdview = [[BaiduMobAdView alloc] init];
    sBaiduAdview.frame = CGRectMake(0, 0, 320, 50);
    sBaiduAdview.autoplayEnabled = NO;
    sBaiduAdview.delegate = self;
    [sBaiduAdview start];
    self.adNetworkView = sBaiduAdview;
}

- (void)stopBeingDelegate{
   
}

- (void)stopTimer {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
}

- (void)dealloc {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    sBaiduAdview.delegate = nil;
    [sBaiduAdview release];
	[super dealloc];
}


- (NSString *)publisherId {
   return [networkConfig.credentials objectForKey:kAdMoGoBaiduAppIDKey];
}

- (NSString*) appSpec {
  return [networkConfig.credentials objectForKey:kAdMoGoBaiduAppSecretKey];
}


-(BOOL) enableLocation {
    return NO;
}

/**
 *  广告将要被载入
 */
-(void) willDisplayAd:(BaiduMobAdView*) adview {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    [adMoGoView adapter:self didGetAd:@"baidu"];
    [adMoGoView adapter:self didReceiveAdView:self.adNetworkView]; 
}
-(void) didAdImpressed {
    [adMoGoView AdMoGoBaiduI:networkConfig.nid netType:networkConfig.networkType];
}
-(void) didAdClicked{
    [adMoGoView AdMoGoBaiduC:networkConfig.nid netType:networkConfig.networkType];
}

/**
 *  广告载入失败
 */
-(void) failedDisplayAd:(BaiduMobFailReason) reason {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    [adMoGoView adapter:self didGetAd:@"baidu"];
    [adMoGoView adapter:self didFailAd:nil];
}


- (void)loadAdTimeOut:(NSTimer*)theTimer {
    if (timer) {
        [timer invalidate];
        [timer release];
        timer = nil;
    }
    [self stopBeingDelegate];
    [adMoGoView adapter:self didFailAd:nil];
}
@end