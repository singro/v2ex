//
//  SCPullRefreshViewController.m
//  v2ex-iOS
//
//  Created by Singro on 4/4/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "SCPullRefreshViewController.h"

#import "SCAnimationView.h"

static CGFloat const kRefreshHeight = 44.0f;

@interface SCPullRefreshViewController ()

@property (nonatomic, strong) UIView *tableHeaderView;
@property (nonatomic, strong) UIView *tableFooterView;

@property (nonatomic, strong) SCAnimationView *refreshView;
@property (nonatomic, strong) SCAnimationView *loadMoreView;

@property (nonatomic, assign) BOOL isLoadingMore;
@property (nonatomic, assign) BOOL isRefreshing;

@property (nonatomic, assign) BOOL hadLoadMore;
@property (nonatomic, assign) CGFloat dragOffsetY;

@end

@implementation SCPullRefreshViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.isLoadingMore = NO;
        self.isRefreshing = NO;
        self.hadLoadMore = NO;
        
        _viewShowing = NO;
        _hiddenEnabled = NO;
        
        self.tableViewInsertTop = UIView.sc_navigationBarHeight;
        self.tableViewInsertBottom = UIView.sc_bottomInset;

    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    self.tableHeaderView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
    self.refreshView = [[SCAnimationView alloc] initWithFrame:(CGRect){0, -44, kScreenWidth, 44}];
    self.refreshView.timeOffset = 0.0;
    [self.tableHeaderView addSubview:self.refreshView];

    self.tableFooterView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0}];
    self.loadMoreView = [[SCAnimationView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 44}];
    self.loadMoreView.timeOffset = 0.0;
    [self.tableFooterView addSubview:self.loadMoreView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = kBackgroundColorWhiteDark;
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (nil != self.tableView.indexPathForSelectedRow) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        if ([cell respondsToSelector:@selector(updateStatus)]) {
            [cell performSelector:@selector(updateStatus)];
        }
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
//    _viewShowing = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveStatusBarTappedNotification) name:kStatusBarTappedNotification object:nil];

}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kStatusBarTappedNotification object:nil];
//    _viewShowing = NO;
}

- (void)dealloc {
    
    self.tableView.delegate = nil;
    self.tableView.dataSource = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.view.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(self.tableViewInsertTop, 0, self.tableViewInsertBottom, 0);

}

#pragma mark - Setters

//- (void)setHiddenEnabled:(BOOL)hiddenEnabled {
//    
//    _hiddenEnabled = hiddenEnabled;
//    
//    
//}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {

    // Refresh
    CGFloat offsetY = -scrollView.contentOffsetY - self.tableViewInsertTop  - 25;

    self.refreshView.timeOffset = MAX(offsetY / 60.0, 0);
    
    // LoadMore
    if ((self.loadMoreBlock && scrollView.contentSizeHeight > 300) || !self.hadLoadMore) {
        self.loadMoreView.hidden = NO;
    } else {
        self.loadMoreView.hidden = YES;
    }
    
    if (scrollView.contentSizeHeight + scrollView.contentInsetTop < kScreenHeight) {
        return;
    }

    CGFloat loadMoreOffset = - (scrollView.contentSizeHeight - self.view.height - scrollView.contentOffsetY + scrollView.contentInsetBottom);

    if (loadMoreOffset > 0) {
        self.loadMoreView.timeOffset = MAX(loadMoreOffset / 60.0, 0);
    } else {
        self.loadMoreView.timeOffset = 0;
    }
    
    // Handle hidden
    
    if (!_hiddenEnabled || !kSetting.navigationBarAutoHidden) {
        return;
    }

    CGFloat dragOffsetY = self.dragOffsetY - scrollView.contentOffsetY;
    
    CGFloat contentOffset = scrollView.contentOffsetY + scrollView.contentInsetTop;
    
    if (contentOffset < 43) {
        [self sc_setNavigationBarHidden:NO animated:YES];
        return;
    }
    
    if (dragOffsetY < - 30) {
        [self sc_setNavigationBarHidden:YES animated:YES];
        return;
    }
    
    if (dragOffsetY > 110) {
       [self sc_setNavigationBarHidden:NO animated:YES];
        return;
    }

    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.dragOffsetY = scrollView.contentOffsetY;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    // Refresh
    CGFloat refreshOffset = -scrollView.contentOffsetY - scrollView.contentInsetTop;
    if (refreshOffset > 60 && self.refreshBlock && !self.isRefreshing) {
        [self beginRefresh];
    }
//    NSLog(@"refreshOffset:  %.f", refreshOffset);

    // loadMore
    CGFloat loadMoreOffset = scrollView.contentSizeHeight - self.view.height - scrollView.contentOffsetY + scrollView.contentInsetBottom;
    if (loadMoreOffset < -60 && self.loadMoreBlock && !self.isLoadingMore && scrollView.contentSizeHeight > kScreenHeight) {
        [self beginLoadMore];
    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    
}

#pragma mark - Public Methods

- (void)setRefreshBlock:(void (^)())refreshBlock {
    _refreshBlock = refreshBlock;
    
    if (self.tableView) {
        self.tableView.tableHeaderView = self.tableHeaderView;
    }
    
}

- (void)beginRefresh {
    
    if (self.isRefreshing) {
        return;
    }
    
    self.isRefreshing = YES;
    
    [self.refreshView beginRefreshing];
    
    if (self.refreshBlock) {
        self.refreshBlock();
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            self.tableView.contentInsetTop = kRefreshHeight + self.tableViewInsertTop;
            [self.tableView setContentOffset:(CGPoint){0,- (kRefreshHeight + self.tableViewInsertTop )} animated:NO];
            self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
            
        } completion:^(BOOL finished){
            
        }];
    });
}

- (void)endRefresh {
    
    [self.refreshView endRefreshing];
    
    self.isRefreshing = NO;
    
    [UIView animateWithDuration:0.5 animations:^{
        self.tableView.contentInsetTop = self.tableViewInsertTop;
        self.tableView.scrollIndicatorInsets = self.tableView.contentInset;
    }];

}

- (void)beginLoadMore {
    
    [self.loadMoreView beginRefreshing];
    
    self.isLoadingMore = YES;
    self.hadLoadMore = YES;
    
    if (self.loadMoreBlock) {
        self.loadMoreBlock();
    }
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentInsetBottom = kRefreshHeight + self.tableViewInsertBottom;
    }];
    
    
}

- (void)endLoadMore {
    
    [self.loadMoreView endRefreshing];
    
    self.isLoadingMore = NO;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.tableView.contentInsetBottom =  + self.tableViewInsertBottom;
    }];
    
}

- (void)setLoadMoreBlock:(void (^)())loadMoreBlock {
    _loadMoreBlock = loadMoreBlock;
    
    if (self.loadMoreBlock && self.tableView) {
        self.tableView.tableFooterView = self.tableFooterView;
    }
    
}

#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {

    self.view.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    [self.tableView reloadData];
    
}

- (void)didReceiveStatusBarTappedNotification {
    
    [self.tableView scrollRectToVisible:(CGRect){0, 0, kScreenWidth, 0.1} animated:YES];

}

@end
