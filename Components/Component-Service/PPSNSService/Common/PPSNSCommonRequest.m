//
//  PPSNSCommonRequest.m
//  Draw
//
//  Created by qqn_pipi on 12-11-16.
//
//

#import "PPSNSCommonRequest.h"

@implementation PPSNSCommonRequest

- (id)initWithService:(PPSNSCommonService*)service
         successBlock:(PPSNSSuccessBlock)successBlock
         failureBlock:(PPSNSFailureBlock)failureBlock
{
    self = [super init];
    self.successBlock = successBlock;
    self.failureBlock = failureBlock;
    self.service = service;

    return self;
}


- (void)dealloc
{
    [self clearBlock];
    [super dealloc];
}

- (void)setSuccessBlock:(PPSNSSuccessBlock)successBlock
{
    if (_successBlock != NULL){
        Block_release(_successBlock);
        _successBlock = NULL;
    }
    
    if (successBlock != NULL){
        _successBlock = Block_copy(successBlock);
    }
    
}

- (void)setFailureBlock:(PPSNSFailureBlock)failureBlock
{
    if (_failureBlock != NULL){
        Block_release(_failureBlock);
        _failureBlock = NULL;
    }
    
    if (failureBlock != NULL){
        _failureBlock = Block_copy(failureBlock);
    }
}

- (void)clearBlock
{
    if (_failureBlock != NULL){
        Block_release(_failureBlock);
        _failureBlock = NULL;
    }
    
    if (_successBlock != NULL){
        Block_release(_successBlock);
        _successBlock = NULL;
    }
}

- (void)removeFromService
{
    [self.service removeRequest:self];
}

- (void)login
{
    PPDebug(@"Login NOT implemented");
}

- (void)logout
{
    PPDebug(@"Logout NOT implemented");
}


- (void)handleOpenURL:(NSURL*)url
{
    PPDebug(@"handleOpenURL NOT implemented");
    
}

- (void)readUserInfo:(NSString*)userId
{
    PPDebug(@"readUserInfo NOT implemented");
}

- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    PPDebug(@"publishWeibo NOT implemented");
}

- (void)followUser:(NSString*)nickName userId:(NSString*)userId successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    PPDebug(@"followUser NOT implemented");    
}

- (BOOL)isAuthorizeExpired
{
    PPDebug(@"isAuthorizeExpired NOT implemented");
    return YES;
}

- (void)safeSetKeyFrom:(NSDictionary*)fromDict toDict:(NSMutableDictionary*)toDict fromKey:(NSString*)fromKey toKey:(NSString*)toKey
{
    if (fromKey == nil || toKey == nil)
        return;
    
    NSObject* value = [fromDict objectForKey:fromKey];
    if (value == nil)
        return;
    
    if ([value isKindOfClass:[NSString class]]){
        [toDict setObject:value forKey:toKey];
    }
    else{
        [toDict setObject:[value description] forKey:toKey];
    }
}

@end
