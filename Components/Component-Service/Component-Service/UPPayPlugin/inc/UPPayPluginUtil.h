//
//  UPPayPluginUtil.h
//  Travel
//
//  Created by haodong on 13-1-30.
//
//

#import <Foundation/Foundation.h>
#import "UPPayPluginDelegate.h"

@interface UPPayPluginUtil : NSObject

+ (BOOL)startPay:(NSString *)payData
      sysProvide:(NSString*) sysProvide
            spId:(NSString*)spId
            mode:(NSString*)mode
  viewController:(UIViewController *)viewController
        delegate:(id<UPPayPluginDelegate>)delegate;

@end
