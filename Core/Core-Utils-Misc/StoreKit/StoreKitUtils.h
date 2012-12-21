//
//  StoreKitUtils.h
//  Draw
//
//  Created by  on 12-4-23.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    VERIFY_OK = 0,
    VERIFY_UNKNOWN = -1,
    VERIFY_INVALID_PRODUCT_ID = 99998,
    VERIFY_FAKE_IAP = 99999,
    
} TransactionVerifyResult;

@interface StoreKitUtils : NSObject

+ (TransactionVerifyResult)verifyReceipt:(NSString*)transactionReceipt 
                         productIdPrefix:(NSString*)productIdPrefix;

@end
