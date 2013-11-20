//
//  CommonSplashAdService.h
//  Draw
//
//  Created by qqn_pipi on 13-5-4.
//
//

#import <Foundation/Foundation.h>

// Genders to help deliver more relevant ads.
typedef enum {
    kAdUserGenderUnknown,
    kAdUserGenderMale,
    kAdUserGenderFemale
} AdUserGender;

@protocol SplashAdServiceProtocol <NSObject>

- (id)initWithPublisherId:(NSString *)publisherId   // PublisherId
                   window:(UIWindow *)keyWindow     // 用于呈现开屏广告的Key Window
               background:(UIImage *)image          // 开屏广告出现前的背景颜色、图片（默认为黑色）
                animation:(BOOL)yesOrNo;            // 开屏广告关闭时，是否使用渐变动画（默认有关闭动画）


- (void)present;

@end

@interface CommonSplashAdService : NSObject<SplashAdServiceProtocol>
{
    
}

@property (nonatomic, retain) NSString* adPubliserId;
@property (nonatomic, assign) AdUserGender gender;

- (void)setGender:(AdUserGender)gender;

@end
