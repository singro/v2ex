//
//  V2NotificationManager.h
//  v2ex-iOS
//
//  Created by Singro on 4/5/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

@class V2NotificationList;

@interface V2NotificationManager : NSObject

+ (instancetype)manager;

@property (nonatomic, assign) NSInteger unreadCount;

@end
