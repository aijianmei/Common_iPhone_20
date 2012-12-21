//
//  PPResourceUtils.h
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import <Foundation/Foundation.h>
#import "PPResourcePackage.h"

@interface PPResourceUtils : NSObject

+ (NSString*)getTempResourcePackageFileDir;
+ (NSString*)getResourcePackageFileDir;
+ (NSString*)getResourcePackageFileDataTopDir;

+ (NSString*)getResourcePackageFileDataDir:(NSString*)resourcePackageName;
+ (NSString*)getTempResourcePackageFilePath:(NSString*)resourcePackageName;
+ (NSString*)getResourcePackageFilePath:(NSString*)resourcePackageName;

+ (BOOL)isTestMode;
+ (NSString*)getResourceStatusKey:(NSString*)resourcePackageName;
+ (NSURL*)getDownloadURL:(NSString*)resourceName resourcePackageType:(PPResourcePackageType)resourcePackageType;

@end
