//
//  PPFacebookRequest.m
//  Draw
//
//  Created by qqn_pipi on 12-11-17.
//
//

#import "PPFacebookRequest.h"
#import "PPSNSConstants.h"
#import "PPSNSStorageService.h"

@implementation PPFacebookRequest

- (void)dealloc
{
    [_facebook release];
    [super dealloc];
}

- (id)initWithService:(PPSNSCommonService*)service
         successBlock:(PPSNSSuccessBlock)successBlock
         failureBlock:(PPSNSFailureBlock)failureBlock
{
    self = [super initWithService:service
                     successBlock:successBlock
                     failureBlock:failureBlock];
    
    self.facebook = [[[Facebook alloc] initWithAppId:service.appKey andDelegate:self] autorelease];    
    
    // load data
    _facebook.accessToken = service.accessToken;
    _facebook.expirationDate = service.expirationDate;    
    return self;
}

- (BOOL)isAuthorizeExpired
{
    return ([_facebook isSessionValid] == NO);
}

- (void)login
{
    [_facebook authorize:[NSArray arrayWithObjects:@"publish_actions", @"publish_stream", nil]];
}

- (void)logout
{
    [_facebook logout];
}


- (void)readUserInfo:(NSString*)userId
{
    // note: userId is NOT used yet!!!! only read user's own information
    
    [self setAction:SNS_ACTION_GET_USER_INFO];
    
    // Using the "pic" picture since this currently has a maximum width of 100 pixels
    // and since the minimum profile picture size is 180 pixels wide we should be able
    // to get a 100 pixel wide version of the profile picture
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"SELECT uid, name, sex, pic, first_name FROM user WHERE uid=me()", @"query",
                                   nil];
    [_facebook requestWithMethodName:@"fql.query"
                           andParams:params
                       andHttpMethod:@"POST"
                         andDelegate:self];    
}

- (void)publishWeibo:(NSString*)text imageFilePath:(NSString*)imageFilePath successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    [self setAction:SNS_ACTION_PUBLISH_WEIBO];
        
    if (imageFilePath != nil){
        // TEXT & IMAGE
        NSData* data = [NSData dataWithContentsOfFile:imageFilePath];        
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       text, @"message",
                                       data, @"source",
                                       nil];
        
        [[self facebook] requestWithGraphPath:@"me/photos"
                                    andParams:params
                                andHttpMethod:@"POST"
                                  andDelegate:self];
    }
    else{
        // TEXT
        NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                       text, @"message",
                                       nil];
        
        [[self facebook] requestWithGraphPath:@"me/feed"
                                    andParams:params
                                andHttpMethod:@"POST"
                                  andDelegate:self];
    }
}

- (void)followUser:(NSString*)nickName userId:(NSString*)userId successBlock:(PPSNSSuccessBlock)successBlock failureBlock:(PPSNSFailureBlock)failureBlock
{
    PPDebug(@"Facebook Follow User Not Supported Yet");
    if (failureBlock != NULL){
        failureBlock([NSError errorWithDomain:@"Follow Not Support" code:ERROR_SNS_ACTION_NOT_SUPPORT userInfo:nil]);
    }
}


- (void)handleOpenURL:(NSURL*)url
{
    [_facebook handleOpenURL:url];    
}


#pragma mark - Facebook Session Delegate

- (void)fbDidLogin
{
    PPDebug(@"<fbDidLogin>");
    
    // save token and key
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    [defaults setObject:[_facebook accessToken] forKey:@"FBAccessTokenKey"];
//    [defaults setObject:[_facebook expirationDate] forKey:@"FBExpirationDateKey"];
//    [defaults synchronize];
    
    // set data and store
    self.service.accessToken = _facebook.accessToken;
    self.service.expirationDate = _facebook.expirationDate;
    self.service.userId = @"facebook_temp_user_id";                         // store a temp string
    [[PPSNSStorageService defaultService] storeAuthData:self.service];
    
    if (self.successBlock != NULL){
        self.successBlock(nil);
    }
    
    [self removeFromService];
}

/**
 * Called when the user dismissed the dialog without logging in.
 */
- (void)fbDidNotLogin:(BOOL)cancelled
{
    PPDebug(@"<fbDidNotLogin> login cancel");
    if (self.failureBlock != NULL){
        self.failureBlock([NSError errorWithDomain:@"Facebook Login Cancel" code:ERROR_SNS_LOGIN_CANCEL userInfo:nil]);
    }
    
    [self removeFromService];
}

/**
 * Called after the access token was extended. If your application has any
 * references to the previous access token (for example, if your application
 * stores the previous access token in persistent storage), your application
 * should overwrite the old access token with the new one in this method.
 * See extendAccessToken for more details.
 */
- (void)fbDidExtendToken:(NSString*)accessToken
               expiresAt:(NSDate*)expiresAt
{
    PPDebug(@"<fbDidExtendToken> accessToke=%@, expireAt=%@", accessToken, expiresAt);
    self.service.accessToken = _facebook.accessToken;
    self.service.expirationDate = _facebook.expirationDate;
    [[PPSNSStorageService defaultService] storeAuthData:self.service];
    
    if (self.successBlock != NULL){
        self.successBlock(nil);
    }
    
    [self removeFromService];

}

/**
 * Called when the user logged out.
 */
- (void)fbDidLogout
{
    PPDebug(@"<fbDidLogout>");
    
    [[PPSNSStorageService defaultService] removeAuthData:self.service];
    
    if (self.successBlock != NULL){
        self.successBlock(nil);
    }
    
    [self removeFromService];
}

/**
 * Called when the current session has expired. This might happen when:
 *  - the access token expired
 *  - the app has been disabled
 *  - the user revoked the app's permissions
 *  - the user changed his or her password
 */
- (void)fbSessionInvalidated
{
    PPDebug(@"<fbSessionInvalidated>");
    if (self.failureBlock != NULL){
        self.failureBlock([NSError errorWithDomain:@"Facebook Session Invalid" code:ERROR_SNS_SESSION_INVALID userInfo:nil]);
    }
    
    [self removeFromService];
}

#pragma mark - FBRequestDelegate Methods
/**
 * Called when the Facebook API request has returned a response.
 *
 * This callback gives you access to the raw response. It's called before
 * (void)request:(FBRequest *)request didLoad:(id)result,
 * which is passed the parsed response object.
 */
- (void)request:(FBRequest *)request didReceiveResponse:(NSURLResponse *)response {
    PPDebug(@"<didReceiveResponse>");
}

/**
 * Called when a request returns and its response has been parsed into
 * an object.
 *
 * The resulting object may be a dictionary, an array or a string, depending
 * on the format of the API response. If you need access to the raw response,
 * use:
 *
 * (void)request:(FBRequest *)request
 *      didReceiveResponse:(NSURLResponse *)response
 */

- (NSMutableDictionary*)parseUserInfo:(NSDictionary*)origUserInfo
{
    NSMutableDictionary *retDict = [NSMutableDictionary dictionary];
    
    [retDict setObject:SNS_FACEBOOK forKey:SNS_NETWORK];
    
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"uid" toKey:SNS_USER_ID];
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"first_name" toKey:SNS_NICK_NAME];
    [self safeSetKeyFrom:origUserInfo toDict:retDict fromKey:@"pic" toKey:SNS_USER_IMAGE_URL];
    
    [retDict setObject:[_facebook accessToken] forKey:SNS_OAUTH_TOKEN];
    [retDict setObject:[_facebook expirationDate] forKey:SNS_EXPIRATION_DATE];
    
    // store user id here
    NSString* userId = [origUserInfo objectForKey:@"uid"];
    if ([userId length] > 0){
        [self.service setUserId:userId];
        [[PPSNSStorageService defaultService] storeAuthData:self.service];
    }
    
    NSString* sex = [origUserInfo objectForKey:@"sex"];
    if ([sex length] > 0){
        NSString* value = nil;
        if ([sex isEqualToString:@"male"]){
            value = @"m";
        }
        else if ([sex isEqualToString:@"female"]){
            value = @"f";
        }
        
        if (value){
            [retDict setObject:value forKey:SNS_GENDER];
        }
    }
    
    return retDict;
}


- (void)request:(FBRequest *)request didLoad:(id)result {
    PPDebug(@"FBRequest <didLoad> result = %@", result);
//    
//    if (_action == ACTION_GET_USER_INFO){
//        [self.displayViewController hideActivity];
//    }
//    
//    if ([result isKindOfClass:[NSArray class]]) {
//        result = [result objectAtIndex:0];
//        NSDictionary* userInfo = [self parseUserInfo:result];
//        if (_action == ACTION_GET_USER_INFO){
//            if ([_displayViewController respondsToSelector:@selector(didLogin:userInfo:)]){
//                [_displayViewController didLogin:0 userInfo:userInfo];
//            }
//            
//        }
//    }
    
    if (self.action == SNS_ACTION_GET_USER_INFO){
        if ([result isKindOfClass:[NSArray class]]) {
            result = [result objectAtIndex:0];
            NSDictionary* userInfo = [self parseUserInfo:result];
            if (self.successBlock != NULL){
                self.successBlock(userInfo);
            }
        }
        else{
            if (self.failureBlock != NULL){
                self.failureBlock([NSError errorWithDomain:@"Facebook Read User Info NULL" code:ERROR_SNS_USER_NO_DATA userInfo:nil]);
            }                        
        }
    }
    else{
        if (self.successBlock != NULL){
            self.successBlock(nil);
        }        
    }
    
    [self removeFromService];
}

/**
 * Called when an error prevents the Facebook API request from completing
 * successfully.
 */
- (void)request:(FBRequest *)request didFailWithError:(NSError *)error {
    PPDebug(@"<didFailWithError> Err code: %d message: %@ ", [error code], [[error userInfo] objectForKey:@"error_msg"]);
    if (self.failureBlock != NULL){
        self.failureBlock(error);
    }
    
    [self removeFromService];
}

@end
