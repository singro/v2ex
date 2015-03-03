//
//  V2TopicStateManager.h
//  v2ex-iOS
//
//  Created by Singro on 3/22/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2TopicModel.h"

@interface V2TopicStateManager : NSObject

+ (instancetype)manager;

- (V2TopicState)getTopicStateWithTopicModel:(V2TopicModel *)model;

- (BOOL)saveStateForTopicModel:(V2TopicModel *)model;

@end
