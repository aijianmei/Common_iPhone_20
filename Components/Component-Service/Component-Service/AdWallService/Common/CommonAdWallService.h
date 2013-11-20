//
//  CommonAdWallService.h
//  Draw
//
//  Created by qqn_pipi on 13-3-16.
//
//

#import <Foundation/Foundation.h>


typedef void(^AdWallCompleteHandler)(int resultCode, int score);

@protocol AdWallProtocol <NSObject>

- (void)prepareWallService:(NSString*)userId;
- (void)show:(UIViewController*)viewController userId:(NSString*)userId;
- (void)queryScore:(NSString*)userId;
- (void)reduceScore:(NSString*)userId score:(int)score;
- (void)setUserInfo:(NSString*)userId;

@optional
- (void)showInsert:(UIViewController*)viewController userId:(NSString*)userId;

@end

@interface CommonAdWallService : NSObject<AdWallProtocol>

@property (nonatomic, assign) AdWallCompleteHandler queryScoreCompleteHandler;
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSString* adUnitId;
@property (nonatomic, retain) NSString* adUnitSecret;
@property (nonatomic, assign) UIViewController* viewController;
@property (nonatomic, assign) int type;
@property (nonatomic, assign) int isQueryingScore;

- (id)initWithUserId:(NSString*)userId
            adUnitId:(NSString*)adUnitId
        adUnitSecret:(NSString*)adUnitSecret
                type:(int)type;

- (void)queryScore:(NSString*)userId completeHandler:(AdWallCompleteHandler)completeHandler;
- (void)handleQueryScoreResult:(int)resultCode score:(int)score;

@end
