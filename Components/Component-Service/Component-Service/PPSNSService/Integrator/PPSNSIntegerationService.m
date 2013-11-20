//
//  PPSNSIntegerationService.m
//  Draw
//
//  Created by qqn_pipi on 12-11-16.
//
//

#import "PPSNSIntegerationService.h"
#import "PPSNSConstants.h"

@interface PPSNSIntegerationService()

@property (nonatomic, retain) NSMutableDictionary* allSNSServices;

@end

@implementation PPSNSIntegerationService

static PPSNSIntegerationService* _defaultSNSIntegrationService = nil;
static dispatch_once_t onceToken;

+ (PPSNSIntegerationService*)defaultService
{
    // thread safe singleton implementation
    dispatch_once(&onceToken, ^{
        _defaultSNSIntegrationService = [[PPSNSIntegerationService alloc] init];
    });
    
    return _defaultSNSIntegrationService;
}

- (id)init
{
    self = [super init];
    _allSNSServices = [[NSMutableDictionary alloc] init];
    return self;
}

- (void)dealloc
{
    [_allSNSServices release];
    [super dealloc];
}

- (void)addSNS:(PPSNSCommonService*)service
{
    [_allSNSServices setObject:service forKey:[NSNumber numberWithInt:[service getSNSType]]];
}

- (PPSNSCommonService*)snsServiceByType:(int)type
{
    return [_allSNSServices objectForKey:[NSNumber numberWithInt:type]];
}

- (void)publishWeiboToAll:(NSString*)text
            imageFilePath:(NSString*)imageFilePath
             successBlock:(PPSNSSuccessWithSNSTypeBlock)successBlock
             failureBlock:(PPSNSFailureWithSNSTypeBlock)failureBlock
{
    NSArray* allValues = [_allSNSServices allValues];
    for (PPSNSCommonService* snsService in allValues){

        // copy to retain succ & failure block
        PPSNSSuccessWithSNSTypeBlock succBlockCopy = NULL;
        PPSNSFailureWithSNSTypeBlock failBlockCopy = NULL;
        if (successBlock != NULL)
            succBlockCopy = Block_copy(successBlock);
        if (failureBlock != NULL)
            failBlockCopy = Block_copy(failureBlock);
        
        [snsService publishWeibo:text
                   imageFilePath:imageFilePath
                    successBlock:^(NSDictionary *userInfo) {
                        
                        // call success block
                        if (succBlockCopy != NULL){
                            succBlockCopy([snsService getSNSType], snsService, nil);
                            Block_release(succBlockCopy);
                        }
                        
                        // release failure block
                        if (failBlockCopy != NULL){
                            Block_release(failBlockCopy);
                        }
                        
                    } failureBlock:^(NSError *error) {
                        
                        // call failure block
                        if (failBlockCopy != NULL){
                            failBlockCopy([snsService getSNSType], snsService, nil);
                            Block_release(failureBlock);
                        }
        
                        // release success block
                        if (succBlockCopy != NULL){
                            Block_release(succBlockCopy);
                        }
                    }];
    }
}

- (BOOL)handleOpenURL:(NSURL*)url
{
    NSString* urlString = [url absoluteString];
    PPSNSCommonService* service = nil;
    
    if ([urlString hasPrefix:@"sina"]){
        service = [self snsServiceByType:TYPE_SINA];
    }
    else if ([urlString hasPrefix:@"fb"]){
        service = [self snsServiceByType:TYPE_FACEBOOK];
    }
    
    if (service == nil)
        return NO;

    [service handleOpenURL:url];
    return YES;
}

@end
