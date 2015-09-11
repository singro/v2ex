//
//  V2TopicModel.h
//  v2ex-iOS
//
//  Created by Singro on 3/17/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2BaseModel.h"

#import "SCQuote.h"

typedef NS_ENUM (NSInteger, V2TopicState) {
    
    V2TopicStateUnreadWithReply      = 1 << 0,
    V2TopicStateUnreadWithoutReply   = 1 << 1,
    V2TopicStateReadWithoutReply     = 1 << 2,
    V2TopicStateReadWithReply        = 1 << 3,
    V2TopicStateReadWithNewReply     = 1 << 4,
    V2TopicStateRepliedWithNewReply  = 1 << 5,
    
};

typedef NS_ENUM (NSInteger, V2ContentType) {
    
    V2ContentTypeString,
    V2ContentTypeImage,
    
};


@class V2NodeModel, V2MemberModel;

@interface V2TopicModel : V2BaseModel

@property (nonatomic, copy) NSString *topicId;
@property (nonatomic, copy) NSString *topicTitle;
@property (nonatomic, copy) NSString *topicReplyCount;
@property (nonatomic, copy) NSString *topicUrl;
@property (nonatomic, copy) NSString *topicContent;
@property (nonatomic, copy) NSString *topicContentRendered;
@property (nonatomic, copy) NSNumber *topicCreated;
@property (nonatomic, copy) NSString *topicCreatedDescription;
@property (nonatomic, copy) NSString *topicModified;
@property (nonatomic, copy) NSString *topicTouched;

@property (nonatomic, strong) NSArray            *quoteArray;
@property (nonatomic, copy  ) NSAttributedString *attributedString;
@property (nonatomic, strong) NSArray            *contentArray;
@property (nonatomic, strong) NSArray            *imageURLs;

@property (nonatomic, strong) V2MemberModel *topicCreator;
@property (nonatomic, strong) V2NodeModel   *topicNode;

@property (nonatomic, assign) V2TopicState  state;
@property (nonatomic, assign) CGFloat cellHeight;
@property (nonatomic, assign) CGFloat titleHeight;

@end


@interface V2TopicList : NSObject

@property (nonatomic, strong) NSArray *list;

- (instancetype)initWithArray:(NSArray *)array;

+ (V2TopicList *)getTopicListFromResponseObject:(id)responseObject;

@end

@interface V2ContentBaseModel : NSObject

@property (nonatomic, assign) V2ContentType contentType;

@end

@interface V2ContentStringModel : V2ContentBaseModel

@property (nonatomic, copy) NSAttributedString *attributedString;
@property (nonatomic, strong) NSArray *quoteArray;

@end

@interface V2ContentImageModel : V2ContentBaseModel

@property (nonatomic, strong) SCQuote *imageQuote;

@end
