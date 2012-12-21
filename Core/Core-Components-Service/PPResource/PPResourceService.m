//
//  PPResourceService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import "PPResourceService.h"
#import "PPResourcePackageManager.h"
#import "PPResourceUtils.h"
#import "FileUtil.h"
#import "UIUtils.h"
#import "PPResourceSearchService.h"
#import "SDImageCache.h"
#import "ImplicitDownloadService.h"
#import "PPResourceCacheService.h"

@interface PPResourceService ()
{
    PPResourceCacheService *_cacheService;
}

@property (nonatomic, retain) PPResourcePackageManager* resourcePackageManager;

@end

@implementation PPResourceService

static PPResourceService* _defaultResourceService = nil;
static dispatch_once_t onceToken;

+ (PPResourceService*)defaultService
{
    // thread safe singleton implementation
    dispatch_once(&onceToken, ^{
        _defaultResourceService = [[PPResourceService alloc] init];
    });
    
    return _defaultResourceService;
}

- (id)init
{
    self = [super init];
    
    NSString* tempDir = [PPResourceUtils getTempResourcePackageFileDir];
    NSString* zipDir =[PPResourceUtils getResourcePackageFileDir];
    NSString* dataDir =[PPResourceUtils getResourcePackageFileDataTopDir];
    
    [FileUtil createDir:tempDir];
    [FileUtil createDir:dataDir];
    [FileUtil createDir:zipDir];
    
    _resourcePackageManager = [[PPResourcePackageManager alloc] init];
    _cacheService = [PPResourceCacheService defaultService];
    
    [[PPResourceSearchService defaultService] rebuildIndex];
    return self;
}

- (void)dealloc
{
    [_resourcePackageManager release];
    [super dealloc];
}

- (void)addImplicitResourcePackage:(NSSet*)resourcePackages
{
    for (PPResourcePackage* rp in resourcePackages){
        [_resourcePackageManager addResourcePackage:rp];
        [[PPResourceSearchService defaultService] rebuildIndexForResourcePackage:rp.name];
        if ([self isResourcePackageExists:rp.name] == NO){
            PPDebug(@"<addImplicitResourcePackage> resource %@ not exist, start download", rp.name);
            [[ImplicitDownloadService defaultService] downloadResourcePackage:rp];
//            [rp startBackgroundDownload];
        }
        else{
            PPDebug(@"<addImplicitResourcePackage> resource %@ exist, skip download", rp.name);
        }
    }
}

- (void)addExplicitResourcePackage:(NSSet*)resourcePackages
{
    for (PPResourcePackage* rp in resourcePackages){
        [_resourcePackageManager addResourcePackage:rp];
        [[PPResourceSearchService defaultService] rebuildIndexForResourcePackage:rp.name];        
    }
}

- (BOOL)isResourcePackageExists:(NSString*)resourcePackageName
{
    return [_resourcePackageManager isResourcePackageExists:resourcePackageName];
}

#define DOWNLOAD_IMAGE_WIDTH            240
#define DOWNLOAD_IMAGE_HEIGHT           400
#define PROGRESS_BAR_HEIGHT             40
#define PROGRESS_BAR_HEIGHT_MARGIN      20

- (void)startDownloadInView:(UIView*)superView
            backgroundImage:(NSString*)imageName
        resourcePackageName:(NSString*)resourcePackageName
                    success:(PPResourceServiceDownloadSuccessBlock)successBlock
                    failure:(PPResourceServiceDownloadFailureBlock)failureBlock
{
    if ([PPResourceUtils isTestMode] || [_resourcePackageManager isResourcePackageExists:resourcePackageName]){
        successBlock(YES);
        return;
    }
    
    // set view frame
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    int x = (screenBounds.size.width - DOWNLOAD_IMAGE_WIDTH) / 2;
    int y = (screenBounds.size.height - DOWNLOAD_IMAGE_HEIGHT) / 2;
    CGRect frame = CGRectMake(x, y, DOWNLOAD_IMAGE_WIDTH, DOWNLOAD_IMAGE_HEIGHT);
    
    frame = screenBounds;
    
    UIView* downloadView = [[UIView alloc] initWithFrame:frame];

    // add image view
    UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame = CGRectMake(0, 0, DOWNLOAD_IMAGE_WIDTH, DOWNLOAD_IMAGE_HEIGHT);
    [downloadView addSubview:imageView];
    [imageView release];    
    
    // add progress view
    UIProgressView* progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar];
    progressView.tag = PP_RESOURCE_PROGRESS_VIEW_TAG;
    progressView.frame = CGRectMake(0,
                                    DOWNLOAD_IMAGE_HEIGHT - PROGRESS_BAR_HEIGHT - PROGRESS_BAR_HEIGHT_MARGIN,
                                    DOWNLOAD_IMAGE_WIDTH,
                                    DOWNLOAD_IMAGE_HEIGHT);
    [downloadView addSubview:progressView];
    [progressView release];
    
    // add subview into super view
    // TODO show animation ???
    [superView addSubview:downloadView];
    [downloadView release];
    
    // start download request for the resource
    PPResourcePackage* rp = [_resourcePackageManager resourcePackageByName:resourcePackageName];
    if (rp == nil){
        PPDebug(@"<PPResourcePackage> startDownloadInView but %@ not found", resourcePackageName);
        NSError* error = [NSError errorWithDomain:@"Resource Package Not Found" code:2 userInfo:nil];
        failureBlock(error, downloadView);
    }
    else{
        [rp startDownloadWithDownloadView:downloadView success:successBlock failure:failureBlock];
    }
}

- (UIImage*)imageByName:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName
{
    if ([PPResourceUtils isTestMode]){
        UIImage* image = [UIImage imageNamed:resourceName];
        if (image == nil && [[resourceName pathExtension] length] == 0){
            return [UIImage imageNamed:[resourceName stringByAppendingPathExtension:@"jpg"]];
        }
        else{
            return image;
        }
        
    }
    
    UIImage* returnImage = nil;
    
    // search in cache
    returnImage = [_cacheService imageFromCacheByName:resourceName inResourcePackage:resourcePackageName];
    if (returnImage != nil){
        return returnImage;
    }    
    
    // search resource locally
    NSString* resourcePath = [[PPResourceSearchService defaultService] search:resourceName inResourcePackage:resourcePackageName];
    if (resourcePath != nil){
        returnImage = [[[UIImage alloc] initWithContentsOfFile:resourcePath] autorelease];
        [_cacheService setImage:returnImage resourceName:resourceName inResourcePackage:resourcePackageName];
    }
    else{
        PPDebug(@"<imageByName> resource %@ not found in %@", resourceName, resourcePackageName);        
    }
    
    return returnImage;
}

- (NSURL*)audioURLByName:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName
{
    NSURL* url = nil;
    if ([PPResourceUtils isTestMode]){
        
        NSString* name = [resourceName stringByDeletingPathExtension];
        NSString* type = [resourceName pathExtension];
        if ([type length] == 0){
            type = @"WAV";
        }
        NSString* soundFilePath = [[NSBundle mainBundle] pathForResource:name ofType:type];
        url = [NSURL fileURLWithPath:soundFilePath];
        PPDebug(@"<audioURLByName> test mode, return %@", [url description]);
        return url;
    }
                                    
    // search resource locally
    NSString* resourcePath = [[PPResourceSearchService defaultService] search:resourceName inResourcePackage:resourcePackageName];
    if (resourcePath != nil){
        url = [NSURL fileURLWithPath:resourcePath];
//        PPDebug(@"<audioURLByName> resource found, return %@", [url description]);
    }
    else{
        PPDebug(@"<audioURLByName> resource %@ not found in %@", resourceName, resourcePackageName);
    }
    
    return url;
    
}

@end
