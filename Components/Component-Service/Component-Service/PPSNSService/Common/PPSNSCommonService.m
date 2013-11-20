//
//  PPSNSCommonService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-16.
//
//

#import "PPSNSCommonService.h"
#import "PPSNSCommonRequest.h"
#import "PPSNSStorageService.h"
#import "PPSNSConstants.h"
#import "FileUtil.h"

@implementation PPSNSCommonService

- (void)dealloc
{
    PPRelease(_appRedirectURI);
    PPRelease(_appSecret);
    PPRelease(_appKey);
    PPRelease(_queue);
    PPRelease(_requestArray);
    PPRelease(_currentWeiboRequest);
    PPRelease(_expirationDate);
    PPRelease(_accessToken);
    PPRelease(_refreshToken);
    PPRelease(_userId);
    PPRelease(_qqOpenId);
    PPRelease(_followAlertView);
    PPRelease(_followWeiboId);
    PPRelease(_officialWeiboId);
    [super dealloc];
}

- (id)initWithAppKey:(NSString*)appKey
           appSecret:(NSString*)appSecret
      appRedirectURI:(NSString*)appRedirectURI
     officialWeiboId:(NSString*)officialWeiboId
{
    
    self = [super init];

    PPDebug(@"Start to Init %@ Service. AppKey(%@) Secret(%@) redirectURI(%@) officialWeiboId(%@)",
            [self snsName], appKey, appSecret, appRedirectURI, officialWeiboId);
    
    self.appKey = appKey;
    self.appSecret = appSecret;
    self.appRedirectURI = appRedirectURI;
    self.officialWeiboId = officialWeiboId;

    _requestArray = [[NSMutableArray alloc] init];
    _queue = [[NSOperationQueue alloc] init];
    _snsType = [self getSNSType];
    
    [[PPSNSStorageService defaultService] loadAuthData:self];
    
    _currentWeiboRequest = [self createRequestWithService:self successBlock:nil failureBlock:nil];    

    PPDebug(@"Init %@ Service Completed", [self snsName]);
    return self;
}

- (PPSNSCommonRequest*)createRequestWithService:(PPSNSCommonService*)service
                  successBlock:(PPSNSSuccessBlock)successBlock
                  failureBlock:(PPSNSFailureBlock)failureBlock
{
    PPDebug(@"WARNNING ======= createRequestWithService NOT OVERRIDED ==============");
    return nil;
}

- (int)getSNSType
{
    PPDebug(@"WARNNING ======= getSNSType NOT OVERRIDED ==============");
    return 0;
}

- (void)handleOpenURL:(NSURL*)url
{
    PPDebug(@"WARNNING ======= handleOpenURL NOT OVERRIDED ==============");
}

- (NSString*)storageKeyPrefix
{
    PPDebug(@"WARNNING ======= storageKeyPrefix NOT OVERRIDED ==============");
    return nil;
}

- (NSString*)snsName
{
    PPDebug(@"WARNNING ======= snsName NOT OVERRIDED ==============");
    return nil;    
}

- (void)addRequest:(PPSNSCommonRequest*)request
{
    PPDebug(@"%@ Add Request %@", [self snsName], [request description]);
    [self.requestArray addObject:request];
}

- (void)removeRequest:(PPSNSCommonRequest*)request
{
    PPDebug(@"%@ Remove Request %@", [self snsName], [request description]);
    [self.requestArray removeObject:request];
    if (self.currentWeiboRequest == request){
        self.currentWeiboRequest = nil;
    }
}

- (void)login:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    
    PPDebug(@"%@ Login", [self snsName]);
    PPSNSCommonRequest* request = [self createRequestWithService:self
                                                    successBlock:successBlock
                                                    failureBlock:failureBlock];
    request.action = SNS_ACTION_LOGIN;
    
    self.currentWeiboRequest = request;
    [self addRequest:request];
    [request login];
    [request release];
}

- (void)logout
{

    
    PPDebug(@"%@ logout", [self snsName]);    
    PPSNSCommonRequest* request = [self createRequestWithService:self
                                                    successBlock:NULL
                                                    failureBlock:NULL];
    
    request.action = SNS_ACTION_LOGOUT;
    
    [request logout];
    [[PPSNSStorageService defaultService] removeAuthData:self];
    [request release];
}

- (void)readUserInfo:(NSString*)userId successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    PPDebug(@"%@ read User Info", [self snsName]);    
    if (userId == nil){
        failureBlock([NSError errorWithDomain:@"SNS Error" code:ERROR_SNS_USERID_NULL userInfo:nil]);
        return;
    }
    
    PPSNSCommonRequest* request = [self createRequestWithService:self
                                                    successBlock:successBlock
                                                    failureBlock:failureBlock];
    
    request.action = SNS_ACTION_GET_USER_INFO;
    
    self.currentWeiboRequest = request;
    [self addRequest:request];
    [request readUserInfo:userId];
    [request release];
    
}

- (void)readMyUserInfo:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    NSString* userId = [self snsUserId];
    [self readUserInfo:userId successBlock:successBlock failureBlock:failureBlock];
}


- (void)publishWeibo:(NSString*)text successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    PPDebug(@"%@ publish Weibo", [self snsName]);    
    [self publishWeibo:text imageFilePath:nil successBlock:successBlock failureBlock:failureBlock];
}

- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    PPDebug(@"%@ publish Weibo", [self snsName]);    
    if (text == nil && imageFilePath == nil){
        failureBlock([NSError errorWithDomain:@"SNS Error" code:ERROR_SNS_TEXT_IMAGE_NULL userInfo:nil]);
        return;
    }
    
    if (imageFilePath != nil && [[NSFileManager defaultManager] fileExistsAtPath:imageFilePath] == NO){
        failureBlock([NSError errorWithDomain:@"SNS Error" code:ERROR_SNS_IMAGE_PATH_NOT_EXIST userInfo:nil]);
        return;        
    }
    
    PPSNSCommonRequest* request = [self createRequestWithService:self
                                                    successBlock:successBlock
                                                    failureBlock:failureBlock];
    
    request.action = SNS_ACTION_PUBLISH_WEIBO;
    
    self.currentWeiboRequest = request;
    [self addRequest:request];
    [request publishWeibo:text imageFilePath:imageFilePath successBlock:successBlock failureBlock:failureBlock];
    [request release];    
}

// follow operation
- (void)followUser:(NSString*)nickName userId:(NSString*)userId successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    PPDebug(@"%@ followUser", [self snsName]);    
    if (nickName == nil && userId == nil){
        failureBlock([NSError errorWithDomain:@"SNS Error" code:ERROR_SNS_NICK_NAME_NULL userInfo:nil]);
        return;
    }
    
    PPSNSCommonRequest* request = [self createRequestWithService:self
                                                    successBlock:successBlock
                                                    failureBlock:failureBlock];
    
    
    request.action = SNS_ACTION_FOLLOW_USER;

    self.currentWeiboRequest = request;
    [self addRequest:request];
    [request followUser:nickName userId:userId  successBlock:successBlock failureBlock:failureBlock];
    [request release];
}

- (BOOL)isAuthorizeExpired
{
    PPSNSCommonRequest* request = [self createRequestWithService:self
                                                    successBlock:NULL
                                                    failureBlock:NULL];
   
    BOOL result = [request isAuthorizeExpired];
    [request release];
    return result;
}

- (void)saveAccessToken:(NSString*)accessToken
           refreshToken:(NSString*)refreshToken
             expireDate:(NSDate*)expireDate
                 userId:(NSString*)userId
               qqOpenId:(NSString*)qqOpenId
{
    [self setAccessToken:accessToken];
    [self setRefreshToken:refreshToken];
    [self setExpirationDate:expireDate];
    [self setUserId:userId];
    [self setQqOpenId:qqOpenId];
    
    [[PPSNSStorageService defaultService] storeAuthData:self];
}


- (NSString*)snsUserId
{
    return [[PPSNSStorageService defaultService] snsUserId:self];
}

- (BOOL)isLogin
{
    return [[PPSNSStorageService defaultService] isLogin:self];    
}

// for follow user
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 1:
            [self followUser:_followWeiboId
                      userId:_followWeiboId
                successBlock:self.followSuccessBlock
                failureBlock:self.followFailureBlock];
            
            break;
            
        default:
            break;
    }
    
    self.followAlertView = nil;
    self.followWeiboId = nil;
             
    if (_followSuccessBlock != NULL){
        Block_release(_followSuccessBlock);
        self.followSuccessBlock = NULL;
    }

    if (_followFailureBlock != NULL){
        Block_release(_followFailureBlock);
        self.followFailureBlock = NULL;
    }
}

- (void)askFollowWithTitle:(NSString*)displayTitle
              displayMessage:(NSString*)displayMessage
                     weiboId:(NSString*)weiboId
                successBlock:(PPSNSSuccessBlock)successBlock
                failureBlock:(PPSNSFailureBlock)failureBlock
{
    self.followWeiboId = weiboId;
    
    if (_followSuccessBlock != NULL){
        Block_release(_followSuccessBlock);
        self.followSuccessBlock = NULL;
    }

    if (_followFailureBlock != NULL){
        Block_release(_followFailureBlock);
        self.followFailureBlock = NULL;
    }
        
    if (successBlock != NULL){
        self.followSuccessBlock = Block_copy(successBlock);
    }
    
    if (failureBlock != NULL){
        self.followFailureBlock = Block_copy(failureBlock);
    }
    
    self.followAlertView = [[[UIAlertView alloc] initWithTitle:displayTitle //@"关注猜猜画画吗"
                                                 message:displayMessage //@"关注和收听官方微博"
                                                delegate:self
                                       cancelButtonTitle:@"不需要"
                                       otherButtonTitles:@"我试下", nil] autorelease];
    [_followAlertView show];
}

- (BOOL)supportFollow
{
    return NO;
}



@end