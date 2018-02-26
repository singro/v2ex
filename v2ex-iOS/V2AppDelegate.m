//
//  SCAppDelegate.m
//  v2ex-iOS
//
//  Created by Singro on 3/17/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2AppDelegate.h"

#import "V2RootViewController.h"
#import "V2LoginViewController.h"

#import "V2TopicStateManager.h"
#import "SCWeiboManager.h"
#import "SCWeixinManager.h"
#import "V2QuickActionManager.h"
#import "V2DataManager.h"
#import <MBProgressHUD.h>

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface V2AppDelegate ()

@property (nonatomic, strong) MBProgressHUD      *HUD;

@end

@implementation V2AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Preload StateManager
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    
    [V2TopicStateManager manager];
    [V2SettingManager manager];
    [V2CheckInManager manager];
    [SCWeiboManager manager];
    [SCWeixinManager manager];
    [V2QuickActionManager manager];
    
    // Configure URLCache capacity
    // Set URLCache to 3MB
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:5 * 1024 * 1024
                                                         diskCapacity:3 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    self.rootViewController = [[V2RootViewController alloc] init];
    self.window.rootViewController = self.rootViewController;
        
    
    [Fabric with:@[CrashlyticsKit]];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

    if (kSetting.themeAutoChange) {
        CGFloat brightness = [UIScreen mainScreen].brightness;
        
        if (brightness < 0.2) {
            kSetting.theme = V2ThemeNight;
        } else {
            kSetting.theme = V2ThemeDefault;
        }
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{

    if ([url.scheme isEqualToString:[@"wb" stringByAppendingString:kWeiboAppKey]]) {
        return [WeiboSDK handleOpenURL:url delegate:[SCWeiboManager manager]];
    }
    
    if ([WXApi handleOpenURL:url delegate:[SCWeixinManager manager]]) {
        return YES;
    }
    
    return YES;
}

#pragma mark - Quick Action

- (void)application:(UIApplication *)application performActionForShortcutItem:(UIApplicationShortcutItem *)shortcutItem completionHandler:(void (^)(BOOL))completionHandler
{
    if ([shortcutItem.type isEqualToString:V2CheckInQuickAction]) {
        if ([self checkAndLogin]) {
            UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
            if ([V2CheckInManager manager].isExpired) {
                self.HUD = [[MBProgressHUD alloc] initWithWindow:keyWindow];
                self.HUD.removeFromSuperViewOnHide = YES;
                self.HUD.mode = MBProgressHUDModeIndeterminate;
                [keyWindow addSubview:self.HUD];
                [self.HUD show:YES];
                [[V2CheckInManager manager] checkInSuccess:^(NSInteger count) {
                    UIImage *image = [UIImage imageNamed:@"37x-Checkmark"];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
                    self.HUD.customView = imageView;
                    self.HUD.mode = MBProgressHUDModeCustomView;
                    self.HUD.labelText = [NSString stringWithFormat:@"已连续签到 %zd 天", count];
                    [self.HUD hide:YES afterDelay:3];
                } failure:^(NSError *error) {
                    
                }];
            } else {
                self.HUD = [[MBProgressHUD alloc] initWithWindow:keyWindow];
                self.HUD.removeFromSuperViewOnHide = YES;
                self.HUD.mode = MBProgressHUDModeText;
//                self.HUD.labelText = @"今天已签到";
                self.HUD.labelText = [NSString stringWithFormat:@"已连续签到 %zd 天", [V2CheckInManager manager].checkInCount];
//                self.HUD.detailsLabelColor = kFontColorBlackLight;
                [keyWindow addSubview:self.HUD];
                [self.HUD show:YES];
                [self.HUD hide:YES afterDelay:2.5];
            }
        }
    }
    
    if ([shortcutItem.type isEqualToString:V2NotificationQuickAction]) {
        if ([self checkAndLogin]) {
            [self.rootViewController showViewControllerAtIndex:V2SectionIndexNotification animated:NO];
        }
    }
}

#pragma mark - Status bar touch tracking
- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    CGPoint location = [[[event allTouches] anyObject] locationInView:[self window]];
    CGRect statusBarFrame = [UIApplication sharedApplication].statusBarFrame;
    if (CGRectContainsPoint(statusBarFrame, location)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kStatusBarTappedNotification
                                                            object:nil];
    }
}

#pragma mark - Helper

- (BOOL)checkAndLogin
{
    if (nil == [V2DataManager manager].user) {
        
        MBProgressHUD *huds = [[MBProgressHUD alloc] initWithView:self.window];
        huds.removeFromSuperViewOnHide = YES;
        huds.mode = MBProgressHUDModeText;
        huds.labelText = @"请先登录";
        [huds show:YES];
        [huds hide:YES afterDelay:2.];
        [huds setCompletionBlock:^{
            V2LoginViewController *loginViewController = [[V2LoginViewController alloc] init];
            [self.rootViewController presentViewController:loginViewController animated:YES completion:^{
                ;
            }];
        }];
        
        return NO;
    }
    
    return YES;
}

@end
