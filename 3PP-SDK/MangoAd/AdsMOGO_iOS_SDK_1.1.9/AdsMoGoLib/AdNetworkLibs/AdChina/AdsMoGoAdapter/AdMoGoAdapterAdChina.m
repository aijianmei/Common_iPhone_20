//
//  File: AdMoGoAdapterAdChina.m
//  Project: AdsMOGO iOS SDK
//  Version: 1.1.9
//
//  Copyright 2011 AdsMogo.com. All rights reserved.
//

#import "AdMoGoAdapterAdChina.h"
#import "AdMoGoView.h"
#import "AdMoGoAdNetworkRegistry.h"
#import "AdMoGoAdNetworkAdapter+Helpers.h"
#import "AdMoGoAdNetworkConfig.h" 
#import "AdChinaBannerView.h"
#import "AdChinaUserInfoDelegateProtocol.h"

@implementation AdMoGoAdapterAdChina

+ (AdMoGoAdNetworkType)networkType {
	return AdMoGoAdNetworkTypeAdChina;
}

+ (void)load {
	[[AdMoGoAdNetworkRegistry sharedRegistry] registerClass:self];
}

- (void)getAd {
    AdViewType type = adMoGoView.adType;
    CGSize size = CGSizeZero;
    switch (type) {
        case AdViewTypeNormalBanner:
            size = CGSizeMake(320, 48);
            break;
        case AdViewTypeLargeBanner:
            size = CGSizeMake(728, 90);
            break;
        default:
            [adMoGoView adapter:self didGetAd:@"adchina"];
            [adMoGoView adapter:self didFailAd:nil];
            return;
            break;
    }

    AdChinaBannerView *bannerAd =[AdChinaBannerView requestAdWithAdSpaceId:networkConfig.pubId delegate:self adSize:size];
    [bannerAd setAnimationMask:AnimationMaskChangeAlpha];
    [bannerAd setViewControllerForBrowser:[adMoGoDelegate viewControllerForPresentingModalView]];
    bannerAd.frame = CGRectMake(0, 0, size.width, size.height);
    [bannerAd setRefreshInterval:DisableRefresh];
    self.adNetworkView = bannerAd;
    [bannerAd release];
}

- (void)stopBeingDelegate {
    AdChinaBannerView *adView = (AdChinaBannerView *)self.adNetworkView;
    if(adView != nil)
    {
        self.adNetworkView = nil;
    }
}

- (void)dealloc {
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
- (void)presentModalViewController:(UIViewController *)modalViewController animated:(BOOL)animated {
    [[adMoGoDelegate viewControllerForPresentingModalView] 
     presentModalViewController:modalViewController animated:animated];
}
- (void)dismissModalViewControllerAnimated:(BOOL)animated {
    [[adMoGoDelegate viewControllerForPresentingModalView] dismissModalViewControllerAnimated:animated];
}
- (void)interfaceOrientation {
	
}

#pragma mark AdChinaDelegate required methods
#pragma mark Banner
- (void)didGetBanner:(AdChinaBannerView *)adView {
        [adMoGoView adapter:self didGetAd:@"adchina"];
        [adMoGoView adapter:self didReceiveAdView:adView];
}
- (void)didFailToGetBanner:(AdChinaBannerView *)adView {
    [adMoGoView adapter:self didGetAd:@"adchina"];
	[adMoGoView adapter:self didFailAd:nil];
}

- (void)didEnterFullScreenMode {
    [self helperNotifyDelegateOfFullScreenModal];
}
- (void)didExitFullScreenMode {
    [self helperNotifyDelegateOfFullScreenModalDismissal];
}

#pragma mark optional targeting info methods

// user's phone number
- (NSString *)phoneNumber {
	if ([adMoGoDelegate respondsToSelector:@selector(phoneNumber)]) {
		return [adMoGoDelegate phoneNumber];
	}
	return @"";
}		
// user's gender (@"1" for male, @"2" for female)	
- (Sex)gender {
    if ([adMoGoDelegate respondsToSelector:@selector(gender)]) {
        NSUInteger tempInt = [[adMoGoDelegate gender] integerValue];
        switch (tempInt) {
            case 1:
                return SexMale;
            case 2:
                return SexFemale;
            default:
                return SexUnknown;
        }
	}
	return SexUnknown;
}


// user's postal code, e.g. @"200040"
- (NSString *)postalCode {
	if ([adMoGoDelegate respondsToSelector:@selector(postalCode)]) {
		return [adMoGoDelegate postalCode];
	}
	return @"";
}
// user's date of birth, e.g. @"19820101"
- (NSString *)dateOfBirth {
	if ([adMoGoDelegate respondsToSelector:@selector(dateOfBirth)]) {
		NSString *Date = [[NSString alloc] init];
		NSDateFormatter *dataFormatter = [[NSDateFormatter alloc] init];
		NSDate *date = [adMoGoDelegate dateOfBirth];
		[dataFormatter setDateFormat:@"YYYYMMdd"];
		[Date stringByAppendingFormat:@"%@",[dataFormatter stringFromDate:date]];
		[Date autorelease];
		[dataFormatter autorelease];
		return Date;
	}
	return @"";
}
// keyword about the type of your app, e.g. @"Business"
- (NSString *)keywords {
	if ([adMoGoDelegate respondsToSelector:@selector(keywords)]) {
		return [adMoGoDelegate keywords];
	}
	return @"";
}
@end