//
//  V2QuickActionManager.m
//  v2ex-iOS
//
//  Created by Singro on 11/15/15.
//  Copyright © 2015 Singro. All rights reserved.
//

#import "V2QuickActionManager.h"

#import "V2CheckInManager.h"
#import "V2NotificationManager.h"

NSString * V2CheckInQuickAction = @"com.singro.v2ex.checkin";
NSString * V2NotificationQuickAction = @"com.singro.v2ex.notification";

//#define EnableNotification

@interface V2QuickActionManager ()

@end

@implementation V2QuickActionManager

- (instancetype)init {
    if (self = [super init]) {
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveEnterBackgroundNotification) name:UIApplicationDidEnterBackgroundNotification object:nil];

    }
    return self;
}
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

+ (instancetype)manager {
    static V2QuickActionManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[V2QuickActionManager alloc] init];
    });
    return manager;
}

- (void)updateAction
{
#ifdef EnableNotification
    NSArray <UIApplicationShortcutItem *> *existingShortcutItems = [[UIApplication sharedApplication] shortcutItems];
    if (existingShortcutItems.count != 2) {
        UIApplicationShortcutItem *checkInItem = [self createCheckInItem];
        UIApplicationShortcutItem *notificationItem = [self createNotificationItem];
        [[UIApplication sharedApplication] setShortcutItems: @[notificationItem, checkInItem]];
    }

    [self updateCheckInItem];
    [self updateNotificationItem];
#else
    NSArray <UIApplicationShortcutItem *> *existingShortcutItems = [[UIApplication sharedApplication] shortcutItems];
    if (existingShortcutItems.count != 1) {
        UIApplicationShortcutItem *checkInItem = [self createCheckInItem];
        [[UIApplication sharedApplication] setShortcutItems: @[checkInItem]];
    }
    
    [self updateCheckInItem];
#endif
}

- (void)updateCheckInItem
{
    NSArray <UIApplicationShortcutItem *> *existingShortcutItems = [[UIApplication sharedApplication] shortcutItems];
    UIApplicationShortcutItem *anExistingShortcutItem;
    for (UIApplicationShortcutItem *item in existingShortcutItems) {
        if ([item.type isEqualToString:V2CheckInQuickAction]) {
            anExistingShortcutItem = item;
        }
    }
    if (anExistingShortcutItem) {
        NSUInteger anIndex = [existingShortcutItems indexOfObject:anExistingShortcutItem];
        NSMutableArray <UIApplicationShortcutItem *> *updatedShortcutItems = [existingShortcutItems mutableCopy];
        UIMutableApplicationShortcutItem *aMutableShortcutItem = [anExistingShortcutItem mutableCopy];
        aMutableShortcutItem.localizedTitle = [NSString stringWithFormat:@"签到"];
        if ([V2CheckInManager manager].checkInCount > 0) {
            aMutableShortcutItem.localizedSubtitle = [NSString stringWithFormat:@"已连续登录 %zd 天", [V2CheckInManager manager].checkInCount];
        } else {
            aMutableShortcutItem.localizedSubtitle = nil;
        }
        [updatedShortcutItems replaceObjectAtIndex: anIndex withObject: aMutableShortcutItem];
        [[UIApplication sharedApplication] setShortcutItems: updatedShortcutItems];
    } else {
    }
}

- (UIApplicationShortcutItem *)createCheckInItem
{
    UIApplicationShortcutIcon *checkInIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"quick_checkin"];
    UIMutableApplicationShortcutItem *checkInItem = [[UIMutableApplicationShortcutItem alloc] initWithType:V2CheckInQuickAction localizedTitle:@"签到" localizedSubtitle:nil icon:checkInIcon userInfo:nil];
    if ([V2CheckInManager manager].checkInCount > 0) {
        checkInItem.localizedSubtitle = [NSString stringWithFormat:@"已连续登录 %zd 天", [V2CheckInManager manager].checkInCount];
    }
    return checkInItem;
}

- (void)updateNotificationItem
{
    NSArray <UIApplicationShortcutItem *> *existingShortcutItems = [[UIApplication sharedApplication] shortcutItems];
    UIApplicationShortcutItem *anExistingShortcutItem;
    for (UIApplicationShortcutItem *item in existingShortcutItems) {
        if ([item.type isEqualToString:V2NotificationQuickAction]) {
            anExistingShortcutItem = item;
        }
    }
    if (anExistingShortcutItem) {
        NSUInteger anIndex = [existingShortcutItems indexOfObject:anExistingShortcutItem];
        NSMutableArray <UIApplicationShortcutItem *> *updatedShortcutItems = [existingShortcutItems mutableCopy];
        UIMutableApplicationShortcutItem *aMutableShortcutItem = [anExistingShortcutItem mutableCopy];
        aMutableShortcutItem.localizedTitle = [NSString stringWithFormat:@"提醒"];
        if ([V2NotificationManager manager].unreadCount > 0) {
            aMutableShortcutItem.localizedSubtitle = [NSString stringWithFormat:@"未读 %zd 条", [V2CheckInManager manager].checkInCount];
        } else {
            aMutableShortcutItem.localizedSubtitle = @"无未读";
        }
        [updatedShortcutItems replaceObjectAtIndex: anIndex withObject: aMutableShortcutItem];
        [[UIApplication sharedApplication] setShortcutItems: updatedShortcutItems];
    } else {
    }
}

- (UIApplicationShortcutItem *)createNotificationItem
{
    UIApplicationShortcutIcon *notificationIcon = [UIApplicationShortcutIcon iconWithTemplateImageName:@"section_notification_highlighted"];
    UIMutableApplicationShortcutItem *notificationItem = [[UIMutableApplicationShortcutItem alloc] initWithType:V2NotificationQuickAction localizedTitle:@"提醒" localizedSubtitle:nil icon:notificationIcon userInfo:nil];
    if ([V2NotificationManager manager].unreadCount > 0) {
        notificationItem.localizedSubtitle = [NSString stringWithFormat:@"未读 %zd 条", [V2CheckInManager manager].checkInCount];
    }
    return notificationItem;

}

#pragma mark - Notifications

- (void)didReceiveEnterBackgroundNotification {
    if (kDeviceOSVersion > 9.0) {
        [self updateAction];
    }
    
}

@end
