//
//  PPResourceUtils.m
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import "PPResourceUtils.h"
#import "FileUtil.h"
#import "UIUtils.h"
#import "MobClickUtils.h"
#import "PPResource.h"
#import "DeviceDetection.h"
#import "PPResourcePackage.h"

#define APP_RESOURCE_ZIP_DIR         @"app_res/zip"
#define APP_RESOURCE_TEMP_DIR        @"app_res/temp"
#define APP_RESOURCE_DATA_DIR        @"app_res/data"

@implementation PPResourceUtils

+ (NSString*)getTopPath
{
    return [FileUtil getAppCacheDir];
}

+ (NSString*)getTempResourcePackageFileDir
{
    return [NSString stringWithFormat:@"%@/%@/%@",
            [PPResourceUtils getTopPath],
            APP_RESOURCE_TEMP_DIR,
            [UIUtils getAppVersion]
            ];
}

+ (NSString*)getResourcePackageFileDir
{
    return [NSString stringWithFormat:@"%@/%@/%@",
            [PPResourceUtils getTopPath],
            APP_RESOURCE_ZIP_DIR,
            [UIUtils getAppVersion]
            ];
}


+ (NSString*)getTempResourcePackageFilePath:(NSString*)resourcePackageName
{
    return [NSString stringWithFormat:@"%@/%@.zip",
            [PPResourceUtils getTempResourcePackageFileDir],
            resourcePackageName
            ];
}



+ (NSString*)getResourcePackageFilePath:(NSString*)resourcePackageName
{
    return [NSString stringWithFormat:@"%@/%@.zip",
            [PPResourceUtils getResourcePackageFileDir],
            resourcePackageName
            ];
    
}

+ (NSString*)getResourcePackageFileDataDir:(NSString*)resourcePackageName
{
    return [NSString stringWithFormat:@"%@/%@/%@/%@_%@",
            [PPResourceUtils getTopPath],
            APP_RESOURCE_DATA_DIR,
            [UIUtils getAppVersion],
            resourcePackageName,
            [DeviceDetection deviceScreenTypeString]
            ];
}

+ (NSString*)getResourcePackageFileDataTopDir
{
    return [NSString stringWithFormat:@"%@/%@/%@",
            [PPResourceUtils getTopPath],
            APP_RESOURCE_DATA_DIR,
            [UIUtils getAppVersion]
            ];
}

static BOOL isTestMode;

+ (BOOL)isTestMode
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSNumber* obj = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFResourceTest"];
        isTestMode = [obj boolValue];
    });
    
    return isTestMode;
}

+ (NSString*)getResourceStatusKey:(NSString*)resourcePackageName
{
    
    return [NSString stringWithFormat:@"KEY_RESOURCE_STATUS_%@_%@_%@",
            resourcePackageName,
            [DeviceDetection deviceScreenTypeString],
            [UIUtils getAppVersion]];
}

+ (NSURL*)getDownloadURL:(NSString*)resourceName resourcePackageType:(PPResourcePackageType)resourcePackageType
{
    NSString* resourceServerURL = [MobClickUtils getStringValueByKey:PP_RESOURCE_DOWNLOAD_URL_KEY defaultValue:PP_RESOURCE_DOWNLOAD_URL];
    NSString* version = [UIUtils getAppVersion];
    

    NSString* fileExt = @"";
    if (resourcePackageType == PPResourceImage){
        DeviceScreenType screenType = [DeviceDetection deviceScreenType];
        switch (screenType) {
            case DEVICE_SCREEN_IPHONE:
                fileExt = @"_iphone";
                break;
                
            case DEVICE_SCREEN_IPHONE5:
                fileExt = @"_iphone5";
                break;

            case DEVICE_SCREEN_IPAD:
                fileExt = @"_ipad";
                break;

            case DEVICE_SCREEN_NEW_IPAD:
                fileExt = @"_newipad";
                break;

            default:
                fileExt = @"_iphone";
                break;
        }
    }

    // for test
    // fileExt = @"";
    
    NSString* urlString = [NSString stringWithFormat:@"%@/app_res/%@/%@%@.zip", resourceServerURL, version, resourceName, fileExt];
    return [NSURL URLWithString:urlString];
}

@end
