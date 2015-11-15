//
//  SCNavigationController.m
//  newSponia
//
//  Created by Singro on 2/19/14.
//  Copyright (c) 2014 Sponia. All rights reserved.
//

#import "SCNavigationController.h"

#import "SCNavigationPopAnimation.h"
#import "SCNavigationPushAnimation.h"

#import "V2RootViewController.h"
#import "V2AppDelegate.h"

#import "V2NavigationBar.h"

@interface SCNavigationController ()  <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIPanGestureRecognizer *panRecognizer;
@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *interactivePopTransition;

@property (nonatomic, assign) UIViewController *lastViewController;

@end

@implementation SCNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController {
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        
        self.enableInnerInactiveGesture = YES;
        
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        
        self.enableInnerInactiveGesture = YES;
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    self.navigationBar.barStyle = UIBarStyleBlack;
//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.navigationBarHidden = YES;
    
    self.interactivePopGestureRecognizer.delegate = self;
    super.delegate = self;
    
    self.panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanRecognizer:)];
    V2AppDelegate *appDelegate = (V2AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.currentNavigationController = self;
    
}

#pragma mark - UINavigationDelegate

// forbid User VC to be NavigationController's delegate
- (void)setDelegate:(id<UINavigationControllerDelegate>)delegate {
}

#pragma mark - Push & Pop

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kRootViewControllerCancelDelegateNotification object:nil];
    [self configureNavigationBarForViewController:viewController];

    [super pushViewController:viewController animated:animated];
    
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated {
    
    return [super popViewControllerAnimated:animated];
    
}

#pragma mark UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
}

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animate
{

    [viewController.view bringSubviewToFront:viewController.sc_navigationBar];
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        if (navigationController.viewControllers.count == 1) {
            self.interactivePopGestureRecognizer.delegate = nil;
            self.delegate = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:kRootViewControllerResetDelegateNotification object:nil];
            self.interactivePopGestureRecognizer.enabled = NO;
        } else {
            self.interactivePopGestureRecognizer.enabled = YES;
        }
    }
    
    if (self.enableInnerInactiveGesture) {
        BOOL hasPanGesture = NO;
        BOOL hasEdgePanGesture = NO;
        for (UIGestureRecognizer *recognizer in [viewController.view gestureRecognizers]) {
            if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                if ([recognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
                    hasEdgePanGesture = YES;
                } else {
                    hasPanGesture = YES;
                }
            }
        }
        if (!hasPanGesture && (navigationController.viewControllers.count > 1)) {
            [viewController.view addGestureRecognizer:self.panRecognizer];
        }
    }

    viewController.navigationController.delegate = self;
    
    V2AppDelegate *appDelegate = (V2AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.currentNavigationController = (SCNavigationController *)viewController.navigationController;
    
}


// Animation
- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController
                                  animationControllerForOperation:(UINavigationControllerOperation)operation
                                               fromViewController:(UIViewController *)fromVC
                                                 toViewController:(UIViewController *)toVC {
    
    if (operation == UINavigationControllerOperationPop && navigationController.viewControllers.count >= 1 && self.enableInnerInactiveGesture) {
        return [[SCNavigationPopAnimation alloc] init];
    } else if (operation == UINavigationControllerOperationPush) {
        SCNavigationPushAnimation *animation = [[SCNavigationPushAnimation alloc] init];
        return animation;
    } else {
        return nil;
    }
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController
                         interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController {
    if ([animationController isKindOfClass:[SCNavigationPopAnimation class]] && self.enableInnerInactiveGesture) {
        return self.interactivePopTransition;
    }
    else {
        return nil;
    }
}


- (void)handlePanRecognizer:(UIPanGestureRecognizer*)recognizer {
    
    if (!self.enableInnerInactiveGesture) {
        return;
    }
    
    static CGFloat startLocationX = 0;
    
    CGPoint location = [recognizer locationInView:self.view];
    
    CGFloat progress = (location.x - startLocationX) / kScreenWidth;
    progress = MIN(1.0, MAX(0.0, progress));
    
//    NSLog(@"progress:   %.2f", progress);
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        startLocationX = location.x;
        self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
        [self popViewControllerAnimated:YES];
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        
        [self.interactivePopTransition updateInteractiveTransition:progress];
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        CGFloat velocityX = [recognizer velocityInView:self.view].x;
        if (progress > 0.3 || velocityX > 300) {
            self.interactivePopTransition.completionSpeed = 0.4;
            [self.interactivePopTransition finishInteractiveTransition];
        }
        else {
            self.interactivePopTransition.completionSpeed = 0.3;
            [self.interactivePopTransition cancelInteractiveTransition];
        }
        
        self.interactivePopTransition = nil;
    }
}

/*
 - (void)handleEdgePanRecognizer:(UIScreenEdgePanGestureRecognizer *)recognizer {
 CGFloat progress = [recognizer translationInView:self.view].x / (self.view.bounds.size.width);
 progress = MIN(1.0, MAX(0.0, progress));
 NSLog(@"percent:  %.2f", progress);
 
 if (recognizer.state == UIGestureRecognizerStateBegan) {
 
 self.interactivePopTransition = [[UIPercentDrivenInteractiveTransition alloc] init];
 [self popViewControllerAnimated:YES];
 
 }
 else if (recognizer.state == UIGestureRecognizerStateChanged) {
 
 [self.interactivePopTransition updateInteractiveTransition:progress];
 
 }
 else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
 
 if (progress > 0.4) {
 self.interactivePopTransition.completionSpeed = 0.4;
 [self.interactivePopTransition finishInteractiveTransition];
 }
 else {
 self.interactivePopTransition.completionSpeed = 0.4;
 [self.interactivePopTransition cancelInteractiveTransition];
 }
 
 self.interactivePopTransition = nil;
 
 }
 
 }
 
 */

#pragma mark - Private Helper

//- (UIView *)createNavigationBar {
//    
//    V2NavigationBar *navigationBar = [[V2NavigationBar alloc] initWithFrame:(CGRect){0, 0, 320, 64}];
//    navigationBar.backgroundColor = kNavigationBarColor;
//    
//    UIView *lineView = [[UIView alloc] initWithFrame:(CGRect){0, 64, 320, 0.5}];
//    lineView.backgroundColor = kNavigationBarLineColor;
//    [navigationBar addSubview:lineView];
//
//    return navigationBar;
//}

- (void)configureNavigationBarForViewController:(UIViewController *)viewController {
    
    [[self class] createNavigationBarForViewController:viewController];

}

+ (void)createNavigationBarForViewController:(UIViewController *)viewController {
    
    if (!viewController.sc_navigationItem) {
        SCNavigationItem *navigationItem = [[SCNavigationItem alloc] init];
        [navigationItem setValue:viewController forKey:@"_sc_viewController"];
        viewController.sc_navigationItem = navigationItem;
    }
    if (!viewController.sc_navigationBar) {
        viewController.sc_navigationBar = [[V2NavigationBar alloc] init];
        [viewController.view addSubview:viewController.sc_navigationBar];
    }
    
}


@end
