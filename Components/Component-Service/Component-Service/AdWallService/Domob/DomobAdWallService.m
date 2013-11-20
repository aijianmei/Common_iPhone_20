//
//  DomobAdWallService.m
//  Draw
//
//  Created by Kira on 13-4-23.
//
//

#import "DomobAdWallService.h"

@interface DomobAdWallService () {
    BOOL _isLoadingInsertWall;
}

@end

@implementation DomobAdWallService

- (void)dealloc
{
    PPRelease(_dmController);
    [super dealloc];
}

- (void)prepareWallService:(NSString*)userId
{
    _dmController = [[DMOfferWallViewController alloc] initWithPublisherID:self.adUnitId andUserID:userId];
    [_dmController setDelegate:self];
    [self setUserInfo:userId];
}

- (void)show:(UIViewController*)viewController userId:(NSString*)userId
{
    PPDebug(@"<requestOffers>");
    
    [self setUserInfo:userId];
    self.viewController = viewController;
    [_dmController loadOfferWall];
}

- (void)showInsert:(UIViewController *)viewController userId:(NSString *)userId
{
    PPDebug(@"<requestInsertOffers>");
    
    [self setUserInfo:userId];
    self.viewController = viewController;
    [_dmController loadOfferWallInterstitial]; //这个方法会同时请求积分墙和插屏积分墙
    _isLoadingInsertWall = YES;         //用来判断到底是请求积分墙还是插屏
}

- (void)queryScore:(NSString*)userId
{
    if ([userId length] == 0){
        return;
    }
    
    [self setUserInfo:userId];
    
    PPDebug(@"<requestEarnedPoints>");
    [_dmController requestOnlinePointCheck];
}


- (void)reduceScore:(NSString*)userId score:(int)score
{
    // prepare data
    [self setUserInfo:userId];

    [_dmController requestOnlineConsumeWithPoint:score];
}

- (void)setUserInfo:(NSString*)userId
{
    //此属性针对多账户用户，主要用于区分不同账户下的积分
    if ([userId length] > 0){
//        _wall.userID = userId;
    }
    
    [self setUserId:userId];
}

#pragma mark - domo ad wall delegate

// 积分墙开始加载数据。
// Offer wall starts to work.
- (void)offerWallDidStartLoad
{
    PPDebug(@"<DomoAdWallService> did started load offer wall");
}

// 积分墙加载完成。此方法实现中可进行积分墙入口Button显示等操作。
// Load offer wall successfully. You can set your IBOutlet.hidden to NO in this callback.
// This IBOutlet is the one which response to present OfferWall.
- (void)offerWallDidFinishLoad
{
    PPDebug(@"<DomoAdWallService> did finished load offer wall");
    if (!_isLoadingInsertWall) {
        [_dmController presentOfferWallWithViewController:self.viewController];
    }
}

// 积分墙加载失败。可能的原因由error部分提供，例如网络连接失败、被禁用等。建议在此隐藏积分墙入口Button。
// Failed to load offer wall. You should set THE IBOutlet.hidden to YES in this callback.
- (void)offerWallDidFailLoadWithError:(NSError *)error
{
    PPDebug(@"<DomoAdWallService> failed to load offer wall, error = %@", [error description]);
    self.viewController = nil;
}

// 关闭积分墙页面。
// Offer wall closed.
- (void)offerWallDidClosed
{
    PPDebug(@"<DomoAdWallService> closed offer wall");
    self.viewController = nil;
}

#pragma mark Point Check Callbacks
// 积分查询成功之后，回调该接口，获取总积分和总已消费积分。
- (void)offerWallDidFinishCheckPointWithTotalPoint:(NSInteger)totalPoint
                             andTotalConsumedPoint:(NSInteger)consumed
{
    PPDebug(@"<offerWallDidFinishCheckPointWithTotalPoint> total=%d, consumed=%d", totalPoint, consumed);
    [self handleQueryScoreResult:0 score:totalPoint];
}

// 积分查询失败之后，回调该接口，返回查询失败的错误原因。
- (void)offerWallDidFailCheckPointWithError:(NSError *)error
{
    PPDebug(@"<offerWallDidFailCheckPointWithError> error=%@", [error description]);
    [self handleQueryScoreResult:0 score:0];
}

#pragma mark Consume Callbacks
// 消费请求正常应答后，回调该接口，并返回消费状态（成功或余额不足），以及总积分和总已消费积分。
- (void)offerWallDidFinishConsumePointWithStatusCode:(DMOfferWallConsumeStatusCode)statusCode
                                          totalPoint:(NSInteger)totalPoint
                                  totalConsumedPoint:(NSInteger)consumed
{
    PPDebug(@"<offerWallDidFinishConsumePointWithStatusCode> closed offer wall, total points = %d and total cousumed point = %d.", totalPoint, consumed);
}

// 消费请求异常应答后，回调该接口，并返回异常的错误原因。
- (void)offerWallDidFailConsumePointWithError:(NSError *)error
{
    PPDebug(@"<offerWallDidFailConsumePointWithError> consume point error, error=%@", [error description]);
}

#pragma mark OfferWall Interstitial
// 当积分墙插屏广告被成功加载后，回调该方法
- (void)dmOfferWallInterstitialSuccessToLoadAd:(DMOfferWallViewController *)dmOWInterstitial {
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    if (rootViewController) {
        NSLog(@"Application root controller.");
        _dmController.rootViewController = rootViewController;
    }
    if ([_dmController isOfferWallInterstitialReady]) {
        [_dmController presentOfferWallInterstitial];
    }

}

// 当积分墙插屏广告加载失败后，回调该方法
- (void)dmOfferWallInterstitialFailToLoadAd:(DMOfferWallViewController *)dmOWInterstitial withError:(NSError *)err {
    PPDebug(@"<dmOfferWallInterstitialFailToLoadAd> err = %@", [err description]);
    self.viewController = nil;
}

// 当积分墙插屏广告要被呈现出来前，回调该方法
- (void)dmOfferWallInterstitialWillPresentScreen:(DMOfferWallViewController *)dmOWInterstitial {
    PPDebug(@"<dmOfferWallInterstitialWillPresentScreen>");
}

// 当积分墙插屏广告被关闭后，回调该方法
- (void)dmOfferWallInterstitialDidDismissScreen:(DMOfferWallViewController *)dmOWInterstitial {
    PPDebug(@"<dmOfferWallInterstitialDidDismissScreen>");
}

@end
