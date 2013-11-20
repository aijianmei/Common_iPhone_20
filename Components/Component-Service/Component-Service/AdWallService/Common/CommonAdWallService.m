//
//  CommonAdWallService.m
//  Draw
//
//  Created by qqn_pipi on 13-3-16.
//
//

#import "CommonAdWallService.h"
#import "BlockUtils.h"


@implementation CommonAdWallService

- (void)dealloc
{
    PPRelease(_userId);
    PPRelease(_adUnitId);
    PPRelease(_adUnitSecret);
    [super dealloc];
}

- (id)initWithUserId:(NSString*)userId adUnitId:(NSString*)adUnitId  adUnitSecret:(NSString*)adUnitSecret type:(int)type
{
    self = [super init];
    [self setAdUnitId:adUnitId];
    [self setAdUnitSecret:adUnitSecret];
    [self setType:type];
    [self prepareWallService:userId];
    return self;
}

- (void)queryScore:(NSString*)userId completeHandler:(AdWallCompleteHandler)completeHandler
{
    if (_isQueryingScore){
        PPDebug(@"Querying score... Don't call it again");
        return;
    }
    
    RELEASE_BLOCK(_queryScoreCompleteHandler);
    COPY_BLOCK(_queryScoreCompleteHandler, completeHandler);
    
    _isQueryingScore = YES;
    
    [self queryScore:userId];
}

- (void)handleQueryScoreResult:(int)resultCode score:(int)score
{
    if (resultCode == 0 && score > 0){
        [self reduceScore:self.userId score:score];
    }

    _isQueryingScore = NO;
    
    EXECUTE_BLOCK(_queryScoreCompleteHandler, resultCode, score);
    RELEASE_BLOCK(_queryScoreCompleteHandler);
}

- (void)prepareWallService:(NSString*)userId
{
    PPDebug(@"<prepareWallService> NOT IMPLEMENTED!!!");
}

- (void)show:(UIViewController*)viewController userId:(NSString*)userId
{
    PPDebug(@"<show> NOT IMPLEMENTED!!!");
    
}

- (void)queryScore:(NSString*)userId
{
    PPDebug(@"<queryScore> NOT IMPLEMENTED!!!");
    
}

- (void)reduceScore:(NSString*)userId score:(int)score
{
    PPDebug(@"<reduceScore> NOT IMPLEMENTED!!!");
    
}

- (void)setUserInfo:(NSString*)userId
{
    PPDebug(@"<setUserInfo> NOT IMPLEMENTED!!!");    
}


@end
