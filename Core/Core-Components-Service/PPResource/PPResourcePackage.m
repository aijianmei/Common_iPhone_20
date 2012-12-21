//
//  PPResourcePackage.m
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import "PPResourcePackage.h"
#import "PPResourcePackageDownloadRequest.h"
#import "ASIHTTPRequest.h"
#import "MobClickUtils.h"
#import "UIUtils.h"
#import "FileUtil.h"
#import "SSZipArchive.h"
#import "PPResourceUtils.h"
#import "PPResourceSearchService.h"

@implementation PPResourcePackage

- (void)dealloc
{
    if (_queue != NULL){
        dispatch_release(_queue);
        _queue = NULL;
    }
    
    [self clearBlock];
    [_name release];
    [_version release];
    [_downloadRequest release];
    [_downloadView release];
    [super dealloc];
}

+ (PPResourcePackage*)resourcePackageWithName:(NSString*)name type:(PPResourcePackageType)type
{
    PPResourcePackage* rp = [[[PPResourcePackage alloc] init] autorelease];
    
    rp.queue = dispatch_queue_create([name UTF8String], NULL);
    rp.name = name;
    rp.type = type;
    rp.version = [UIUtils getAppVersion];
    [rp loadStatus];
    
    return rp;
}



- (void)setSuccessBlock:(PPResourceServiceDownloadSuccessBlock)successBlock
{
    if (_successBlock != NULL){
        Block_release(_successBlock);
        _successBlock = NULL;
    }

    if (successBlock != NULL){
        _successBlock = Block_copy(successBlock);
    }
    
}

- (void)setFailureBlock:(PPResourceServiceDownloadFailureBlock)failureBlock
{
    if (_failureBlock != NULL){
        Block_release(_failureBlock);
        _failureBlock = NULL;
    }
    
    if (failureBlock != NULL){
        _failureBlock = Block_copy(failureBlock);
    }
}

- (void)clearBlock
{
    if (_failureBlock != NULL){
        Block_release(_failureBlock);
        _failureBlock = NULL;
    }
    
    if (_successBlock != NULL){
        Block_release(_successBlock);
        _successBlock = NULL;
    }
}

- (UIProgressView*)getProgressView
{
    UIView* view = [self.downloadView viewWithTag:PP_RESOURCE_PROGRESS_VIEW_TAG];
    if ([view isKindOfClass:[UIProgressView class]]){
        return (UIProgressView*)view;
    }
    else{
        return nil;
    }
}

- (void)startDownloadWithDownloadView:(UIView*)downloadView
                              success:(PPResourceServiceDownloadSuccessBlock)successBlock
                              failure:(PPResourceServiceDownloadFailureBlock)failureBlock

{
    if (_downloadRequest == nil){
        NSURL* url = [PPResourceUtils getDownloadURL:self.name resourcePackageType:self.type];
        _downloadRequest = [[PPResourcePackageDownloadRequest alloc] initWithURL:url resourcePackage:self];
    }

    [self setSuccessBlock:successBlock];
    [self setFailureBlock:failureBlock];
    self.downloadView = downloadView;
            
    [_downloadRequest startDownload];
}

- (void)startBackgroundDownload
{
    if (_downloadRequest == nil){
        NSURL* url = [PPResourceUtils getDownloadURL:self.name resourcePackageType:self.type];
        _downloadRequest = [[PPResourcePackageDownloadRequest alloc] initWithURL:url resourcePackage:self];
    }
    
    [_downloadRequest startBackgroundDownload];
}

- (void)setStatus:(PPResourcePackageStatus)status
{
    PPDebug(@"PPResource set %@ status to %d", self.name, status);
    _status = status;
    [[NSUserDefaults standardUserDefaults] setInteger:status
                                               forKey:[PPResourceUtils getResourceStatusKey:self.name]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadStatus
{
    _status = [[NSUserDefaults standardUserDefaults]
               integerForKey:[PPResourceUtils getResourceStatusKey:self.name]];
}

+ (BOOL)isStatusReady:(NSString*)resourcePackageName
{
    int status = [[NSUserDefaults standardUserDefaults]
                  integerForKey:[PPResourceUtils getResourceStatusKey:resourcePackageName]];
    
    return (status == PPResourcePackageStatusReady);
}

- (BOOL)isExists
{
    return ([PPResourcePackage isStatusReady:self.name] &&
            [[NSFileManager defaultManager] fileExistsAtPath:[PPResourceUtils getResourcePackageFileDataDir:self.name]]);
}

- (BOOL)unzipResourcePackage
{
    NSString* zipFilePath = [PPResourceUtils getResourcePackageFilePath:self.name];
    NSString* destDir = [PPResourceUtils getResourcePackageFileDataDir:self.name];
        
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:zipFilePath];
    if (!isFileExist){
        PPDebug(@"<unzipResourcePackage> zip file(%@) not exists", zipFilePath);
        return NO;
    }
    
    PPDebug(@"<unzipResourcePackage> start unzip %@", zipFilePath);
    BOOL result;
    if ([SSZipArchive unzipFileAtPath:zipFilePath
                        toDestination:destDir
                            overwrite:YES
                             password:nil
                                error:nil]) {
        PPDebug(@"<unzipResourcePackage> unzip %@ successfully", zipFilePath);
        result = YES;
        
        // remove MACOSX dir
        NSString* macZipTemp = [destDir stringByAppendingPathComponent:@"__MACOSX"];
        [FileUtil removeFile:macZipTemp];
        
    } else {
        PPDebug(@"<unzipResourcePackage> unzip %@ fail", zipFilePath);
        result = NO;
    }
        
    dispatch_async(_queue, ^{
        // delete files after it's unzip, if unzip failure, maybe the file is corrupted so we don't wait!
        [FileUtil removeFile:zipFilePath];
    });
    
    return result;    
}

- (void)processAfterDownloadSuccess
{
    dispatch_async(_queue, ^{
        
        // unzip files
        BOOL result = [self unzipResourcePackage];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (result){
                
                // unzip success, rebuild search index
                [[PPResourceSearchService defaultService] rebuildIndex];
                [[PPResourceSearchService defaultService] rebuildIndexForResourcePackage:self.name];
                
                // update status
                [self setStatus:PPResourcePackageStatusReady];
                
                // dismiss view
                // TODO animation
                [self.downloadView removeFromSuperview];
                self.downloadView = nil;
                
                if (self.successBlock != NULL){
                    _successBlock(NO);
                }
            }
            else{
                
                // update status
                [self setStatus:PPResourcePackageStatusNotDownloaded];
                
                // save view for invoke callback
                UIView* viewForCallback = self.downloadView;
                
                // release view
                self.downloadView = nil;

                if (self.failureBlock != NULL){
                    NSError* error = [NSError errorWithDomain:@"Unzip file failure" code:1 userInfo:nil];
                    _failureBlock(error, viewForCallback);
                }
            }
        });
    });
    
}

- (void)processDownloadFailure:(NSError*)error
{
    [self setStatus:PPResourcePackageStatusNotDownloaded];
    
    if (self.failureBlock != NULL){
        self.failureBlock(error, self.downloadView);
    }
}

- (void)processAfterDownloadStarted
{
    [self setStatus:PPResourcePackageStatusDownloading];
}


- (void)updateDownloadProgress:(float)newProgress
{
    UIProgressView* progressView = [self getProgressView];
    [progressView setProgress:newProgress];
}

@end
