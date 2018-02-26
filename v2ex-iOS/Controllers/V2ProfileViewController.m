//
//  V2ProfileViewController.m
//  v2ex-iOS
//
//  Created by Singro on 4/7/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2ProfileViewController.h"

#import "MBProgressHUD.h"
#import "SCActionSheet.h"

#import "V2MemberTopicsViewController.h"
#import "V2MemberRepliesViewController.h"
#import "V2SettingViewController.h"
#import "V2WebViewController.h"

#import "V2ProfileCell.h"
#import "V2ProfileBioCell.h"

static CGFloat const kAvatarHeight = 60.0f;

@interface V2ProfileViewController () <UITableViewDataSource, UITableViewDelegate, MBProgressHUDDelegate>

@property (nonatomic, strong) SCBarButtonItem    *leftBarItem;
@property (nonatomic, strong) SCBarButtonItem    *backBarItem;
@property (nonatomic, strong) SCBarButtonItem    *settingBarItem;
@property (nonatomic, strong) SCBarButtonItem    *actionBarItem;

@property (nonatomic, strong) SCActionSheet      *actionSheet;
@property (nonatomic, strong) MBProgressHUD      *HUD;

@property (nonatomic, strong) UIView      *topPanel;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel     *nameLabel;
@property (nonatomic, strong) UILabel     *signLabel;

@property (nonatomic, strong) NSArray *headerTitleArray;
@property (nonatomic, strong) NSArray *profileCellArray;

@property (nonatomic, copy) NSURLSessionDataTask* (^getProfileBlock)();
@property (nonatomic, assign) BOOL didGetProfile;

@end

@implementation V2ProfileViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.headerTitleArray = @[@"社区", @"信息", @"个人简介"];
        self.didGetProfile = NO;
        
    }
    return self;
}


- (void)loadView {
    [super loadView];
    
    [self configureBarItems];
    [self configureTableView];
    [self configureTopView];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
        
//    self.sc_navigationItem.title = [V2DataManager manager].user.member.memberName;
    if (self.isSelf) {
        self.sc_navigationItem.title = @"个人";
        self.sc_navigationItem.leftBarButtonItem = self.leftBarItem;
        self.sc_navigationItem.rightBarButtonItem = self.settingBarItem;
    } else {
        self.sc_navigationItem.title = @"用户";
        self.sc_navigationItem.leftBarButtonItem = self.backBarItem;
        self.sc_navigationItem.rightBarButtonItem = self.actionBarItem;
    }
    
//    if ([V2CheckInManager manager].isExpired && kSetting.checkInNotiticationOn) {
//        self.settingBarItem.badge = @"";
//    } else {
//        self.settingBarItem.badge = nil;
//    }
//    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUpdateCheckInBadgeNotification) name:kUpdateCheckInBadgeNotification object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didSubViewReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];

    [self configureBlocks];
    
//    [self configureGestures];
    [self configureNotifications];
    
}

- (void)dealloc {
    
    self.tableView.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    
    if (!self.didGetProfile) {
        [self beginLoadMore];
    }
}


#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.topPanel.frame = (CGRect){0, UIView.sc_navigationBarHeight, kAvatarHeight + 10, kAvatarHeight + 10};

}

#pragma mark - Configure Views & blocks

- (void)configureBarItems {
    
    @weakify(self);
    if (self.isSelf) {
        
        self.leftBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_menu_2"] style:SCBarButtonItemStylePlain handler:^(id sender) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowMenuNotification object:nil];
        }];
        
        self.settingBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"section_setting"] style:SCBarButtonItemStylePlain handler:^(id sender) {
            @strongify(self);
            
            V2SettingViewController *settingVC = [[V2SettingViewController alloc] init];
            [self.navigationController pushViewController:settingVC animated:YES];
            
        }];
        
    } else {
        
        self.backBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_back"] style:SCBarButtonItemStylePlain handler:^(id sender) {
            @strongify(self);
            
            [self.navigationController popViewControllerAnimated:YES];
            
        }];
        
        self.actionBarItem = [[SCBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"navi_more"] style:SCBarButtonItemStylePlain handler:^(id sender) {
            @strongify(self);
                        
            self.actionSheet = [[SCActionSheet alloc] sc_initWithTitles:@[self.username] customViews:nil buttonTitles:@"关注", @"屏蔽", nil];
            
            @weakify(self);
            
            [self.actionSheet sc_setButtonHandler:^{
                @strongify(self);
                [self memberFollow];
            } forIndex:0];
            
            [self.actionSheet sc_setButtonHandler:^{
                @strongify(self);
                [self memberBlock];
            } forIndex:1];
            
            [self.actionSheet sc_show:YES];
            
        }];
        
    }

}

- (void)configureTableView {
    
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.contentInsetTop = 124;
    self.tableView.contentInsetBottom = 15;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    [self.view addSubview:self.tableView];
        
}

- (void)configureTopView {
    
    self.topPanel = [[UIView alloc] init];
    [self.view addSubview:self.topPanel];
    
    self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_default"]];
    self.avatarImageView.contentMode        = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds      = YES;
    self.avatarImageView.layer.cornerRadius = 5; //kAvatarHeight / 2.0;
    [self.topPanel addSubview:self.avatarImageView];

    self.nameLabel                          = [[UILabel alloc] init];
    self.nameLabel.textColor                = kFontColorBlackDark;
    self.nameLabel.font                     = [UIFont systemFontOfSize:17];;
    [self.topPanel addSubview:self.nameLabel];

    self.signLabel                          = [[UILabel alloc] init];
    self.signLabel.textColor                = kFontColorBlackLight;
    self.signLabel.font                     = [UIFont systemFontOfSize:14];
    self.signLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.signLabel.numberOfLines = 2;
    [self.topPanel addSubview:self.signLabel];
    
    // layout
    self.avatarImageView.frame = (CGRect){10, 10, kAvatarHeight, kAvatarHeight};
    self.nameLabel.frame = (CGRect){80, 20, 200, 20};
    self.signLabel.frame = (CGRect){80, 43, 200, 40};
    
    if (self.member) {
        if (self.isSelf) {
            [self.avatarImageView setImageWithURL:[NSURL URLWithString:self.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        } else {
            [self.avatarImageView setImageWithURL:[NSURL URLWithString:self.member.memberAvatarNormal] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        }
        self.nameLabel.text = self.member.memberName;
        self.signLabel.text = self.member.memberTagline;
        [self.signLabel sizeToFit];
        
        self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;

    }
    
}

- (void)configureBlocks {
    
    @weakify(self);
    self.getProfileBlock = ^(){
        @strongify(self);
        
//        [self beginLoadMore];
        
        return [[V2DataManager manager] getMemberProfileWithUserId:nil username:self.username success:^(V2MemberModel *member) {
            @strongify(self);
            
            self.didGetProfile = YES;
            self.member = member;
            
            [self endLoadMore];
            
            self.loadMoreBlock = nil;
            
        } failure:^(NSError *error) {
            @strongify(self);
            
            [self endLoadMore];

        }];
        
    };
    
    
    self.loadMoreBlock = ^{
        @strongify(self);
        
        self.getProfileBlock();
        
    };
    
}

- (void)configureNotifications {
    
    if (self.isSelf) {
        @weakify(self);
        [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
            @strongify(self);
            
            self.username = [V2DataManager manager].user.member.memberName;
            self.getProfileBlock();
            
        }];
    }
    
}

#pragma mark - Actions

- (void)memberFollow {
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
    
    @weakify(self);
    [[V2DataManager manager] memberFollowWithMemberName:self.member.memberName success:^(NSString *message) {
        @strongify(self);
        
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.HUD.customView = imageView;
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.labelText = @"已关注";
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

- (void)memberBlock {
    
    self.HUD = [[MBProgressHUD alloc] initWithView:self.view];
    self.HUD.removeFromSuperViewOnHide = YES;
    [self.view addSubview:self.HUD];
    [self.HUD show:YES];
    
    @weakify(self);
    [[V2DataManager manager] memberBlockWithMemberName:self.member.memberName success:^(NSString *message) {
        @strongify(self);
        
        UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        self.HUD.customView = imageView;
        self.HUD.mode = MBProgressHUDModeCustomView;
        self.HUD.labelText = @"已屏蔽";
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

#pragma mark - Setters

- (void)setIsSelf:(BOOL)isSelf {
    _isSelf = isSelf;
    
    if (isSelf) {
        self.member = [V2DataManager manager].user.member;
    }
}

- (void)setUsername:(NSString *)username {
    _username = username;
    
    self.nameLabel.text = username;
}

- (void)setMember:(V2MemberModel *)member {
    _member = member;
    
    [self.avatarImageView setImageWithURL:[NSURL URLWithString:member.memberAvatarLarge]];
    self.signLabel.text = member.memberTagline;
    self.username = member.memberName;
    
    [self.signLabel sizeToFit];
    
    NSMutableArray *profileArray = [[NSMutableArray alloc] init];
    if (self.member.memberTwitter.length > 1) {
        NSDictionary *dict = @{
                               kProfileType: @(V2ProfileCellTypeTwitter),
                               kProfileValue: self.member.memberTwitter
                               };
        [profileArray addObject:dict];
    }
    if (self.member.memberLocation.length > 1) {
        NSDictionary *dict = @{
                               kProfileType: @(V2ProfileCellTypeLocation),
                               kProfileValue: self.member.memberLocation
                               };
        [profileArray addObject:dict];
    }
    if (self.member.memberWebsite.length > 1) {
        NSDictionary *dict = @{
                               kProfileType: @(V2ProfileCellTypeWebsite),
                               kProfileValue: self.member.memberWebsite
                               };
        [profileArray addObject:dict];
    }

    self.profileCellArray = profileArray;
    
    [self.tableView reloadData];
}

#pragma mark - ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [super scrollViewDidScroll:scrollView];
    
    self.topPanel.y = - (self.tableView.contentInsetTop + scrollView.contentOffsetY) + UIView.sc_navigationBarHeight;
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [super scrollViewWillBeginDragging:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [super scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.didGetProfile) {
        NSInteger sectionCount = 3;
        if (self.profileCellArray.count == 0) {
            sectionCount --;
        }
        if (self.member.memberBio.length < 1) {
            sectionCount --;
        }
        return sectionCount;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    if (section == 1) {
        if (self.profileCellArray.count == 0) {
            return 1;
        } else {
            return self.profileCellArray.count;
        }
    }
    if (section == 2) {
        return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 2) {
        return [V2ProfileBioCell getCellHeightWithBioString:self.member.memberBio];
    } else {
        return 44;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *profileCellIdentifier = @"profileCellIdentifier";
    V2ProfileCell *profileCell = (V2ProfileCell *)[tableView dequeueReusableCellWithIdentifier:profileCellIdentifier];
    if (!profileCell) {
        profileCell = [[V2ProfileCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileCellIdentifier];
    }
    
    static NSString *profileBioCellIdentifier = @"profileBioCellIdentifier";
    V2ProfileBioCell *profileBioCell = (V2ProfileBioCell *)[tableView dequeueReusableCellWithIdentifier:profileBioCellIdentifier];
    if (!profileBioCell) {
        profileBioCell = [[V2ProfileBioCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:profileBioCellIdentifier];
    }

    profileCell.isTop = NO;
    profileCell.isBottom = NO;

    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            profileCell.type = V2ProfileCellTypeTopic;
            profileCell.title = @"主题";
            profileCell.isTop = YES;
            return profileCell;
        }
        if (indexPath.row == 1) {
            profileCell.type = V2ProfileCellTypeReply;
            profileCell.title = @"回复";
            profileCell.isBottom = YES;
            return profileCell;
        }
    }
    
    if (indexPath.section == 1) {
        if (self.profileCellArray.count) {
            profileCell.isTop = !indexPath.row;
            profileCell.isBottom = (indexPath.row == (self.profileCellArray.count - 1));
            NSDictionary *cellDict = self.profileCellArray[indexPath.row];
            profileCell.type = [[cellDict objectForSafeKey:kProfileType] integerValue];
            profileCell.title = [cellDict objectForSafeKey:kProfileValue];
            return profileCell;
        } else {
            profileBioCell.bioString = self.member.memberBio;
            return profileBioCell;
        }
    }
    
    if (indexPath.section == 2) {
        profileBioCell.bioString = self.member.memberBio;
        return profileBioCell;
    }
    
    return [UITableViewCell new];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
            V2MemberTopicsViewController *topicsVC = [[V2MemberTopicsViewController alloc] init];
            topicsVC.model = self.member;
            [self.navigationController pushViewController:topicsVC animated:YES];
            
        }
        if (indexPath.row == 1) {
            
            V2MemberRepliesViewController *repliesVC = [[V2MemberRepliesViewController alloc] init];
            repliesVC.memberName = self.member.memberName;
            [self.navigationController pushViewController:repliesVC animated:YES];

        }
    }
    
    if (indexPath.section == 1) {
        if (self.profileCellArray.count) {
            NSDictionary *cellDict = self.profileCellArray[indexPath.row];
            V2ProfileCellType type = [[cellDict objectForSafeKey:kProfileType] integerValue];
            NSString *title = [cellDict objectForSafeKey:kProfileValue];
            if (type == V2ProfileCellTypeTwitter) {
                
                NSArray *urls = [NSArray arrayWithObjects:
                                 @"twitter://user?screen_name={handle}", // Twitter
                                 @"tweetbot:///user_profile/{handle}", // TweetBot
                                 @"echofon:///user_timeline?{handle}", // Echofon
                                 @"twit:///user?screen_name={handle}", // Twittelator Pro
                                 @"x-seesmic://twitter_profile?twitter_screen_name={handle}", // Seesmic
                                 @"x-birdfeed://user?screen_name={handle}", // Birdfeed
                                 @"tweetings:///user?screen_name={handle}", // Tweetings
                                 @"simplytweet:?link=http://twitter.com/{handle}", // SimplyTweet
                                 @"icebird://user?screen_name={handle}", // IceBird
                                 @"fluttr://user/{handle}", // Fluttr
                                 @"http://twitter.com/{handle}",
                                 nil];
                
                UIApplication *application = [UIApplication sharedApplication];
                
                for (NSString *candidate in urls) {
                    NSURL *url = [NSURL URLWithString:[candidate stringByReplacingOccurrencesOfString:@"{handle}" withString:title]];
                    if ([application canOpenURL:url]) 
                    {
                        [application openURL:url];
                        return;
                    }
                }

            }
            
            if (type == V2ProfileCellTypeWebsite) {
                if (![title hasPrefix:@"http://"]) {
                    title = [@"http://" stringByAppendingString:title];
                }
                NSURL *URL = [NSURL URLWithString:title];
                
                V2WebViewController *webVC = [[V2WebViewController alloc] init];
                webVC.url = URL;
                [self.navigationController pushViewController:webVC animated:YES];

            }

        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
        
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

    UILabel *label = [[UILabel alloc] initWithFrame:(CGRect){10, 0, kScreenWidth - 20, 36}];
    label.textColor = kFontColorBlackLight;
    label.font = [UIFont systemFontOfSize:15.0];
    label.text = self.headerTitleArray[section];
    [headerView addSubview:label];
    
    return headerView;
}

#pragma mark - Nofitications

- (void)didSubViewReceiveThemeChangeNotification {

    self.nameLabel.textColor                = kFontColorBlackDark;
    self.signLabel.textColor                = kFontColorBlackLight;
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    
}

- (void)didReceiveUpdateCheckInBadgeNotification {
    
    if ([V2CheckInManager manager].isExpired && kSetting.checkInNotiticationOn) {
        self.leftBarItem.badge = @"";
    } else {
        self.leftBarItem.badge = nil;
    }
    
}

@end
