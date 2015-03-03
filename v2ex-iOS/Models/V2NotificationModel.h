//
//  V2NotificationModel.h
//  v2ex-iOS
//
//  Created by Singro on 4/5/14.
//  Copyright (c) 2014 Singro. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface V2NotificationModel : NSObject

@property (nonatomic, copy) NSString *notificationDescriptionBefore;
@property (nonatomic, copy) NSString *notificationDescriptionAfter;
@property (nonatomic, copy) NSString *notificationContent;
@property (nonatomic, copy) NSString *notificationCreatedDescription;
@property (nonatomic, copy) NSString *notificationId;

@property (nonatomic, copy) NSAttributedString *notificationTopAttributedString;
@property (nonatomic, copy) NSAttributedString *notificationDescriptionAttributedString;

@property (nonatomic, strong) V2TopicModel  *notificationTopic;
@property (nonatomic, strong) V2MemberModel *notificationMember;

@end

@interface V2NotificationList : NSObject

@property (nonatomic, strong) NSArray *list;

+ (V2NotificationList *)getNotificationFromResponseObject:(id)responseObject;

@end