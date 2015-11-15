//
//  SCNavigationController.h
//  newSponia
//
//  Created by Singro on 2/19/14.
//  Copyright (c) 2014 Sponia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCNavigationController : UINavigationController

@property (nonatomic, assign) BOOL enableInnerInactiveGesture;

+ (void)createNavigationBarForViewController:(UIViewController *)viewController;

@end

static NSString * const kRootViewControllerResetDelegateNotification = @"RootViewControllerResetDelegateNotification";
static NSString * const kRootViewControllerCancelDelegateNotification = @"RootViewControllerCancelDelegateNotification";