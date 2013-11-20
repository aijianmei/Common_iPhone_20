//
//  GoogleCustomSearchNetworkRequest.h
//  Draw
//
//  Created by Kira on 13-6-4.
//
//

#import <Foundation/Foundation.h>

@class CommonNetworkOutput;

@interface GoogleCustomSearchNetworkRequest : NSObject
+ (CommonNetworkOutput*)searchImage:(NSString*)baseURL
                               text:(NSString*)text
                          imageSize:(CGSize)size
                          startPage:(int)startPage
                          paramDict:(NSDictionary*)paramDict;

@end
