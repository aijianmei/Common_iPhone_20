//
//  PPSmartUpdateDataUtils.m
//  Draw
//
//  Created by qqn_pipi on 12-11-29.
//
//

#import "PPSmartUpdateDataUtils.h"
#import "FileUtil.h"
#import "PPSmartUpdateData.h"

@implementation PPSmartUpdateDataUtils


#define SMART_DATA_TOP_DIR                      @"/config_data/"
#define SMART_DATA_DOWNLOAD_DIR                 @"/config_data/download/"
#define SMART_DATA_DOWNLOAD_TEMP_DIR            @"/config_data/download/temp/"

+ (void)initPaths
{
    [FileUtil createDir:[PPSmartUpdateDataUtils getTopPath]];
    [FileUtil createDir:[PPSmartUpdateDataUtils getDownloadTopPath]];
    [FileUtil createDir:[PPSmartUpdateDataUtils getDownloadTempTopPath]];
}

+ (NSString*)getTopPath
{
    NSString* dir = [[FileUtil getAppCacheDir] stringByAppendingPathComponent:SMART_DATA_TOP_DIR];
    return dir;
}

+ (NSString*)getDownloadTopPath
{
    NSString* dir = [[FileUtil getAppCacheDir] stringByAppendingPathComponent:SMART_DATA_DOWNLOAD_DIR];
    return dir;
}

+ (NSString*)getDownloadTempTopPath
{
    NSString* dir = [[FileUtil getAppCacheDir] stringByAppendingPathComponent:SMART_DATA_DOWNLOAD_TEMP_DIR];
    return dir;
}

+ (NSString*)dataVersionKeyByName:(NSString*)name
{
    return [NSString stringWithFormat:@"SMART_DATA_KEY_%@", name];
}

+ (NSString*)copyFilePathByName:(NSString*)name
{
    return [[PPSmartUpdateDataUtils getTopPath] stringByAppendingPathComponent:name];
}

+ (NSString*)getVersionUpdateURL:(NSString*)name
{
    NSString* shortName = [name stringByDeletingPathExtension];
    NSString* versionFile = [NSString stringWithFormat:@"%@_version.txt", shortName];
    NSString* url = [SMART_DATA_SERVER_URL stringByAppendingString:versionFile];
    return url;
}

+ (NSString*)getVersionFileName:(NSString*)name
{
    NSString* shortName = [name stringByDeletingPathExtension];
    NSString* versionFile = [NSString stringWithFormat:@"%@_version.txt", shortName];
    return versionFile;
}

+ (NSString*)getFileUpdateURL:(NSString*)name
{
    NSString* url = [SMART_DATA_SERVER_URL stringByAppendingString:name];
    return url;
}


+ (NSString*)pathByName:(NSString*)name type:(PPSmartUpdateDataType)type
{
    NSString* finalName = name;
    if (type == SMART_UPDATE_DATA_TYPE_ZIP){
        finalName = [finalName stringByDeletingPathExtension];
    }
    
    return [[PPSmartUpdateDataUtils getTopPath] stringByAppendingPathComponent:finalName];
}

+ (NSString*)versionByName:(NSString*)name
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:[PPSmartUpdateDataUtils dataVersionKeyByName:name]];
}

+ (void)storeVersionByName:(NSString*)name version:(NSString*)version
{
    if ([version length] == 0)
        return;
    
    PPDebug(@"<storeVersionByName> name=%@, version=%@", name, version);
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:[PPSmartUpdateDataUtils dataVersionKeyByName:name]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (BOOL)isDataExists:(NSString*)name type:(PPSmartUpdateDataType)type
{
    NSString* version = [[NSUserDefaults standardUserDefaults] objectForKey:[PPSmartUpdateDataUtils dataVersionKeyByName:name]];
    NSString* path = [PPSmartUpdateDataUtils pathByName:name type:type];
    
    if ([version length] > 0 && [path length] > 0 && [[NSFileManager defaultManager] fileExistsAtPath:path]){
        return YES;
    }
    else{
        return NO;
    }
}

+ (NSString*)getFileUpdateDownloadPath:(NSString*)name
{
    return [[PPSmartUpdateDataUtils getDownloadTopPath] stringByAppendingPathComponent:name];
}

+ (NSString*)getFileUpdateDownloadTempPath:(NSString*)name
{
    return [[PPSmartUpdateDataUtils getDownloadTempTopPath] stringByAppendingPathComponent:name];
}


@end
