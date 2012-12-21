//
//  PPResourceCacheService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-20.
//
//

#import "PPResourceCacheService.h"
#import <malloc/malloc.h>
#import "UIImageExt.h"

@interface PPResourceCacheService()
{
    NSCache     *_cache;
}

@end

@implementation PPResourceCacheService

static PPResourceCacheService* _defaultResourceCacheService = nil;
static dispatch_once_t onceToken;

+ (PPResourceCacheService*)defaultService
{
    // thread safe singleton implementation
    dispatch_once(&onceToken, ^{
        _defaultResourceCacheService = [[PPResourceCacheService alloc] init];
    });
    
    return _defaultResourceCacheService;
}

#define RESOURCE_CACHE_PERCENTAGE       (20)
#define MAX_RESOURCE_CACHE_LIMIT        (8*1024*1024)
#define MIN_RESOURCE_CACHE_LIMIT        (2*1024*1024)
#define MAX_RESOURCE_CACHE_COUNT        (100)

- (id)init
{
    self = [super init];
    _cache = [[NSCache alloc] init];
    [_cache setDelegate:self];
    
    int freeMemory = [DeviceDetection freeMemory];
    int memory = (freeMemory/100) * RESOURCE_CACHE_PERCENTAGE;
    if (memory > MAX_RESOURCE_CACHE_LIMIT){
        memory = MAX_RESOURCE_CACHE_LIMIT;
    }
    else if (memory < MIN_RESOURCE_CACHE_LIMIT){
        memory = MIN_RESOURCE_CACHE_LIMIT;
    }
    PPDebug(@"PPResourceCacheService Cache Memory=%d Free Memory=%d", memory, freeMemory);
    
    [_cache setTotalCostLimit:memory];
    [_cache setCountLimit:MAX_RESOURCE_CACHE_COUNT];
    return self;
}

- (void)dealloc
{
    [_cache release];
    [super dealloc];
}

- (NSString*)getResourceKeyByName:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName
{
    NSString* resourceKey = [NSString stringWithFormat:@"%@_%@_%@", resourceName, resourcePackageName, [DeviceDetection deviceScreenTypeString]];
    return resourceKey;
}

- (UIImage*)imageFromCacheByName:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName
{
    NSString* resourceKey = [self getResourceKeyByName:resourceName inResourcePackage:resourcePackageName];    
    id returnImage = [_cache objectForKey:resourceKey];
    if ([returnImage isKindOfClass:[UIImage class]])
        return returnImage;
    else
        return nil;
}

- (void)setImage:(UIImage*)image resourceName:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName
{
    NSString* resourceKey = [self getResourceKeyByName:resourceName inResourcePackage:resourcePackageName];
    int cost = [image uncompressSize];
//    PPDebug(@"PPResourceCacheService set image for %@, cost=%d", resourceKey, cost);
    [_cache setObject:image forKey:resourceKey cost:cost];
}

#pragma mark - Cache Delegate

- (void)cache:(NSCache *)cache willEvictObject:(id)obj
{
    PPDebug(@"PPResourceCacheService <willEvictObject>");
}

@end
