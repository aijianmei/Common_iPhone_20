//
//  PPSNSStorageService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-20.
//
//

#import "PPSNSStorageService.h"
#import "LogUtil.h"

@implementation PPSNSStorageService

static PPSNSStorageService* _defaultSNSStorageService = nil;
static dispatch_once_t onceToken;

+ (PPSNSStorageService*)defaultService
{
    // thread safe singleton implementation
    dispatch_once(&onceToken, ^{
        _defaultSNSStorageService = [[PPSNSStorageService alloc] init];
    });
    
    return _defaultSNSStorageService;
}

- (id)init
{
    self = [super init];
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (NSString*)dataKeyByService:(PPSNSCommonService*)service
{
    NSString* key = [service storageKeyPrefix];
    return [key stringByAppendingString:@"_SNS_DATA_KEY"];
}

- (NSString*)accessTokenKeyByService:(PPSNSCommonService*)service
{
    NSString* key = [service storageKeyPrefix];
    return [key stringByAppendingString:@"_SNS_ACCESS_TOKEN_KEY"];
}

- (NSString*)expirationDateKeyByService:(PPSNSCommonService*)service
{
    NSString* key = [service storageKeyPrefix];
    return [key stringByAppendingString:@"_SNS_EXPIRATION_DATE_KEY"];
}


- (NSString*)userIdKeyByService:(PPSNSCommonService*)service
{
    NSString* key = [service storageKeyPrefix];
    return [key stringByAppendingString:@"_SNS_USER_ID_KEY"];
}

- (NSString*)refreshTokenKeyByService:(PPSNSCommonService*)service
{
    NSString* key = [service storageKeyPrefix];
    return [key stringByAppendingString:@"_SNS_REFRESH_TOKEN_KEY"];
}

- (NSString*)qqOpenIdKeyByService:(PPSNSCommonService*)service
{
    NSString* key = [service storageKeyPrefix];
    return [key stringByAppendingString:@"_SNS_QQ_OPEN_ID_KEY"];
}


- (void)storeAuthData:(PPSNSCommonService*)service
{
    if ([service accessToken] == nil ||
        [service userId] == nil ||
        [service expirationDate] == nil){
        return;
    }
    
    NSDictionary *authData = [NSDictionary dictionaryWithObjectsAndKeys:
                              [service accessToken], [self accessTokenKeyByService:service],
                              [service expirationDate], [self expirationDateKeyByService:service],
                              [service userId],[self userIdKeyByService:service],
                              [service refreshToken], [self refreshTokenKeyByService:service],
                              [service qqOpenId], [self qqOpenIdKeyByService:service], nil];
    
    PPDebug(@"Store Auth Data=%@", [authData description]);
    [[NSUserDefaults standardUserDefaults] setObject:authData forKey:[self dataKeyByService:service]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)removeAuthData:(PPSNSCommonService*)service
{
    NSString* key = [self dataKeyByService:service];
    PPDebug(@"Remove Auth Data %@", key);    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    service.expirationDate = nil;
    service.accessToken = nil;
    service.refreshToken = nil;
    service.userId = nil;
    service.qqOpenId = nil;
}

- (void)loadAuthData:(PPSNSCommonService*)service
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [self dataKeyByService:service];
    NSDictionary *info = [defaults objectForKey:key];
    
    NSString* accessToken = [info objectForKey:[self accessTokenKeyByService:service]];
    NSDate* expirationDate = [info objectForKey:[self expirationDateKeyByService:service]];
    NSString* userId = [info objectForKey:[self userIdKeyByService:service]];
    NSString* refreshToken = [info objectForKey:[self refreshTokenKeyByService:service]];
    NSString* qqOpenId = [info objectForKey:[self qqOpenIdKeyByService:service]];
    
    if ( accessToken &&
         expirationDate &&
         userId )
    {
        PPDebug(@"Load SNS data success, data=%@", [info description]);
        [service setAccessToken:accessToken];
        [service setExpirationDate:expirationDate];
        [service setUserId:userId];
        [service setRefreshToken:refreshToken];
        [service setQqOpenId:qqOpenId];
    }
    else{
        PPDebug(@"Load SNS data, but not enough data=%@", [info description]);
    }
    
}

- (NSString*)snsUserId:(PPSNSCommonService*)service
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [self dataKeyByService:service];
    NSDictionary *info = [defaults objectForKey:key];
    
    NSString* accessToken = [info objectForKey:[self accessTokenKeyByService:service]];
    NSDate* expirationDate = [info objectForKey:[self expirationDateKeyByService:service]];
    NSString* userId = [info objectForKey:[self userIdKeyByService:service]];
    
    if ( accessToken &&
        expirationDate &&
        userId )
    {
        return userId;
    }
    else{
        return nil;
    }
}

- (BOOL)isLogin:(PPSNSCommonService*)service
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* key = [self dataKeyByService:service];
    NSDictionary *info = [defaults objectForKey:key];
    
    NSString* accessToken = [info objectForKey:[self accessTokenKeyByService:service]];
    NSDate* expirationDate = [info objectForKey:[self expirationDateKeyByService:service]];
    NSString* userId = [info objectForKey:[self userIdKeyByService:service]];
    
    if ( accessToken &&
        expirationDate &&
        userId )
    {
        return YES;
    }
    else{
        return NO;
    }
}


@end
