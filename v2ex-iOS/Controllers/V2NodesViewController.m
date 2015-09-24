//
//  V2NodesViewController.m
//  v2ex-iOS
//
//  Created by Singro on 3/18/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2NodesViewController.h"

#import "V2NodesViewCell.h"

@interface V2NodesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) SCBarButtonItem    *leftBarItem;

@property (nonatomic, strong) NSArray *headerTitleArray;
@property (nonatomic, strong) NSArray *nodesArray;

@property (nonatomic, strong) NSArray *myNodesArray;
@property (nonatomic, strong) NSArray *otherNodesArray;

@property (nonatomic, copy) NSURLSessionDataTask* (^getNodeListBlock)();
@property (nonatomic, copy) NSString *myNodeListPath;

@end

@implementation V2NodesViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.headerTitleArray = @[@"我的节点",@"分享与探索", @"V2EX", @"iOS", @"Geek", @"游戏", @"Apple", @"生活", @"Internet", @"城市", @"品牌"];
        
        self.myNodeListPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        self.myNodeListPath = [self.myNodeListPath stringByAppendingString:@"/nodes.plist"];
        
        self.myNodesArray = [NSArray arrayWithContentsOfFile:self.myNodeListPath];
        if (!self.myNodesArray) {
            self.myNodesArray = [NSArray array];
        }
        
        self.otherNodesArray = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"NodesList" ofType:@"plist"]];
        
        [self loadData];
        
    }
    return self;
}


- (void)loadView {
    [super loadView];
    
    [self configureBarItems];
    [self configureTableView];
    [self configureBlocks];
    
}


- (void)dealloc {
    
    self.tableView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
    self.sc_navigationItem.title = @"节点";
    self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
        
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.myNodesArray.count == 0) {
        [self beginRefresh];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Setters

- (void)setNodesArray:(NSArray *)nodesArray {
    _nodesArray = nodesArray;
    
//    [self.tableView reloadData];
    [self.tableView beginUpdates];
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
    [self.tableView endUpdates];
}

#pragma mark - Data

- (void)loadData {
    
    NSMutableArray *nodesArray = [NSMutableArray arrayWithObject:self.myNodesArray];;
    [nodesArray addObjectsFromArray:self.otherNodesArray];
    
    self.nodesArray = [self itemsWithDictArray:nodesArray];
    [self.tableView reloadData];
    
}

- (NSArray *)itemsWithDictArray:(NSArray *)nodesArray {
    
    NSMutableArray *items = [NSMutableArray new];
    
    for (NSArray *sectionDictList in nodesArray) {
        NSMutableArray *setionItems = [NSMutableArray new];
        for (NSDictionary *dataDict in sectionDictList) {
            NSString *nodeTitle = dataDict[@"name"];
            NSString *nodeName = dataDict[@"title"];
            
            V2NodeModel *model = [[V2NodeModel alloc] init];
            model.nodeTitle = nodeTitle;
            model.nodeName = nodeName;
            
            [setionItems addObject:model];
        }
        [items addObject:setionItems];
    }
    
    return items;
}

#pragma mark - Configure Views & blocks

- (void)configureBarItems {
    
    self.leftBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_menu_2"] style:SCBarButtonItemStylePlain handler:^(id sender) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
    }];
    
    
}

- (void)configureTableView {
    
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInsetBottom = 15;
    self.tableView.contentInsetTop = 44;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    [self.view addSubview:self.tableView];
    
}

- (void)configureBlocks {
    
    @weakify(self);
    self.getNodeListBlock = ^{
        
        return [[V2DataManager manager] getMemberNodeListSuccess:^(NSArray *list) {
            @strongify(self);
            
            if ([list writeToFile:self.myNodeListPath atomically:YES]) {
            }
            
            self.myNodesArray = list;
            [self loadData];
            [self endRefresh];
            
        } failure:^(NSError *error) {
            @strongify(self);
            [self endRefresh];
        }];
        
    };
    
    self.refreshBlock = ^{
        @strongify(self);
        
        self.getNodeListBlock();
    };
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.headerTitleArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [V2NodesViewCell getCellHeightWithNodesArray:self.nodesArray[indexPath.section]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *nodeCellIdentifier = @"nodeCellIdentifier";
    V2NodesViewCell *nodeCell = (V2NodesViewCell *)[tableView dequeueReusableCellWithIdentifier:nodeCellIdentifier];
    if (!nodeCell) {
        nodeCell = [[V2NodesViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nodeCellIdentifier];
    }
    
    nodeCell.navi = self.navigationController;
    nodeCell.nodesArray = self.nodesArray[indexPath.section];
    
    return nodeCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 36;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 36}];
    headerView.backgroundColor = kBackgroundColorWhiteDark;
    
    UILabel *label                       = [[UILabel alloc] initWithFrame:(CGRect){10, 0, kScreenWidth - 20, 36}];
    label.textColor                      = kFontColorBlackLight;
    label.font                           = [UIFont systemFontOfSize:15.0];
    label.text                           = self.headerTitleArray[section];
    [headerView addSubview:label];

    if (section == 0) {
        UIView *topBorderLineView            = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 0.5}];
        topBorderLineView.backgroundColor    = kLineColorBlackDark;
        [headerView addSubview:topBorderLineView];
    }

    UIView *bottomBorderLineView         = [[UIView alloc] initWithFrame:(CGRect){0, 35.5, kScreenWidth, 0.5}];
    bottomBorderLineView.backgroundColor = kLineColorBlackDark;
    [headerView addSubview:bottomBorderLineView];
    

    return headerView;
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
