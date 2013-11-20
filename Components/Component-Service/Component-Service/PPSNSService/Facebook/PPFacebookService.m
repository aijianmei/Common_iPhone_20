//
//  PPFacebookService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-17.
//
//

#import "PPFacebookService.h"
#import "PPSNSConstants.h"
#import "PPFacebookRequest.h"

@implementation PPFacebookService

- (void)dealloc
{
    [super dealloc];
}

- (PPSNSCommonRequest*)createRequestWithService:(PPSNSCommonService*)service
                                   successBlock:(PPSNSSuccessBlock)successBlock
                                   failureBlock:(PPSNSFailureBlock)failureBlock
{
    return [[PPFacebookRequest alloc] initWithService:service successBlock:successBlock failureBlock:failureBlock];
}

- (int)getSNSType
{
    return TYPE_FACEBOOK;
}

- (void)handleOpenURL:(NSURL*)url
{
    [self.currentWeiboRequest handleOpenURL:url];
}

- (NSString*)storageKeyPrefix
{
    return @"FB";
}

- (NSString*)snsName
{
    return @"Facebook";
}

@end
