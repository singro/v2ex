//
//  V2MemberTopicsViewController.m
//  v2ex-iOS
//
//  Created by Singro on 5/12/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2MemberTopicsViewController.h"

#import "V2TopicViewController.h"

#import "V2TopicListCell.h"

@interface V2MemberTopicsViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SCBarButtonItem *leftBarItem;
//@property (nonatomic, strong) SCBarButtonItem *addBarItem;

@property (nonatomic, strong) V2TopicList     *topicList;
//@property (nonatomic, assign) NSInteger       pageCount;

@property (nonatomic, copy) NSURLSessionDataTask* (^getTopicListBlock)(BOOL isLoadMore);
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) BOOL needsRefresh;

@end

@implementation V2MemberTopicsViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.currentPage = 1;
        
        self.needsRefresh = YES;
        
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self configureNavibarItems];
    [self configureTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureBlocks];
    
    self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationItem.title = [NSString stringWithFormat:@"%@的主题", self.model.memberName];
    
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
    
    self.hiddenEnabled = YES;
    
}


#pragma mark - Configure

- (void)configureNavibarItems {
    
    @weakify(self);
    self.leftBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        @strongify(self);
        
        [self.navigationController popViewControllerAnimated:YES];
        
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
    self.getTopicListBlock = ^(BOOL isLoadMore){
        @strongify(self);
        
        NSInteger page = 1;
        
        if (isLoadMore) {
            page = self.currentPage + 1;
        }
        
        return [[V2DataManager manager] getMemberTopicListWithMemberModel:self.model page:page Success:^(V2TopicList *list) {
            @strongify(self);
            
            if (isLoadMore) {
                self.currentPage = page;
                NSMutableArray *newList = [NSMutableArray arrayWithArray:self.topicList.list];
                [newList addObjectsFromArray:list.list];
                list.list = newList;
            } else {
                self.currentPage = 1;
            }
            
            self.topicList = list;
            
            if (isLoadMore) {
                [self endLoadMore];
            } else {
                [self endRefresh];
            }
            
        } failure:^(NSError *error) {
            @strongify(self);
            
            if (isLoadMore) {
                [self endLoadMore];
            } else {
                [self endRefresh];
            }
            
        }];
        
    };
    
    
    
    self.refreshBlock = ^{
        @strongify(self);
        
        self.getTopicListBlock(NO);
    };
    
    self.loadMoreBlock = ^{
        @strongify(self);
        
        self.getTopicListBlock(YES);
        
    };
    
    
}

#pragma mark - Data

- (void)setTopicList:(V2TopicList *)topicList {
    
    _topicList = topicList;
    
    [self.tableView reloadData];
    
}

#pragma mark - Private Methods

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
