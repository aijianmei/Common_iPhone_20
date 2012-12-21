//
//  PPSinaWeiboService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-16.
//
//

#import "PPSinaWeiboService.h"
#import "PPSNSConstants.h"

@implementation PPSinaWeiboService

- (void)dealloc
{
    [super dealloc];
}

- (PPSNSCommonRequest*)createRequestWithService:(PPSNSCommonService*)service
                                   successBlock:(PPSNSSuccessBlock)successBlock
                                   failureBlock:(PPSNSFailureBlock)failureBlock
{
    return [[PPSinaWeiboRequest alloc] initWithService:service successBlock:successBlock failureBlock:failureBlock];
}

- (int)getSNSType
{
    return TYPE_SINA;
}

- (void)handleOpenURL:(NSURL*)url
{
    [self.currentWeiboRequest handleOpenURL:url];
}

- (NSString*)storageKeyPrefix
{
    return @"SINA";
}

- (NSString*)snsName
{
    return @"SinaWeibo";
}

@end
