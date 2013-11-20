//
//  AderWallService.h
//  Draw
//
//  Created by qqn_pipi on 13-3-20.
//
//

#import <Foundation/Foundation.h>
#import "CommonAdWallService.h"
#import "AderPointWall.h"

@interface AderAdWallService : CommonAdWallService<AderWallDelegate>
{
    AderPointWall* _wall;
    BOOL _isShowWall;
}


@end
