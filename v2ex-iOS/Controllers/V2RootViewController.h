//
//  V2RootViewController.h
//  v2ex-iOS
//
//  Created by Singro on 3/17/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, V2SectionIndex) {
    V2SectionIndexLatest       = 0,
    V2SectionIndexCategories   = 1,
    V2SectionIndexNodes        = 2,
    V2SectionIndexFavorite     = 3,
    V2SectionIndexNotification = 4,
    V2SectionIndexProfile      = 5,
};

@interface V2RootViewController : UIViewController

- (void)showViewControllerAtIndex:(V2SectionIndex)index animated:(BOOL)animated;

@end
