//
//  PPSinaWeiboRequest.h
//  Draw
//
//  Created by qqn_pipi on 12-11-16.
//
//

#import <Foundation/Foundation.h>
#import "PPSNSCommonRequest.h"
#import "SinaWeibo.h"

@interface PPSinaWeiboRequest : PPSNSCommonRequest<SinaWeiboDelegate, SinaWeiboRequestDelegate>

@property (nonatomic, retain) SinaWeibo *sinaWeibo;

//+ (NSString*)snsUserId;
//+ (BOOL)isLogin;

@end
