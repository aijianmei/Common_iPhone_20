//
//  EGORefreshTableViewConstant.h
//  Travel
//
//  Created by 小涛 王 on 12-6-7.
//  Copyright (c) 2012年 甘橙软件. All rights reserved.
//

#ifndef Travel_EGORefreshTableViewConstant_h
#define Travel_EGORefreshTableViewConstant_h

#pragma mark - User interface 

#define BACKGROUND_COLOR [UIColor colorWithRed:226.0/255.0 green:231.0/255.0 blue:237.0/255.0 alpha:1.0]
#define TEXT_COLOR	 [UIColor colorWithRed:87.0/255.0 green:108.0/255.0 blue:137.0/255.0 alpha:1.0]
#define FLIP_ANIMATION_DURATION 0.18f


#pragma mark - Localize string table

#define LOCALIZE_STRING_TABLE @"EGORefreshTableHeaderView"

#define kAM		NSLocalizedStringFromTable(@"kAM", LOCALIZE_STRING_TABLE, nil)
#define kPM		NSLocalizedStringFromTable(@"kPM", LOCALIZE_STRING_TABLE, nil)

#define kLastUpdatedDate NSLocalizedStringFromTable(@"kLastUpdatedDate", LOCALIZE_STRING_TABLE, nil)

#define kPullDownToRefresh NSLocalizedStringFromTable(@"kPullDownToRefresh", LOCALIZE_STRING_TABLE, nil)
#define kReleaseToRefresh NSLocalizedStringFromTable(@"kReleaseToRefresh", LOCALIZE_STRING_TABLE, nil)
#define kLoading NSLocalizedStringFromTable(@"kLoading", LOCALIZE_STRING_TABLE, nil)

#define kPullUpToLoadMore NSLocalizedStringFromTable(@"kPullUpToLoadMore", LOCALIZE_STRING_TABLE, nil)
#define kReleaseToLoadMore NSLocalizedStringFromTable(@"kReleaseToLoadMore", LOCALIZE_STRING_TABLE, nil)
#define kMore NSLocalizedStringFromTable(@"kMore", LOCALIZE_STRING_TABLE, nil)

#endif
