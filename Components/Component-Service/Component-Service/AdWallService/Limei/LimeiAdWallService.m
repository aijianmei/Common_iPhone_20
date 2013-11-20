//
//  LimeiAdWallService.m
//  Draw
//
//  Created by qqn_pipi on 13-3-16.
//
//

#import "LimeiAdWallService.h"

@implementation LimeiAdWallService

@synthesize adWallView = _adWallView;

- (void)dealloc
{
    PPRelease(_adWallView);
    [super dealloc];
}

- (void)prepareWallService:(NSString*)userId
{
    self.adWallView = [[[immobView alloc] initWithAdUnitID:self.adUnitId] autorelease];
    _adWallView.delegate = self;
    [self setUserInfo:userId];
}

- (void)show:(UIViewController*)viewController userId:(NSString*)userId
{
    [self setUserInfo:userId];    
    self.viewController = viewController;
    [self.adWallView immobViewRequest];
}

- (void)showInsert:(UIViewController *)viewController userId:(NSString *)userId
{
    [self setUserInfo:userId];
    self.viewController = viewController;
    [self.adWallView immobViewRequest];
}

- (void)queryScore:(NSString*)userId
{
    if ([userId length] == 0){
        return;
    }
    
    [self setUserInfo:userId];
    
    PPDebug(@"<LmmobAdWallSDK> UserQueryScore");
    [self.adWallView immobViewQueryScoreWithAdUnitID:[GameApp lmwallId] WithAccountID:userId];
}


- (void)reduceScore:(NSString*)userId score:(int)score
{
    // prepare data
    [self setUserInfo:userId];    
    [self.adWallView immobViewReduceScore:score WithAdUnitID:self.adUnitId WithAccountID:userId];
    
}

- (void)setUserInfo:(NSString*)userId
{
    //此属性针对多账户用户，主要用于区分不同账户下的积分
    if ([userId length] > 0){
        [_adWallView.UserAttribute setObject:userId
                                      forKey:@"accountname"];
    }
    
    [self setUserId:userId];
}
    
#pragma mark - delegate
    
    
/**
 *email phone sms等所需要
 *返回当前添加immobView的ViewController
 */
- (UIViewController *)immobViewController{
    return self.viewController;
}

/**
 *根据广告的状态来决定当前广告是否展示到当前界面上 AdReady
 *YES  当前广告可用
 *NO   当前广告不可用
 */
- (void) immobViewDidReceiveAd:(immobView *)immobView{
    PPDebug(@"<immobViewDidReceiveAd>");
    if ([self.adWallView isAdReady]){
        [self.viewController.view addSubview:self.adWallView];
        [self setUserInfo:self.userId];
        [self.adWallView immobViewDisplay];
    }
}

- (void) immobViewQueryScore:(NSUInteger)score WithMessage:(NSString *)returnMessage
{
    PPDebug(@"<LmmobAdWallSDK> UserQueryScore, score=%d, message=%@", score, returnMessage);
    [self handleQueryScoreResult:0 score:score];
}

- (void) immobViewReduceScore:(BOOL)status WithMessage:(NSString *)message
{
    PPDebug(@"<ReduceScore> status=%d, message=%@", status, message);
}

- (void) immobView: (immobView*) immobView didFailReceiveimmobViewWithError: (NSInteger) errorCode{
    PPDebug(@"<didFailReceiveimmobViewWithError> errorCode:%i",errorCode);
    self.viewController = nil;
}

- (void) onDismissScreen:(immobView *)immobView{
    PPDebug(@"<onDismissScreen> immobView");
    self.viewController = nil;
}


@end
