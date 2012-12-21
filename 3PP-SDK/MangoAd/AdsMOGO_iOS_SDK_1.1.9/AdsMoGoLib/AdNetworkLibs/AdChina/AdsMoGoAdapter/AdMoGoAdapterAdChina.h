//
//  File: AdMoGoAdapterAdChina.h
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//
//AdChina v2.3.6

#import "AdMoGoAdNetworkAdapter.h"
#import "AdChinaBannerView.h"

@interface AdMoGoAdapterAdChina : AdMoGoAdNetworkAdapter <AdChinaBannerViewDelegate,AdChinaUserInfoDelegate>{
}
+ (AdMoGoAdNetworkType)networkType;
@end
