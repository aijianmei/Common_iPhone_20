//
//  RewardedWallViewController.h
//  YouMiSDK_Sample_Wall
//
//  Created by  on 12-1-5.
//  Copyright (c) 2012年 YouMi Mobile Co. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"


@interface RewardedWallViewController : UITableViewController {
    
    NSInteger point;  // 用户的积分
    
    
    // 
    YouMiWall *wall;
    NSMutableArray *openApps;
}

@end
