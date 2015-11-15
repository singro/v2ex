//
//  V2QuickActionManager.h
//  v2ex-iOS
//
//  Created by Singro on 11/15/15.
//  Copyright © 2015 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString * V2CheckInQuickAction;
FOUNDATION_EXPORT NSString * V2NotificationQuickAction;

@interface V2QuickActionManager : NSObject

+ (instancetype)manager;

- (void)updateAction;

@end
