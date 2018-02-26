//
//  V2RootViewController.m
//  v2ex-iOS
//
//  Created by Singro on 3/17/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2RootViewController.h"

#import "SCNavigationController.h"
#import "UIView+SafeArea.h"

#import "V2LatestViewController.h"
#import "V2CategoriesViewController.h"
#import "V2NodesViewController.h"
#import "V2FavoriteViewController.h"
#import "V2NotificationViewController.h"
#import "V2ProfileViewController.h"

#import "V2LoginViewController.h"

#import "UIView+REFrosted.h"
#import "UIImage+REFrosted.h"

#import "V2MenuView.h"

static CGFloat const kMenuWidth = 240.0;

@interface V2RootViewController () <UIGestureRecognizerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) V2LatestViewController       *latestViewController;
@property (nonatomic, strong) V2CategoriesViewController   *categoriesViewController;
@property (nonatomic, strong) V2NodesViewController        *nodesViewController;
@property (nonatomic, strong) V2CategoriesViewController     *favouriteViewController;
@property (nonatomic, strong) V2NotificationViewController *notificationViewController;
@property (nonatomic, strong) V2ProfileViewController      *profileViewController;

@property (nonatomic, strong) SCNavigationController       *latestNavigationController;
@property (nonatomic, strong) SCNavigationController       *categoriesNavigationController;
@property (nonatomic, strong) SCNavigationController       *nodesNavigationController;
@property (nonatomic, strong) SCNavigationController       *favoriteNavigationController;
@property (nonatomic, strong) SCNavigationController       *nofificationNavigationController;
@property (nonatomic, strong) SCNavigationController       *profilenavigationController;

@property (nonatomic, strong) V2MenuView *menuView;
@property (nonatomic, strong) UIView *viewControllerContainView;

@property (nonatomic, strong) UIButton   *rootBackgroundButton;
@property (nonatomic, strong) UIImageView *rootBackgroundBlurView;
//@property (nonatomic, strong) UIView     *naviBottomLineView;

@property (nonatomic, strong) UIScreenEdgePanGestureRecognizer *edgePanRecognizer;

@property (nonatomic, assign) NSInteger currentSelectedIndex;

@end

@implementation V2RootViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.currentSelectedIndex = 0;
        
        [V2SettingManager manager];
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self configureViewControllers];
    [self configureViews];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
 
    [self configureGestures];
    [self configureNotifications];
    
    
//    [UINavigationBar appearance].tintColor = [UIColor blackColor];
//    [UINavigationBar appearance].titleTextAttributes = @{
//                                                         NSForegroundColorAttributeName:[UIColor blackColor],
//                                                         NSFontAttributeName:[UIFont systemFontOfSize:17]};
    self.edgesForExtendedLayout = UIRectEdgeAll;
    self.automaticallyAdjustsScrollViewInsets = NO;
}

#pragma mark - Life Cycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.edgePanRecognizer.delegate                                    = self;
    self.navigationController.delegate                                 = self;
    self.navigationController.interactivePopGestureRecognizer.delegate = self;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    [self setBlurredScreenShoot];
    
    NSLog(@"status: %.f", UIView.sc_statusBarHeight);
    NSLog(@"navi: %.f", UIView.sc_navigationBarHeight);
    NSLog(@"naviEx: %.f", UIView.sc_navigationBarHeighExcludeStatusBar);

}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Layouts

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.viewControllerContainView.frame = self.view.frame;
    self.rootBackgroundButton.frame = self.view.frame;
    self.rootBackgroundBlurView.frame = self.view.frame;
    
}

#pragma mark - Configure Views

- (void)configureViews {

    // NaviButtonBorder
//    self.naviBottomLineView                 = [[UIView alloc] init];
//    self.naviBottomLineView.backgroundColor = [UIColor colorWithWhite:0.98 alpha:0.50];
//    self.naviBottomLineView.frame           = (CGRect){0, 64, 320, 0.5};
////    self.naviBottomLineView.hidden = YES;
//    [self.view addSubview:self.naviBottomLineView];

    self.rootBackgroundButton               = [UIButton buttonWithType:UIButtonTypeCustom];
    self.rootBackgroundButton.alpha = 0.0;
    self.rootBackgroundButton.backgroundColor = [UIColor blackColor];
    self.rootBackgroundButton.hidden = YES;
    [self.view addSubview:self.rootBackgroundButton];

    self.menuView                           = [[V2MenuView alloc] initWithFrame:(CGRect){-kMenuWidth, 0, kMenuWidth, kScreenHeight}];
    [self.view addSubview:self.menuView];
    
    // Handles
    @weakify(self);
    [self.rootBackgroundButton bk_whenTapped:^{
        @strongify(self);
        
        [UIView animateWithDuration:0.3 animations:^{
            [self setMenuOffset:0.0f];
        }];
    }];
    
    [self.menuView setDidSelectedIndexBlock:^(NSInteger index) {
        @strongify(self);
        
        [self showViewControllerAtIndex:index animated:YES];
        [V2SettingManager manager].selectedSectionIndex = index;
        
    }];
    
}

- (void)configureViewControllers {
    
    self.viewControllerContainView          = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, kScreenHeight}];
    [self.view addSubview:self.viewControllerContainView];
    

    self.latestViewController       = [[V2LatestViewController alloc] init];
    self.latestNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.latestViewController];

    self.categoriesViewController = [[V2CategoriesViewController alloc] init];
    self.categoriesNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.categoriesViewController];
    
    self.nodesViewController        = [[V2NodesViewController alloc] init];
    self.nodesNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.nodesViewController];

    self.favouriteViewController      = [[V2CategoriesViewController alloc] init];
    self.favouriteViewController.favorite = YES;
    self.favoriteNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.favouriteViewController];

    self.notificationViewController = [[V2NotificationViewController alloc] init];
    self.nofificationNavigationController = [[SCNavigationController alloc] initWithRootViewController:self.notificationViewController];

    self.profileViewController      = [[V2ProfileViewController alloc] init];
    self.profileViewController.isSelf = YES;
    self.profilenavigationController = [[SCNavigationController alloc] initWithRootViewController:self.profileViewController];

    [self.viewControllerContainView addSubview:[self viewControllerForIndex:[V2SettingManager manager].selectedSectionIndex].view];
    self.currentSelectedIndex = [V2SettingManager manager].selectedSectionIndex;
    
    self.rootBackgroundBlurView = [[UIImageView alloc] init];
    self.rootBackgroundBlurView.userInteractionEnabled = NO;
    self.rootBackgroundBlurView.alpha = 0.0;
    [self.viewControllerContainView addSubview:self.rootBackgroundBlurView];

    
}

- (void)configureNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveShowMenuNotification) name:kShowMenuNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveCancelInactiveDelegateNotifacation) name:kRootViewControllerCancelDelegateNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveResetInactiveDelegateNotification) name:kRootViewControllerResetDelegateNotification object:nil];
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kShowLoginVCNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        
        V2LoginViewController *loginViewController = [[V2LoginViewController alloc] init];
        [self presentViewController:loginViewController animated:YES completion:^{
            ;
        }];
        
    }];
    
}

- (void)configureGestures {
    
    self.edgePanRecognizer          = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleEdgePanRecognizer:)];
    self.edgePanRecognizer.edges    = UIRectEdgeLeft;
    self.edgePanRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.edgePanRecognizer];
    
    UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanRecognizer:)];
    panRecognizer.delegate = self;
    [self.rootBackgroundButton addGestureRecognizer:panRecognizer];
    
}

#pragma mark - Private Methods

- (void)showViewControllerAtIndex:(V2SectionIndex)index animated:(BOOL)animated {
    
    if (self.currentSelectedIndex != index) {
        
        @weakify(self);
        void (^showBlock)() = ^{
            @strongify(self);
            
            UIViewController *previousViewController = [self viewControllerForIndex:self.currentSelectedIndex];
            UIViewController *willShowViewController = [self viewControllerForIndex:index];
            
            if (willShowViewController) {
                                
                BOOL isViewInRootView = NO;
                for (UIView *subView in self.view.subviews) {
                    if ([subView isEqual:willShowViewController.view]) {
                        isViewInRootView = YES;
                    }
                }
                if (isViewInRootView) {
                    willShowViewController.view.x = 320;
                    [self.viewControllerContainView bringSubviewToFront:willShowViewController.view];
                } else {
                    [self.viewControllerContainView addSubview:willShowViewController.view];
                    willShowViewController.view.x = 320;
                }
                
                if (animated) {
                    [UIView animateWithDuration:0.2 animations:^{
                        previousViewController.view.x += 20;
                        
                    } completion:^(BOOL finished) {
                        
                    }];
                    
                    [UIView animateWithDuration:0.6 delay:0 usingSpringWithDamping:1 initialSpringVelocity:1.2 options:UIViewAnimationOptionCurveLinear animations:^{
                        willShowViewController.view.x = 0;
                    } completion:nil];
                    
                    [UIView animateWithDuration:0.3 delay:0.1 options:UIViewAnimationOptionCurveEaseOut animations:^{
                        [self setMenuOffset:0.0f];
                    } completion:nil];
                } else {
                    previousViewController.view.x += 20;
                    willShowViewController.view.x = 0;
                    [self setMenuOffset:0.0f];
                }
                
                self.currentSelectedIndex = index;
                
            }
            
        };
        
        showBlock();
        
    } else {
        
        UIViewController *willShowViewController = [self viewControllerForIndex:index];
        
        [UIView animateWithDuration:0.4 animations:^{
            willShowViewController.view.x = 0;
        } completion:^(BOOL finished) {
        }];
        [UIView animateWithDuration:0.5 animations:^{
            [self setMenuOffset:0.0f];
        }];

    }
    
    [self.menuView selectIndex:index];
}

- (UIViewController *)viewControllerForIndex:(V2SectionIndex)index {
    
    UIViewController *viewController;

    switch (index) {
        case V2SectionIndexLatest:
            viewController = self.latestNavigationController;
            break;
        case V2SectionIndexCategories:
            viewController = self.categoriesNavigationController;
            break;
        case V2SectionIndexNodes:
            viewController = self.nodesNavigationController;
            break;
        case V2SectionIndexFavorite:
            viewController = self.favoriteNavigationController;
            break;
        case V2SectionIndexNotification:
            viewController = self.nofificationNavigationController;
            break;
        case V2SectionIndexProfile:
            viewController = self.profilenavigationController;
            break;
        default:
            break;
    }
    
    return viewController;
}

- (void)setMenuOffset:(CGFloat)offset {
    
    self.menuView.x = offset - kMenuWidth;
    [self.menuView setOffsetProgress:offset/kMenuWidth];
    self.rootBackgroundButton.alpha = offset/kMenuWidth * 0.3;

    UIViewController *previousViewController = [self viewControllerForIndex:self.currentSelectedIndex];

    previousViewController.view.x       = offset/8.0;
//    self.categoriesNavigationController.view.x   = offset/8.0;
//    self.favoriteNavigationController.view.x     = offset/8.0;
//    self.nofificationNavigationController.view.x = offset/8.0;
    
}

- (void)setBlurredScreenShoot {
    
    __block UIImage *screenShoot = [self.view re_screenshot];
    
    @weakify(self);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        UIColor *blurColor = [UIColor colorWithWhite:0.970 alpha:0.50];
        if (kCurrentTheme == V2ThemeNight) {
            blurColor = [UIColor colorWithWhite:0.028 alpha:0.50];
        }

        screenShoot = [screenShoot re_applyBlurWithRadius:12.0 tintColor:blurColor saturationDeltaFactor:1.0 maskImage:nil];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(self);
            
            self.menuView.blurredImage = screenShoot;
            self.rootBackgroundBlurView.image = screenShoot;
            
        });
        
    });

}

#pragma mark - Gestures
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    
    if ([gestureRecognizer isKindOfClass:[UIScreenEdgePanGestureRecognizer class]]) {
        if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
            return YES;
        }
        
        if ([otherGestureRecognizer.view isKindOfClass:[UITableView class]]) {
            return YES;
        }
        
    }
    return NO;
}

- (void)handlePanRecognizer:(UIPanGestureRecognizer *)recognizer {
    
    CGFloat progress = [recognizer translationInView:self.rootBackgroundButton].x / (self.rootBackgroundButton.bounds.size.width * 0.5);
    progress = - MIN(progress, 0);
    
    [self setMenuOffset:kMenuWidth - kMenuWidth * progress];
    
    static CGFloat sumProgress = 0;
    static CGFloat lastProgress = 0;
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
        sumProgress = 0;
        lastProgress = 0;
        
    }
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        if (progress > lastProgress) {
            sumProgress += progress;
        } else {
            sumProgress -= progress;
        }
        lastProgress = progress;
        
    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.3 animations:^{
            if (sumProgress > 0.1) {
                [self setMenuOffset:0];
            } else {
                [self setMenuOffset:kMenuWidth];
            }
        } completion:^(BOOL finished) {
            if (sumProgress > 0.1) {
                self.rootBackgroundButton.hidden = YES;
            } else {
                self.rootBackgroundButton.hidden = NO;
            }
        }];
    }
    
}

- (void)handleEdgePanRecognizer:(UIScreenEdgePanGestureRecognizer *)recognizer {
    CGFloat progress = [recognizer translationInView:self.view].x / kMenuWidth;
    progress = MIN(1.0, MAX(0.0, progress));
    
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        
//        [self setBlurredScreenShoot];
        self.rootBackgroundButton.hidden = NO;
        
    }
    else if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        [self setMenuOffset:kMenuWidth * progress];
        
    }
    else if (recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
        
        
        CGFloat velocity = [recognizer velocityInView:self.view].x;
        
        if (velocity > 20 || progress > 0.5) {
            
            [UIView animateWithDuration:(1-progress)/1.5 delay:0 usingSpringWithDamping:1 initialSpringVelocity:3.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                [self setMenuOffset:kMenuWidth];
            } completion:^(BOOL finished) {
                ;
            }];
        }
        else {
            [UIView animateWithDuration:progress/3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                [self setMenuOffset:0];
            } completion:^(BOOL finished) {
                self.rootBackgroundButton.hidden = YES;
                self.rootBackgroundButton.alpha = 0.0;
            }];
        }
        
    }
    
}

#pragma mark - Notifications

- (void)didReceiveShowMenuNotification {
    
//    [self setBlurredScreenShoot];
    
    
    [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:3.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self setMenuOffset:kMenuWidth];
        self.rootBackgroundButton.hidden = NO;
    } completion:nil];
    
}

- (void)didReceiveResetInactiveDelegateNotification {
    
//    self.latestNavigationController.delegate = nil;
//    self.edgePanRecognizer.delegate = nil;
    self.edgePanRecognizer.enabled = YES;

}


- (void)didReceiveCancelInactiveDelegateNotifacation {
    
    self.edgePanRecognizer.enabled = NO;
    
}

@end
