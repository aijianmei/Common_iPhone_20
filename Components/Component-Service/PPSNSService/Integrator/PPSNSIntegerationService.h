//
//  PPSNSIntegerationService.h
//  Draw
//
//  Created by qqn_pipi on 12-11-16.
//
//

#import <Foundation/Foundation.h>
#import "PPSNSCommonService.h"

typedef void(^PPSNSSuccessWithSNSTypeBlock)(int snsType, PPSNSCommonService* snsService, NSDictionary* userInfo);
typedef void(^PPSNSFailureWithSNSTypeBlock)(int snsType, PPSNSCommonService* snsService, NSError *error);


@interface PPSNSIntegerationService : NSObject

+ (PPSNSIntegerationService*)defaultService;

// add/get operations
- (void)addSNS:(PPSNSCommonService*)service;
- (PPSNSCommonService*)snsServiceByType:(int)type;

// handleOpenURL
- (BOOL)handleOpenURL:(NSURL*)url;

- (void)publishWeiboToAll:(NSString*)text
            imageFilePath:(NSString*)imageFilePath
             successBlock:(PPSNSSuccessWithSNSTypeBlock)successBlock
             failureBlock:(PPSNSFailureWithSNSTypeBlock)failureBlock;

//// bind to SNS account
//- (void)bindSNSAccount;
//- (void)unbindSNSAccount;
//
//// to all SNS account bind
//- (void)publishMessageToAll;
//
//// to specific SNS
//- (void)publishMessage;

@end
