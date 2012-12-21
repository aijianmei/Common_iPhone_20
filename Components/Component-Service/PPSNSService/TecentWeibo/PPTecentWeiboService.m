//
//  PPTecentWeiboService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-17.
//
//

#import "PPTecentWeiboService.h"
#import "PPSNSConstants.h"
#import "TCWBEngine.h"
#import "PPTecentWeiboRequest.h"

@implementation PPTecentWeiboService

- (PPSNSCommonRequest*)createRequestWithService:(PPSNSCommonService*)service
                                   successBlock:(PPSNSSuccessBlock)successBlock
                                   failureBlock:(PPSNSFailureBlock)failureBlock
{
    return [[PPTecentWeiboRequest alloc] initWithService:service successBlock:successBlock failureBlock:failureBlock];
}

- (int)getSNSType
{
    return TYPE_QQ;
}


- (void)handleOpenURL:(NSURL*)url
{
    
}

- (NSString*)storageKeyPrefix
{
    return @"TC";
}

- (NSString*)snsName
{
    return @"TecentWeibo";
}


@end
