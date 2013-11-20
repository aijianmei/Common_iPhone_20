//
//  GoogleCustomSearchNetworkRequest.m
//  Draw
//
//  Created by Kira on 13-6-4.
//
//

#import "GoogleCustomSearchNetworkRequest.h"
#import "PPNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "BasicSearch.h"
#import "Reachability.h"
#import "StringUtil.h"
#import "GoogleCustomSearchNetworkConstants.h"
#import "BasicSearch.h"

@implementation GoogleCustomSearchNetworkRequest

+ (CommonNetworkOutput*)searchImage:(NSString*)baseURL
                               text:(NSString*)text
                          imageSize:(CGSize)size
                          startPage:(int)startPage
                          paramDict:(NSDictionary*)paramDict
{
    CommonNetworkOutput* output = [[[CommonNetworkOutput alloc] init] autorelease];
    
    ConstructURLBlock constructURLHandler = ^NSString *(NSString *baseURL) {
        
        // set input parameters
        NSString* str = [NSString stringWithString:baseURL];

        str = [str stringByAddQueryParameter:PARA_SEARCH_ENGIN_KEY value:kApiKey];
        str = [str stringByAddQueryParameter:PARA_SEARCH_TEXT value:text];
        str = [str stringByAddQueryParameter:PARA_START_PAGE intValue:startPage];
        str = [str stringByAddQueryParameter:PARA_USER_IP  value:kIpAddress];
        for (NSString* key in [paramDict allKeys]) {
            str = [str stringByAddQueryParameter:key value:[paramDict objectForKey:key]];
        }
        
        return str;
    };
    
    
    PPNetworkResponseBlock responseHandler = ^(NSDictionary *dict, CommonNetworkOutput *output) {
        output.jsonDataDict = [dict objectForKey:OLD_G_RET_DATA];
        output.resultCode = ((NSString*)[dict objectForKey:OLD_G_RET_CODE]).intValue;
        return;
    };
    
    return [PPNetworkRequest sendRequest:baseURL
                     constructURLHandler:constructURLHandler
                         responseHandler:responseHandler
                                  output:output];
}

@end
