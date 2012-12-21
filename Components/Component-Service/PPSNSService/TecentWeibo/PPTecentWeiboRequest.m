//
//  PPTecentWeiboRequest.m
//  Draw
//
//  Created by qqn_pipi on 12-11-17.
//
//

#import "PPTecentWeiboRequest.h"
#import "TCWBEngine.h"
#import "PPSNSStorageService.h"
#import "PPSNSConstants.h"

@implementation PPTecentWeiboRequest

- (id)initWithService:(PPSNSCommonService*)service
         successBlock:(PPSNSSuccessBlock)successBlock
         failureBlock:(PPSNSFailureBlock)failureBlock
{
    self = [super initWithService:service
                     successBlock:successBlock
                     failureBlock:failureBlock];
    
    TCWBEngine *engine = [[TCWBEngine alloc] initWithAppKey:service.appKey
                                                  andSecret:service.appSecret
                                             andRedirectUrl:service.appRedirectURI];

    UIViewController* rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    [engine setRootViewController:rootViewController];
    
    self.tecentEngine = engine;
    [engine release];
    
    // load data from service
//    self.tecentEngine.expireTime = [service.expirationDate timeIntervalSince1970];
//    self.tecentEngine.accessToken = service.accessToken;
//    self.tecentEngine.refreshToken = service.refreshToken;
//    self.tecentEngine.openId = service.userId;
    
    return self;
}

- (void)login
{
    [_tecentEngine logInWithDelegate:self
                         onSuccess:@selector(onSuccessLogin)
                         onFailure:@selector(onFailureLogin:)];
}

- (void)logout
{
    [_tecentEngine logOut];
}

- (BOOL)isAuthorizeExpired
{
    if (_tecentEngine.expireTime == 0)
        return YES;

    return [_tecentEngine isAuthorizeExpired];
}

- (void)readUserInfo:(NSString*)userId
{
    [_tecentEngine getUserInfoWithFormat:@"json"
                        parReserved:nil
                           delegate:self
                          onSuccess:@selector(readUserInfoSuccessCallBack:)
                          onFailure:@selector(readUserInfoFailureCallBack:)];        
}

#define TEST_IP @"192.168.1.198"    

- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    [self setAction:SNS_ACTION_PUBLISH_WEIBO];
    
    if (imageFilePath != nil){
        NSData *data = [NSData dataWithContentsOfFile:imageFilePath];
        [_tecentEngine postPictureTweetWithFormat:@"json"
                                     content:text
                                    clientIP:TEST_IP
                                         pic:data
                              compatibleFlag:@"0"
                                   longitude:nil
                                 andLatitude:nil
                                 parReserved:nil
                                    delegate:self
                                   onSuccess:@selector(successGeneralCallback:)
                                   onFailure:@selector(failureGeneralCallback:)];
    }
    else{
        // TEXT
        [_tecentEngine postTextTweetWithFormat:@"json"
                                  content:text
                                 clientIP:TEST_IP
                                longitude:nil
                              andLatitude:nil
                              parReserved:nil
                                 delegate:self
                                onSuccess:@selector(successGeneralCallback:)
                                onFailure:@selector(failureGeneralCallback:)];
    }
}

- (void)followUser:(NSString*)nickName userId:(NSString*)userId successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    [_tecentEngine addFriendsWithFormat:@"json"
                             names:userId
                        andOpenIDs:nil
                       parReserved:nil
                          delegate:self
                         onSuccess:@selector(successGeneralCallback:)
                         onFailure:@selector(failureGeneralCallback:)];
}

#pragma mark - Delegate Callback

- (void)onSuccessLogin
{
    PPDebug(@"<onSuccessLogin>");
    
    // set data and store
    self.service.accessToken = _tecentEngine.accessToken;
    self.service.expirationDate = [NSDate dateWithTimeIntervalSince1970:_tecentEngine.expireTime];
    self.service.refreshToken = _tecentEngine.refreshToken;
    self.service.userId = _tecentEngine.name;
    self.service.qqOpenId = _tecentEngine.openId;
    
    [[PPSNSStorageService defaultService] storeAuthData:self.service];
    
    if (self.successBlock != NULL){
        self.successBlock(nil);
    }
    
    [self removeFromService];
}

- (void)onFailureLogin:(NSError *)error
{
    PPDebug(@"<onFailureLogin> error=%@", [error description]);
    if (self.failureBlock != NULL){
        self.failureBlock(error);
    }
    
    [self removeFromService];    
}

- (void)readUserInfoSuccessCallBack:(id)result{
    PPDebug(@"<readUserInfoSuccessCallBack> result=%@", [result description]);
    
    NSDictionary* resultDict = (NSDictionary*)result;
    int errorCode = [[resultDict objectForKey:@"errcode"] intValue];
    if (errorCode != 0){
        if (self.failureBlock != NULL){
            self.failureBlock([NSError errorWithDomain:@"Read User Info Error" code:errorCode userInfo:nil]);
        }
        
        [self removeFromService];
        return;
    }    
    
    NSDictionary* origUserInfo = [resultDict objectForKey:@"data"];
    NSMutableDictionary *retDict = [NSMutableDictionary dictionary];
    
    if ([[origUserInfo allKeys] count] == 0){
        if (self.failureBlock != NULL){
            self.failureBlock([NSError errorWithDomain:@"Read User Info Data Null" code:ERROR_SNS_USER_NO_DATA userInfo:nil]);
        }
        
        [self removeFromService];
        return;
    }
    
    [retDict setObject:SNS_QQ_WEIBO forKey:SNS_NETWORK];
    
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"name" toKey:SNS_USER_ID];
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"nick" toKey:SNS_NICK_NAME];
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"province_code" toKey:SNS_PROVINCE];
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"city_code" toKey:SNS_CITY];
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"location" toKey:SNS_LOCATION];
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"name" toKey:SNS_DOMAIN];
    
    NSString *gender = [origUserInfo objectForKey:@"sex"];
    if (gender){
        NSString* genderValue = ([gender intValue] == 1) ? @"m" : @"f";
        [retDict setObject:genderValue forKey:SNS_GENDER];
    }
    
    int day = [[origUserInfo objectForKey:@"birth_day"] intValue];
    int month = [[origUserInfo objectForKey:@"birth_month"] intValue];
    int year = [[origUserInfo objectForKey:@"birth_year"] intValue];
    if (year && month && day){
        NSString *birthday = [NSString stringWithFormat:@"%d-%02d-%02d", year, month, day];
        [retDict setObject:birthday forKey:SNS_BIRTHDAY];
    }
    
    NSString *avatar = [origUserInfo objectForKey:@"head"];
    if (avatar && [avatar length] > 0){
        avatar = [NSString stringWithFormat:@"%@/%d", avatar, 100];
        [retDict setObject:avatar forKey:SNS_USER_IMAGE_URL];
    }

    // set auth information
    if ([_tecentEngine refreshToken]){
        [retDict setObject:[_tecentEngine refreshToken] forKey:SNS_REFRESH_TOKEN];
    }
    [retDict setObject:[_tecentEngine accessToken] forKey:SNS_OAUTH_TOKEN];
    [retDict setObject:[NSDate dateWithTimeIntervalSince1970:[_tecentEngine expireTime]] forKey:SNS_EXPIRATION_DATE];
    [retDict setObject:[_tecentEngine openId] forKey:SNS_QQ_OPEN_ID];
    
    if (self.successBlock != NULL){
        self.successBlock(retDict);
    }
    
    [self removeFromService];
}

- (void)readUserInfoFailureCallBack:(NSError *)error{
    PPDebug(@"<readUserInfoFailureCallBack> error=%@", [error description]);
    if (self.failureBlock != NULL){
        self.failureBlock(error);
    }
    
    [self removeFromService];
}


- (void)successGeneralCallback:(id)result
{
    PPDebug(@"<successGeneralCallback> result=%@", [result description]);
    if (self.successBlock != NULL){
        self.successBlock(nil);
    }
    
    [self removeFromService];
}

- (void)failureGeneralCallback:(NSError *)error{
    PPDebug(@"<failureGeneralCallback> error=%@", [error description]);
    if (self.failureBlock != NULL){
        self.failureBlock(error);
    }
    
    [self removeFromService];
}


@end
