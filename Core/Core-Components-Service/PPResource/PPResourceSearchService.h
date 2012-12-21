//
//  PPResourceSearchService.h
//  Draw
//
//  Created by qqn_pipi on 12-11-5.
//
//

#import <Foundation/Foundation.h>

@interface PPResourceSearchService : NSObject

+ (PPResourceSearchService*)defaultService;

@property (nonatomic, retain) NSArray* resourceList;
@property (nonatomic, retain) NSMutableDictionary* resourcePackageList;

- (void)rebuildIndex;
- (void)rebuildIndexForResourcePackage:(NSString*)resourcePackageName;

- (NSString*)search:(NSString*)resourceName;
- (NSString*)search:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName;

@end
