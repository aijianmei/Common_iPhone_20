//
//  YoumiAdWallService.h
//  Draw
//
//  Created by qqn_pipi on 13-3-20.
//
//

#import <Foundation/Foundation.h>
#import "CommonAdWallService.h"
#import "YouMiWallDelegateProtocol.h"

@class YouMiWall;

@interface YoumiAdWallService : CommonAdWallService<YouMiWallDelegate>
{
    YouMiWall *_wall;
    BOOL _isShowWall;
}

@end
