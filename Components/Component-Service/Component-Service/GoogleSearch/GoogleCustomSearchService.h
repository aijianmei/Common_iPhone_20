//
//  GoogleCustomSearchService.h
//  Draw
//
//  Created by Kira on 13-6-4.
//
//

#import "CommonService.h"
@protocol GoogleCustomSearchServiceDelegate <NSObject>

- (void)didSearchImageResultList:(NSMutableArray*)array
                      resultCode:(NSInteger)resultCode;

@end

@interface GoogleCustomSearchService : CommonService

+ (GoogleCustomSearchService*)defaultService;

- (void)searchImageBytext:(NSString*)text
                imageSize:(CGSize)size
                imageType:(NSString*)imageType
                startPage:(int)startPage
                paramDict:(NSDictionary*)paramDict
                 delegate:(id<GoogleCustomSearchServiceDelegate>)delegate;

@end
