//
//  V2DataManager.h
//  v2ex-iOS
//
//  Created by Singro on 3/17/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "V2NodeModel.h"
#import "V2TopicModel.h"
#import "V2ReplyModel.h"
#import "V2MemberModel.h"
#import "V2UserModel.h"
#import "V2NotificationModel.h"
#import "V2MemberReplyModel.h"

typedef NS_ENUM(NSInteger, V2ErrorType) {
    
    V2ErrorTypeNoOnceAndNext          = 700,
    V2ErrorTypeLoginFailure           = 701,
    V2ErrorTypeRequestFailure         = 702,
    V2ErrorTypeGetFeedURLFailure      = 703,
    V2ErrorTypeGetTopicListFailure    = 704,
    V2ErrorTypeGetNotificationFailure = 705,
    V2ErrorTypeGetFavUrlFailure       = 706,
    V2ErrorTypeGetMemberReplyFailure  = 707,
    V2ErrorTypeGetTopicTokenFailure   = 708,
    V2ErrorTypeGetCheckInURLFailure   = 709,
    
};

typedef NS_ENUM (NSInteger, V2HotNodesType) {
    
    V2HotNodesTypeTech,
    V2HotNodesTypeCreative,
    V2HotNodesTypePlay,
    V2HotNodesTypeApple,
    V2HotNodesTypeJobs,
    V2HotNodesTypeDeals,
    V2HotNodesTypeCity,
    V2HotNodesTypeQna,
    V2HotNodesTypeHot,
    V2HotNodesTypeAll,
    V2HotNodesTypeR2,
    V2HotNodesTypeNodes,
    V2HotNodesTypeMembers,
    V2HotNodesTypeFav,
    
};

@interface V2DataManager : NSObject

+ (instancetype)manager;

@property (nonatomic, strong) V2UserModel *user;
@property (nonatomic, assign) BOOL preferHttps;

#pragma mark - GET

- (NSURLSessionDataTask *)getAllNodesSuccess:(void (^)(V2NodeList *list))success
                                     failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getNodeWithId:(NSString *)nodeId
                                   name:(NSString *)name
                                success:(void (^)(V2NodeModel *model))success
                                failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getTopicListWithNodeId:(NSString *)nodeId
                                        nodename:(NSString *)name
                                        username:(NSString *)username
                                            page:(NSInteger)page
                                         success:(void (^)(V2TopicList *list))success
                                         failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getTopicListLatestWithPage:(NSInteger)page
                                             Success:(void (^)(V2TopicList *list))success
                                             failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getTopicListWithType:(V2HotNodesType)type
                                       Success:(void (^)(V2TopicList *list))success
                                       failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getTopicWithTopicId:(NSString *)topicId
                                      success:(void (^)(V2TopicModel *model))success
                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getReplyListWithTopicId:(NSString *)topicId
                                          success:(void (^)(V2ReplyList *list))success
                                          failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getMemberProfileWithUserId:(NSString *)userid
                                            username:(NSString *)username
                                             success:(void (^)(V2MemberModel *member))success
                                             failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getMemberTopicListWithType:(V2HotNodesType)type
                                                page:(NSInteger)page
                                       Success:(void (^)(V2TopicList *list))success
                                       failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getMemberTopicListWithMemberModel:(V2MemberModel *)model
                                                       page:(NSInteger)page
                                                    Success:(void (^)(V2TopicList *list))success
                                                    failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getMemberNodeListSuccess:(void (^)(NSArray *list))success
                                           failure:(void (^)(NSError *error))failure;

#pragma mark - Action

- (NSURLSessionDataTask *)favNodeWithName:(NSString *)nodeName
                                  success:(void (^)(NSString *message))success
                                  failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)favTopicWithTopicId:(NSString *)topicId
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)topicFavWithTopicId:(NSString *)topicId
                                        token:(NSString *)token
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)topicFavCancelWithTopicId:(NSString *)topicId
                                        token:(NSString *)token
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)topicThankWithTopicId:(NSString *)topicId
                                        token:(NSString *)token
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)topicIgnoreWithTopicId:(NSString *)topicId
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)replyThankWithReplyId:(NSString *)replyId
                                        token:(NSString *)token
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)memberFollowWithMemberName:(NSString *)memberName
                                      success:(void (^)(NSString *message))success
                                      failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)memberBlockWithMemberName:(NSString *)memberName
                                           success:(void (^)(NSString *message))success
                                           failure:(void (^)(NSError *error))failure;


#pragma mark - Token

- (NSURLSessionDataTask *)getTopicTokenWithTopicId:(NSString *)topicId
                                               success:(void (^)(NSString *token))success
                                               failure:(void (^)(NSError *error))failure;


#pragma mark - Create

- (NSURLSessionDataTask *)replyCreateWithTopicId:(NSString *)topicId
                                         content:(NSString *)content
                                         success:(void (^)(V2ReplyModel *model))success
                                         failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)topicCreateWithNodeName:(NSString *)nodeName
                                            title:(NSString *)title
                                          content:(NSString *)content
                                          success:(void (^)(NSString *message))success
                                          failure:(void (^)(NSError *error))failure;


#pragma mark - Login & Profile

- (NSURLSessionDataTask *)UserLoginWithUsername:(NSString *)username password:(NSString *)password
                                        success:(void (^)(NSString *message))success
                                        failure:(void (^)(NSError *error))failure;

- (void)UserLogout;

- (NSURLSessionDataTask *)getFeedURLSuccess:(void (^)(NSURL *feedURL))success
                                    failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getUserNotificationWithPage:(NSInteger)page
                                              success:(void (^)(V2NotificationList *list))success
                                              failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getUserReplyWithUsername:(NSString *)username
                                              page:(NSInteger)page
                                           success:(void (^)(V2MemberReplyList *list))success
                                           failure:(void (^)(NSError *error))failure;

#pragma mark - Notifications

- (NSURLSessionDataTask *)getCheckInURLSuccess:(void (^)(NSURL *URL))success
                                       failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)checkInWithURL:(NSURL *)url
                                 Success:(void (^)(NSInteger count))success
                                   failure:(void (^)(NSError *error))failure;

- (NSURLSessionDataTask *)getCheckInCountSuccess:(void (^)(NSInteger count))success
                                 failure:(void (^)(NSError *error))failure;

@end
