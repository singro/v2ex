//
//  V2MenuSectionView.m
//  v2ex-iOS
//
//  Created by Singro on 3/30/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2MenuSectionView.h"

#import "SCActionSheet.h"
#import "SCActionSheetButton.h"

#import "V2MenuSectionCell.h"

static CGFloat const kAvatarHeight = 70.0f;

@interface V2MenuSectionView () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UIButton    *avatarButton;
@property (nonatomic, strong) UIImageView *divideImageView;
@property (nonatomic, strong) UILabel     *usernameLabel;

@property (nonatomic, strong) SCActionSheet      *actionSheet;

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray     *sectionImageNameArray;
@property (nonatomic, strong) NSArray     *sectionTitleArray;

@end

@implementation V2MenuSectionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        
        self.sectionImageNameArray = @[@"section_latest", @"section_categories", @"section_nodes", @"section_fav", @"section_notification", @"section_profile"];
//        self.sectionTitleArray = @[@"Latest", @"Categories", @"Nodes", @"Favorite", @"Notification", @"Profile"];
        self.sectionTitleArray = @[@"最新", @"分类", @"节点", @"收藏", @"提醒", @"个人"];

        [self configureTableView];
        [self configureProfileView];
        [self configureSearchView];
        [self configureNotifications];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveThemeChangeNotification) name:kThemeDidChangeNotification object:nil];
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveUpdateCheckInBadgeNotification) name:kUpdateCheckInBadgeNotification object:nil];

    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)configureTableView {
    
    self.tableView                 = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    self.tableView.contentInsetTop = 100 + UIView.sc_statusBarHeight;
    [self addSubview:self.tableView];
    
}

- (void)configureProfileView {
    
    self.avatarImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"avatar_default"]];
    self.avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 5; //kAvatarHeight / 2.0;
    self.avatarImageView.layer.borderColor = RGB(0x8a8a8a, 1.0).CGColor;
    self.avatarImageView.layer.borderWidth = 1.0f;
    [self addSubview:self.avatarImageView];
    
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;

    if ([V2DataManager manager].user.isLogin) {
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:[V2DataManager manager].user.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        self.avatarImageView.layer.borderColor = RGB(0x8a8a8a, 0.1).CGColor;
    }
    
    self.avatarButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self addSubview:self.avatarButton];
    
    self.divideImageView = [[UIImageView alloc] init];
    self.divideImageView.backgroundColor = kLineColorBlackDark;
    self.divideImageView.contentMode = UIViewContentModeScaleAspectFill;
//    self.divideImageView.image = [UIImage imageNamed:@"section_divide"];
    self.divideImageView.clipsToBounds = YES;
    [self addSubview:self.divideImageView];

    // Handles
    [self.avatarButton bk_addEventHandler:^(id sender) {
        
        if (![V2DataManager manager].user.isLogin) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kShowLoginVCNotification object:nil];
        } else {
            
            self.actionSheet = [[SCActionSheet alloc] sc_initWithTitles:@[@"是否注销？"] customViews:nil buttonTitles:@"注销", nil];
            
            [self.actionSheet sc_configureButtonWithBlock:^(SCActionSheetButton *button) {
                button.type = SCActionSheetButtonTypeRed;
            } forIndex:0];
            
            [self.actionSheet sc_setButtonHandler:^{
                
                [[V2DataManager manager] UserLogout];
                
            } forIndex:0];
            
            [self.actionSheet sc_show:YES];

//            UIAlertView *alertView = [[UIAlertView alloc] bk_initWithTitle:@"是否注销？" message:nil];
//            [alertView bk_addButtonWithTitle:@"注销" handler:^{
//                [[V2DataManager manager] UserLogout];
//            }];
//            [alertView bk_setCancelButtonWithTitle:@"取消" handler:^{
//                ;
//            }];
//            [alertView show];
            
        }
     
    } forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)configureSearchView {
    
    
    
    
}

- (void)configureNotifications {
    
    @weakify(self);
    [[NSNotificationCenter defaultCenter] addObserverForName:kLoginSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:[V2DataManager manager].user.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        self.avatarImageView.layer.borderColor = RGB(0x8a8a8a, 0.1).CGColor;

    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kLogoutSuccessNotification object:nil queue:nil usingBlock:^(NSNotification *note) {
        @strongify(self);
        
        [self.avatarImageView setImageWithURL:[NSURL URLWithString:[V2DataManager manager].user.member.memberAvatarLarge] placeholderImage:[UIImage imageNamed:@"avatar_default"]];
        self.avatarImageView.layer.borderColor = RGB(0x8a8a8a, 1.0).CGColor;
        
    }];

}

#pragma mark - Layout

- (void)layoutSubviews {
    
    self.avatarImageView.frame = (CGRect){30, 10 + UIView.sc_statusBarHeight, kAvatarHeight, kAvatarHeight};
    self.avatarButton.frame = self.avatarImageView.frame;
    self.divideImageView.frame = (CGRect){-self.width, kAvatarHeight + 30 + UIView.sc_statusBarHeight, self.width * 2, 0.5};
    self.tableView.frame = (CGRect){0, 0, self.width, self.height};
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[V2SettingManager manager].selectedSectionIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
}

#pragma mark - Setters

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    
    if (selectedIndex < self.sectionTitleArray.count) {
        _selectedIndex = selectedIndex;
        
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:selectedIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
        
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetY = - scrollView.contentOffsetY;
    
//    CGFloat spaceHeight = (self.tableView.contentInsetTop - kAvatarHeight) / 3.0;
    
    self.avatarImageView.y = 30 - (scrollView.contentInsetTop - offsetY) / 1.7;
    self.avatarButton.frame = self.avatarImageView.frame;

    self.divideImageView.y = self.avatarImageView.y + kAvatarHeight + (offsetY - (self.avatarImageView.y + kAvatarHeight)) / 2.0 + fabs(offsetY - self.tableView.contentInsetTop)/self.tableView.contentInsetTop * 8.0 + 10;
    
    
}

#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sectionTitleArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self heightCellForIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"CellIdentifier";
    V2MenuSectionCell *cell = (V2MenuSectionCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[V2MenuSectionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return [self configureWithCell:cell IndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.didSelectedIndexBlock) {
        self.didSelectedIndexBlock(indexPath.row);
    }
    
}

#pragma mark - Configure TableCell

- (CGFloat)heightCellForIndexPath:(NSIndexPath *)indexPath {
    
    return [V2MenuSectionCell getCellHeight];
    
}

- (V2MenuSectionCell *)configureWithCell:(V2MenuSectionCell *)cell IndexPath:(NSIndexPath *)indexPath {
    
    cell.imageName = self.sectionImageNameArray[indexPath.row];
    cell.title     = self.sectionTitleArray[indexPath.row];
    
    cell.badge = nil;
    
//    if (indexPath.row == 5) {
//        if ([V2CheckInManager manager].isExpired && kSetting.checkInNotiticationOn) {
//            cell.badge = @"";
//        }
//    }
    
    return cell;
    
}


#pragma mark - Notifications

- (void)didReceiveThemeChangeNotification {
    
    [self.tableView reloadData];
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:[V2SettingManager manager].selectedSectionIndex inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    self.avatarImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;
    self.divideImageView.alpha = kSetting.imageViewAlphaForCurrentTheme;

}

- (void)didReceiveUpdateCheckInBadgeNotification {
    
    [self.tableView reloadData];
//    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.sectionTitleArray.count - 1 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    
}

@end
