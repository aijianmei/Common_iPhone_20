//
//  PPSNSCommonRequest.h
//  Draw
//
//  Created by qqn_pipi on 12-11-16.
//
//

#import <Foundation/Foundation.h>
#import "PPSNSCommonService.h"
#import "PPSNSConstants.h"
#import "LogUtil.h"


@interface PPSNSCommonRequest : NSObject

@property (nonatomic, assign) PPSNSSuccessBlock successBlock;
@property (nonatomic, assign) PPSNSFailureBlock failureBlock;
@property (nonatomic, assign) PPSNSCommonService* service;
@property (nonatomic, assign) PPSNSAction action;


- (void)removeFromService;
- (void)safeSetKeyFrom:(NSDictionary*)fromDict toDict:(NSMutableDictionary*)toDict fromKey:(NSString*)fromKey toKey:(NSString*)toKey;

// to be implemented by subclass
- (id)initWithService:(PPSNSCommonService*)service
         successBlock:(PPSNSSuccessBlock)successBlock
         failureBlock:(PPSNSFailureBlock)failureBlock;

- (void)login;
- (void)logout;
- (void)readUserInfo:(NSString*)userId;
- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock;
- (void)followUser:(NSString*)nickName userId:(NSString*)userId successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock;
- (void)handleOpenURL:(NSURL*)url;
- (BOOL)isAuthorizeExpired;

@end
