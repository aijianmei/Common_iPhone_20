//
//  PPSNSStorageService.h
//  Draw
//
//  Created by qqn_pipi on 12-11-20.
//
//

#import <Foundation/Foundation.h>
#import "PPSNSCommonService.h"

@interface PPSNSStorageService : NSObject

+ (PPSNSStorageService*)defaultService;

- (void)loadAuthData:(PPSNSCommonService*)service;
- (void)removeAuthData:(PPSNSCommonService*)service;
- (void)storeAuthData:(PPSNSCommonService*)service;

- (BOOL)isLogin:(PPSNSCommonService*)service;
- (NSString*)snsUserId:(PPSNSCommonService*)service;

@end
