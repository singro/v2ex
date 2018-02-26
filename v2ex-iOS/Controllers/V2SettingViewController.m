//
//  V2SettingViewController.m
//  v2ex-iOS
//
//  Created by Singro on 3/18/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2SettingViewController.h"

#import "V2WeiboViewController.h"
#import "V2WebViewController.h"
#import "V2ProfileViewController.h"

#import "SCActionSheet.h"
#import "SCActionSheetButton.h"

#import "V2SettingSwitchCell.h"
#import "V2SettingCheckInCell.h"
#import "V2SettingWeiboCell.h"

typedef NS_ENUM(NSInteger, V2SettingSection) {
//    V2SettingSectionNotification = 0,
    V2SettingSectionDisplay      = 0,
    V2SettingSectionTraffic      = 1,
    V2SettingSectionCheckIn      = 2,
    V2SettingSectionWeibo        = 3,
    V2SettingSectionAbout        = 4,
    V2SettingSectionFour         = 5,
};


@interface V2SettingViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSArray *headerTitleArray;

@property (nonatomic, strong) SCBarButtonItem *backBarItem;

@property (nonatomic, strong) SCActionSheet      *actionSheet;

@end

@implementation V2SettingViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        self.headerTitleArray = @[@"提醒", @"显示", @"流量", @"签到", @"绑定", @"关于"];
    }
    return self;
}

- (void)loadView {
    [super loadView];
    
    [self configureBarItems];
    [self configureTableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.sc_navigationItem.leftBarButtonItem = self.backBarItem;
    self.sc_navigationItem.title = @"设置";
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.tableView.contentInsetTop = UIView.sc_navigationBarHeight;
    self.tableView.contentInsetBottom = 15;

}

#pragma mark - Configure Views

- (void)configureBarItems {
    
    self.backBarItem = [self createBackItem];
    
}


- (void)configureTableView {
    
    self.tableView                 = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle  = UITableViewCellSeparatorStyleNone;
    self.tableView.delegate        = self;
    self.tableView.dataSource      = self;
    [self.view addSubview:self.tableView];
    
}


#pragma mark - TableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == V2SettingSectionAbout) {
        return 2;
    }
    if (section == V2SettingSectionDisplay) {
        return 3;
    }
    if (section == V2SettingSectionTraffic) {
        return 2;
    }
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *checkInCellIdentifier = @"CheckInSettingIdentifier";
    V2SettingCheckInCell *checkInCell = (V2SettingCheckInCell *)[tableView dequeueReusableCellWithIdentifier:checkInCellIdentifier];
    if (!checkInCell) {
        checkInCell = [[V2SettingCheckInCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:checkInCellIdentifier];
    }
    
    static NSString *weiboCellIdentifier = @"WeiboSettingIdentifier";
    V2SettingWeiboCell *weiboCell = (V2SettingWeiboCell *)[tableView dequeueReusableCellWithIdentifier:weiboCellIdentifier];
    if (!weiboCell) {
        weiboCell = [[V2SettingWeiboCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:weiboCellIdentifier];
    }

    static NSString *switchCellIdentifier = @"SwitchSettingIdentifier";
    V2SettingSwitchCell *switchCell = (V2SettingSwitchCell *)[tableView dequeueReusableCellWithIdentifier:switchCellIdentifier];
    if (!switchCell) {
        switchCell = [[V2SettingSwitchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:switchCellIdentifier];
    }

    static NSString *CellIdentifier = @"SettingIdentifier";
    V2SettingCell *settingCell = (V2SettingSwitchCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!settingCell) {
        settingCell = [[V2SettingCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
//    if (indexPath.section == V2SettingSectionNotification) {
//        
//        if (indexPath.row == 0) {
//            switchCell.title = @"签到提醒";
//            switchCell.isOn = kSetting.checkInNotiticationOn;
//            switchCell.top = YES;
//        }
//        
//        if (indexPath.row == 1) {
//            switchCell.title = @"新消息提醒";
//            switchCell.isOn = kSetting.newNotificationOn;
//            switchCell.bottom = YES;
//        }
//        
//        return switchCell;
//
//    }

    if (indexPath.section == V2SettingSectionDisplay) {
        
        if (indexPath.row == 0) {
            switchCell.title = @"夜间模式";
            switchCell.isOn = kSetting.theme == V2ThemeNight;
            switchCell.top = YES;
        }

        if (indexPath.row == 1) {
            switchCell.title = @"自动选择夜间模式";
            switchCell.isOn = kSetting.themeAutoChange;
        }
        
        if (indexPath.row == 2) {
            switchCell.title = @"自动隐藏导航栏";
            switchCell.isOn = kSetting.navigationBarAutoHidden;
            switchCell.bottom = YES;
        }

        return switchCell;
    }
    
    if (indexPath.section == V2SettingSectionTraffic) {
        
        if (indexPath.row == 0) {
            switchCell.title = @"使用 HTTPS";
            switchCell.isOn = kSetting.preferHttps;
            switchCell.top = YES;
            switchCell.bottom = NO;
        }
        
        if (indexPath.row == 1) {
            switchCell.title = @"省流量模式";
            switchCell.isOn = kSetting.trafficSaveModeOnSetting;
            switchCell.top = NO;
            switchCell.bottom = YES;
        }
        
        return switchCell;
    }
    
    if (indexPath.section == V2SettingSectionCheckIn) {
        
        checkInCell.title = @"签到";
        checkInCell.top = YES;
        checkInCell.bottom = YES;
        
        return checkInCell;
    }
    
    if (indexPath.section == V2SettingSectionWeibo) {
        
        if (indexPath.row == 0) {
            weiboCell.title = @"微博";
            weiboCell.top = YES;
            weiboCell.bottom = YES;
        }
        
        return weiboCell;
    }

    if (indexPath.section == V2SettingSectionAbout) {
        
        if (indexPath.row == 0) {
            settingCell.title = @"关于作者";
            settingCell.top = YES;
        }
        
        if (indexPath.row == 1) {
            settingCell.title = @"关于V2EX";
            settingCell.bottom = YES;
        }

        return settingCell;
    }
    
    UITableViewCell *blackCell = [UITableViewCell new];
    blackCell.backgroundColor = kBackgroundColorWhite;
    
    return blackCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    @weakify(self);

    V2SettingCell *settingCell = (V2SettingCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([settingCell isKindOfClass:[V2SettingSwitchCell class]]) {
        
        V2SettingSwitchCell *switchCell = (V2SettingSwitchCell *)settingCell;
        
        switchCell.isOn = !switchCell.isOn;
        
//        if (indexPath.section == V2SettingSectionNotification) {
//            
//            if (indexPath.row == 0) {
//                kSetting.checkInNotiticationOn = switchCell.isOn;
//            }
//            
//            if (indexPath.row == 1) {
//                kSetting.newNotificationOn = switchCell.isOn;
//            }
//            
//        }
        
        if (indexPath.section == V2SettingSectionDisplay) {
            
            if (indexPath.row == 0) {
                if (switchCell.isOn) {
                    kSetting.theme = V2ThemeNight;
                } else {
                    kSetting.theme = V2ThemeDefault;
                }
            }
            
            if (indexPath.row == 1) {
                kSetting.themeAutoChange = switchCell.isOn;
            }

            if (indexPath.row == 2) {
                kSetting.navigationBarAutoHidden = switchCell.isOn;
            }
            
        }
        
        if (indexPath.section == V2SettingSectionTraffic) {
            
            if (indexPath.row == 0) {
                kSetting.preferHttps = switchCell.isOn;
            }
            
            if (indexPath.row == 1) {
                kSetting.trafficSaveModeOn = switchCell.isOn;
            }

        }
        
    }
    
    if ([settingCell isKindOfClass:[V2SettingCheckInCell class]]) {
        
        V2SettingCheckInCell *checkInCell = (V2SettingCheckInCell *)settingCell;
        
        if ([V2CheckInManager manager].isExpired) {
            [checkInCell beginCheckIn];
            [[V2CheckInManager manager] checkInSuccess:^(NSInteger count) {
                [checkInCell endCheckIn];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } failure:^(NSError *error) {
                [checkInCell endCheckIn];
                [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            }];
        }
    }
    
    if ([settingCell isKindOfClass:[V2SettingWeiboCell class]]) {
        
//        V2SettingWeiboCell *weiboCell = (V2SettingWeiboCell *)settingCell;
//        
        if ([SCWeiboManager manager].isExpired) {
            [[SCWeiboManager manager] authorizeToWeiboSuccess:^(WBBaseResponse *response) {
                @strongify(self);
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            } failure:^(NSError *error) {
                ;
            }];
        } else {
            
            self.actionSheet = [[SCActionSheet alloc] sc_initWithTitles:@[@"微博"] customViews:nil buttonTitles:@"取消绑定", nil];
            
            [self.actionSheet sc_configureButtonWithBlock:^(SCActionSheetButton *button) {
                button.type = SCActionSheetButtonTypeRed;
            } forIndex:0];
            
            [self.actionSheet sc_setButtonHandler:^{
                
                [[SCWeiboManager manager] clean];
                [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
                
            } forIndex:0];
            
            [self.actionSheet sc_show:YES];

        }
    }
    
    if (indexPath.section == V2SettingSectionAbout) {
        
        NSURL *URL;
        
        if (indexPath.row == 0) {
            
//            V2ProfileViewController *profileVC = [[V2ProfileViewController alloc] init];
//            profileVC.username = @"hoogle";
//            [self.navigationController pushViewController:profileVC animated:YES];
//            
            URL = [NSURL URLWithString:@"https://github.com/singro/V2EX-iOS-Opensource/blob/master/ABOUT.MD"];

            //https://gist.github.com/singro/cd2cbdc0cc9576947529
        }
        
        if (indexPath.row == 1) {
            
            URL = [NSURL URLWithString:@"https://v2ex.com/about"];
            
        }
        
        V2WebViewController *webVC = [[V2WebViewController alloc] init];
        webVC.url = URL;
        [self.navigationController pushViewController:webVC animated:YES];

    }

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if (section == V2SettingSectionTraffic) {
        return 22;
    }
    return 0.1;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    UIView *footerView;
    
    if (section == V2SettingSectionTraffic) {
        footerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, kScreenWidth, 22}];
        footerView.backgroundColor = kBackgroundColorWhiteDark;
        
        UILabel *label                       = [[UILabel alloc] initWithFrame:(CGRect){15, 0, kScreenWidth - 20, 30}];
        label.textColor                      = kFontColorBlackLight;
        label.font                           = [UIFont systemFontOfSize:12.0];
        label.text = @"移动网络下，不直接显示帖子图片";
        label.alpha = 0.7;
        [label sizeToFit];
        label.x = 15;
        label.y = 22 - label.height;
        [footerView addSubview:label];
        
    }
    
    return footerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 15;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    UIView *headerView = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 44}];
//    headerView.backgroundColor = kBackgroundColorWhiteDark;
//    
//    UILabel *label                       = [[UILabel alloc] initWithFrame:(CGRect){15, 8, 300, 36}];
//    label.textColor                      = kFontColorBlackLight;
//    label.font                           = [UIFont systemFontOfSize:15.0];
//    label.text                           = self.headerTitleArray[section];
//    [headerView addSubview:label];
//    
////    if (section == 0) {
////        UIView *topBorderLineView            = [[UIView alloc] initWithFrame:(CGRect){0, 0, 320, 0.5}];
////        topBorderLineView.backgroundColor    = kLineColorBlackDark;
////        [headerView addSubview:topBorderLineView];
////    }
////    
////    UIView *bottomBorderLineView         = [[UIView alloc] initWithFrame:(CGRect){0, 35.5, 320, 0.5}];
////    bottomBorderLineView.backgroundColor = kLineColorBlackDark;
////    [headerView addSubview:bottomBorderLineView];
//    
//    
//    return headerView;
//}

@end
