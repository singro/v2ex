//
//  SPViewController+NaviBar.m
//  newSponia
//
//  Created by Singro on 5/19/14.
//  Copyright (c) 2014 Sponia. All rights reserved.
//

static char const * const kNaviHidden = "kSPNaviHidden";
static char const * const kNaviBar = "kSPNaviBar";
static char const * const kNaviBarView = "kNaviBarView";

#import "SCViewController+NaviBar.h"
//#import "RSSwizzle.h"

@implementation UIViewController (SCNavigation)

@dynamic sc_navigationItem;
@dynamic sc_navigationBar;
@dynamic sc_navigationBarHidden;

//+(void)load {

//    RSSwizzleInstanceMethod([self class],
//                            @selector(viewWillAppear:),
//                            RSSWReturnType(void),
//                            RSSWArguments(BOOL animated),
//                            RSSWReplacement(
//    {
//        RSSWCallOriginal(animated);
//        [self __viewWillAppear:animated];
//    }), 0, NULL);
    
//}

//+(void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        Class class = [self class];
//        
//        // When swizzling a class method, use the following:
//        // Class class = object_getClass((id)self);
//        
//        SEL originalSelector = @selector(viewWillAppear:);
//        SEL swizzledSelector = @selector(__viewWillAppear:);
//        
//        Method originalMethod = class_getInstanceMethod(class, originalSelector);
//        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
//        
//        BOOL didAddMethod =
//        class_addMethod(class,
//                        originalSelector,
//                        method_getImplementation(swizzledMethod),
//                        method_getTypeEncoding(swizzledMethod));
//        
//        if (didAddMethod) {
//            class_replaceMethod(class,
//                                swizzledSelector,
//                                method_getImplementation(originalMethod),
//                                method_getTypeEncoding(originalMethod));
//        } else {
//            method_exchangeImplementations(originalMethod, swizzledMethod);
//        }
//    });
//}
//

//- (void)__viewWillAppear:(BOOL)animated {
//    NSLog(@"viewWillAppear: %@", self);
//}

- (BOOL)sc_isNavigationBarHidden {
    return [objc_getAssociatedObject(self, kNaviHidden) boolValue];
}

- (void)setSc_navigationBarHidden:(BOOL)sc_navigationBarHidden {
    objc_setAssociatedObject(self, kNaviHidden, @(sc_navigationBarHidden), OBJC_ASSOCIATION_ASSIGN);
}

- (void)sc_setNavigationBarHidden:(BOOL)hidden animated:(BOOL)animated {
    if (hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            self.sc_navigationBar.y = -44;
            for (UIView *view in self.sc_navigationBar.subviews) {
                view.alpha = 0.0;
            }
        } completion:^(BOOL finished) {
            self.sc_navigationBarHidden = YES;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.sc_navigationBar.y = 0;
            for (UIView *view in self.sc_navigationBar.subviews) {
                view.alpha = 1.0;
            }
        } completion:^(BOOL finished) {
            self.sc_navigationBarHidden = NO;
        }];
    }
}

- (SCNavigationItem *)sc_navigationItem {
    return objc_getAssociatedObject(self, kNaviBar);
}

- (void)setSc_navigationItem:(SCNavigationItem *)sc_navigationItem {
    objc_setAssociatedObject(self, kNaviBar, sc_navigationItem, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)sc_navigationBar {
    return objc_getAssociatedObject(self, kNaviBarView);
}

- (void)setSc_navigationBar:(UIView *)sc_navigationBar {
    objc_setAssociatedObject(self, kNaviBarView, sc_navigationBar, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

//
//- (void)configureBarItemsShowing:(BOOL)isShowing {
//    if (self.sc_navigationBar) {
//        [self.sc_navigationBar removeFromSuperview];
//    }
//    
//    self.sc_navigationBar = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 64}];
//    self.sc_navigationBar.backgroundColor = RGB(0x9d64be, 0.98);
//    [self.view addSubview:self.sc_navigationBar];
//    
//    for (UIView *view in self.sc_navigationBar.subviews) {
//        [view removeFromSuperview];
//    }
//
//    if (isShowing) {
//        self.sc_navigationItem.leftBarButtonItem.view.x = 0;
//        self.sc_navigationItem.rightBarButtonItem.view.x = 320 - self.sc_navigationItem.rightBarButtonItem.view.width;
//        NSUInteger otherButtonWidth = self.sc_navigationItem.leftBarButtonItem.view.width + self.sc_navigationItem.rightBarButtonItem.view.width;
//        self.sc_navigationItem.titleLabel.width = 320 - otherButtonWidth - 20;
//        self.sc_navigationItem.titleLabel.centerX = 160;
//        [self.sc_navigationBar addSubview:self.sc_navigationItem.leftBarButtonItem.view];
//        [self.sc_navigationBar addSubview:self.sc_navigationItem.rightBarButtonItem.view];
//        [self.sc_navigationBar addSubview:self.sc_navigationItem.titleLabel];
//    }
//}

- (SCBarButtonItem *)createBackItem {
    
    @weakify(self);
    return [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:SCBarButtonItemStyleDone handler:^(id sender) {
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];

}

- (void)naviBeginRefreshing {
    
    UIActivityIndicatorView *activityView;
    for (UIView *view in self.sc_navigationBar.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            activityView = (UIActivityIndicatorView *)view;
        }
        if ([view isEqual:self.sc_navigationItem.rightBarButtonItem.view]) {
            [view removeFromSuperview];
        }
    }
    
    if (!activityView) {
        activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityView setColor:[UIColor blackColor]];
        activityView.frame = (CGRect){kScreenWidth - 42, 25, 35, 35};
        [self.sc_navigationBar addSubview:activityView];
    }
    
    [activityView startAnimating];

}


- (void)naviEndRefreshing {
    
    UIActivityIndicatorView *activityView;
    for (UIView *view in self.sc_navigationBar.subviews) {
        if ([view isKindOfClass:[UIActivityIndicatorView class]]) {
            activityView = (UIActivityIndicatorView *)view;
        }
    }
    
    if (self.sc_navigationItem.rightBarButtonItem) {
        [self.sc_navigationBar addSubview:self.sc_navigationItem.rightBarButtonItem.view];
    }
    
    [activityView stopAnimating];
    
}

- (void)createNavigationBar {
    
    return [SCNavigationController createNavigationBarForViewController:self];
    
}

@end
