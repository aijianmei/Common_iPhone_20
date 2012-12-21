//
//  PPResourceSearchService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-5.
//
//

#import "PPResourceSearchService.h"
#import "PPResourceUtils.h"

@implementation PPResourceSearchService

static PPResourceSearchService* _defaultResourceSearchService = nil;
static dispatch_once_t onceToken;

+ (PPResourceSearchService*)defaultService
{
    // thread safe singleton implementation
    dispatch_once(&onceToken, ^{
        _defaultResourceSearchService = [[PPResourceSearchService alloc] init];
    });
    
    return _defaultResourceSearchService;
}

- (id)init
{
    self = [super init];
    _resourcePackageList = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc
{
    [_resourceList release];
    [super dealloc];
}

- (void)rebuildIndex
{
    NSString* filePath = [PPResourceUtils getResourcePackageFileDataTopDir];
    NSArray*  subPaths = nil;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    subPaths = [fileManager subpathsAtPath:filePath];
    self.resourceList = subPaths;
    [fileManager release];        
}

- (void)rebuildIndexForResourcePackage:(NSString*)resourcePackageName
{
    [self buildIndexForResourcePackage:resourcePackageName];
}

- (void)buildIndexForResourcePackage:(NSString*)resourcePackageName
{
    NSString* filePath = [PPResourceUtils getResourcePackageFileDataDir:resourcePackageName];
    NSArray*  subPaths = nil;
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    subPaths = [fileManager subpathsAtPath:filePath];
    if (subPaths != nil){
        [self.resourcePackageList setObject:subPaths forKey:resourcePackageName];
    }
    [fileManager release];
}

- (NSArray*)getResourceList
{
    if (self.resourceList == nil){
        [self rebuildIndex];
    }
    
    return self.resourceList;
}

- (NSString*)search:(NSString*)resourceName resourcePackageName:(NSString*)resourcePackageName inPath:(NSArray*)subPaths
{
    NSString* resourceNameWith2x = nil;
    if ([resourceName hasSuffix:@"@2x"] == NO){
        resourceNameWith2x = [resourceName stringByAppendingString:@"@2x"];
    }
    
    __block NSString* pathFound = nil;
    
    [subPaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString* filePath = obj;
        NSString* fileName = [filePath lastPathComponent];
        NSString* nameForCompare = [fileName stringByDeletingPathExtension];
        
        if ([fileName caseInsensitiveCompare:resourceName] == NSOrderedSame){
            *stop = YES;
        }
        else if ([nameForCompare caseInsensitiveCompare:resourceName] == NSOrderedSame){
            *stop = YES;
        }
        else if (resourceNameWith2x != nil && [resourceNameWith2x caseInsensitiveCompare:nameForCompare] == NSOrderedSame){
            *stop = YES;
        }
        else{
            *stop = NO;
        }
        
        if (*stop){
            pathFound = filePath;
        }
    }];
    
    if (pathFound != nil){
        NSString* topDir = [PPResourceUtils getResourcePackageFileDataDir:resourcePackageName];
        NSString* imagePath = [topDir stringByAppendingPathComponent:pathFound];
//        PPDebug(@"PPResource search resource found at %@", imagePath);
        return imagePath;
    }
    else{
        PPDebug(@"PPResource search resource %@ not found!", resourceName);
        return nil;
    }        
}

- (NSString*)search:(NSString*)resourceName
{
    NSArray* subPaths = [self getResourceList];
    return [self search:resourceName resourcePackageName:@"" inPath:subPaths];
}

- (NSArray*)getResourceList:(NSString*)resourcePackageName
{
    NSArray* resourceListInPackage = [self.resourcePackageList objectForKey:resourcePackageName];
    if (resourceListInPackage == nil){
        // build index
        [self buildIndexForResourcePackage:resourcePackageName];
    }

    resourceListInPackage = [self.resourcePackageList objectForKey:resourcePackageName];
    return resourceListInPackage;
}

- (NSString*)search:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName
{
    NSArray* resourceListInPackage = [self getResourceList:resourcePackageName];
    return [self search:resourceName resourcePackageName:resourcePackageName inPath:resourceListInPackage];
}

@end
