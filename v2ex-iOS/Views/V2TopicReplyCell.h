//
//  V2TopicReplyCell.h
//  v2ex-iOS
//
//  Created by Singro on 3/20/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2TopicReplyCell : UITableViewCell

@property (nonatomic, strong) V2ReplyModel *model;
@property (nonatomic, strong) V2ReplyModel *selectedReplyModel;

@property (nonatomic, assign) UINavigationController *navi;
@property (nonatomic, assign) V2ReplyList *replyList;

@property (nonatomic, copy) void (^longPressedBlock)();
@property (nonatomic, copy) void (^reloadCellBlock)();

+ (CGFloat)getCellHeightWithReplyModel:(V2ReplyModel *)model;

@end

static NSString * const kSelectMemberNotification = @"SelectMemberNotification";
