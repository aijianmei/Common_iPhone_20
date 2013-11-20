//
//  AderWallService.m
//  Draw
//
//  Created by qqn_pipi on 13-3-20.
//
//

#import "AderAdWallService.h"
#import "UIUtils.h"

@implementation AderAdWallService

- (void)dealloc
{
    PPRelease(_wall);
    [super dealloc];
}

- (void)prepareWallService:(NSString*)userId
{    
    _wall = [[AderPointWall alloc] initWithAppId:self.adUnitId Delegate:self Model:MODEL_RELEASE];
    [self setUserInfo:userId];
}

- (void)show:(UIViewController*)viewController userId:(NSString*)userId
{
    _isShowWall = YES;
    
    PPDebug(@"<startPointWallService>");
    [self setUserInfo:userId];
    self.viewController = viewController;
    [_wall startPointWallService];
}

- (void)queryScore:(NSString*)userId
{
    if ([userId length] == 0){
        return;
    }
    
    [self setUserInfo:userId];    
    PPDebug(@"<getAderPoints>");
    [_wall getAderPoints];
}


- (void)reduceScore:(NSString*)userId score:(int)score
{
    // prepare data
    [self setUserInfo:userId];
    PPDebug(@"<spendAderPoints>");    
    [_wall spendAderPoints];    
}

- (void)setUserInfo:(NSString*)userId
{
    //此属性针对多账户用户，主要用于区分不同账户下的积分
    if ([userId length] > 0){

    }
    
    [self setUserId:userId];
}

#pragma mark - AderWallDelegate

//积分墙视图成功展示
-(void)aderWallDidReceiveSuccess:(AderPointWall *)aderWall
{
    //可以在这里做显示操作
    PPDebug(@"aderWallDidReceiveSuccess");
    [_wall displayWallWithViewController:self.viewController];
    
    _isShowWall = NO;
}

-(void)aderWallFaildToShow:(NSError *)error
{
    PPDebug(@"aderWallFaildToShow, error:%@",error);
    
    if (_isShowWall){
        [UIUtils alert:@"暂无可下载的免费应用"];
        _isShowWall = NO;
    }
}

//积分墙视图移除
-(void)aderWallCloseActionCallBack:(AderPointWall *)aderWall
{
    [_wall dismissWall];
    /*
     广告墙dismiss以后，释放掉积分墙
     [aAderPointADWall release];
     aAderPointADWall = nil;
     */
}

/**
 *查询积分接口回调
 */
- (void) aderWallQuery:(BOOL)status Score:(long long)score WithMessage:(NSString *)message;
{
    PPDebug(@"aderWallQuery status=%d score=%ld message=%@", status, score
            , message);
    [self handleQueryScoreResult:status ? 0 : 1 score:score];
    
}

/**
 *减少积分接口回调
 */
- (void) aderWallReducscore:(BOOL)status WithMessage:(NSString *)message
{
    PPDebug(@"aderWallReducscore status=%d message=%@", status, message);
}


@end
