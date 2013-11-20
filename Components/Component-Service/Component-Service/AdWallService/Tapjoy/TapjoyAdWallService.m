//
//  TapjoyAdWallService.m
//  Draw
//
//  Created by Kira on 13-4-25.
//
//

#import "TapjoyAdWallService.h"
#import "TapjoyConnect.h"

@implementation TapjoyAdWallService

- (void)prepareWallService:(NSString*)userId
{
    //TODO:register notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offerWallDidFinishLoad) name:TJC_CONNECT_SUCCESS object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(offerWallDidFailLoadWithError:) name:TJC_CONNECT_FAILED object:nil];
	
	// NOTE: This must be replaced by your App ID. It is Retrieved from the Tapjoy website, in your account.
	[TapjoyConnect requestTapjoyConnect:self.adUnitId
							  secretKey:self.adUnitSecret
								options:@{
		  TJC_OPTION_TRANSITION_EFFECT : @(TJCTransitionExpand),
			 TJC_OPTION_ENABLE_LOGGING : @(NO),
     // If you are not using Tapjoy Managed currency, you would set your own user ID here.
     //TJC_OPTON_USER_ID : @"A_UNIQUE_USER_ID"
	 }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didGetTapPoints:)
												 name:TJC_TAP_POINTS_RESPONSE_NOTIFICATION
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didSpendTapPoints:)
												 name:TJC_SPEND_TAP_POINTS_RESPONSE_NOTIFICATION
											   object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(getTapPointsError:)
												 name:TJC_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(didSpendTapPointsError:)
												 name:TJC_SPEND_TAP_POINTS_RESPONSE_NOTIFICATION_ERROR
											   object:nil];

    
    // Notification for Offers related callback
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(getOffersError:)
												 name:TJC_OFFERS_RESPONSE_NOTIFICATION_ERROR
											   object:nil];

}

- (void)show:(UIViewController*)viewController userId:(NSString*)userId
{
    PPDebug(@"<requestOffers>");
    
    [self setUserInfo:userId];
//    self.viewController = viewController;
    [TapjoyConnect showOffers];
}

- (void)queryScore:(NSString*)userId
{
    if ([userId length] == 0){
        return;
    }
    
    [self setUserInfo:userId];
    
    PPDebug(@"<requestEarnedPoints>");
    [TapjoyConnect getTapPoints];
}


- (void)reduceScore:(NSString*)userId score:(int)score
{
    // prepare data
    [self setUserInfo:userId];
    
    [TapjoyConnect spendTapPoints:score];
}

- (void)setUserInfo:(NSString*)userId
{
    //此属性针对多账户用户，主要用于区分不同账户下的积分
    if ([userId length] > 0){
        [TapjoyConnect setUserID:userId];
    }
    
    [self setUserId:userId];
}

#pragma mark - domo ad wall delegate

// 积分墙加载完成。此方法实现中可进行积分墙入口Button显示等操作。
// Load offer wall successfully. You can set your IBOutlet.hidden to NO in this callback.
// This IBOutlet is the one which response to present OfferWall.
- (void)offerWallDidFinishLoad
{
    PPDebug(@"<offerWallDidFinishLoad> did finished load offer wall");
    self.viewController = nil;
}

// 积分墙加载失败。可能的原因由error部分提供，例如网络连接失败、被禁用等。建议在此隐藏积分墙入口Button。
// Failed to load offer wall. You should set THE IBOutlet.hidden to YES in this callback.
- (void)offerWallDidFailLoadWithError:(NSNotification*)notifyObj
{
    PPDebug(@"<offerWallDidFailLoadWithError> failed to load offer wall");
    self.viewController = nil;
}


#pragma mark Point Check Callbacks
// 积分查询成功之后，回调该接口，获取总积分和总已消费积分。

- (void)didGetTapPoints:(NSNotification*)notifyObj
{
	NSNumber *tapPoints = notifyObj.object;
	NSString *tapPointsStr = [NSString stringWithFormat:@"<didGetTapPoints> Tap Points: %d", [tapPoints intValue]];
	PPDebug(@"%@", tapPointsStr);
	
	[self handleQueryScoreResult:0 score:tapPoints.intValue];
}

// 积分查询失败之后，回调该接口，返回查询失败的错误原因。
- (void)getTapPointsError:(NSNotification*)notifyObj
{
    PPDebug(@"<getTapPointsError> error=%@", [notifyObj description]);
    [self handleQueryScoreResult:0 score:0];
}

#pragma mark Consume Callbacks
// 消费请求正常应答后，回调该接口，并返回消费状态（成功或余额不足），以及总积分和总已消费积分。
- (void)didSpendTapPoints:(NSNotification*)notifyObj
{
    NSNumber *tapPoints = notifyObj.object;
    PPDebug(@"<didSpendTapPoints> total points = %d .", tapPoints.intValue);
}

// 消费请求异常应答后，回调该接口，并返回异常的错误原因。
- (void)didSpendTapPointsError:(NSNotification*)notifyObj
{
    PPDebug(@"<didSpendTapPointsError> error=%@", [notifyObj description]);
}


@end
