//
//  PPResourcePackage.h
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import <Foundation/Foundation.h>
#import "PPResource.h"

@class PPResourcePackageDownloadRequest;

typedef enum{
    PPResourceImage = 1,
    PPResourceAudio,
    PPResourceHtml,
    PPResourceOther
} PPResourcePackageType;

typedef enum{
    PPResourcePackageStatusNotDownloaded = 0,
    PPResourcePackageStatusReady,                   // ready for usage
    PPResourcePackageStatusDownloaded,
    PPResourcePackageStatusDownloading,    
} PPResourcePackageStatus;

@interface PPResourcePackage : NSObject

@property (nonatomic, assign) dispatch_queue_t queue;
@property (nonatomic, retain) NSString* name;
@property (nonatomic, assign) PPResourcePackageType type;
@property (nonatomic, assign) PPResourcePackageStatus status;
@property (nonatomic, retain) NSString* version;
@property (nonatomic, retain) PPResourcePackageDownloadRequest* downloadRequest;
@property (nonatomic, assign) PPResourceServiceDownloadSuccessBlock successBlock;
@property (nonatomic, assign) PPResourceServiceDownloadFailureBlock failureBlock;
@property (nonatomic, retain) UIView* downloadView;
@property (nonatomic, assign) int downloadRetryTimes;

+ (PPResourcePackage*)resourcePackageWithName:(NSString*)name type:(PPResourcePackageType)type;

// download operations
- (void)startDownloadWithDownloadView:(UIView*)downloadView
                              success:(PPResourceServiceDownloadSuccessBlock)successBlock
                              failure:(PPResourceServiceDownloadFailureBlock)failureBlock;
- (void)startBackgroundDownload;
+ (BOOL)isStatusReady:(NSString*)resourcePackageName;
- (BOOL)isExists;

// internal usage
- (void)processAfterDownloadStarted;
- (void)processAfterDownloadSuccess;
- (void)processDownloadFailure:(NSError*)error;
- (void)updateDownloadProgress:(float)newProgress;



@end
