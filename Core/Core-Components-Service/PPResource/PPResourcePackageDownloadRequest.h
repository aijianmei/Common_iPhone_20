//
//  PPResourcePackageDownloadRequest.h
//  Draw
//
//  Created by qqn_pipi on 12-11-3.
//
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"

@class PPResourcePackage;

@interface PPResourcePackageDownloadRequest : NSObject

@property (nonatomic, retain) PPResourcePackage* resourcePackage;
@property (nonatomic, retain) NSURL* url;
@property (nonatomic, retain) ASIHTTPRequest* httpRequest;

- (id)initWithURL:(NSURL*)url resourcePackage:(PPResourcePackage*)resourcePackage;
- (void)startDownload;
- (void)startBackgroundDownload;

@end
