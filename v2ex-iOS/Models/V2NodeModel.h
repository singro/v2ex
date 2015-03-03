//
//  V2NodeModel.h
//  v2ex-iOS
//
//  Created by Singro on 3/17/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2BaseModel.h"

@interface V2NodeModel : V2BaseModel

@property (nonatomic, copy) NSString *nodeId;
@property (nonatomic, copy) NSString *nodeName;
@property (nonatomic, copy) NSString *nodeUrl;
@property (nonatomic, copy) NSString *nodeTitle;
@property (nonatomic, copy) NSString *nodeTitleAlternative;
@property (nonatomic, copy) NSString *nodeTopicCount;
@property (nonatomic, copy) NSString *nodeHeader;
@property (nonatomic, copy) NSString *nodeFooter;
@property (nonatomic, copy) NSString *nodeCreated;

@end

@interface V2NodeList : NSObject

@property (nonatomic, strong) NSArray *list;

- (instancetype)initWithArray:(NSArray *)array;

@end
