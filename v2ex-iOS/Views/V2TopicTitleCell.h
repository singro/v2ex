//
//  V2TopicTitleCell.h
//  v2ex-iOS
//
//  Created by Singro on 3/19/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2TopicTitleCell : UITableViewCell

@property (nonatomic, strong) V2TopicModel *model;
@property (nonatomic, assign) UINavigationController *navi;

+ (CGFloat)getCellHeightWithTopicModel:(V2TopicModel *)model;

@end
