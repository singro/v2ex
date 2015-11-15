//
//  SPViewController+NaviBar.h
//  newSponia
//
//  Created by Singro on 5/19/14.
//  Copyright (c) 2014 Sponia. All rights reserved.
//

#import "SCNavigationItem.h"
#import "SCBarButtonItem.h"

@interface UIViewController (SCNavigation)

@property (nonatomic, strong) SCNavigationItem *sc_navigationItem;
@property (nonatomic, strong) UIView *sc_navigationBar;

@property(nonatomic, getter = sc_isNavigationBarHidden) BOOL sc_navigationBarHidden;

- (void)sc_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated;



//- (void)configureBarItemsShowing:(BOOL)isShowing;

- (SCBarButtonItem *)createBackItem;

- (void)naviBeginRefreshing;
- (void)naviEndRefreshing;

- (void)createNavigationBar;


@end
