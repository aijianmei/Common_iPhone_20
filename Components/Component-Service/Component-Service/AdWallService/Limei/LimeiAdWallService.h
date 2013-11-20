//
//  LimeiAdWallService.h
//  Draw
//
//  Created by qqn_pipi on 13-3-16.
//
//

#import <Foundation/Foundation.h>
#import <immobSDK/immobView.h>
#import "CommonAdWallService.h"

@interface LimeiAdWallService : CommonAdWallService<immobViewDelegate>

@property (nonatomic, retain)immobView *adWallView;

@end
