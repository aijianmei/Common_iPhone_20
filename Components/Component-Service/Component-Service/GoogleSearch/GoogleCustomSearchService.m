//
//  GoogleCustomSearchService.m
//  Draw
//
//  Created by Kira on 13-6-4.
//
//

#import "GoogleCustomSearchService.h"
#import "GoogleCustomSearchNetworkRequest.h"
#import "GoogleCustomSearchNetworkConstants.h"
#import "PPNetworkRequest.h"
#import "ImageSearchResult.h"
#import "SynthesizeSingleton.h"

@implementation GoogleCustomSearchService

SYNTHESIZE_SINGLETON_FOR_CLASS(GoogleCustomSearchService)


- (void)searchImageBytext:(NSString*)text
                    imageSize:(CGSize)size
                    imageType:(NSString*)imageType
                startPage:(int)startPage
                paramDict:(NSDictionary*)paramDict
                     delegate:(id<GoogleCustomSearchServiceDelegate>)delegate{
    NSMutableArray* array = [[[NSMutableArray alloc] init] autorelease];
    
    dispatch_async(workingQueue, ^{
        CommonNetworkOutput* output = [GoogleCustomSearchNetworkRequest searchImage:GOOGLE_SEARCH_BASEURL text:text imageSize:size startPage:startPage paramDict:paramDict];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (output.resultCode == OLD_G_ERROR_SUCCESS) {
                NSArray* resultArray = [output.jsonDataDict objectForKey:OLG_G_IMG_DATA];
                for (NSDictionary* dict in resultArray) {
                    ImageSearchResult* result = [[[ImageSearchResult alloc] initWithDict:dict] autorelease];
                    [array addObject:result];
                    PPDebug(@"get an image %@", result.url);
                }
                
            }
                       if (delegate && [delegate respondsToSelector:@selector(didSearchImageResultList:resultCode:)]) {
                           [delegate didSearchImageResultList:array resultCode:output.resultCode];
                       }
        });
    });
 
}

@end
