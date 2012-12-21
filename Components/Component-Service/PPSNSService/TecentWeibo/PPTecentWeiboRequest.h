//
//  PPTecentWeiboRequest.h
//  Draw
//
//  Created by qqn_pipi on 12-11-17.
//
//

#import <Foundation/Foundation.h>
#import "PPSNSCommonRequest.h"

@class TCWBEngine;

@interface PPTecentWeiboRequest : PPSNSCommonRequest

@property (nonatomic, retain) TCWBEngine *tecentEngine;

@end
