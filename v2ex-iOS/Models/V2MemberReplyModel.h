//
//  V2MemberReplyModel.h
//  v2ex-iOS
//
//  Created by Singro on 5/14/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface V2MemberReplyModel : NSObject

@property (nonatomic, copy  ) NSString           *memberReplyContent;
@property (nonatomic, copy  ) NSString           *memberReplyCreatedDescription;

@property (nonatomic, copy  ) NSAttributedString *memberReplyTopAttributedString;
@property (nonatomic, copy  ) NSAttributedString *memberReplyContentAttributedString;

@property (nonatomic, strong) V2TopicModel       *memberReplyTopic;

@end

@interface V2MemberReplyList : NSObject

@property (nonatomic, strong) NSArray *list;

+ (V2MemberReplyList *)getMemberReplyListFromResponseObject:(id)responseObject;

@end