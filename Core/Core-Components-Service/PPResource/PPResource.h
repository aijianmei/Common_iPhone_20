//
//  PPResource.h
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#ifndef Draw_PPResource_h
#define Draw_PPResource_h

#define DEFAULT_HTTP_USER_NAME  @"gancheng"
#define DEFAULT_HTTP_PASSWORD   @"gancheng123^&*"

typedef void(^PPResourceServiceDownloadSuccessBlock)(BOOL alreadyExisted);
typedef void(^PPResourceServiceDownloadFailureBlock)(NSError *error, UIView* downloadView);

#define PP_RESOURCE_PROGRESS_VIEW_TAG   20121104

#define PP_RESOURCE_DOWNLOAD_URL        @"http://58.215.160.100:8080"
#define PP_RESOURCE_DOWNLOAD_URL_KEY    @"RESOURCE_URL"

#endif
