//
//  V2SettingManager.m
//  v2ex-iOS
//
//  Created by Singro on 4/10/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2SettingManager.h"

#define userDefaults [NSUserDefaults standardUserDefaults]

#define kLineColorBlackDarkDefault    RGB(0xdbdbdb, 1.0)
#define kLineColorBlackLightDefault   RGB(0xebebeb, 1.0)

#define kFontColorBlackDarkDefault    RGB(0x333333, 1.0)
#define kFontColorBlackDarkMiddle     RGB(0x777777, 1.0)
#define kFontColorBlackLightDefault   RGB(0x999999, 1.0)
#define kFontColorBlackBlueDefault    RGB(0x778087, 1.0)
#define kColorBlueDefault             RGB(0x3fb7fc, 1.0)

static NSString *const kSelectedSectionIndex = @"SelectedSectionIndex";
static NSString *const kCategoriesSelectedSectionIndex = @"CategoriesSelectedSectionIndex";
static NSString *const kFavoriteSelectedSectionIndex = @"FavoriteSelectedSectionIndex";

static NSString *const kTheme           = @"Theme";
static NSString *const kThemeAutoChange = @"ThemeAutoChange";

static NSString *const kCheckInNotiticationOn = @"CheckInNotitication";
static NSString *const kNewNotificationOn     = @"NewNotification";
static NSString *const kNavigationBarHidden   = @"NavigationBarHidden";

static NSString *const kTrafficeSaveOn = @"TrafficeSaveOn";
static NSString *const kPreferHttps = @"PreferHttps";

@interface V2SettingManager () {
    
    BOOL _trafficSaveModeOn;

}

@end

@implementation V2SettingManager

- (instancetype)init {
    if (self = [super init]) {
        
        self.selectedSectionIndex = [[userDefaults objectForKey:kSelectedSectionIndex] unsignedIntegerValue];
        self.categoriesSelectedSectionIndex = [[userDefaults objectForKey:kCategoriesSelectedSectionIndex] unsignedIntegerValue];
        self.favoriteSelectedSectionIndex = [[userDefaults objectForKey:kFavoriteSelectedSectionIndex] unsignedIntegerValue];
        
        _theme = [[userDefaults objectForKey:kTheme] integerValue];
        
        id themeAutoChange = [userDefaults objectForKey:kThemeAutoChange];
        if (themeAutoChange) {
            _themeAutoChange = [themeAutoChange boolValue];
        } else {
            _themeAutoChange = YES;
        }
        
        id checkInNotiticationOn = [userDefaults objectForKey:kCheckInNotiticationOn];
        if (checkInNotiticationOn) {
            _checkInNotiticationOn = [checkInNotiticationOn boolValue];
        } else {
            _checkInNotiticationOn = YES;
        }
        
        id newNotificationOn = [userDefaults objectForKey:kNewNotificationOn];
        if (newNotificationOn) {
            _newNotificationOn = [newNotificationOn boolValue];
        } else {
            _newNotificationOn = YES;
        }


        id navigationBarHidden = [userDefaults objectForKey:kNavigationBarHidden];
        if (navigationBarHidden) {
            _navigationBarAutoHidden = [navigationBarHidden boolValue];
        } else {
            _navigationBarAutoHidden = YES;
        }
        
        id trafficSaveOn = [userDefaults objectForKey:kTrafficeSaveOn];
        if (trafficSaveOn) {
            _trafficSaveModeOn = [trafficSaveOn boolValue];
        } else {
            _trafficSaveModeOn = NO;
        }
        
        id preferHttps = [userDefaults objectForKey:kPreferHttps];
        if (preferHttps) {
            _preferHttps = [preferHttps boolValue];
        } else {
            _preferHttps = NO;
        }
        
        [self configureTheme:_theme];

    }
    return self;
}

+ (instancetype)manager {
    static V2SettingManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[V2SettingManager alloc] init];
    });
    return manager;
}

#pragma mark - Index

- (void)setSelectedSectionIndex:(NSUInteger)selectedSectionIndex {
    _selectedSectionIndex = selectedSectionIndex;
    
    [userDefaults setObject:@(selectedSectionIndex) forKey:kSelectedSectionIndex];
    [userDefaults synchronize];
    
}

- (void)setCategoriesSelectedSectionIndex:(NSUInteger)categoriesSelectedSectionIndex {
    _categoriesSelectedSectionIndex = categoriesSelectedSectionIndex;
    
    [userDefaults setObject:@(categoriesSelectedSectionIndex) forKey:kCategoriesSelectedSectionIndex];
    [userDefaults synchronize];
    
}

- (void)setFavoriteSelectedSectionIndex:(NSUInteger)favoriteSelectedSectionIndex {
    _favoriteSelectedSectionIndex = favoriteSelectedSectionIndex;
    
    [userDefaults setObject:@(favoriteSelectedSectionIndex) forKey:kFavoriteSelectedSectionIndex];
    [userDefaults synchronize];

}

#pragma mark - Theme

- (void)setTheme:(V2Theme)theme {
    _theme = theme;
    
    [userDefaults setObject:@(theme) forKey:kTheme];
    [userDefaults synchronize];

    [self configureTheme:theme];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kThemeDidChangeNotification object:nil];

}

- (void)configureTheme:(V2Theme)theme {
    
    if (theme == V2ThemeDefault) {
        
        self.navigationBarTintColor = [UIColor blackColor];
        self.navigationBarColor = [UIColor colorWithWhite:1.00 alpha:0.980];
        self.navigationBarLineColor = [UIColor colorWithWhite:0.869 alpha:1];
        
        self.backgroundColorWhite = [UIColor whiteColor];
        self.backgroundColorWhiteDark = [UIColor colorWithWhite:0.98 alpha:1.000];
        
        self.lineColorBlackDark = kLineColorBlackDarkDefault;
        self.lineColorBlackLight = kLineColorBlackLightDefault;
        
        self.fontColorBlackDark = kFontColorBlackDarkDefault;
        self.fontColorBlackMid = kFontColorBlackDarkMiddle;
        self.fontColorBlackLight = kFontColorBlackLightDefault;
        self.fontColorBlackBlue = kFontColorBlackBlueDefault;
        
        self.colorBlue = kColorBlueDefault;
        self.cellHighlightedColor = RGB(0xdbdbdb, 0.6f);
        self.menuCellHighlightedColor = RGB(0xf6f6f6,1.0);
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        
    }
    
    if (theme == V2ThemeNight) {
        
        self.navigationBarTintColor = RGB(0xcccccc, 1.0);
        self.navigationBarColor = [UIColor colorWithWhite:0.000 alpha:0.980];
        self.navigationBarLineColor = [UIColor colorWithWhite:0.281 alpha:1.000];
        
        self.backgroundColorWhite = [UIColor blackColor];
        self.backgroundColorWhiteDark = [UIColor colorWithWhite:0.08 alpha:1.000];
        
        self.lineColorBlackDark = [UIColor colorWithWhite:0.281 alpha:1.000];
        self.lineColorBlackLight = [UIColor colorWithWhite:0.119 alpha:1.000];
        
        self.fontColorBlackDark = RGB(0x989898, 1.0);
        self.fontColorBlackMid =  RGB(0x777777, 1.0);;
        self.fontColorBlackLight = [UIColor colorWithWhite:0.272 alpha:1.000];
        self.fontColorBlackBlue = RGB(0x778087, 1.0);
        
        self.colorBlue = [UIColor colorWithWhite:1.000 alpha:0.10];
        self.cellHighlightedColor = RGB(0x333333, 1.0f);
        self.menuCellHighlightedColor = [UIColor colorWithWhite:0.119 alpha:1.000];

        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        
    }

}

- (void)setThemeAutoChange:(BOOL)themeAutoChange {
    _themeAutoChange = themeAutoChange;
    
    [userDefaults setObject:@(themeAutoChange) forKey:kThemeAutoChange];
    [userDefaults synchronize];
}

#pragma mark - Alpha

- (CGFloat)imageViewAlphaForCurrentTheme {
    if (kCurrentTheme == V2ThemeNight) {
        return 0.4;
    } else {
        return 1.0;
    }
}

#pragma mark - Notification

- (void)setCheckInNotiticationOn:(BOOL)checkInNotiticationOn {
    _checkInNotiticationOn = checkInNotiticationOn;
    
    [userDefaults setObject:@(checkInNotiticationOn) forKey:kCheckInNotiticationOn];
    [userDefaults synchronize];

}

- (void)setNewNotificationOn:(BOOL)newNotificationOn {
    _newNotificationOn = newNotificationOn;
    
    [userDefaults setObject:@(newNotificationOn) forKey:kNewNotificationOn];
    [userDefaults synchronize];
    
}

#pragma mark - Navigation Bar

- (void)setNavigationBarAutoHidden:(BOOL)navigationBarAutoHidden {
    _navigationBarAutoHidden = navigationBarAutoHidden;
    
    [userDefaults setObject:@(navigationBarAutoHidden) forKey:kNavigationBarHidden];
    [userDefaults synchronize];

}

#pragma mark - Traffic

- (void)setTrafficSaveModeOn:(BOOL)trafficSaveModeOn {
    _trafficSaveModeOn = trafficSaveModeOn;
    
    [userDefaults setObject:@(trafficSaveModeOn) forKey:kTrafficeSaveOn];
    [userDefaults synchronize];

}

- (BOOL)trafficSaveModeOn {
    
    return ![AFNetworkReachabilityManager sharedManager].isReachableViaWiFi && _trafficSaveModeOn;
}

- (BOOL)trafficSaveModeOnSetting {
    return _trafficSaveModeOn;
}

- (void)setPreferHttps:(BOOL)preferHttps {
    _preferHttps = preferHttps;
    
    [V2DataManager manager].preferHttps = preferHttps;
    
    [userDefaults setObject:@(preferHttps) forKey:kPreferHttps];
    [userDefaults synchronize];
}

@end
