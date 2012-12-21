//
//  PPSmartUpdateData.m
//  Draw
//
//  Created by qqn_pipi on 12-11-29.
//
//

#import "PPSmartUpdateData.h"
#import "PPSmartUpdateDataUtils.h"
#import "FileUtil.h"
#import "SSZipArchive.h"
#import "ASIHTTPRequest.h"
#import "BlockUtils.h"
#import "PPDataConstants.h"

@interface PPSmartUpdateData()
{
    dispatch_queue_t _queue;
}

@end

@implementation PPSmartUpdateData

- (void)releaseBlocks
{
    RELEASE_BLOCK(_downloadDataSuccessBlock);
    RELEASE_BLOCK(_downloadDataFailureBlock);
}

- (void)dealloc
{
    dispatch_release(_queue);
    _queue = NULL;
 
    [self releaseBlocks];
    
    [_name release];
    [_downloadDataVersion release];
    [_currentDataPath release];
    [_currentVersion release];
    [_initDataPath release];
    [_latestVersion release];
    [_checkVersionHttpRequest release];
    [_downloadHttpRequest release];
    [super dealloc];
}

- (id)initWithName:(NSString*)name
              type:(PPSmartUpdateDataType)type
      initDataPath:(NSString*)initDataPath
   initDataVersion:(NSString*)initDataVersion
{
    self = [super init];
    
    _queue = dispatch_queue_create([name UTF8String], NULL);
    
    self.name = name;
    self.type = type;    
    
    self.initDataPath = initDataPath;
    
    // read whether there is data path or data version exist, if yes load it
    // otherwize load from init data path        
    if ([PPSmartUpdateDataUtils isDataExists:name type:type]){
        PPDebug(@"Init smart data %@ exists ", self.name);
        self.currentDataPath = [PPSmartUpdateDataUtils pathByName:name type:type];
        self.currentVersion = [PPSmartUpdateDataUtils versionByName:name];
    }
    else{
        [self processData:initDataPath dataVersion:initDataVersion];
    }    
    
    return self;
}

- (id)initWithName:(NSString*)name
              type:(PPSmartUpdateDataType)type
        bundlePath:(NSString*)bundlePath
   initDataVersion:(NSString*)initDataVersion
{
    NSString* path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:bundlePath];
    return [self initWithName:name type:type initDataPath:path initDataVersion:initDataVersion];
}

// call this method to get data file path
- (NSString*)dataFilePath
{
    return _currentDataPath;
}

// call this method to download data
- (void)downloadData:(PPSmartDataFetchSuccessBlock)successBlock
        failureBlock:(PPSmartDataFetchFailureBlock)failureBlock
 downloadDataVersion:(NSString*)downloadDataVersion
{
    NSURL* url = [NSURL URLWithString:[PPSmartUpdateDataUtils getFileUpdateURL:self.name]];
    if (_downloadHttpRequest == nil || [_downloadHttpRequest isFinished]){
        self.downloadHttpRequest = [ASIHTTPRequest requestWithURL:url];
    }
    
    if ([_downloadHttpRequest isExecuting]){
        return;
    }
    
    [self releaseBlocks];
    
    self.downloadDataVersion = downloadDataVersion;
    COPY_BLOCK(_downloadDataSuccessBlock, successBlock);
    COPY_BLOCK(_downloadDataFailureBlock, failureBlock);    
    
    _downloadHttpRequest.delegate = self;
    [_downloadHttpRequest setAllowCompressedResponse:YES];
    [_downloadHttpRequest setUsername:DEFAULT_SMART_DATA_HTTP_USER_NAME];
    [_downloadHttpRequest setPassword:DEFAULT_SMART_DATA_HTTP_PASSWORD];
    
    NSString* destPath = [PPSmartUpdateDataUtils getFileUpdateDownloadPath:self.name];
    [_downloadHttpRequest setDownloadDestinationPath:destPath];
    
    NSString* tempPath = [PPSmartUpdateDataUtils getFileUpdateDownloadTempPath:self.name];
    [_downloadHttpRequest setTemporaryFileDownloadPath:tempPath];
    
    [_downloadHttpRequest setDownloadProgressDelegate:self];
    [_downloadHttpRequest setAllowResumeForFileDownloads:YES];
    
    PPDebug(@"<downloadData> URL=%@, Local Temp=%@, Store At=%@",
            url.absoluteString, tempPath, destPath);
    
    [_downloadHttpRequest startAsynchronous];
}

// call this method to check whether the data has updated version
- (void)checkHasUpdate:(PPSmartDataCheckUpdateSuccessBlock)successBlock failureBlock:(PPSmartDataFetchFailureBlock)failureBlock
{
    NSURL* url = [NSURL URLWithString:[PPSmartUpdateDataUtils getVersionUpdateURL:self.name]];
    if (_checkVersionHttpRequest == nil || [_checkVersionHttpRequest isFinished]){
        self.checkVersionHttpRequest = [ASIHTTPRequest requestWithURL:url];
    }
    
    if ([_checkVersionHttpRequest isExecuting]){
        PPDebug(@"<checkHasUpdate> but it's executing");
        return;
    }
    
    [_checkVersionHttpRequest setAllowCompressedResponse:YES];
    [_checkVersionHttpRequest setUsername:DEFAULT_SMART_DATA_HTTP_USER_NAME];
    [_checkVersionHttpRequest setPassword:DEFAULT_SMART_DATA_HTTP_PASSWORD];
    
    [_checkVersionHttpRequest setTimeOutSeconds:8]; // 8 seconds for timeout
        
    PPDebug(@"<checkHasUpdate> URL=%@", url.absoluteString);
    
    dispatch_async(_queue, ^{
        [_checkVersionHttpRequest startSynchronous];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (_checkVersionHttpRequest.responseStatusCode == 200){
                // success, check if has update
                NSString* newVersionString = _checkVersionHttpRequest.responseString;
                if ([self hasUpdateVersion:newVersionString]){
                    PPDebug(@"<checkHasUpdate> has new version = %@", newVersionString);
                    // has update
                    if (successBlock != NULL){
                        successBlock(YES, newVersionString);
                    }
                }
                else{
                    // no update
                    PPDebug(@"<checkHasUpdate> no new version = %@", newVersionString);
                    successBlock(NO, nil);
                }
            }
            else{
                // failure, call failure block
                PPDebug(@"<checkHasUpdate> HTTP error, message=%@, url=%@, status=%d, error=%@", _checkVersionHttpRequest.responseStatusMessage, _checkVersionHttpRequest.url.absoluteString, _checkVersionHttpRequest.responseStatusCode, [_checkVersionHttpRequest.error description]);
                if (failureBlock != NULL){
                    failureBlock([NSError errorWithDomain:@"HTTP Error" code:_checkVersionHttpRequest.responseStatusCode userInfo:nil]);
                }
            }

            self.checkVersionHttpRequest = nil;
        });
    });

}


// call this method to check and update and auto download
- (void)checkUpdateAndDownload:(PPSmartDataFetchSuccessBlock)successBlock failureBlock:(PPSmartDataFetchFailureBlock)failureBlock
{
    [self checkHasUpdate:^(BOOL hasNewVersion, NSString *latestVersion) {
        if (hasNewVersion){
            [self downloadData:successBlock
                  failureBlock:failureBlock
           downloadDataVersion:latestVersion];
        }
        else{
            successBlock(YES, latestVersion);
        }
    } failureBlock:^(NSError *error) {
        if (failureBlock != NULL){
            failureBlock(error);
        }
    }];
}

- (BOOL)processData:(NSString*)sourceDataPath dataVersion:(NSString*)dataVersion
{
    PPDebug(@"<processData> path=%@, version=%@", sourceDataPath, dataVersion);
    NSString* destPath = [PPSmartUpdateDataUtils copyFilePathByName:self.name];
    NSError* error = nil;
    BOOL result = [[NSFileManager defaultManager] copyItemAtPath:sourceDataPath toPath:destPath error:&error];
    if (result && error == nil){
        // copy success, check file type if it's zip file, then unzip the file
        if (self.type == SMART_UPDATE_DATA_TYPE_ZIP){
            NSString* unzipDir = [PPSmartUpdateDataUtils pathByName:self.name type:self.type];
            result = [self unzipFileFromPath:destPath destDir:unzipDir deleteSource:YES];
        }
        
        // store data version and set data
        if (result){
            self.currentVersion = dataVersion;
            self.currentDataPath = [PPSmartUpdateDataUtils pathByName:self.name type:self.type];
            [PPSmartUpdateDataUtils storeVersionByName:self.name version:self.currentVersion];
        }
    }
    else{
        PPDebug(@"<processData> but copy file from %@ to %@ failure", sourceDataPath, destPath);
    }
    
    return result;
}


- (BOOL)unzipFileFromPath:(NSString*)zipFilePath destDir:(NSString*)destDir deleteSource:(BOOL)deleteSource
{
//    NSString* zipFilePath = [PPResourceUtils getResourcePackageFilePath:self.name];
//    NSString* destDir = [PPResourceUtils getResourcePackageFileDataDir:self.name];
    
    BOOL isFileExist = [[NSFileManager defaultManager] fileExistsAtPath:zipFilePath];
    if (!isFileExist){
        PPDebug(@"<unzipFileFromPath> zip file(%@) not exists", zipFilePath);
        return NO;
    }
    
    PPDebug(@"<unzipFileFromPath> start unzip %@", zipFilePath);
    BOOL result;
    if ([SSZipArchive unzipFileAtPath:zipFilePath
                        toDestination:destDir
                            overwrite:YES
                             password:nil
                                error:nil]) {
        PPDebug(@"<unzipFileFromPath> unzip %@ successfully", zipFilePath);
        result = YES;
        
        // remove MACOSX dir
        NSString* macZipTemp = [destDir stringByAppendingPathComponent:@"__MACOSX"];
        [FileUtil removeFile:macZipTemp];
        
    } else {
        PPDebug(@"<unzipFileFromPath> unzip %@ fail", zipFilePath);
        result = NO;
    }
    
    if (deleteSource){
        dispatch_async(_queue, ^{
            // delete files after it's unzip, if unzip failure, maybe the file is corrupted so we don't wait!
            [FileUtil removeFile:zipFilePath];
        });
    }
    
    return result;
}

- (BOOL)hasUpdateVersion:(NSString*)newVersion
{
    if ([self.currentVersion isEqualToString:newVersion]){
        // same string
        return NO;
    }
    
    return ([newVersion doubleValue] - [self.currentVersion doubleValue]) > 0.0f;
}

#pragma mark - ASIHttpRequest Delegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    PPDebug(@"Download %@ requestStarted", self.name);
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    PPDebug(@"Download %@ didReceiveResponseHeaders", self.name);
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
{
    PPDebug(@"Download %@ willRedirectToURL", self.name);
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    PPDebug(@"Download %@ requestFinished", self.name);
    
    
    
    NSString* destPath = [PPSmartUpdateDataUtils getFileUpdateDownloadPath:self.name];
    BOOL result = [self processData:destPath dataVersion:self.downloadDataVersion];
    
    // handle success
    if (result){
        if (_downloadDataSuccessBlock != NULL){
            _downloadDataSuccessBlock(NO, self.downloadDataVersion);
        }
    }
    else{
        if (_downloadDataFailureBlock != NULL){
            _downloadDataFailureBlock([NSError errorWithDomain:@"Process Data Failure" code:SMART_DATA_PROCESS_ERROR userInfo:nil]);
        }
    }
    
    [self releaseBlocks];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    PPDebug(@"Download %@ requestFailed, error=%@", self.name, [[request error] description]);
    
    // handle failure
    if (_downloadDataFailureBlock != NULL){
        _downloadDataFailureBlock([request error]);
    }
    
    [self releaseBlocks];
}

#pragma mark - Download Delegate

- (void)setProgress:(float)newProgress
{
    PPDebug(@"Download %@ progress=%f", self.name, newProgress);
}



@end
