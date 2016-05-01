//
//  V2LatestViewController.m
//  v2ex-iOS
//
//  Created by Singro on 3/18/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2LatestViewController.h"

#import "V2TopicViewController.h"

#import "V2TopicListCell.h"

@interface V2LatestViewController () <UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) SCBarButtonItem *leftBarItem;

@property (nonatomic, strong) V2TopicList *topicList;
@property (nonatomic, assign) NSInteger pageCount;

@property (nonatomic, copy) NSURLSessionDataTask* (^getTopicListBlock)(NSInteger page);

@end

@implementation V2LatestViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.pageCount = 1;
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self configureTableView];
    [self configureNavibarItems];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureBlocks];
    
    self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationItem.title = @"最新";
    
//    if ([V2CheckInManager manager].isExpired && kSetting.checkInNotiticationOn) {
//        self.leftBarItem.badge = @"";
//    } else {
//        self.leftBarItem.badge = nil;
//    }
//
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUpdateCheckInBadgeNotification) name:kUpdateCheckInBadgeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveIgnoreTopicSuccessNotification:) name:kIgnoreTopicSuccessNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    @weakify(self);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @strongify(self);
        
        [self beginRefresh];

    });
    
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.hiddenEnabled = YES;
    
}

#pragma mark - Configure

- (void)configureNavibarItems {
    
    self.leftBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_menu_2"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
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

- (void)configureBlocks {
    
    @weakify(self);
    self.getTopicListBlock = ^(NSInteger page){
        @strongify(self);
        
        self.pageCount = page;
        
        return [[V2DataManager manager] getTopicListLatestWithPage:page Success:^(V2TopicList *list) {
            @strongify(self);
            
            self.topicList = list;
            
            if (self.pageCount > 1) {
                [self endLoadMore];
            } else {
                [self endRefresh];
                if (list.list.count > 10) {
                    self.loadMoreBlock = ^{
                        @strongify(self);
                        self.pageCount ++;
                        
                        self.getTopicListBlock(self.pageCount);
                    };
                }
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
    
        // register for 3D Touch (if available)
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
        }
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

#pragma mark - Preview

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location  {
    
    CGPoint point = [previewingContext.sourceView convertPoint:location toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if ([self.presentedViewController isKindOfClass:[V2TopicViewController class]]) {
        return nil;
    } else {
        V2TopicViewController *topicVC = [[V2TopicViewController alloc] init];
        topicVC.model = self.topicList.list[indexPath.row];
        topicVC.preview = YES;
        return topicVC;
    }
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit {
    
    V2TopicViewController *topicVC = (V2TopicViewController *)viewControllerToCommit;
    topicVC.preview = NO;
    [self.navigationController pushViewController:viewControllerToCommit animated:YES];
    
}

#pragma mark - Nofitications 

- (void)didReceiveUpdateCheckInBadgeNotification {
    
    if ([V2CheckInManager manager].isExpired && kSetting.checkInNotiticationOn) {
        self.leftBarItem.badge = @"";
    } else {
        self.leftBarItem.badge = nil;
    }
    
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
