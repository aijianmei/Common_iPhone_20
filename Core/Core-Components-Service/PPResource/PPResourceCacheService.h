//
//  PPResourceCacheService.h
//  Draw
//
//  Created by qqn_pipi on 12-11-20.
//
//

#import <Foundation/Foundation.h>

@interface PPResourceCacheService : NSObject<NSCacheDelegate>

+ (PPResourceCacheService*)defaultService;

- (UIImage*)imageFromCacheByName:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName;
- (void)setImage:(UIImage*)image resourceName:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName;

@end
