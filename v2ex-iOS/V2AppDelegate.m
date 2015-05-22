//
//  SCAppDelegate.m
//  v2ex-iOS
//
//  Created by Singro on 3/17/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2AppDelegate.h"

#import "V2RootViewController.h"

#import "V2TopicStateManager.h"
#import "SCWeiboManager.h"
#import "SCWeixinManager.h"

#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

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
    
    // Configure URLCache capacity
    // Set URLCache to 3MB
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:5 * 1024 * 1024
                                                         diskCapacity:3 * 1024 * 1024
                                                             diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];

    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];

    self.rootViewController = [[V2RootViewController alloc] init];
    self.window.rootViewController = self.rootViewController;
        
    [self.window makeKeyAndVisible];
    
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

@end
