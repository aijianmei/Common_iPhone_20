//
//  PPSmartUpdateDataUtils.h
//  Draw
//
//  Created by qqn_pipi on 12-11-29.
//
//

#import <Foundation/Foundation.h>
#import "PPSmartUpdateData.h"
#import "PPDataConstants.h"

@interface PPSmartUpdateDataUtils : NSObject

+ (NSString*)copyFilePathByName:(NSString*)name;
+ (NSString*)pathByName:(NSString*)name type:(PPSmartUpdateDataType)type;
+ (NSString*)versionByName:(NSString*)name;
+ (void)storeVersionByName:(NSString*)name version:(NSString*)version;
+ (BOOL)isDataExists:(NSString*)name type:(PPSmartUpdateDataType)type;

+ (NSString*)getVersionUpdateURL:(NSString*)name;
+ (NSString*)getVersionFileName:(NSString*)name;
+ (NSString*)getFileUpdateURL:(NSString*)name;


+ (NSString*)getFileUpdateDownloadPath:(NSString*)name;
+ (NSString*)getFileUpdateDownloadTempPath:(NSString*)name;

+ (void)initPaths;

@end
