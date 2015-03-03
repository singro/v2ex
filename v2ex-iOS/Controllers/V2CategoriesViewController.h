//
//  V2CategoriesViewController.h
//  v2ex-iOS
//
//  Created by Singro on 4/7/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCPullRefreshViewController.h"

@interface V2CategoriesViewController : SCPullRefreshViewController

@property (nonatomic, assign, getter = isFavorite) BOOL favorite;

@end
