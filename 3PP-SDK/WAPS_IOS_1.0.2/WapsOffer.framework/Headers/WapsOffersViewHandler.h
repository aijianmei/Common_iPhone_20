#import <UIKit/UIKit.h>
#import "WapsCallsWrapper.h"
#import "WapsOffersWebView.h"
#import "AppConnect.h"

@class WapsOffersWebView;

@interface WapsOffersViewHandler : NSObject {
    WapsOffersWebView *offersWebView_;
}

@property(nonatomic, retain) WapsOffersWebView *offersWebView;

- (void)removeOffersWebView;

+ (WapsOffersViewHandler *)sharedWapsOffersViewHandler;

+ (UIView *)showOffers;

+ (void)showOffers:(UIViewController *)vController;

@end


@interface WapsCallsWrapper (WapsOffersViewHandler)
//
- (UIView *)showOffers;

- (void)showOffers:(UIViewController *)vController;

- (void)showOffers:(UIViewController *)vController showNavBar:(BOOL)visible;

@end


@interface AppConnect (WapsOffersViewHandler)
//
+ (UIView *)showOffers;

+ (void)showOffers:(UIViewController *)vController;

+ (void)showOffers:(UIViewController *)vController showNavBar:(BOOL)visible;

@end