//
//  V2TopicBodyCell.h
//  v2ex-iOS
//
//  Created by Singro on 3/19/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2TopicBodyCell : UITableViewCell

@property (nonatomic, strong) V2TopicModel *model;
@property (nonatomic, assign) UINavigationController *navi;

@property (nonatomic, copy) void (^reloadCellBlock)();

+ (CGFloat)getCellHeightWithTopicModel:(V2TopicModel *)model;

@end
