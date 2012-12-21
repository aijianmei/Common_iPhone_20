//
//  PPResourcePackageManager.m
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import "PPResourcePackageManager.h"
#import "PPResourceUtils.h"

@interface PPResourcePackageManager ()

@property (nonatomic, retain) NSMutableArray* resourcePackageList;

@end

@implementation PPResourcePackageManager

- (void)dealloc
{
    [_resourcePackageList release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    _resourcePackageList = [[NSMutableArray alloc] init];
    return self;
}

- (void)addResourcePackage:(PPResourcePackage*)rp
{
    // Check if resource exists in list    
    [_resourcePackageList addObject:rp];
}

- (BOOL)isResourcePackageExists:(NSString*)resourcePackageName
{
    return ([PPResourcePackage isStatusReady:resourcePackageName] &&
            [[NSFileManager defaultManager] fileExistsAtPath:[PPResourceUtils getResourcePackageFileDataDir:resourcePackageName]]);
}

- (PPResourcePackage*)resourcePackageByName:(NSString*)resourcePackageName
{
    if ([resourcePackageName length] == 0){
        return nil;
    }
    
    for (PPResourcePackage* rp in _resourcePackageList){
        if ([rp.name isEqualToString:resourcePackageName]){
            return rp;
        }
    }

    return nil;
}

@end
