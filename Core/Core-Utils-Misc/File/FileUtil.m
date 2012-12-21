//
//  FileUtil.m
//  three20test
//
//  Created by qqn_pipi on 10-3-23.
//  Copyright 2010 QQN-PIPI.com. All rights reserved.
//

#import "FileUtil.h"
#import "LogUtil.h"
#import "SSZipArchive.h"

@implementation FileUtil

+ (BOOL)createDir:(NSString*)fullPath
{
    
    // Check if the directory already exists
    if (![[NSFileManager defaultManager] fileExistsAtPath:fullPath]) {
        
        // Directory does not exist so create it
        PPDebug(@"create dir = %@", fullPath);

        NSError* error = nil;
        BOOL result = [[NSFileManager defaultManager] createDirectoryAtPath:fullPath withIntermediateDirectories:YES attributes:nil error:&error];
        if (result == NO){
            NSLog(@"create dir (%@) but error (%@)", fullPath, [error description]);
        }        
        
        return result;
    }
    else{
        return YES;
    }
}

+ (NSString*)getAppHomeDir
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentDir = [paths objectAtIndex:0];
	
	return documentDir;
}

+ (NSString*)getAppCacheDir
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
	NSString *retDir = [paths objectAtIndex:0];
	
	return retDir;    
}

+ (NSString*)getAppTempDir
{	
	return NSTemporaryDirectory();
}

+ (NSString*)getFileFullPath:(NSString*)fileName
{
	return [[FileUtil getAppHomeDir] stringByAppendingPathComponent:fileName];
}

// find database file in given databasePath, and copy it to Document directory as initialize DB
+ (BOOL) copyFileFromBundleToAppDir:(NSString *)bundleResourceFile appDir:(NSString *)appDir overwrite:(BOOL)overwrite
{
	BOOL success = NO;
	
	// init file manager
	NSFileManager *fileManager = [NSFileManager defaultManager];
	
	// init path
	NSString* bundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundleResourceFile];
//	NSString* appPath = [NSString stringWithFormat:@"%@/%@", appDir, bundleResourceFile];
    NSString *appPath = [appDir stringByAppendingPathComponent:bundleResourceFile];
	    
	// check if file exist to app directory
	success = [fileManager fileExistsAtPath:appPath];
	if (success) {
//		NSLog(@"<copyFileFromBundleToAppDir> targeted file (%@) exists", appPath);
	}
	
	if (overwrite == NO && success == YES){
//		NSLog(@"<copyFileFromBundleToAppDir> don't overwrite, return");
		return YES;
	}
	
	// now copy to file
    NSError* error = nil;
	if ((success = [fileManager copyItemAtPath:bundlePath toPath:appPath error:nil]) == YES)
		NSLog(@"<copyFileFromBundleToAppDir> copy file from %@ to %@ successfully", bundlePath, appPath);
	else {
		NSLog(@"<copyFileFromBundleToAppDir> copy file from %@ to %@ failure, error=%@", bundlePath, appPath, [error description]);
	}
	return success;
}

+ (NSURL*)bundleURL:(NSString*)filename
{
    if (filename == nil)
        return nil;
    
	NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",filename]];
	NSURL* url = [NSURL fileURLWithPath:path];	    
    return url;
}

+ (NSString*)getFileNameByFullPath:(NSString *)path
{
    NSArray* stringArray = [path componentsSeparatedByString:@"/"];
    if (stringArray.count > 1) {
        return (NSString*)[stringArray objectAtIndex:(stringArray.count-1)];
    }
    return path;
}

+ (BOOL)removeFile:(NSString *)fullPath
{
    PPDebug(@"<removeFile> %@", fullPath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:fullPath error:nil];
}

+ (NSInteger)numberOfFilesBelowDir:(NSString *)fullDirPath
{
    if ([fullDirPath length] == 0) {
        PPDebug(@"warnning<numberOfFilesBelowDir>: parameter is illegal,dir = %@",fullDirPath);
        return 0;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:fullDirPath isDirectory:&isDir]) {
        if (!isDir) {
            PPDebug(@"warnning:<numberOfFilesBelowDir> %@ is not a directory",fullDirPath);
            return 0;
        }
        //delete the files.
        NSArray *fileList = [fileManager contentsOfDirectoryAtPath:fullDirPath error:nil];
        return [fileList count];
    }
    PPDebug(@"warnning:<numberOfFilesBelowDir> %@  not exists!",fullDirPath);
    return NO;

}

+ (BOOL)removeFilesBelowDir:(NSString *)fullDirPath 
           timeIntervalSinceNow:(NSTimeInterval)timeInterval
{
    if ([fullDirPath length] == 0) {
        PPDebug(@"warnning<removeFilesBelowDir>: parameter is illegal,dir = %@, date = %f",fullDirPath, timeInterval);
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    if ([fileManager fileExistsAtPath:fullDirPath isDirectory:&isDir]) {
        if (!isDir) {
            PPDebug(@"warnning:<removeFilesBelowDir> %@ is not a directory",fullDirPath);
            return NO;
        }
        //delete the files.
        NSArray *fileList = [fileManager contentsOfDirectoryAtPath:fullDirPath error:nil];
        for (NSString *file in fileList) {
            NSString *filePath = [fullDirPath stringByAppendingPathComponent:file];
            NSDictionary *attr = [fileManager attributesOfItemAtPath:filePath error:nil];
            if (attr) {
                NSDate *modifyDate = [attr objectForKey:NSFileModificationDate];
                NSTimeInterval interval = [[NSDate date] timeIntervalSinceDate:modifyDate];
                if (interval >= timeInterval) {
                    PPDebug(@"remove the file = %@, modify date = %@", filePath,modifyDate);
                    [FileUtil removeFile:filePath];
                }
            }
        }
        return YES;
    }
    PPDebug(@"warnning:<removeFilesBelowDir> %@  not exists!",fullDirPath);
    return NO;
}

#define KEY_FILE_VERSION(fileName)  [NSString stringWithFormat:@"%@_version", fileName]

+ (void)unzipFile:(NSString *)zipFileName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hasUnzip = [userDefaults boolForKey:zipFileName];
    
    // set path to cache path to avoid the data is backup by iCloud
    NSString* destPath = [FileUtil getAppCacheDir];
    NSString *zipFilePath = [destPath stringByAppendingPathComponent:zipFileName];
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:zipFilePath];

    NSString *lastversion = [userDefaults stringForKey:KEY_FILE_VERSION(zipFileName)];
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    if (hasUnzip && [lastversion isEqualToString:currentVersion] && isFileExist == YES){
        PPDebug(@"<FileUtil> already unzip file %@, skip", zipFileName);
        return ;
    }
    
    [FileUtil copyFileFromBundleToAppDir:zipFileName
                                  appDir:destPath
                               overwrite:YES];        
    
    PPDebug(@"<FileUtil> start unzip %@", zipFileName);
    if ([SSZipArchive unzipFileAtPath:zipFilePath
                        toDestination:destPath
                            overwrite:YES
                             password:nil
                                error:nil]) {
        PPDebug(@"<FileUtil> unzip %@ successfully", zipFileName);
        [userDefaults setBool:YES forKey:zipFileName];
    } else {
        PPDebug(@"<FileUtil> unzip %@ fail", zipFileName);
        [userDefaults setBool:NO forKey:zipFileName];
    }
    
    [userDefaults setValue:currentVersion forKey:KEY_FILE_VERSION(zipFileName)];    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // delete files after it's unzip
        [FileUtil removeFile:zipFilePath];
    });
    
    return;
    
}



/*
+ (void)unzipFile:(NSString *)zipFileName
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    BOOL hasUnzip = [userDefaults boolForKey:zipFileName];
    
    NSString *lastversion = [userDefaults stringForKey:KEY_FILE_VERSION(zipFileName)];
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    if (hasUnzip && [lastversion isEqualToString:currentVersion]) {
        PPDebug(@"<FileUtil> already unzip file %@, skip", zipFileName);
        return ;
    }
    
    [FileUtil copyFileFromBundleToAppDir:zipFileName
                                  appDir:[self getAppHomeDir]
                               overwrite:YES];
    
    NSString *zipFilePath = [[FileUtil getAppHomeDir] stringByAppendingPathComponent:zipFileName];
    
    PPDebug(@"<FileUtil> start unzip %@", zipFileName);
    if ([SSZipArchive unzipFileAtPath:zipFilePath 
                        toDestination:[FileUtil getAppHomeDir] 
                            overwrite:YES 
                             password:nil 
                                error:nil]) {
        PPDebug(@"<FileUtil> unzip %@ successfully", zipFileName);
        [userDefaults setBool:YES forKey:zipFileName];
    } else {
        PPDebug(@"<FileUtil> unzip %@ fail", zipFileName);
        [userDefaults setBool:NO forKey:zipFileName];
    }
    
    [userDefaults setValue:currentVersion forKey:KEY_FILE_VERSION(zipFileName)];
    
    return;
}
 */

@end
