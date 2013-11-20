//
//  PPSinaWeiboRequest.m
//  Draw
//
//  Created by qqn_pipi on 12-11-16.
//
//

#import "PPSinaWeiboRequest.h"
#import "PPSNSConstants.h"
#import "PPDebug.h"
#import "PPSNSStorageService.h"

#define SINA_COMMAND_GET_USER_INFO   @"users/show.json"

@implementation PPSinaWeiboRequest

- (void)dealloc
{
    [_sinaWeibo release];
    [super dealloc];
}

- (id)initWithService:(PPSNSCommonService*)service
         successBlock:(PPSNSSuccessBlock)successBlock
         failureBlock:(PPSNSFailureBlock)failureBlock
{
    self = [super initWithService:service
                    successBlock:successBlock
                    failureBlock:failureBlock];
    
    _sinaWeibo = [[SinaWeibo alloc] initWithAppKey:service.appKey
                                         appSecret:service.appSecret
                                    appRedirectURI:service.appRedirectURI
                                       andDelegate:self];

    // load data
    _sinaWeibo.accessToken = service.accessToken;
    _sinaWeibo.refreshToken = service.refreshToken;
    _sinaWeibo.userID = service.userId;
    _sinaWeibo.expirationDate = service.expirationDate;
    return self;
}

- (void)login
{
    [_sinaWeibo logIn];
}

- (void)logout
{
    [_sinaWeibo logOut];
}

- (BOOL)isAuthorizeExpired
{
    if (_sinaWeibo.expirationDate == nil)
        return YES;
    
    return [_sinaWeibo isAuthorizeExpired];
}

- (void)readUserInfo:(NSString*)userId
{
    [_sinaWeibo requestWithURL:SINA_COMMAND_GET_USER_INFO
                       params:[NSMutableDictionary dictionaryWithObject:userId forKey:@"uid"]
                   httpMethod:@"GET"
                     delegate:self];
    
}

- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    [self setAction:SNS_ACTION_PUBLISH_WEIBO];
    
    if (imageFilePath != nil){
        // post TEXT + IMAGE 
        NSData *data = [NSData dataWithContentsOfFile:imageFilePath];        
        [_sinaWeibo requestWithURL:@"statuses/upload.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   text, @"status",
                                   data, @"pic", nil]
                       httpMethod:@"POST"
                         delegate:self];
    }
    else{
        // post TEXT
        [_sinaWeibo requestWithURL:@"statuses/update.json"
                           params:[NSMutableDictionary dictionaryWithObjectsAndKeys:text, @"status", nil]
                       httpMethod:@"POST"
                         delegate:self];
    }
    

}

- (void)followUser:(NSString*)nickName userId:(NSString*)userId successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{    
    [_sinaWeibo requestWithURL:@"friendships/create.json"
                        params:[NSMutableDictionary dictionaryWithObjectsAndKeys:nickName, @"screen_name", nil]
                    httpMethod:@"POST"
                      delegate:self];
}

- (void)handleOpenURL:(NSURL*)url
{
    [_sinaWeibo handleOpenURL:url];
    
}
#pragma mark - Sina Weibo Delegate

- (void)sinaweiboDidLogIn:(SinaWeibo *)sinaweibo
{
    PPDebug(@"<sinaweiboDidLogIn>");
    
    // set data and store
    self.service.accessToken = _sinaWeibo.accessToken;
    self.service.expirationDate = _sinaWeibo.expirationDate;
    self.service.refreshToken = _sinaWeibo.refreshToken;
    self.service.userId = _sinaWeibo.userID;
    [[PPSNSStorageService defaultService] storeAuthData:self.service];

    if (self.successBlock != NULL){
        self.successBlock(nil);
    }
    
    [self removeFromService];
}

- (void)sinaweiboDidLogOut:(SinaWeibo *)sinaweibo
{
    PPDebug(@"<sinaweiboDidLogOut>");

    [[PPSNSStorageService defaultService] removeAuthData:self.service];
    
    if (self.successBlock != NULL){
        self.successBlock(nil);
    }

    [self removeFromService];
}

- (void)sinaweiboLogInDidCancel:(SinaWeibo *)sinaweibo
{
    PPDebug(@"<sinaweiboLogInDidCancel>");
    if (self.failureBlock != NULL){
        self.failureBlock([NSError errorWithDomain:@"sinaweiboLogInDidCancel" code:ERROR_SNS_LOGIN_CANCEL userInfo:nil]);
    }
    
    [self removeFromService];
    
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo logInDidFailWithError:(NSError *)error
{
    PPDebug(@"<logInDidFailWithError> error=%@", [error description]);
    if (self.failureBlock != NULL){
        self.failureBlock(error);
    }
    
    [self removeFromService];
    
}

- (void)sinaweibo:(SinaWeibo *)sinaweibo accessTokenInvalidOrExpired:(NSError *)error
{
    PPDebug(@"<accessTokenInvalidOrExpired> error=%@", [error description]);
    if (self.failureBlock != NULL){
        self.failureBlock(error);
    }
    
    [self removeFromService];
}

#pragma mark - Weibo Request Delegate

- (void)request:(SinaWeiboRequest *)request didReceiveResponse:(NSURLResponse *)response
{
    
}

- (void)request:(SinaWeiboRequest *)request didReceiveRawData:(NSData *)data
{
    
}

- (void)request:(SinaWeiboRequest *)request didFailWithError:(NSError *)error
{
    PPDebug(@"<didFailWithError> error=%@", [error description]);
    if (self.failureBlock != NULL){
        self.failureBlock(error);
    }
    
    [self removeFromService];    
}

- (void)request:(SinaWeiboRequest *)request didFinishLoadingWithResult:(id)result
{
    PPDebug(@"<didFinishLoadingWithResult> result=%@", [result description]);
    if ([request.url hasSuffix:SINA_COMMAND_GET_USER_INFO]){
        
        NSMutableDictionary *retDict = [NSMutableDictionary dictionary];
        
        [retDict setObject:SNS_SINA_WEIBO forKey:SNS_NETWORK];
        
        [self safeSetKeyFrom:result toDict:retDict fromKey:@"id" toKey:SNS_USER_ID];
        [self safeSetKeyFrom:result toDict:retDict fromKey:@"screen_name" toKey:SNS_NICK_NAME];
        [self safeSetKeyFrom:result toDict:retDict fromKey:@"domain" toKey:SNS_DOMAIN];
        [self safeSetKeyFrom:result toDict:retDict fromKey:@"gender" toKey:SNS_GENDER];
        [self safeSetKeyFrom:result toDict:retDict fromKey:@"province" toKey:SNS_PROVINCE];
        [self safeSetKeyFrom:result toDict:retDict fromKey:@"city" toKey:SNS_CITY];
        [self safeSetKeyFrom:result toDict:retDict fromKey:@"location" toKey:SNS_LOCATION];
        [self safeSetKeyFrom:result toDict:retDict fromKey:@"profile_image_url" toKey:SNS_USER_IMAGE_URL];
        
        [retDict setObject:[_sinaWeibo accessToken] forKey:SNS_OAUTH_TOKEN];
        [retDict setObject:[_sinaWeibo expirationDate] forKey:SNS_EXPIRATION_DATE];

        if ([_sinaWeibo refreshToken])
            [retDict setObject:[_sinaWeibo refreshToken] forKey:SNS_REFRESH_TOKEN];
        
        if (self.successBlock != NULL){
            self.successBlock(retDict);
        }
    }
    else{
        if (self.successBlock != NULL){
            self.successBlock(nil);
        }        
    }
    
    [self removeFromService];
}



@end
