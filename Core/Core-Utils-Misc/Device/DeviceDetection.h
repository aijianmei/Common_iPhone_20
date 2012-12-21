//
//  DeviceDetection.h
//  three20test
//
//  Created by qqn_pipi on 10-4-14.
//  Copyright 2010 QQN-PIPI.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sys/utsname.h>

enum {
	MODEL_UNKNOWN,
    MODEL_IPHONE_SIMULATOR,
    MODEL_IPOD_TOUCH,
	MODEL_IPOD_TOUCH_2G,
	MODEL_IPOD_TOUCH_3G,
	MODEL_IPOD_TOUCH_4G,
    MODEL_IPHONE,
	MODEL_IPHONE_3G,
	MODEL_IPHONE_3GS,
	MODEL_IPHONE_4G,
    MODEL_IPHONE_4GS,
    MODEL_IPHONE_5G,
	MODEL_IPAD
};

typedef enum{
    DeviceTypeIPhone = 1,
    DeviceTypeIPad = 2,
}DeviceType;

typedef enum{
    DEVICE_SCREEN_IPHONE,
    DEVICE_SCREEN_IPHONE5,
    DEVICE_SCREEN_IPAD,
    DEVICE_SCREEN_NEW_IPAD
} DeviceScreenType;


@interface DeviceDetection : NSObject

+ (uint) detectDevice;
+ (int) detectModel;
+ (NSString *)platform;

+ (NSString *) returnDeviceName:(BOOL)ignoreSimulator;
+ (BOOL) isIPodTouch;
+ (BOOL) isOS4;
+ (BOOL) isOS5;
+ (BOOL) isOS6;
+ (BOOL) canSendSms;
+ (BOOL) isIPAD;
+ (BOOL) isIPhone5;

+ (NSString *)deviceOS;
+ (NSString *)platform;
+ (BOOL) isRetinaDisplay;

+ (CGSize)screenSize;
+ (DeviceType)deviceType;
+ (DeviceScreenType)deviceScreenType;
+ (NSString*)deviceScreenTypeString;

+ (int)freeMemory;
+ (int)totalMemory;

+ (BOOL)isSimulator;

@end