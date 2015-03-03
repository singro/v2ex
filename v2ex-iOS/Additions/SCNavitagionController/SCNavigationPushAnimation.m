//
//  SCNavigationPushAnimation.m
//  v2ex-iOS
//
//  Created by Singro on 5/25/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCNavigationPushAnimation.h"

@interface SCNavigationPushAnimation ()
//
//@property (nonatomic, strong) UIView *leftView;
//@property (nonatomic, strong) UIView *rightView;

@end


@implementation SCNavigationPushAnimation


- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = (UIViewController*)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *containerView = [transitionContext containerView];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    
    //    toViewController.view.frame = [transitionContext finalFrameForViewController:toViewController];
    [containerView addSubview:fromViewController.view];
    [containerView addSubview:toViewController.view];
    fromViewController.view.frame = CGRectMake(0, 0, kScreenWidth, CGRectGetHeight(fromViewController.view.frame));
    toViewController.view.frame = CGRectMake(kScreenWidth, 0, kScreenWidth, CGRectGetHeight(toViewController.view.frame));
    
    // Configure Navi Transition

    UIView *naviBarView;
    
    UIView *toNaviLeft;
    UIView *toNaviRight;
    UIView *toNaviTitle;
    
    UIView *fromNaviLeft;
    UIView *fromNaviRight;
    UIView *fromNaviTitle;
    
    if (fromViewController.sc_isNavigationBarHidden || toViewController.sc_isNavigationBarHidden) {
        ;
    } else {

        naviBarView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 64}];
        naviBarView.backgroundColor = kNavigationBarColor;
        [containerView addSubview:naviBarView];

        UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){0, 64, kScreenWidth, 0.5}];
        lineView.backgroundColor = kNavigationBarLineColor;
        [naviBarView addSubview:lineView];

        toNaviLeft = toViewController.sc_navigationItem.leftBarButtonItem.view;
        toNaviRight = toViewController.sc_navigationItem.rightBarButtonItem.view;
        toNaviTitle = toViewController.sc_navigationItem.titleLabel;
        
        fromNaviLeft = fromViewController.sc_navigationItem.leftBarButtonItem.view;
        fromNaviRight = fromViewController.sc_navigationItem.rightBarButtonItem.view;
        fromNaviTitle = fromViewController.sc_navigationItem.titleLabel;

        [containerView addSubview:toNaviLeft];
        [containerView addSubview:toNaviTitle];
        [containerView addSubview:toNaviRight];
        
        [containerView addSubview:fromNaviLeft];
        [containerView addSubview:fromNaviTitle];
        [containerView addSubview:fromNaviRight];
        
        fromNaviLeft.alpha = 1.0;
        fromNaviRight.alpha =  1.0;
        fromNaviTitle.alpha = 1.0;
        
        toNaviLeft.alpha = 0.0;
        toNaviRight.alpha = 0.0;
        toNaviTitle.alpha = 0.0;
        toNaviTitle.centerX = 44;

        toNaviLeft.x = 0;
        toNaviTitle.centerX = kScreenWidth;
        toNaviRight.x = kScreenWidth + 50 - toNaviRight.width;
    
    }
    
    // End configure

    [UIView animateWithDuration:duration animations:^{
        toViewController.view.x = 0;
        fromViewController.view.x = -120;

        fromNaviLeft.alpha = 0;
        fromNaviRight.alpha =  0;
        fromNaviTitle.alpha = 0;
        fromNaviTitle.centerX = 0;
        
        toNaviLeft.alpha = 1.0;
        toNaviRight.alpha = 1.0;
        toNaviTitle.alpha = 1.0;
        toNaviTitle.centerX = kScreenWidth/2;
        toNaviLeft.x = 0;
        toNaviRight.x = kScreenWidth - toNaviRight.width;

        
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        
        fromNaviLeft.alpha = 1.0;
        fromNaviRight.alpha = 1.0;
        fromNaviTitle.alpha = 1.0;
        fromNaviTitle.centerX = kScreenWidth / 2;
        fromNaviLeft.x = 0;
        fromNaviRight.x = kScreenWidth - fromNaviRight.width;
        
        [naviBarView removeFromSuperview];

        [toNaviLeft removeFromSuperview];
        [toNaviTitle removeFromSuperview];
        [toNaviRight removeFromSuperview];
        
        [fromNaviLeft removeFromSuperview];
        [fromNaviTitle removeFromSuperview];
        [fromNaviRight removeFromSuperview];
        
        [toViewController.sc_navigationBar addSubview:toNaviLeft];
        [toViewController.sc_navigationBar addSubview:toNaviTitle];
        [toViewController.sc_navigationBar addSubview:toNaviRight];

        [fromViewController.sc_navigationBar addSubview:fromNaviLeft];
        [fromViewController.sc_navigationBar addSubview:fromNaviTitle];
        [fromViewController.sc_navigationBar addSubview:fromNaviRight];
        
    }];
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.3;
}

@end
