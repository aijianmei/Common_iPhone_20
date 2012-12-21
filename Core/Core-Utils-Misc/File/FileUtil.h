//
//  FileUtil.h
//  three20test
//
//  Created by qqn_pipi on 10-3-23.
//  Copyright 2010 QQN-PIPI.com. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface FileUtil : NSObject {

}

+ (NSString*)getAppHomeDir;
+ (NSString*)getAppTempDir;
+ (NSString*)getAppCacheDir;

+ (NSString*)getFileFullPath:(NSString*)fileName;
+ (BOOL) copyFileFromBundleToAppDir:(NSString *)bundleResourceFile appDir:(NSString *)appDir overwrite:(BOOL)overwrite;
+ (NSURL*)bundleURL:(NSString*)filename;
+ (BOOL)createDir:(NSString*)fullPath;
+ (NSString*)getFileNameByFullPath:(NSString*)path;
+ (BOOL)removeFile:(NSString *)fullPath;
+ (NSInteger)numberOfFilesBelowDir:(NSString *)fullDirPath;
+ (BOOL)removeFilesBelowDir:(NSString *)fullDirPath 
       timeIntervalSinceNow:(NSTimeInterval)timeInterval;

+ (void)unzipFile:(NSString *)zipFileName;

@end
