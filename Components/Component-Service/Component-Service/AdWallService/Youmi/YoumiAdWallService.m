//
//  YoumiAdWallService.m
//  Draw
//
//  Created by qqn_pipi on 13-3-20.
//
//

#import "YoumiAdWallService.h"
#import "YouMiWall.h"


@implementation YoumiAdWallService

- (void)dealloc
{
    PPRelease(_wall);
    [super dealloc];
}

- (void)prepareWallService:(NSString*)userId
{
    [YouMiConfig launchWithAppID:self.adUnitId appSecret:self.adUnitSecret];
//    _wall = [[YouMiWall alloc] initWithAppID:self.adUnitId withAppSecret:self.adUnitSecret];
    _wall = [[YouMiWall alloc] init];
    [_wall setDelegate:self];
    [self setUserInfo:userId];
}

- (void)show:(UIViewController*)viewController userId:(NSString*)userId
{    
    PPDebug(@"<requestOffers>");
    if (_isShowWall){
        return;
    }
    
    _isShowWall = YES;
    [self setUserInfo:userId];
    self.viewController = viewController;
    [_wall requestOffers:YES];
}

- (void)queryScore:(NSString*)userId
{
    if ([userId length] == 0){
        return;
    }
    
    [self setUserInfo:userId];
    
    PPDebug(@"<requestEarnedPoints>");
    [_wall requestEarnedPoints];
}


- (void)reduceScore:(NSString*)userId score:(int)score
{
    // prepare data
    [self setUserInfo:userId];

    // do nothing for youmi
}

- (void)setUserInfo:(NSString*)userId
{
    //此属性针对多账户用户，主要用于区分不同账户下的积分
    if ([userId length] > 0){
//        _wall.userID = userId; //new version change interface
        [YouMiConfig setUserID:userId];
    }
    
    [self setUserId:userId];
}

#pragma mark Request Offers Notification Methods

// 请求应用列表成功
//
// 详解:
//      应用列表请求成功后回调该方法
// 补充:
//      查看YOUMI_OFFERS_RESPONSE_NOTIFICATION
//
- (void)didReceiveOffers:(YouMiWall *)adWall
{
    PPDebug(@"<didReceiveOffers>");    
    [_wall showOffers];
}

// 请求应用列表失败
//
// 详解:
//      应用列表请求失败后回调该方法
// 补充:
//      查看YOUMI_OFFERS_RESPONSE_NOTIFICATION_ERROR
//
- (void)didFailToReceiveOffers:(YouMiWall *)adWall error:(NSError *)error
{
    PPDebug(@"<didFailToReceiveOffers> error=%@", [error description]);
    _isShowWall = NO;
}

#pragma mark Screen View Notification Methods

// 显示全屏页面
//
// 详解:
//      全屏页面显示完成后回调该方法
// 补充:
//      查看YOUMI_WALL_VIEW_OPENED_NOTIFICATION
//
- (void)didShowWallView:(YouMiWall *)adWall
{
    PPDebug(@"<didShowWallView>");    
}

// 隐藏全屏页面
//
// 详解:
//      全屏页面隐藏完成后回调该方法
// 补充:
//      查看YOUMI_WALL_VIEW_CLOSED_NOTIFICATION
//
- (void)didDismissWallView:(YouMiWall *)adWall
{
    PPDebug(@"<didDismissWallView>");
    _isShowWall = NO;
    
}

- (void)setAppAddPointStatus:(NSString*)appName
{
    if ([appName length] == 0)
        return;
    
    PPDebug(@"<setAppAddPointStatus> appName=%@", appName);
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setBool:YES forKey:appName];
    [userDefaults synchronize];
}

- (BOOL)isAppAddPoints:(NSString*)appName
{
    if ([appName length] == 0)
        return NO;

    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults boolForKey:appName];
}

// 查询积分情况成功
// @info 里面包含积分记录的NSDictionary
//
// 详解:
//      积分查询请求成功后回调该方法
// 补充:
//      查看YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION
//
- (void)didReceiveEarnedPoints:(YouMiWall *)adWall info:(NSArray *)info
{
    PPDebug(@"<didReceiveEarnedPoints> record count=%d", [info count]);
    int point = 0;
    for (NSDictionary *dic in info) {
        for (NSString *key in [dic allKeys]) {
            NSString *orderID = [dic objectForKey:kOneAccountRecordOrderIDOpenKey];
            NSString *userID = (NSString *)[dic objectForKey:kOneAccountRecordUserIDOpenKey];
            NSString *name = (NSString *)[dic objectForKey:kOneAccountRecordNameOpenKey];
            NSInteger earnedPoint = [(NSNumber *)[dic objectForKey:kOneAccountRecordPoinstsOpenKey] integerValue];
            PPDebug(@"<didReceiveEarnedPoints> user(%@), name(%@), point(%d)", userID, name, earnedPoint);
            
            if ([self isPointEarned:orderID] == NO){
                PPDebug(@"<YoumiWallService> add conins (%d) for order (%@)", earnedPoint, orderID);
                point += earnedPoint;
                
                // update point earning order
                [self updateOrder:dic];
            }
            else{
                PPDebug(@"<YoumiWallService> order (%@) already added coins (%d)", orderID, earnedPoint);
            }
        }
    }
    
    // charge account
    [self handleQueryScoreResult:0 score:point];
}

// 查询积分情况失败
//
// 详解:
//      积分查询请求失败后回调该方法
// 补充:
//      查看YOUMI_EARNED_POINTS_RESPONSE_NOTIFICATION_ERROR
//
- (void)didFailToReceiveEarnedPoints:(YouMiWall *)adWall error:(NSError *)error
{
    PPDebug(@"<didFailToReceiveEarnedPoints> error=%@", [error description]);
    [self handleQueryScoreResult:0 score:0];
}


#pragma mark - Youmi Award Order

#define YOUMI_WALL_ORDER_LIST @"YOUMI_WALL_ORDER_LIST"

- (BOOL)isPointEarned:(NSString*)orderId
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSArray *orderList = [userDefault objectForKey:YOUMI_WALL_ORDER_LIST];
    if (orderList == nil){
        return NO;
    }
    
    for (NSDictionary* obj in orderList){
        NSString* oid = [obj objectForKey:kOneAccountRecordOrderIDOpenKey];
        if ([oid isEqualToString:orderId]){
            return YES;
        }
    }
    
    return NO;
}

- (void)updateOrder:(NSDictionary*)order
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    // read old data
    NSArray *oldOrderList = [userDefault objectForKey:YOUMI_WALL_ORDER_LIST];
    NSMutableArray *newOrderList = [[NSMutableArray alloc] init];
    if (oldOrderList != nil){
        [newOrderList addObjectsFromArray:oldOrderList];
    }
    
    // add new order
    //    NSString* orderId = [order objectForKey:kOneAccountRecordOrderIDOpenKey];
    //    NSString* appName = [order objectForKey:kOneAccountRecordStoreIDOpenKey];
    [newOrderList addObject:order];
    
    PPDebug(@"<YoumiWallService> new order list = %@", [newOrderList description]);
    
    // save
    [userDefault setObject:newOrderList forKey:YOUMI_WALL_ORDER_LIST];
    [userDefault synchronize];
    
    [newOrderList release];
}

- (NSArray*)getOrderList
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:YOUMI_WALL_ORDER_LIST];
}

@end
