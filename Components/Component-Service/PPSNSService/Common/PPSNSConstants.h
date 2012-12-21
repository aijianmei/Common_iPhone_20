//
//  PPSNSConstants.h
//  Draw
//
//  Created by qqn_pipi on 12-11-16.
//
//

#ifndef Draw_PPSNSConstants_h
#define Draw_PPSNSConstants_h

typedef enum {
    ERROR_SNS_SUCCESS = 0,
    ERROR_SNS_USERID_NULL,
    ERROR_SNS_LOGIN_CANCEL,
    ERROR_SNS_USER_NO_DATA,
    ERROR_SNS_SESSION_INVALID,
    ERROR_SNS_TEXT_IMAGE_NULL,
    ERROR_SNS_NICK_NAME_NULL,
    ERROR_SNS_IMAGE_PATH_NOT_EXIST,
} SNS_ERROR_CODE;

typedef enum {
    SNS_ACTION_GET_USER_INFO,
    SNS_ACTION_PUBLISH_WEIBO,
    SNS_ACTION_FOLLOW_USER,
    ERROR_SNS_ACTION_NOT_SUPPORT,
} PPSNSAction;


#define SNS_NETWORK             @"SNS_NETWORK"
#define SNS_USER_ID             @"SNS_USER_ID"
#define SNS_DOMAIN              @"SNS_DOMAIN"
#define SNS_GENDER              @"SNS_GENDER"
#define SNS_PROVINCE            @"SNS_PROVINCE"
#define SNS_CITY                @"SNS_CITY"
#define SNS_LOCATION            @"SNS_LOCATION"
#define SNS_USER_IMAGE_URL      @"SNS_USER_IMAGE_URL"
#define SNS_BIRTHDAY            @"SNS_BIRTHDAY"
#define SNS_NICK_NAME           @"SNS_NICK_NAME"
#define SNS_OAUTH_TOKEN         @"SNS_OAUTH_TOKEN"
#define SNS_OAUTH_TOKEN_SECRET  @"SNS_OAUTH_TOKEN_SECRET"

#define SNS_EXPIRATION_DATE     @"SNS_EXPIRATION_DATE"
#define SNS_REFRESH_TOKEN       @"SNS_REFRESH_TOKEN"
#define SNS_QQ_OPEN_ID          @"SNS_QQ_OPEN_ID"


#define SNS_SINA_WEIBO          @"SINA"
#define SNS_QQ_WEIBO            @"QQ"
#define SNS_FACEBOOK            @"Facebook"
#define SNS_TWITTER             @"TWitter"

typedef enum {
    TYPE_EMAIL   = 1,
    TYPE_SINA    = 2,
    TYPE_QQ      = 3,
    TYPE_RENREN  = 4,
    TYPE_FACEBOOK = 5,
    TYPE_TWITTER  = 6,
} PPSNSType;

#endif
