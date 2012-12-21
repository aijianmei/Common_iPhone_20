//
//  PPSNSCommonService.h
//  Draw
//
//  Created by qqn_pipi on 12-11-16.
//
//

#import <Foundation/Foundation.h>

@class PPSNSCommonRequest;

typedef void(^PPSNSSuccessBlock)(NSDictionary* userInfo);
typedef void(^PPSNSFailureBlock)(NSError *error);

@interface PPSNSCommonService : NSObject

@property (nonatomic, retain) NSString* appKey;
@property (nonatomic, retain) NSString* appSecret;
@property (nonatomic, retain) NSString* appRedirectURI;
@property (nonatomic, retain) NSString* officialWeiboId;
@property (nonatomic, assign) int snsType;

@property (nonatomic, retain) NSOperationQueue* queue;
@property (nonatomic, retain) NSMutableArray* requestArray;
@property (nonatomic, retain) PPSNSCommonRequest *currentWeiboRequest;

@property (nonatomic, retain) NSString* accessToken;
@property (nonatomic, retain) NSString* userId;
@property (nonatomic, retain) NSDate*   expirationDate;
@property (nonatomic, retain) NSString* refreshToken;
@property (nonatomic, retain) NSString* qqOpenId;

@property (nonatomic, retain) UIAlertView* followAlertView;
@property (nonatomic, retain) NSString* followWeiboId;
@property (nonatomic, assign) PPSNSSuccessBlock followSuccessBlock;
@property (nonatomic, assign) PPSNSFailureBlock followFailureBlock;

- (id)initWithAppKey:(NSString*)appKey
           appSecret:(NSString*)appSecret
      appRedirectURI:(NSString*)appRedirectURI
     officialWeiboId:(NSString*)officialWeiboId;

#pragma mark - weibo methods

// login & logout & status
- (void)login:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock;
- (void)logout;

- (void)readUserInfo:(NSString*)userId successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock;
- (void)readMyUserInfo:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock;

// publish weibo
- (void)publishWeibo:(NSString*)text successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock;
- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock;

// follow operation
- (void)followUser:(NSString*)nickName userId:(NSString*)userId successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock;

- (void)askFollowWithTitle:(NSString*)displayTitle
            displayMessage:(NSString*)displayMessage
                   weiboId:(NSString*)weiboId
              successBlock:(PPSNSSuccessBlock)successBlock
              failureBlock:(PPSNSFailureBlock)failureBlock;

- (void)saveAccessToken:(NSString*)accessToken
           refreshToken:(NSString*)refreshToken
             expireDate:(NSDate*)expireDate
                 userId:(NSString*)userId
               qqOpenId:(NSString*)qqOpenId;

#pragma mark - request lifecycle management

// request lifecycle management
- (void)addRequest:(PPSNSCommonRequest*)request;
- (void)removeRequest:(PPSNSCommonRequest*)request;

#pragma mark - sns status

- (NSString*)snsUserId;
- (BOOL)isLogin;
- (BOOL)isAuthorizeExpired;

#pragma mark - to be overrided by sub class

// To be overrided by sub class
- (PPSNSCommonRequest*)createRequestWithService:(PPSNSCommonService*)service
                  successBlock:(PPSNSSuccessBlock)successBlock
                  failureBlock:(PPSNSFailureBlock)failureBlock;
- (int)getSNSType;
- (void)handleOpenURL:(NSURL*)url;
- (NSString*)storageKeyPrefix;
- (NSString*)snsName;


@end
