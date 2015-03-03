//
//  V2MemberReplyCell.h
//  v2ex-iOS
//
//  Created by Singro on 5/14/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface V2MemberReplyCell : UITableViewCell

@property (nonatomic, strong) V2MemberReplyModel *model;

@property (nonatomic, assign, getter = isTop) BOOL top;

+ (CGFloat)getCellHeightWithMemberReplyModel:(V2MemberReplyModel *)model;

@end
