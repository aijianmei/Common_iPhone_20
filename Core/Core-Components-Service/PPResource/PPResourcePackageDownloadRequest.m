//
//  PPResourcePackageDownloadRequest.m
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import "PPResourcePackageDownloadRequest.h"
#import "PPResourcePackage.h"
#import "PPResourceUtils.h"
#import "PPResource.h"

@implementation PPResourcePackageDownloadRequest

- (void)dealloc
{
    [_resourcePackage release];
    [_url release];
    [_httpRequest release];
    [super dealloc];
}

- (id)initWithURL:(NSURL*)url resourcePackage:(PPResourcePackage*)resourcePackage
{
    self = [super init];
    
    self.url = url;
    self.resourcePackage = resourcePackage;    
    return self;
}


// downloadView is useless now... to be removed
- (void)startDownloadWithDownloadView:(UIView*)downloadView async:(BOOL)async
{
    if (_httpRequest == nil || [_httpRequest isFinished]){
        self.httpRequest = [ASIHTTPRequest requestWithURL:_url];
    }    
    
    if ([_httpRequest isExecuting]){
        return;
    }
    
    // inc download times for later usage
    self.resourcePackage.downloadRetryTimes = self.resourcePackage.downloadRetryTimes + 1;
    
    _httpRequest.delegate = self;
    [_httpRequest setAllowCompressedResponse:YES];
    [_httpRequest setUsername:DEFAULT_HTTP_USER_NAME];
    [_httpRequest setPassword:DEFAULT_HTTP_PASSWORD];
    
    NSString* destPath = [PPResourceUtils getResourcePackageFilePath:_resourcePackage.name];
    [_httpRequest setDownloadDestinationPath:destPath];
    
    NSString* tempPath = [PPResourceUtils getTempResourcePackageFilePath:_resourcePackage.name];
    [_httpRequest setTemporaryFileDownloadPath:tempPath];
    
    [_httpRequest setDownloadProgressDelegate:self];
    [_httpRequest setAllowResumeForFileDownloads:YES];
    
    PPDebug(@"Download resource URL=%@, Local Temp=%@, Store At=%@",
            _url.absoluteString, tempPath, destPath);
    
    if (async){
        [_httpRequest startAsynchronous];
    }
    else{
        [_httpRequest startSynchronous];
    }
}

- (void)startDownload
{
    [self startDownloadWithDownloadView:nil async:YES];
}

- (void)startBackgroundDownload
{
    [self startDownloadWithDownloadView:nil async:YES];
}


#pragma mark - ASIHttpRequest Delegate

- (void)requestStarted:(ASIHTTPRequest *)request
{
    PPDebug(@"<PPResourcePackageDownloadRequest> %@ requestStarted", self.resourcePackage.name);
    [self.resourcePackage processAfterDownloadStarted];
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    PPDebug(@"<PPResourcePackageDownloadRequest> %@ didReceiveResponseHeaders", self.resourcePackage.name);
}

- (void)request:(ASIHTTPRequest *)request willRedirectToURL:(NSURL *)newURL
{
    PPDebug(@"<PPResourcePackageDownloadRequest> %@ willRedirectToURL", self.resourcePackage.name);
}

- (void)requestFinished:(ASIHTTPRequest *)request
{
    PPDebug(@"<PPResourcePackageDownloadRequest> %@ requestFinished", self.resourcePackage.name);
    [self.resourcePackage processAfterDownloadSuccess];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    PPDebug(@"<PPResourcePackageDownloadRequest> %@ requestFailed, error=%@", self.resourcePackage.name, [[request error] description]);
    [self.resourcePackage processDownloadFailure:[request error]];
}

#pragma mark - Download Delegate

- (void)setProgress:(float)newProgress
{
    PPDebug(@"<PPResourcePackageDownloadRequest> %@ progress=%f", self.resourcePackage.name, newProgress);
    [self.resourcePackage updateDownloadProgress:newProgress];
}

@end
