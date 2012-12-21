//
//  PPFacebookRequest.h
//  Draw
//
//  Created by qqn_pipi on 12-11-17.
//
//

#import <Foundation/Foundation.h>
#import "PPSNSCommonRequest.h"
#import "FBConnect.h"
#import "PPSNSConstants.h"

@interface PPFacebookRequest : PPSNSCommonRequest<FBSessionDelegate, FBRequestDelegate>

@property (nonatomic, retain) Facebook *facebook;

@end
