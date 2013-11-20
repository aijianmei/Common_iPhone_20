//
//  WanpuAdWallService.m
//  Draw
//
//  Created by qqn_pipi on 13-3-20.
//
//

#import "WanpuAdWallService.h"
#import "WapsOffer/AppConnect.h"

@implementation WanpuAdWallService

- (void)dealloc
{
    [super dealloc];
}

- (void)prepareWallService:(NSString*)userId
{
    [AppConnect getConnect:self.adUnitId pid:@"AppStore"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWanpuConnectSuccess:) name:WAPS_CONNECT_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onWanpuConnectFailed:) name:WAPS_CONNECT_FAILED object:nil];
    
    // init WANPU SDK Wall Notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUpdatedPoints:) name:WAPS_GET_POINTS_SUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUpdatedPointsFailed:) name:WAPS_GET_POINTS_FAILED object:nil];
    
}

- (void)show:(UIViewController*)viewController userId:(NSString*)userId
{
    PPDebug(@"<showOffers>");
    
    [AppConnect showOffers];
}

- (void)queryScore:(NSString*)userId
{
    PPDebug(@"<WanpuWall> getPoints");
    [AppConnect getPoints];
}


- (void)reduceScore:(NSString*)userId score:(int)score
{
    PPDebug(@"<spendPoints>");    
    [AppConnect spendPoints:score];
}

- (void)setUserInfo:(NSString*)userId
{
    [self setUserId:userId];
}

#pragma mark - Wanpu Delegates

- (void)onWanpuConnectSuccess:(id)sender
{
    PPDebug(@"<onWanpuConnectSuccess>");
}

- (void)onWanpuConnectFailed:(id)sender
{
    PPDebug(@"<onWanpuConnectFailed>");
}


#pragma mark - Wap Pu Wall For Query Points

//获取积分成功处理方法:
-(void)getUpdatedPoints:(NSNotification*)notifyObj{
    WapsUserPoints *userPoints = notifyObj.object;
    NSString *pointsName=[userPoints getPointsName];
    int pointsValue=[userPoints getPointsValue];
    
    PPDebug(@"Wappu SDK <getUpdatedPoints> success, name=%@, points=%d",
            pointsName, pointsValue);
    if (pointsValue <= 0)
        return;
    
    [self handleQueryScoreResult:0 score:pointsValue];
}

//获取积分失败处理方法:
-(void)getUpdatedPointsFailed:(NSNotification*)notifyObj{
    PPDebug(@"Wappu SDK <getUpdatedPoints> failure, info=%@", [notifyObj.object description]);
    [self handleQueryScoreResult:0 score:0];
    
}

@end
