//
//  V2NodeViewController.m
//  v2ex-iOS
//
//  Created by Singro on 4/27/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2NodeViewController.h"

#import "V2TopicViewController.h"
#import "V2TopicCreateViewController.h"

#import "V2TopicToolBarItemView.h"
#import "MBProgressHUD.h"

#import "V2TopicListCell.h"

@interface V2NodeViewController () <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) SCBarButtonItem *leftBarItem;
@property (nonatomic, strong) SCBarButtonItem *addBarItem;

@property (nonatomic, strong) UIView          *menuContainView;
@property (nonatomic, strong) UIView          *menuView;
@property (nonatomic, strong) UIButton        *menuBackgroundButton;

@property (nonatomic, strong) MBProgressHUD    *HUD;

@property (nonatomic, strong) V2TopicList     *topicList;
@property (nonatomic, assign) NSInteger       pageCount;

@property (nonatomic, copy) NSURLSessionDataTask* (^getTopicListBlock)(NSInteger page);

@property (nonatomic, assign) BOOL isMenuShowing;
@property (nonatomic, assign) BOOL needsRefresh;

@end

@implementation V2NodeViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.pageCount = 1;
        
        self.isMenuShowing = NO;
        self.needsRefresh = YES;
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self configureNavibarItems];
    [self configureTableView];
    [self configureMenuView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationItem.rightBarButtonItem = self.addBarItem;
    self.sc_navigationItem.title = self.model.nodeTitle;

    [self configureBlocks];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveIgnoreTopicSuccessNotification:) name:kIgnoreTopicSuccessNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    
    self.tableView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.needsRefresh) {
        self.needsRefresh = NO;
        [self beginRefresh];
    }
    
}


#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.menuContainView.frame = self.view.bounds;
    self.menuBackgroundButton.frame = self.menuContainView.bounds;
    
}


#pragma mark - Configure

- (void)configureNavibarItems {
    
    @weakify(self);
    self.leftBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
        
    }];
    
    self.addBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_add"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        if (self.isMenuShowing) {
            [self hideMenuAnimated:YES];
        }
        else {
            [self showMenuAnimated:YES];
        }
        
    }];

}

- (void)configureTableView {
    
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.backgroundColor = kBackgroundColorWhiteDark;
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    [self.view addSubview:self.tableView];
    
}

- (void)configureMenuView {
    
    self.menuContainView = [[UIView alloc] init];
    self.menuContainView.userInteractionEnabled = NO;
    [self.view addSubview:self.menuContainView];
    
    self.menuBackgroundButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuBackgroundButton.backgroundColor = [UIColor colorWithWhite:0.667 alpha:0];
    
    @weakify(self)
    UIPanGestureRecognizer *menuBGButtonPanGesture = [UIPanGestureRecognizer bk_recognizerWithHandler:^(UIGestureRecognizer *sender, UIGestureRecognizerState state, CGPoint location) {
        @strongify(self)
        [self hideMenuAnimated:NO];
    }];
    [self.menuBackgroundButton addGestureRecognizer:menuBGButtonPanGesture];
    [self.menuContainView addSubview:self.menuBackgroundButton];
    
    self.menuView = [[UIView alloc] init];
    self.menuView.alpha = 0.0;
    self.menuView.frame = (CGRect){200, UIView.sc_navigationBarHeight, 130, 118};
    [self.menuContainView addSubview:self.menuView];
    
    UIView *topArrowView = [[UIView alloc] init];
    topArrowView.frame = (CGRect){87, 5, 10, 10};
    topArrowView.backgroundColor = [UIColor blackColor];
    topArrowView.transform = CGAffineTransformMakeRotation(M_PI_4);
    [self.menuView addSubview:topArrowView];
    
    UIView *menuBackgroundView = [[UIView alloc] init];
    menuBackgroundView.frame = (CGRect){10, 10, 100, 88};
    menuBackgroundView.backgroundColor = [UIColor colorWithWhite:0.000 alpha:0.90];
    menuBackgroundView.layer.cornerRadius = 5.0;
    menuBackgroundView.clipsToBounds = YES;
    [self.menuView addSubview:menuBackgroundView];
    
    NSArray *itemTitleArray = @[@"发帖", @"收藏"];
    NSArray *itemImageArray = @[@"icon_post", @"icon_fav"];
    
    void (^buttonHandleBlock)(NSInteger index) = ^(NSInteger index) {
        @strongify(self);
        
        if (index == 0) {
            
            V2TopicViewController *topicCreateVC = [[V2TopicViewController alloc] init];
            topicCreateVC.create = YES;
            V2TopicModel *topicModel = [[V2TopicModel alloc] init];
            topicModel.topicNode = self.model;
            topicCreateVC.model = topicModel;
            [self.navigationController pushViewController:topicCreateVC animated:YES];
            
//            V2TopicCreateViewController *topicCreateVC = [[V2TopicCreateViewController alloc] init];
//            topicCreateVC.nodeName = self.model.nodeName;
//            [self.navigationController pushViewController:topicCreateVC animated:YES];
            
        }
        
        if (index == 1) {
            
            self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
            self.HUD.removeFromSuperViewOnHide = YES;
            [self.view addSubview:self.HUD];
            [self.HUD show:YES];
            
            [[V2DataManager manager] favNodeWithName:self.model.nodeName success:^(NSString *message) {
                @strongify(self);
                
                UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                self.HUD.customView = imageView;
                self.HUD.mode = MBProgressHUDModeCustomView;
                self.HUD.labelText = @"Saved";
                [self.HUD hide:YES afterDelay:0.6];
                
            } failure:^(NSError *error) {
                @strongify(self);
                
                UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
                UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                self.HUD.customView = imageView;
                self.HUD.mode = MBProgressHUDModeCustomView;
                self.HUD.labelText = @"Failed";
                [self.HUD hide:YES afterDelay:0.6];

            }];

        }
        
        [self hideMenuAnimated:NO];
    };

    for (int i = 0; i < 2; i ++) {
        V2TopicToolBarItemView *item = [[V2TopicToolBarItemView alloc] init];
        item.itemTitle = itemTitleArray[i];
        item.itemImage = [UIImage imageNamed:itemImageArray[i]];
        item.alpha = 1.0;
        item.buttonPressedBlock = ^{
            buttonHandleBlock(i);
        };
        item.frame = (CGRect){0, 44 * i, item.width, item.height};
        item.backgroundColorNormal = [UIColor clearColor];
        [menuBackgroundView addSubview:item];
    }

    // Handles
    [self.menuBackgroundButton bk_addEventHandler:^(id sender) {
        @strongify(self);
        
        [self hideMenuAnimated:YES];
        
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configureBlocks {
    
    @weakify(self);
    self.getTopicListBlock = ^(NSInteger page){
        @strongify(self);
        
        self.pageCount = page;
        
        return [[V2DataManager manager] getTopicListWithNodeId:nil nodename:self.model.nodeName username:nil page:self.pageCount success:^(V2TopicList *list) {
            @strongify(self);
            
            self.topicList = list;
            
            if (self.pageCount > 1) {
                [self endLoadMore];
            } else {
                [self endRefresh];
//                if (list.list.count > 10) {
//                    self.loadMoreBlock = ^{
//                        @strongify(self);
//                        self.pageCount ++;
//                        
//                        self.getTopicListBlock(self.pageCount);
//                    };
//                }
            }
            
        } failure:^(NSError *error) {
            @strongify(self);
            
            if (self.pageCount > 1) {
                [self endLoadMore];
            } else {
                [self endRefresh];
            }
            
        }];
        
    };
    
    
    
    self.refreshBlock = ^{
        @strongify(self);
        
        self.getTopicListBlock(1);
    };
    
    
}

- (void)configureNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTopicCreateSuccessNotification) name:kTopicCreateSuccessNotification object:nil];
    
}

#pragma mark - Data

- (void)setTopicList:(V2TopicList *)topicList {
    
    if (self.topicList.list.count > 0 && self.pageCount != 1) {
        
        NSMutableArray *list = [[NSMutableArray alloc] initWithArray:self.topicList.list];
        [list addObjectsFromArray:topicList.list];
        topicList.list = list;
        
    }
    
    _topicList = topicList;
    
    [self.tableView reloadData];
    
}

#pragma mark - Private Methods

- (void)showMenuAnimated:(BOOL)animated {
    
    if (self.isMenuShowing) {
        return;
    }
    
    self.isMenuShowing = YES;
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    CGRect addBarF = [self.menuContainView convertRect:self.addBarItem.view.frame fromView:window];
    self.menuView.frame = (CGRect){CGRectGetMidX(addBarF) - 72, CGRectGetMaxY(addBarF), 130, 118};
    
    if (animated) {
        self.menuView.origin = (CGPoint){CGRectGetMidX(addBarF) - 72, CGRectGetMaxY(addBarF) - 44};
//        self.menuView.origin = (CGPoint){220, 20};
        self.menuView.transform = CGAffineTransformMakeScale(0.3, 0.3);
        
        [UIView animateWithDuration:0.3 animations:^{
            self.menuView.alpha = 1.0;
            self.menuView.transform = CGAffineTransformIdentity;
            self.menuView.frame = (CGRect){CGRectGetMidX(addBarF) - 92, CGRectGetMaxY(addBarF), 130, 118};
//            self.menuView.frame = (CGRect){200, 64, 130, 118};
        } completion:^(BOOL finished) {
            self.menuContainView.userInteractionEnabled = YES;
        }];
    } else {
        self.menuView.alpha = 1.0;
        self.menuView.transform = CGAffineTransformIdentity;
        self.menuView.frame = (CGRect){CGRectGetMidX(addBarF) - 72, CGRectGetMaxY(addBarF), 130, 118};
//        self.menuView.frame = (CGRect){200, 64, 130, 118};
        self.menuContainView.userInteractionEnabled = YES;
    }
    
}

- (void)hideMenuAnimated:(BOOL)animated {
    
    UIWindow *window = [[UIApplication sharedApplication].windows lastObject];
    CGRect addBarF = [self.menuContainView convertRect:self.addBarItem.view.frame fromView:window];
    
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            self.menuView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.menuContainView.userInteractionEnabled = NO;
        }];
        
        [UIView animateWithDuration:0.3 animations:^{
            
            self.menuView.transform = CGAffineTransformMakeScale(0.3, 0.3);
            self.menuView.origin = (CGPoint){CGRectGetMidX(addBarF) - 72 + 40, CGRectGetMaxY(addBarF)};
//            self.menuView.origin = (CGPoint){260, 64};
            
        } completion:^(BOOL finished) {
            self.menuView.transform = CGAffineTransformIdentity;
            self.menuView.frame = (CGRect){CGRectGetMidX(addBarF) - 72, CGRectGetMaxY(addBarF), 130, 118};
//            self.menuView.frame = (CGRect){200, 64, 130, 118};
            self.isMenuShowing = NO;
        }];
    } else {
        [UIView animateWithDuration:0.1 animations:^{
            self.menuView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.menuContainView.userInteractionEnabled = NO;
            self.isMenuShowing = NO;
        }];
    }
    
}

#pragma mark - ScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kHideTimeLabelNotification object:nil];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:kShowTimeLabelNotification object:nil];
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.topicList.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightOfTopicCellForIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    V2TopicListCell *cell = (V2TopicListCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[V2TopicListCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return [self configureTopicCellWithCell:cell IndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    V2TopicModel *model = self.topicList.list[indexPath.row];
    V2TopicViewController *topicViewController = [[V2TopicViewController alloc] init];
    topicViewController.model = model;
    [self.navigationController pushViewController:topicViewController animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Configure TableCell

- (CGFloat)heightOfTopicCellForIndexPath:(NSIndexPath *)indexPath {
    
    V2TopicModel *model = self.topicList.list[indexPath.row];
    
    return [V2TopicListCell getCellHeightWithTopicModel:model];
    
}

- (V2TopicListCell *)configureTopicCellWithCell:(V2TopicListCell *)cell IndexPath:(NSIndexPath *)indexPath {
    
    V2TopicModel *model = self.topicList.list[indexPath.row];
    
    cell.model = model;
    cell.isTop = !indexPath.row;
    
    return cell;
}

#pragma mark - Notifications 

- (void)didReceiveTopicCreateSuccessNotification {
    
    self.needsRefresh = YES;
    
}

- (void)didReceiveIgnoreTopicSuccessNotification:(NSNotification *)notification {
    
    V2TopicModel *model = notification.object;
    if ([model isKindOfClass:[V2TopicModel class]]) {
        
        NSMutableArray *list = [[NSMutableArray alloc] init];
        __block NSUInteger index = NSNotFound;
        
        [self.topicList.list enumerateObjectsUsingBlock:^(V2TopicModel *item, NSUInteger idx, BOOL *stop) {
            if ([item isKindOfClass:[V2TopicModel class]]) {
                if ([item.topicId integerValue] != [model.topicId integerValue]) {
                    [list addObject:item];
                } else {
                    index = idx;
                }
            }
        }];
        
        if (index != NSNotFound) {
            self.topicList.list = list;
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
        }
        
    }
    
}

@end
