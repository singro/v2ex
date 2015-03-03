//
//  V2MemberRepliesViewController.m
//  v2ex-iOS
//
//  Created by Singro on 5/14/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2MemberRepliesViewController.h"

#import "V2TopicViewController.h"

#import "V2MemberReplyCell.h"

@interface V2MemberRepliesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) V2MemberReplyList *memberReplyList;

@property (nonatomic, copy) void (^getMemberReplyListBlock)(BOOL isLoadMore);
@property (nonatomic, assign) NSInteger currentPage;

@property (nonatomic, assign) BOOL needsRefresh;

@property (nonatomic, strong) SCBarButtonItem *leftBarItem;

@end

@implementation V2MemberRepliesViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
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

    self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
    self.sc_navigationItem.title = [NSString stringWithFormat:@"%@的回复", self.memberName];

    [self configureBlocks];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.needsRefresh) {
        self.needsRefresh = NO;
        [self beginRefresh];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    
    self.tableView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
//    [self.leftBarItem setBackButtonBackgroundImage:[UIImage imageNamed:@"navi_back"] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    
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
    self.getMemberReplyListBlock = ^(BOOL isLoadMore){
        @strongify(self);
        
        NSInteger page = 1;
        
        if (isLoadMore) {
            page = self.currentPage + 1;
        }

        [[V2DataManager manager] getUserReplyWithUsername:self.memberName page:page success:^(V2MemberReplyList *list) {
            @strongify(self);
            
            if (isLoadMore) {
                self.currentPage = page;
                NSMutableArray *newList = [NSMutableArray arrayWithArray:self.memberReplyList.list];
                [newList addObjectsFromArray:list.list];
                list.list = newList;
            } else {
                self.currentPage = 1;
            }
            
            self.memberReplyList = list;
            
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
        
        self.getMemberReplyListBlock(NO);
    };
    
    self.loadMoreBlock = ^{
        @strongify(self);
        
        self.getMemberReplyListBlock(YES);
        
    };
    
}

#pragma mark - Data

- (void)setMemberReplyList:(V2MemberReplyList *)memberReplyList {
    
    _memberReplyList = memberReplyList;
    
    [self.tableView reloadData];

}


#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.memberReplyList.list.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    V2MemberReplyModel *model = self.memberReplyList.list[indexPath.row];
    return [V2MemberReplyCell getCellHeightWithMemberReplyModel:model];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    V2MemberReplyCell *cell = (V2MemberReplyCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[V2MemberReplyCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    V2MemberReplyModel *model = self.memberReplyList.list[indexPath.row];
    cell.model = model;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    V2MemberReplyModel *model = self.memberReplyList.list[indexPath.row];
    V2TopicViewController *topicViewController = [[V2TopicViewController alloc] init];
    topicViewController.model = model.memberReplyTopic;
    [self.navigationController pushViewController:topicViewController animated:YES];
    
}


@end
