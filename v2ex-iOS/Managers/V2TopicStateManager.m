//
//  V2TopicStateManager.m
//  v2ex-iOS
//
//  Created by Singro on 3/22/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import "V2TopicStateManager.h"

// timeout for 7 days
static NSTimeInterval const kTimeoutInterval    = 7 * 24 * 60 * 60;

static NSString *const kTopicStateStoreFilePath = @"/topicState.plist";

static NSString *const kReplyCount = @"replyCountKey";
static NSString *const kReplyTime  = @"replyTimeKey";
static NSString *const kModel      = @"modelKey";

@interface V2TopicStateManager ()

@property (nonatomic, strong) NSMutableDictionary *topicStateDictionary;

@end

@implementation V2TopicStateManager

- (instancetype)init {
    if (self = [super init]) {
        
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [path stringByAppendingString:kTopicStateStoreFilePath];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                
                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
                self.topicStateDictionary = [[NSMutableDictionary alloc] initWithDictionary:dict];
                
                // remove timeout record
                for (NSString *key in [self.topicStateDictionary allKeys]) {
                    NSDictionary *dataDict = [self.topicStateDictionary objectForSafeKey:key];
                    NSDate *date = [dataDict objectForSafeKey:kReplyTime];
                    if ([date timeIntervalSinceNow] > kTimeoutInterval) {
                        [self.topicStateDictionary removeObjectForKey:key];
                    }
                }
                
            });
            
        } else {
            self.topicStateDictionary = [[NSMutableDictionary alloc] init];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLeaveAppNotification) name:UIApplicationWillResignActiveNotification object:nil];
        
    }
    return self;
}

+ (instancetype)manager {
    static V2TopicStateManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[V2TopicStateManager alloc] init];
    });
    return manager;
}

- (V2TopicState)getTopicStateWithTopicModel:(V2TopicModel *)model {
    
    NSString *topicIdKey = [NSString stringWithFormat:@"%@", model.topicId];
    NSInteger currentReplyCount = [model.topicReplyCount integerValue];

    NSDictionary *savedDict = [self.topicStateDictionary objectForSafeKey:topicIdKey];
    
    if (savedDict) {
        
        NSInteger savedReplyCount = [[savedDict objectForSafeKey:kReplyCount] integerValue];
        if (currentReplyCount == 0) {
            return V2TopicStateReadWithoutReply;
        } else {
            if (savedReplyCount >= currentReplyCount) {
                return V2TopicStateReadWithReply;
            } else {
                return V2TopicStateReadWithNewReply;
            }
        }
        
    } else {
        
        if (currentReplyCount) {
            return V2TopicStateUnreadWithReply;
        } else {
            return V2TopicStateUnreadWithoutReply;
        }
    }

    return V2TopicStateUnreadWithoutReply;
}

- (BOOL)saveStateForTopicModel:(V2TopicModel *)model {
    
    NSDictionary *dataDict = @{
                               kReplyCount: model.topicReplyCount,
                               kReplyTime: [[NSDate alloc] initWithTimeIntervalSinceNow:0]
                               };
    
    NSString *topicIdKey;
    if (model.topicId) {
        topicIdKey = [NSString stringWithFormat:@"%@", model.topicId];
        [self.topicStateDictionary setObject:dataDict forKey:topicIdKey];
        return YES;
    }
    
    return NO;
}

- (void)didReceiveLeaveAppNotification {
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSString* path = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [path stringByAppendingString:kTopicStateStoreFilePath];
        if ([self.topicStateDictionary writeToFile:filePath atomically:YES]) {
        } else {
        }
        
    });
    
}

@end
