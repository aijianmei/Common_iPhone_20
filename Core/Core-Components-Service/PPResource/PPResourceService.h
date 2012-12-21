//
//  PPResourceService.h
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import <Foundation/Foundation.h>
#import "PPResource.h"

/*
 
 Quick User Guide
 
 1. Init Resource Packages (AppDelegate.m in most cases)
 
 NSSet* resourcePackages = [NSSet setWithObjects:
 [PPResourcePackage resourcePackageWithName:@"common_core" type:PPResourceImage],
 [PPResourcePackage resourcePackageWithName:@"draw_core" type:PPResourceImage],
 [PPResourcePackage resourcePackageWithName:@"dice_core" type:PPResourceImage],
 nil];
 [PPResourcePackage resourcePackageWithName:@"dice_core" type:PPResourceImage],
 nil];
 
 [[PPResourceService defaultService] addExplicitResourcePackage:resourcePackages];
 
 
 2. Call startDownloadInView in viewDidLoad (Only for Excplicitly Download)
 
 [[PPResourceService defaultService] startDownloadInView:self.view backgroundImage:@"DiceDefault" resourcePackageName:@"dice_core" success:^(BOOL alreadyExisted) {
 
 [self popupMessage:@"Load resources OK!" title:@""];
 
 [self.button2 setImage:[[PPResourceService defaultService] imageByName:@"win_face"]  forState:UIControlStateNormal];
 
 } failure:^(NSError *error) {
 
 [self popupMessage:@"Fail to load resources" title:@""];
 
 }];
 
 
 3. Get Image
 
 [[PPResourceService defaultService] imageByName:@"win_face"];
 
 4. Test Mode
 
 If you want to test without remote download, add a new key "CFResourceTest" in Infoplist
 
 Set to YES for Test Mode and then you can get a quick test
 
 5. Others
 
 Refer to PPResourceTestViewController for sample usage
 
 */

@interface PPResourceService : NSObject

+ (PPResourceService*)defaultService;

- (void)addImplicitResourcePackage:(NSSet*)resourcePackages;
- (void)addExplicitResourcePackage:(NSSet*)resourcePackages;

- (BOOL)isResourcePackageExists:(NSString*)resourcePackageName;
- (void)startDownloadInView:(UIView*)superView
            backgroundImage:(NSString*)imageName
        resourcePackageName:(NSString*)resourcePackageName
                    success:(PPResourceServiceDownloadSuccessBlock)successBlock
                    failure:(PPResourceServiceDownloadFailureBlock)failureBlock;

//- (UIImage*)imageByName:(NSString*)resourceName;
- (UIImage*)imageByName:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName;
- (NSURL*)audioURLByName:(NSString*)resourceName inResourcePackage:(NSString*)resourcePackageName;

// TODO audio file handling

@end
