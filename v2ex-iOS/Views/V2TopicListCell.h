//
//  V2TopicListCell.h
//  v2ex-iOS
//
//  Created by Singro on 3/18/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2TopicListCell : UITableViewCell

@property (nonatomic, strong) V2TopicModel *model;

@property (nonatomic, assign) BOOL         isTop;

- (void)updateStatus;

+ (CGFloat)getCellHeightWithTopicModel:(V2TopicModel *)model;
+ (CGFloat)heightWithTopicModel:(V2TopicModel *)model;

@end

static NSString * const kShowTimeLabelNotification = @"ShowTimeLabelNotification";
static NSString * const kHideTimeLabelNotification = @"HideTimeLabelNotification";