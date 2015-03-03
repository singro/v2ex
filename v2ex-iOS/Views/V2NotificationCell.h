//
//  V2NotificationCell.h
//  v2ex-iOS
//
//  Created by Singro on 4/13/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2NotificationCell : UITableViewCell

@property (nonatomic, strong) V2NotificationModel *model;
@property (nonatomic, assign) UINavigationController *navi;

@property (nonatomic, assign, getter = isTop) BOOL top;

+ (CGFloat)getCellHeightWithNotificationModel:(V2NotificationModel *)model;

@end
