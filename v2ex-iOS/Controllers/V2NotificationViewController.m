//
//  V2NotificationViewController.m
//  v2ex-iOS
//
//  Created by Singro on 4/5/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2NotificationViewController.h"

#import "V2TopicViewController.h"

#import "V2NotificationCell.h"

@interface V2NotificationViewController () <UITableViewDataSource, UITableViewDelegate, UIViewControllerPreviewingDelegate>

@property (nonatomic, strong) V2NotificationList *notificationList;
@property (nonatomic, assign) NSInteger pageCount;

@property (nonatomic, copy) void (^getNotificationListBlock)(NSUInteger page);

@property (nonatomic, strong) SCBarButtonItem *leftBarItem;

@end

@implementation V2NotificationViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
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
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationItem.title = @"提醒";

    [self configureBlocks];

//    if ([V2CheckInManager manager].isExpired && kSetting.checkInNotiticationOn) {
//        self.leftBarItem.badge = @"";
//    } else {
//        self.leftBarItem.badge = nil;
//    }
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUpdateCheckInBadgeNotification) name:kUpdateCheckInBadgeNotification object:nil];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

#pragma mark - Configure Views & blocks

- (void)configureNavibarItems {
    
    self.leftBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_menu_2"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
    }];
    
}

- (void)configureTableView {
    
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.frame];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    [self.view addSubview:self.tableView];
    
}

- (void)configureBlocks {
    
    @weakify(self);
    self.getNotificationListBlock = ^(NSUInteger page){
        @strongify(self);
        self.pageCount = page;
        
        [[V2DataManager manager] getUserNotificationWithPage:page success:^(V2NotificationList *list) {
            @strongify(self);
            
            self.notificationList = list;

            if (page == 1) {
                [self endRefresh];
            } else {
                [self endLoadMore];
            }
            
            if (list.list.count > 8) {
                self.loadMoreBlock = ^{
                    @strongify(self);
                    
                    self.pageCount ++;
                    self.getNotificationListBlock(self.pageCount);
                };
            }
            
        } failure:^(NSError *error) {
            @strongify(self);
            
            if (page == 1) {
                [self endRefresh];
            } else {
                [self endLoadMore];
            }
            
        }];
        
    };
    
    self.refreshBlock = ^{
        @strongify(self);
        
        self.getNotificationListBlock(1);
    };
    
}

#pragma mark - Setters

- (void)setNotificationList:(V2NotificationList *)notificationList {
    
    if (self.pageCount > 1) {
        NSMutableArray *list = [NSMutableArray arrayWithArray:self.notificationList.list];
        [list addObjectsFromArray:notificationList.list];
        self.notificationList.list = list;
    } else {
        _notificationList = notificationList;
    }
    
    [self.tableView reloadData];
    
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.notificationList.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    V2NotificationModel *model = self.notificationList.list[indexPath.row];
    return [V2NotificationCell getCellHeightWithNotificationModel:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    V2NotificationCell *cell = (V2NotificationCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[V2NotificationCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.navi = self.navigationController;
        
        // register for 3D Touch (if available)
        if(NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_8_4) {
            if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
                [self registerForPreviewingWithDelegate:self sourceView:cell];
            }
        }
    }
    
    return [self configureNotificationCellWithCell:cell IndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    V2NotificationModel *model = self.notificationList.list[indexPath.row];
    V2TopicViewController *topicViewController = [[V2TopicViewController alloc] init];
    topicViewController.model = model.notificationTopic;
    [self.navigationController pushViewController:topicViewController animated:YES];
    
}

#pragma mark - Configure TableCell

- (CGFloat)heightOfTopicCellForIndexPath:(NSIndexPath *)indexPath {
    
    V2NotificationModel *model = self.notificationList.list[indexPath.row];
    
    return [V2NotificationCell getCellHeightWithNotificationModel:model];
    
}

- (V2NotificationCell *)configureNotificationCellWithCell:(V2NotificationCell *)cell IndexPath:(NSIndexPath *)indexPath {
    
    V2NotificationModel *model = self.notificationList.list[indexPath.row];
    
    cell.model = model;
    cell.top = !indexPath.row;
    
    return cell;
}

#pragma mark - Preview

- (nullable UIViewController *)previewingContext:(id <UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location  {
    
    CGPoint point = [previewingContext.sourceView convertPoint:location toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:point];
    
    if ([self.presentedViewController isKindOfClass:[V2TopicViewController class]]) {
        return nil;
    } else {
        V2NotificationModel *model = self.notificationList.list[indexPath.row];
        V2TopicViewController *topicVC = [[V2TopicViewController alloc] init];
        topicVC.model = model.notificationTopic;
        topicVC.preview = YES;
        return topicVC;
    }
}

#pragma mark - Nofitications

- (void)didReceiveUpdateCheckInBadgeNotification {
    
    if ([V2CheckInManager manager].isExpired && kSetting.checkInNotiticationOn) {
        self.leftBarItem.badge = @"";
    } else {
        self.leftBarItem.badge = nil;
    }
    
}

@end
