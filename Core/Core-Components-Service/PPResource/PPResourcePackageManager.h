//
//  PPResourcePackageManager.h
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import <Foundation/Foundation.h>
#import "PPResourcePackage.h"

@interface PPResourcePackageManager : NSObject

- (void)addResourcePackage:(PPResourcePackage*)rp;
- (BOOL)isResourcePackageExists:(NSString*)resourcePackageName;
- (PPResourcePackage*)resourcePackageByName:(NSString*)resourcePackageName;

@end
