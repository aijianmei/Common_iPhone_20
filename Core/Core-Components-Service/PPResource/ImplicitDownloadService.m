//
//  ImplicitDownloadService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-5.
//
//

#import "ImplicitDownloadService.h"
#import "NSMutableArray+Queue.h"
#import "Reachability.h"

@interface ImplicitDownloadService ()

@property (nonatomic, retain) NSMutableArray* downloadQueue;
@property (nonatomic, assign) BOOL isExecuting;
@property (nonatomic, retain) NSTimer* timer;

@end

@implementation ImplicitDownloadService

static ImplicitDownloadService* _defaultImplicitDownloadService = nil;
static dispatch_once_t onceToken;

+ (ImplicitDownloadService*)defaultService
{
    // thread safe singleton implementation
    dispatch_once(&onceToken, ^{
        _defaultImplicitDownloadService = [[ImplicitDownloadService alloc] init];
    });
    
    return _defaultImplicitDownloadService;
}

#define RETRY_DOWNLOAD_INTERVAL 30

- (id)init
{
    self = [super init];
    _downloadQueue = [[NSMutableArray alloc] init];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:RETRY_DOWNLOAD_INTERVAL
                                                  target:self
                                                selector:@selector(executeDownload)
                                                userInfo:nil
                                                 repeats:YES];
    return self;
}

- (void)dealloc
{
    [_downloadQueue release];
    [_timer release];
    [super dealloc];
}

- (void)executeDownload
{
    Reachability* reachability = [Reachability reachabilityForInternetConnection];
    if ([reachability currentReachabilityStatus] != ReachableViaWiFi){
        PPDebug(@"PPResource <executeDownload> implicitly, but current network is NOT wifi");
        return;
    }
    
    int queueCount = [_downloadQueue count];
    if (queueCount > 0 && _isExecuting == NO){
        PPResourcePackage* resourcePackage = nil;
        
        while ((resourcePackage = [_downloadQueue dequeue]) != nil){
            if ([resourcePackage isExists] == NO){
                _isExecuting = YES;
                [resourcePackage startDownloadWithDownloadView:nil
                                                       success:^(BOOL alreadyExisted) {
                                                           _isExecuting = NO;
                                                           [self executeDownload]; // download next one
                                                       }
                                                       failure:^(NSError *error, UIView *downloadView) {
                                                           _isExecuting = NO;
                                                           [self executeDownload]; // download next one
                                                           [_downloadQueue enqueue:resourcePackage];
                                                       }];
                
                break;
            }
        }
        
        
    }
    
}

- (void)downloadResourcePackage:(PPResourcePackage*)rp
{
    [_downloadQueue enqueue:rp];
    [self executeDownload];
}

@end
