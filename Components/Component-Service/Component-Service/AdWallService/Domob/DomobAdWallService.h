//
//  DomobAdWallService.h
//  Draw
//
//  Created by Kira on 13-4-23.
//
//

#import "CommonAdWallService.h"
#import "DMOfferWallViewController.h"

@interface DomobAdWallService : CommonAdWallService <DMOfferWallDelegate>{
    DMOfferWallViewController* _dmController;
}

@end
