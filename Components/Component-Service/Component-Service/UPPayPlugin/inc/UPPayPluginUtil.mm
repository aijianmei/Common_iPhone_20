//
//  UPPayPluginUtil.m
//  Travel
//
//  Created by haodong on 13-1-30.
//
//

#import "UPPayPluginUtil.h"
#import "UPPayPlugin.h"

@implementation UPPayPluginUtil

+ (BOOL)startPay:(NSString *)payData
      sysProvide:(NSString*)sysProvide
            spId:(NSString*)spId
            mode:(NSString*)mode
  viewController:(UIViewController *)viewController
        delegate:(id<UPPayPluginDelegate>)delegate
{
    return [UPPayPlugin startPay:payData
                      sysProvide:sysProvide
                            spId:spId
                            mode:mode
                  viewController:viewController
                        delegate:delegate];
}

@end
