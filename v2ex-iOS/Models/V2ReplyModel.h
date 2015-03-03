//
//  V2ReplyModel.h
//  v2ex-iOS
//
//  Created by Singro on 3/18/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2BaseModel.h"

@class V2MemberModel;

@interface V2ReplyModel : V2BaseModel

@property (nonatomic, copy  ) NSString *replyId;
@property (nonatomic, copy  ) NSString *replyThanksCount;
@property (nonatomic, copy  ) NSString *replyModified;
@property (nonatomic, strong) NSNumber *replyCreated;
@property (nonatomic, copy  ) NSString *replyContent;
@property (nonatomic, copy  ) NSString *replyContentRendered;

@property (nonatomic, strong) NSArray            *quoteArray;
@property (nonatomic, copy  ) NSAttributedString *attributedString;
@property (nonatomic, strong) NSArray            *contentArray;
@property (nonatomic, strong) NSArray            *imageURLs;

@property (nonatomic, strong) V2MemberModel *replyCreator;

@end


@interface V2ReplyList : NSObject

@property (nonatomic, strong) NSArray *list;

- (instancetype)initWithArray:(NSArray *)array;

@end
