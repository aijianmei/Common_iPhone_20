//
//  PPDataConstants.h
//  Draw
//
//  Created by qqn_pipi on 12-11-30.
//
//

#ifndef Draw_PPDataConstants_h
#define Draw_PPDataConstants_h


typedef enum {
    SMART_DATA_ERROR_SUCCESS = 0,
    SMART_DATA_PROCESS_ERROR,
} PPDataErrorCode;

#define DEFAULT_SMART_DATA_HTTP_USER_NAME  @"gancheng"
#define DEFAULT_SMART_DATA_HTTP_PASSWORD   @"gancheng123^&*"

// TODO read URL from config
#define SMART_DATA_SERVER_URL                   @"http://58.215.160.100:8080/app_res/smart_data/"

#endif
