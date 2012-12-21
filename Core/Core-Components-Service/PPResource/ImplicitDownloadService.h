//
//  ImplicitDownloadService.h
//  Draw
//
//  Created by qqn_pipi on 12-11-5.
//
//

#import <Foundation/Foundation.h>
#import "PPResourcePackage.h"

@interface ImplicitDownloadService : NSObject

+ (ImplicitDownloadService*)defaultService;

- (void)downloadResourcePackage:(PPResourcePackage*)rp;

@end
